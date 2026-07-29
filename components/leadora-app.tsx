'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import Link from 'next/link';
import {
  LayoutDashboard, Users, ContactRound, Building2, Handshake, Columns3,
  Mail, SearchCheck, Bot, Workflow, ChartNoAxesCombined, FileChartColumn,
  Settings, Menu, Bell, Plus, LogOut, Target, ClipboardCheck, History, Sparkles, Trash2, Pencil, Send, Search, Inbox, RefreshCw
} from 'lucide-react';
import { getOutreachWorkflow, CLIENT_CONTACT_PHONE } from '@/lib/outreach-workflows';

type Lead = { name:string; email:string; company:string; status:string; source:string; created:string };
type Contact = { name:string; email:string; company:string; phone:string; status:string };
type BusinessProfile = { id:string; name:string; description:string; services:string[]; serviceArea:string; website:string; signature:string; tone:string; idealCustomer:string; industries:string[]; dailyLimit:number; followUp:string };
type Audit = { auditedAt:string; websiteSpeed:'not_measured'; mobileFriendly:'not_measured'; https:boolean; metaTitle:string; metaDescription:string; h1Tags:string[]; missingAltText:number; brokenLinks:number; basicSeoScore:number; accessibilityScore:number; googleBusinessProfileDetected:boolean; socialLinks:string[]; overallScore:number; notes:string[] };
type Prospect = { id:string; businessId:string; name:string; website:string; email:string; phone?:string; location:string; industry:string; contactUrl:string; googleMapsUrl?:string; score:number; reasons:string[]; discoveredAt:string; contacted:boolean; audit?:Audit; recommendedService?:string; confidence?:number };
type Draft = { id:string; prospectId:string; businessId:string; subject:string; body:string; callToAction?:string; generatedAt:string; status:'pending'|'approved'|'rejected'|'sent'|'edited'|'follow_up_due'|'send_failed'; isFollowUp?:boolean; gmailMessageId?:string; lastError?:string };
type Outreach = { id:string; prospectId:string; businessId:string; date:string; time:string; status:'sent'|'pending'|'rejected'|'follow-up due'; gmailMessageId?:string; sentAt?:string };
type GmailMessage = { id:string; threadId:string; from:string; to:string; cc:string; subject:string; body:string; internalDate:string; labelIds:string[]; businessId?:string|null; isRead?:boolean };
type SystemCheck = { ok:boolean; detail:string };
type SystemStatus = Record<'cloudflare'|'backend'|'database'|'googleOAuth'|'gmailApi'|'connectedAccount',SystemCheck>;
type GmailStatus = {connected:boolean;emailAddress?:string;error?:string;code?:string;diagnostics?:Array<{name:string;configured:boolean}>};

const seedLeads: Lead[] = [
  {name:'Sarah Johnson',email:'sarah@designco.com',company:'Design Co.',status:'New',source:'Website',created:'2 min ago'},
  {name:'David Williams',email:'david@techflow.com',company:'TechFlow',status:'Contacted',source:'LinkedIn',created:'1 h ago'},
  {name:'James Brown',email:'james@marketplus.com',company:'MarketPlus',status:'Qualified',source:'Referral',created:'2 h ago'},
  {name:'Emily Davis',email:'emily@brightidea.com',company:'Bright Idea',status:'Proposal',source:'Website',created:'5 h ago'},
  {name:'Michael Wilson',email:'michael@nextgen.com',company:'NextGen',status:'New',source:'Ads',created:'1 day ago'},
];
const seedContacts: Contact[] = [
  {name:'Sarah Johnson',email:'sarah@designco.com',company:'Design Co.',phone:'+44 7700 900123',status:'Active'},
  {name:'David Williams',email:'david@techflow.com',company:'TechFlow',phone:'+44 7700 900456',status:'Active'},
  {name:'Emily Davis',email:'emily@brightidea.com',company:'Bright Idea',phone:'+44 7700 901234',status:'Inactive'},
];
const seedBusinesses: BusinessProfile[] = [
  {id:'bryant-construction',name:'Bryant Construction Group',description:'Trusted construction and renovation specialists.',services:['Extensions','Renovations','New builds'],serviceArea:'Bournemouth, Poole and Dorset',website:'bryantconstructiongroup.co.uk',signature:`Alex Bryant\nBryant Construction Group\n${CLIENT_CONTACT_PHONE}`,tone:'Professional and warm',idealCustomer:'Homeowners and property developers',industries:['Construction','Property'],dailyLimit:10,followUp:'3 days, then 7 days'},
  {id:'bryant-cleaning',name:'Bryant & Co Cleaning',description:'Reliable commercial and domestic cleaning teams.',services:['Commercial cleaning','End of tenancy','Deep cleaning'],serviceArea:'Bournemouth and surrounding areas',website:'bryantandcocleaning.co.uk',signature:`Alex Bryant\nBryant & Co Cleaning\n${CLIENT_CONTACT_PHONE}`,tone:'Friendly and helpful',idealCustomer:'Busy homeowners and local businesses',industries:['Hospitality','Property','Offices'],dailyLimit:10,followUp:'4 days, then 10 days'},
  {id:'bryant-digital',name:'Bryant Digital Solutions',description:'Practical digital marketing for growing businesses.',services:['Websites','SEO','Lead generation'],serviceArea:'UK-wide',website:'bryantdigital.co.uk',signature:`Alex Bryant\nBryant Digital Solutions\n${CLIENT_CONTACT_PHONE}`,tone:'Clear and consultative',idealCustomer:'Owner-led SMEs',industries:['Professional services','Retail','Hospitality'],dailyLimit:10,followUp:'3 days, then 7 days'},
  {id:'mr-white-teeth',name:'Mr White Teeth Whitening Bournemouth',description:'Safe, professional teeth whitening in Bournemouth.',services:['Teeth whitening','Smile consultations'],serviceArea:'Bournemouth and Poole',website:'mrwhiteteeth.co.uk',signature:`Alex Bryant\nMr White Teeth Whitening Bournemouth\n${CLIENT_CONTACT_PHONE}`,tone:'Reassuring and upbeat',idealCustomer:'Adults seeking a brighter smile',industries:['Beauty','Healthcare'],dailyLimit:10,followUp:'5 days, then 10 days'},
];

const nav = [
  ['dashboard','Dashboard',LayoutDashboard],['leads','Leads',Users],['contacts','Contacts',ContactRound],
  ['companies','Companies',Building2],['deals','Deals',Handshake],['pipelines','Pipelines',Columns3],
  ['email-outreach','Email Outreach',Mail],['website-audits','Website Audits',SearchCheck],
  ['outreach-history','Outreach History',History],['inbox','Inbox',Inbox],
  ['ai-agents','AI Agents',Bot],['automations','Automations',Workflow],['analytics','Analytics',ChartNoAxesCombined],
  ['reports','Reports',FileChartColumn],['settings','Settings',Settings],
] as const;

function useStoredState<T>(key:string, initial:T) {
  const [value,setValue] = useState<T>(initial);
  const loaded=useRef(false);
  useEffect(() => { const saved=localStorage.getItem(key); if(saved) try { setValue(JSON.parse(saved)); } catch {} },[key]);
  useEffect(() => {
    if(!key.startsWith('leadora-') || key==='leadora-auth' || key==='leadora-businesses'){loaded.current=true;return;}
    let cancelled=false;
    fetch(`/api/state/${key}`).then(async response=>{if(!response.ok)throw new Error();return response.json();}).then(data=>{if(!cancelled&&data.value!==null)setValue(data.value as T);}).catch(()=>{}).finally(()=>{loaded.current=true;});
    return ()=>{cancelled=true;};
  },[key]);
  useEffect(() => { localStorage.setItem(key,JSON.stringify(value)); if(loaded.current&&key.startsWith('leadora-')&&key!=='leadora-auth'&&key!=='leadora-businesses') fetch(`/api/state/${key}`,{method:'PUT',headers:{'content-type':'application/json'},body:JSON.stringify({value})}).catch(()=>{}); },[key,value]);
  return [value,setValue] as const;
}

export function LeadoraApp({ route='dashboard' }: { route?:string }) {
  const [auth,setAuth] = useStoredState('leadora-auth',false);
  const [leads,setLeads] = useStoredState<Lead[]>('leadora-leads',seedLeads);
  const [contacts,setContacts] = useStoredState<Contact[]>('leadora-contacts',seedContacts);
  const [businesses,setBusinesses] = useStoredState<BusinessProfile[]>('leadora-businesses',seedBusinesses);
  const [prospects,setProspects] = useStoredState<Prospect[]>('leadora-prospects',[]);
  const [drafts,setDrafts] = useStoredState<Draft[]>('leadora-drafts',[]);
  const [outreach,setOutreach] = useStoredState<Outreach[]>('leadora-outreach',[]);
  const [gmailMessages,setGmailMessages] = useStoredState<GmailMessage[]>('leadora-gmail-messages',[]);
  const [menu,setMenu] = useState(false);

  if(route==='login' || !auth) return <Login onLogin={()=>setAuth(true)} />;
  const active = nav.find(n=>n[0]===route) ?? nav[0];

  return <div className="shell">
    <aside className={`sidebar ${menu?'open':''}`}>
      <div className="brand"><div className="brand-mark">L◉</div><span>LEADORA</span></div>
      <nav className="nav">{nav.map(([slug,label,Icon])=><Link key={slug} href={`/${slug}/`} className={`nav-link ${route===slug?'active':''}`} onClick={()=>setMenu(false)}><Icon size={16}/><span>{label}</span></Link>)}</nav>
      <button className="sidebar-user" onClick={()=>setAuth(false)}><div className="avatar">AB</div><div><b>Alex Bryant</b><br/><span style={{color:'#8792a3'}}>Admin · Sign out</span></div><LogOut size={14}/></button>
    </aside>
    <main className="main">
      <header className="topbar">
        <button className="btn secondary mobile-menu" onClick={()=>setMenu(!menu)} aria-label="Open navigation"><Menu size={18}/></button>
        <input className="search" placeholder="Search everything…" />
        <div style={{display:'flex',alignItems:'center',gap:13}}><button className="btn" aria-label="Create"><Plus size={16}/></button><Bell size={18}/><div className="avatar">AB</div></div>
      </header>
      <section className="content"><Page route={active[0]} leads={leads} setLeads={setLeads} contacts={contacts} setContacts={setContacts} businesses={businesses} setBusinesses={setBusinesses} prospects={prospects} setProspects={setProspects} drafts={drafts} setDrafts={setDrafts} outreach={outreach} setOutreach={setOutreach} gmailMessages={gmailMessages} setGmailMessages={setGmailMessages}/></section>
    </main>
  </div>;
}

function Login({onLogin}:{onLogin:()=>void}) {
  const [email,setEmail]=useState(''); const [password,setPassword]=useState(''); const [error,setError]=useState('');
  function submit(e:React.FormEvent){e.preventDefault(); if(!email.includes('@')||password.length<6){setError('Enter a valid email and a password of at least 6 characters.');return;} onLogin();}
  return <main className="login"><form className="login-card" onSubmit={submit}>
    <div className="login-logo"><div className="brand-mark" style={{margin:'0 auto 10px',width:48,height:48,fontSize:26}}>L◉</div>LEADORA</div>
    <h1>Welcome back</h1><p className="muted">Sign in to your sales workspace.</p>
    <div className="form-row"><label>Email address<input className="field" type="email" value={email} onChange={e=>setEmail(e.target.value)} placeholder="alex@leadora.com"/></label></div>
    <div className="form-row"><label>Password<input className="field" type="password" value={password} onChange={e=>setPassword(e.target.value)} placeholder="6+ characters"/></label></div>
    {error&&<p style={{color:'#b42318',fontSize:12}}>{error}</p>}<button className="btn" style={{width:'100%',marginTop:8}}>Sign in</button>
    <p className="muted" style={{textAlign:'center',marginTop:14}}>Demo access: any valid email and 6+ character password.</p>
  </form></main>;
}

function Page({route,leads,setLeads,contacts,setContacts,businesses,setBusinesses,prospects,setProspects,drafts,setDrafts,outreach,setOutreach,gmailMessages,setGmailMessages}:{route:string;leads:Lead[];setLeads:(v:Lead[])=>void;contacts:Contact[];setContacts:(v:Contact[])=>void;businesses:BusinessProfile[];setBusinesses:(v:BusinessProfile[])=>void;prospects:Prospect[];setProspects:(v:Prospect[])=>void;drafts:Draft[];setDrafts:(v:Draft[])=>void;outreach:Outreach[];setOutreach:(v:Outreach[])=>void;gmailMessages:GmailMessage[];setGmailMessages:(v:GmailMessage[])=>void}) {
  if(route==='dashboard') return <Dashboard leads={leads} prospects={prospects} drafts={drafts} outreach={outreach}/>;
  if(route==='leads') return <Leads leads={leads} setLeads={setLeads}/>;
  if(route==='contacts') return <Contacts contacts={contacts} setContacts={setContacts}/>;
  if(route==='pipelines') return <Pipelines leads={leads}/>;
  if(route==='automations') return <Automations/>;
  if(route==='analytics'||route==='reports') return <Reports title={route==='analytics'?'Analytics':'Reports'}/>;
  if(route==='settings') return <SettingsPage/>;
  if(route==='website-audits') return <AuditPage prospects={prospects}/>;
  if(route==='inbox') return <InboxPage messages={gmailMessages} setMessages={setGmailMessages} businesses={businesses}/>;
  if(route==='email-outreach') return <OutreachPage businesses={businesses} prospects={prospects} setProspects={setProspects} drafts={drafts} setDrafts={setDrafts} outreach={outreach} setOutreach={setOutreach}/>;
  if(route==='outreach-history') return <HistoryPage businesses={businesses} prospects={prospects} outreach={outreach}/>;
  return <GenericPage route={route}/>;
}

function Header({title,sub,action}:{title:string;sub:string;action?:React.ReactNode}){return <div className="heading-row"><div><h1>{title}</h1><div className="muted">{sub}</div></div>{action}</div>}
function Kpi({label,value,change}:{label:string;value:string;change:string}){return <div className="card"><div className="kpi-label">{label}</div><div className="kpi-value">{value}</div><div className="up">↑ {change} vs last 7 days</div></div>}
async function fetchIntegrationStatus() {
  const get = async (url:string) => {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`Status request failed (${response.status})`);
    return response.json();
  };
  const [gmailResult,systemResult]=await Promise.allSettled([
    get('/api/gmail/status'),
    get('/api/system/status'),
  ]);
  const gmailStatus = gmailResult.status === 'fulfilled'
    ? gmailResult.value as GmailStatus
    : {connected:false,code:'GMAIL_API_UNAVAILABLE',error:'The status service is unavailable. Try again shortly.'} satisfies GmailStatus;
  const systemStatus = systemResult.status === 'fulfilled'
    ? systemResult.value as {statuses:SystemStatus}
    : {statuses:Object.fromEntries(
        (['cloudflare','backend','database','googleOAuth','gmailApi','connectedAccount'] as const)
          .map(key => [key,{ok:false,detail:'Status service unavailable'}]),
      ) as SystemStatus};
  return {gmailStatus,systemStatus};
}

function Dashboard({leads,prospects,drafts,outreach}:{leads:Lead[];prospects:Prospect[];drafts:Draft[];outreach:Outreach[]}) {
  const bars=[48,72,55,79,62,88,42];
  return <><Header title="Good morning, Alex 👋" sub="Here’s what’s happening with your business today." action={<button className="btn secondary">Jul 14 – Jul 21, 2026</button>}/>
    <div className="grid kpis"><Kpi label="Leads Found Today" value={String(prospects.filter(p=>new Date(p.discoveredAt).toDateString()===new Date().toDateString()).length)} change="today"/><Kpi label="Awaiting Approval" value={String(drafts.filter(d=>d.status==='pending').length)} change="today"/><Kpi label="Emails Sent" value={String(outreach.filter(o=>o.status==='sent').length)} change="all time"/><Kpi label="Average Audit Score" value={prospects.length?`${Math.round(prospects.reduce((total,p)=>total+p.score,0)/prospects.length)}/100`:'—'} change="all audits"/></div>
    <div className="grid dashboard-grid"><div className="card"><b>Leads Overview</b><div className="chart-bars">{bars.map((h,i)=><div key={i} className="bar" style={{height:`${h}%`}}/>)}</div><div style={{display:'flex',justifyContent:'space-between'}}>{['Mon','Tue','Wed','Thu','Fri','Sat','Sun'].map(x=><span className="muted" key={x}>{x}</span>)}</div></div>
    <div className="card"><b>Recent Activity</b><div className="activity" style={{marginTop:18}}>{['New lead: Sarah Johnson','Email opened: Proposal Follow-up','Deal won: ACME Solutions','Task completed: Call with James','New lead: David Williams'].map((x,i)=><div className="activity-row" key={x}><i className="dot"/><span>{x}</span><span className="muted">{i+1}h</span></div>)}</div></div></div>
    <div className="grid dashboard-grid"><div className="card"><b>Today’s Prospecting</b><div className="grid kpis" style={{gridTemplateColumns:'repeat(4,1fr)',marginTop:14}}><Kpi label="Prospects found" value={String(prospects.length)} change="today"/><Kpi label="Emails drafted" value={String(drafts.length)} change="today"/><Kpi label="Pending approval" value={String(drafts.filter(d=>d.status==='pending').length)} change="today"/><Kpi label="Sent today" value={String(outreach.filter(o=>o.status==='sent'&&o.date===new Date().toLocaleDateString()).length)} change="today"/></div></div><div className="card"><b>Tasks Due Today</b>{['Review new AI drafts','Approve outreach queue','Follow up with prospects','Team meeting'].map((x,i)=><label key={x} style={{display:'flex',gap:10,marginTop:16,fontSize:12}}><input type="checkbox"/>{x}<span className="muted" style={{marginLeft:'auto'}}>{9+i}:00</span></label>)}</div></div>
  </>;
}

function Leads({leads,setLeads}:{leads:Lead[];setLeads:(v:Lead[])=>void}) {
  function add(){const name=prompt('Lead name'); if(!name)return; const email=prompt('Email')||''; setLeads([{name,email,company:prompt('Company')||'New company',status:'New',source:'Manual',created:'Just now'},...leads]);}
  return <><Header title="Leads" sub="Manage and track all your leads." action={<button className="btn" onClick={add}>+ Add Lead</button>}/><div className="tabs">{['All Leads','New','Contacted','Qualified','Proposal','Won','Lost'].map((x,i)=><div className={`tab ${i===0?'active':''}`} key={x}>{x}</div>)}</div><DataTable headers={['Name','Email','Company','Status','Source','Created']} rows={leads.map(l=>[l.name,l.email,l.company,<span className="badge" key={l.name}>{l.status}</span>,l.source,l.created])}/></>;
}

function Contacts({contacts,setContacts}:{contacts:Contact[];setContacts:(v:Contact[])=>void}) {
 function add(){const name=prompt('Contact name'); if(!name)return; setContacts([{name,email:prompt('Email')||'',company:prompt('Company')||'',phone:prompt('Phone')||'',status:'Active'},...contacts]);}
 return <><Header title="Contacts" sub="Your complete customer and prospect directory." action={<button className="btn" onClick={add}>+ Add Contact</button>}/><DataTable headers={['Name','Email','Company','Phone','Status']} rows={contacts.map(c=>[c.name,c.email,c.company,c.phone,<span className="badge" key={c.name}>{c.status}</span>])}/></>;
}

function DataTable({headers,rows}:{headers:string[];rows:React.ReactNode[][]}) {return <div className="card table-wrap"><table><thead><tr>{headers.map(h=><th key={h}>{h}</th>)}</tr></thead><tbody>{rows.map((r,i)=><tr key={i}>{r.map((v,j)=><td key={j}>{v}</td>)}</tr>)}</tbody></table></div>}

function Pipelines({leads}:{leads:Lead[]}) { const stages=['New','Contacted','Qualified','Proposal']; return <><Header title="Pipeline" sub="Move prospects through your sales process." action={<button className="btn">+ Add Deal</button>}/><div className="grid pipeline">{stages.map((s,si)=><div className="pipeline-col" key={s}><div className="pipeline-title"><span>{s}</span><span>{leads.filter(l=>l.status===s).length||si+2}</span></div>{leads.filter(l=>l.status===s).concat(leads.slice(si,si+1)).slice(0,3).map((l,i)=><div className="deal" key={l.name+i}><b>{l.company}</b><p className="muted">{l.name}</p><strong style={{color:'#886b22'}}>£{(2400+si*1750).toLocaleString()}</strong></div>)}</div>)}</div></> }

function Automations(){const rows=[['New Lead Welcome','Welcome a new lead','124','86%'],['Follow-Up Sequence','Follow up with leads','98','72%'],['Re-engagement Campaign','Win back inactive leads','64','45%'],['Deal Won Celebration','Reward new customers','23','100%']];return <><Header title="Automations" sub="Create workflows that work for you." action={<button className="btn">+ New Automation</button>}/><div className="card">{rows.map(r=><div key={r[0]} style={{display:'grid',gridTemplateColumns:'42px 1fr 80px 80px 45px',gap:14,alignItems:'center',padding:'15px 4px',borderBottom:'1px solid #eee'}}><div className="avatar"><Workflow size={15}/></div><div><b>{r[0]}</b><div className="muted">{r[1]}</div></div><div><b>{r[2]}</b><div className="muted">Active</div></div><div><b>{r[3]}</b><div className="muted">Open rate</div></div><div className="toggle"/></div>)}</div></>}

function Reports({title}:{title:string}){return <><Header title={title} sub="Track your performance and growth." action={<button className="btn secondary">Jul 14 – Jul 21, 2026</button>}/><div className="grid kpis"><Kpi label="Total Leads" value="248" change="18%"/><Kpi label="Conversions" value="23" change="8%"/><Kpi label="Conversion Rate" value="9.3%" change="2.1%"/><Kpi label="Revenue" value="£12,540" change="22%"/></div><div className="grid dashboard-grid"><div className="card"><b>Leads Over Time</b><div className="chart-bars">{[22,45,86,52,68,38,91,61,73,49,80,57].map((h,i)=><div className="bar" key={i} style={{height:`${h}%`}}/>)}</div></div><div className="card"><b>Leads by Source</b><div style={{width:190,height:190,borderRadius:'50%',margin:'28px auto',background:'conic-gradient(#c9a84c 0 42%,#0b1220 42% 70%,#e8d8ae 70% 87%,#dfe2e8 87%)',display:'grid',placeItems:'center'}}><div style={{width:105,height:105,borderRadius:'50%',background:'#fff',display:'grid',placeItems:'center',fontWeight:800,fontSize:25}}>248</div></div></div></div></>}

function OutreachPage({businesses,prospects,setProspects,drafts,setDrafts,outreach,setOutreach}:{businesses:BusinessProfile[];prospects:Prospect[];setProspects:(v:Prospect[])=>void;drafts:Draft[];setDrafts:(v:Draft[])=>void;outreach:Outreach[];setOutreach:(v:Outreach[])=>void}) {
  const [businessId,setBusinessId]=useState(businesses[0]?.id||''); const [busy,setBusy]=useState(false); const [sending,setSending]=useState<string|null>(null); const [sendError,setSendError]=useState(''); const [website,setWebsite]=useState('');
  const workflow=getOutreachWorkflow(businessId) ?? getOutreachWorkflow('bryant-digital');
  const pending=drafts.filter(d=>d.status==='pending'&&d.businessId===businessId);
  function selectBusiness(nextBusinessId:string) { setBusinessId(nextBusinessId); setBusy(false); setSending(null); setSendError(''); setWebsite(''); }
  useEffect(()=>{
    const due = outreach.filter(o => o.status==='sent' && o.sentAt && Date.now()-new Date(o.sentAt).getTime() >= 3*24*60*60*1000 && !drafts.some(d=>d.prospectId===o.prospectId&&d.isFollowUp));
    if(!due.length)return;
    const followUps=due.map((o):Draft|null=>{const p=prospects.find(item=>item.id===o.prospectId);const b=businesses.find(item=>item.id===o.businessId);if(!p||!b)return null;return {id:`follow-up-${o.id}`,prospectId:p.id,businessId:b.id,subject:`Following up — ${p.name}`,body:`Hi there,\n\nI wanted to follow up on my earlier note. If improving ${b.services[0].toLowerCase()} is on your radar, I’d be happy to share a few relevant ideas — no pressure at all.\n\nWould a quick call be useful?\n\n${b.signature}`,callToAction:'Would a quick call be useful?',generatedAt:new Date().toISOString(),status:'pending',isFollowUp:true};}).filter((draft):draft is Draft=>Boolean(draft));
    if(followUps.length)setDrafts([...drafts,...followUps]);
  },[outreach,drafts,prospects,businesses,setDrafts]);
  async function discover() {
    const business=businesses.find(b=>b.id===businessId); if(!business)return;
    if(workflow.workflowType==='dorset-prospecting'){
      setBusy(true); setSendError('');
      try {
        const response=await fetch('/api/prospects/discover',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({limit:10,companyId:business.id})});
        const result=await response.json(); if(!response.ok) throw new Error(result.error||'Public directory search failed.');
        const existingEmails=new Set(prospects.map(p=>p.email.toLowerCase()));
        const found=(result.prospects as Array<{name:string;email:string;website:string;phone:string;location:string;industry:string;contactUrl:string;googleMapsUrl:string;proposal:{subject:string;body:string;callToAction:string}}>).filter(item=>!existingEmails.has(item.email.toLowerCase()));
        if(!found.length){setSendError('No new Dorset businesses with a published public email were returned. Try again later; the public directory changes over time.');return;}
        const created=found.map(item=>({id:`${business.id}-${crypto.randomUUID()}`,businessId:business.id,name:item.name,website:item.website,email:item.email,phone:item.phone,location:item.location,industry:item.industry,contactUrl:item.contactUrl,googleMapsUrl:item.googleMapsUrl,score:70,reasons:[`Public business contact email published via ${workflow.leadSource}.`,`Suitable ${workflow.recommendedService.toLowerCase()} prospect based on its public business category.`],discoveredAt:new Date().toISOString(),contacted:false,recommendedService:workflow.recommendedService,confidence:70} satisfies Prospect));
        const createdDrafts=created.map((prospect,index)=>({id:`draft-${prospect.id}`,prospectId:prospect.id,businessId:business.id,subject:found[index].proposal.subject,body:found[index].proposal.body,callToAction:found[index].proposal.callToAction,generatedAt:new Date().toISOString(),status:'pending'} satisfies Draft));
        setProspects([...prospects,...created]); setDrafts([...drafts,...createdDrafts]);
      } catch(error) {setSendError(error instanceof Error?error.message:'Public directory search failed.');} finally {setBusy(false);} return;
    }
    if(!workflow.websiteAuditEnabled){setSendError('Website auditing is not available for this company.');return;}
    if(!website.trim()){setSendError('Enter a public business website to analyse.');return;}
    setBusy(true); setSendError('');
    try {
      const response=await fetch('/api/leads/audit',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({website})});
      const result=await response.json(); if(!response.ok) throw new Error(result.error||'Website analysis failed.');
      if(prospects.some(p=>p.website===result.website)){setSendError('This website is already in your CRM.');return;}
      const audit=result.audit as Audit; const opportunity=audit.notes.length ? `The audit found ${audit.notes.slice(0,2).join(' and ').toLowerCase()}.` : 'The website has a solid foundation and may benefit from a focused growth review.';
      const prospect:Prospect={id:`${business.id}-${crypto.randomUUID()}`,businessId:business.id,name:result.businessName,website:result.website,email:result.contactEmail||'',phone:result.phoneNumber||'',location:'',industry:'',contactUrl:result.contactPageUrl||'',googleMapsUrl:`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(result.businessName)}`,score:audit.overallScore,reasons:[opportunity,result.contactEmail?'A public business email was published on the website.':'No public email found — add one before sending.'],discoveredAt:new Date().toISOString(),contacted:false,audit,recommendedService:business.services[0],confidence:Math.max(40,Math.min(95,100-audit.overallScore))};
      const evidence=audit.notes.length ? `I noticed ${audit.notes[0].toLowerCase()} on the public pages I reviewed.` : `I reviewed your public website and noticed a possible opportunity to strengthen its next stage of growth.`;
      const draft:Draft={id:`draft-${prospect.id}`,prospectId:prospect.id,businessId:business.id,subject:`A practical idea for ${prospect.name}`,body:`Hi there,\n\nI came across ${prospect.name} and took a quick look at its public website. ${evidence}\n\n${business.name} helps organisations with ${business.services.slice(0,2).join(' and ')}. If useful, I’d be happy to share a few practical, no-obligation ideas that relate to what I found.\n\nWould a short call next week be helpful?\n\n${business.signature}`,callToAction:'Would a short call next week be helpful?',generatedAt:new Date().toISOString(),status:'pending'};
      setProspects([...prospects,prospect]); setDrafts([...drafts,draft]);
    } catch(error) { setSendError(error instanceof Error?error.message:'Website analysis failed.'); } finally {setBusy(false);}
  }
  function approve(id:string){setDrafts(drafts.map(d=>d.id===id?{...d,status:'approved'}:d));}
  function remove(id:string){setDrafts(drafts.filter(d=>d.id!==id));}
  async function send(id:string){
    const d=drafts.find(x=>x.id===id); const p=prospects.find(x=>x.id===d?.prospectId);
    if(!d||!p)return;
    if(d.status!=='approved'||sending)return;
    const mappings=JSON.parse(localStorage.getItem('leadora-business-email-mappings')||'{}') as Record<string,string>;
    const from=mappings[d.businessId]; if(!from){setSendError('Add a mapped business email in Settings before sending.');return;}
    setSending(id);setSendError('');
    try {
      const response=await fetch('/api/gmail/send',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({from,to:p.email,subject:d.subject,body:d.body})});
      const result=await response.json(); if(!response.ok)throw new Error(result.error||'Gmail send failed.');
      if(drafts.some(x=>x.status==='sent'&&x.id===id))return;
      const now=new Date();
      const record:Outreach={id:`out-${crypto.randomUUID()}`,prospectId:p.id,businessId:d.businessId,date:now.toLocaleDateString(),time:now.toLocaleTimeString([], {hour:'2-digit',minute:'2-digit'}),status:'sent',gmailMessageId:result.id,sentAt:now.toISOString()};
      setDrafts(drafts.map(x=>x.id===id?{...x,status:'sent',gmailMessageId:result.id}:x)); setProspects(prospects.map(x=>x.id===p.id?{...x,contacted:true}:x)); setOutreach([...outreach,record]);
    } catch(e) { const message=e instanceof Error?e.message:'Gmail send failed.'; setSendError(message); setDrafts(drafts.map(x=>x.id===id?{...x,status:'send_failed',lastError:message}:x)); } finally { setSending(null); }
  }
  const prospectMap = new Map(prospects.map(p=>[p.id,p])); const businessMap = new Map(businesses.map(b=>[b.id,b]));
  const selected=businesses.find(b=>b.id===businessId);
  const workflowInputs=workflow.inputFields.map(field=><label className="form-row" key={field.id} style={{display:'block',margin:0,minWidth:260,fontSize:12}}>{field.label}<input className="field" type="url" value={website} placeholder={field.placeholder} onChange={e=>setWebsite(e.target.value)}/></label>);
  return <><Header title={workflow.title} sub={workflow.description} action={<div style={{display:'flex',gap:8,alignItems:'flex-end',flexWrap:'wrap'}}><select aria-label="Outreach company" className="field" style={{margin:0,width:220}} value={businessId} onChange={e=>selectBusiness(e.target.value)}>{businesses.map(b=><option key={b.id} value={b.id}>{b.name}</option>)}</select>{workflowInputs}<button className="btn" onClick={discover} disabled={busy}>{busy?(workflow.websiteAuditEnabled?'Analysing…':'Finding…'):workflow.buttonText}</button></div>}/>
  <div className="card" style={{marginBottom:16}}><b>{selected?.name} workflow</b><p className="muted" style={{marginBottom:8}}>Lead source: {workflow.leadSource} · Proposal: {workflow.proposalTemplate.replace('-', ' ')} · Website audit: {workflow.websiteAuditEnabled?'enabled':'disabled'}</p><ol style={{margin:'0 0 0 18px',padding:0,fontSize:13,lineHeight:1.7}}>{workflow.steps.map(step=><li key={step}>{step}</li>)}</ol></div>
  {sendError&&<div className="card" style={{color:'#b42318',marginBottom:16}}>{sendError}</div>}<div className="card" style={{marginBottom:16}}><b><Sparkles size={15} style={{verticalAlign:'middle',marginRight:6}}/>Approval queue</b><span className="muted" style={{marginLeft:10}}>{pending.length} pending for {workflow.companyName} · emails are never sent automatically</span></div>{pending.length===0?<div className="card" style={{textAlign:'center',padding:40}}><ClipboardCheck size={30} color="#c9a84c"/><p><b>No emails awaiting approval</b></p><p className="muted">{workflow.websiteAuditEnabled?'Analyse a public business website to create the first audit and proposal.':'Find public Dorset prospects to draft the first proposal.'}</p></div>:<div className="grid">{pending.map(d=>{const p=prospectMap.get(d.prospectId);const b=businessMap.get(d.businessId);if(!p||!b)return null;return <div className="card" key={d.id}><div style={{display:'flex',justifyContent:'space-between',gap:15}}><div><b>{p.name}</b><div className="muted">{b.name} · {p.email||'No public email'} · {p.audit?`Audit ${p.score}/100`:`Opportunity ${p.score}/100`}</div></div><span className="badge">Pending approval</span></div><h3 style={{fontSize:14,marginBottom:8}}>{d.subject}</h3><p style={{whiteSpace:'pre-line',fontSize:13,lineHeight:1.6}}>{d.body}</p><div className="muted" style={{marginBottom:12}}>Opportunity: {p.recommendedService} · Confidence {p.confidence}% · {p.reasons.join(' ')}</div><div style={{display:'flex',gap:8}}><button className="btn" onClick={()=>approve(d.id)} disabled={!p.email}><ClipboardCheck size={14}/> Approve</button><button className="btn secondary" onClick={()=>{const subject=prompt('Edit subject',d.subject)||d.subject;setDrafts(drafts.map(x=>x.id===d.id?{...x,subject,status:'edited'}:x))}}><Pencil size={14}/> Edit</button><button className="btn secondary" onClick={()=>remove(d.id)}><Trash2 size={14}/> Delete</button></div></div>})}</div>}{drafts.filter(d=>d.status==='approved'&&d.businessId===businessId).length>0&&<div className="card" style={{marginTop:16}}><b>Approved and ready to send</b>{drafts.filter(d=>d.status==='approved'&&d.businessId===businessId).map(d=><div key={d.id} style={{display:'flex',alignItems:'center',justifyContent:'space-between',padding:'12px 0',borderBottom:'1px solid #eee'}}><span>{prospectMap.get(d.prospectId)?.name}<span className="muted"> · {d.subject}</span></span><button className="btn" onClick={()=>send(d.id)} disabled={sending!==null}><Send size={14}/> {sending===d.id?'Sending…':'Send now'}</button></div>)}</div>}</>;

}

function AuditPage({prospects}:{prospects:Prospect[]}) {
  const audited=prospects.filter(p=>p.audit);
  if(!audited.length) return <><Header title="Website Audits" sub="Evidence gathered from public pages."/><div className="card" style={{textAlign:'center',padding:40}}><SearchCheck size={30} color="#c9a84c"/><p><b>No website audits yet</b></p><p className="muted">Analyse a public business website from Email Outreach to create the first audit.</p></div></>;
  return <><Header title="Website Audits" sub="Evidence gathered from public pages. Speed and mobile testing can be added as a provider later."/><div className="grid">{audited.map(p=>{
    const a=p.audit!;
    return <div className="card" key={p.id}>
      <div style={{display:'flex',justifyContent:'space-between',gap:12}}><div><b>{p.name}</b><div className="muted">{p.website}</div></div><span className="badge">{`${a.overallScore}/100`}</span></div>
      <div className="grid" style={{gridTemplateColumns:'repeat(2,1fr)',marginTop:14,fontSize:12}}><div><b>SEO</b><div className="muted">{`${a.basicSeoScore}/100`}</div></div><div><b>Accessibility</b><div className="muted">{`${a.accessibilityScore}/100`}</div></div><div><b>HTTPS</b><div className="muted">{a.https?'Detected':'Not detected'}</div></div><div><b>Missing alt text</b><div className="muted">{a.missingAltText}</div></div></div>
      <p className="muted" style={{fontSize:12,marginTop:14}}>{a.notes.length?a.notes.join(' · '):'No basic SEO or accessibility issues detected by this audit.'}</p>
    </div>;
  })}</div></>;
}

function HistoryPage({businesses,prospects,outreach}:{businesses:BusinessProfile[];prospects:Prospect[];outreach:Outreach[]}) {
  return <><Header title="Outreach History" sub="A complete record of sent, pending and follow-up activity."/><DataTable headers={['Date','Time','Business','Prospect','Email','Status']} rows={outreach.map(o=>{const p=prospects.find(x=>x.id===o.prospectId);return [o.date,o.time,businesses.find(b=>b.id===o.businessId)?.name||'—',p?.name||'—',p?.email||'—',<span className="badge" key={o.id}>{o.status}</span>]})}/>{outreach.length===0&&<div className="card" style={{textAlign:'center',marginTop:16}}><History size={28} color="#c9a84c"/><p className="muted">No outreach has been sent yet.</p></div>}</>;
}

function InboxPage({messages,setMessages,businesses}:{messages:GmailMessage[];setMessages:(v:GmailMessage[])=>void;businesses:BusinessProfile[]}) {
  const [filter,setFilter]=useState('all'); const [busy,setBusy]=useState(false); const [error,setError]=useState('');
  async function sync() {
    setBusy(true); setError('');
    try {
      const mappings=JSON.parse(localStorage.getItem('leadora-business-email-mappings')||'{}') as Record<string,string>;
      const response=await fetch('/api/gmail/sync',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({mappings:Object.fromEntries(Object.entries(mappings).map(([id,address])=>[id,address?[address]:[]]))})});
      const data=await response.json(); if(!response.ok) throw new Error(data.error||'Synchronisation failed.');
      const existing=new Map(messages.map(m=>[m.id,m])); (data.messages as GmailMessage[]).forEach(m=>existing.set(m.id,m)); setMessages([...existing.values()]);
    } catch (e) { setError(e instanceof Error?e.message:'Synchronisation failed.'); } finally { setBusy(false); }
  }
  const visible=messages.filter(m=>filter==='all'||filter==='unread'&&!m.isRead||filter==='replied'&&m.labelIds.includes('SENT')||filter==='unassigned'&&!m.businessId);
  return <><Header title="Inbox & conversations" sub="Gmail conversations matched to your prospects and businesses." action={<button className="btn" onClick={sync} disabled={busy}><RefreshCw size={14}/> {busy?'Syncing…':'Sync now'}</button>}/>{error&&<div className="card" style={{color:'#b42318',marginBottom:16}}>{error}</div>}<div className="tabs">{[['all','All'],['unread','Unread'],['replied','Replied'],['unassigned','Unassigned']].map(([key,label])=><button className={`tab ${filter===key?'active':''}`} key={key} onClick={()=>setFilter(key)}>{label}</button>)}</div>{visible.length===0?<div className="card" style={{textAlign:'center',padding:40}}><Inbox size={30} color="#c9a84c"/><p><b>No conversations imported</b></p><p className="muted">Connect Gmail in Settings, then choose Sync now.</p></div>:<div className="grid">{visible.map(m=><div className="card" key={m.id}><div style={{display:'flex',justifyContent:'space-between',gap:12}}><div><b>{m.subject||'(no subject)'}</b><div className="muted">{m.from} · {new Date(Number(m.internalDate)||m.internalDate).toLocaleString()}</div></div><span className="badge">{businesses.find(b=>b.id===m.businessId)?.name||'Business not identified'}</span></div><p style={{whiteSpace:'pre-line',fontSize:13,lineHeight:1.5}}>{m.body.slice(0,320)}{m.body.length>320?'…':''}</p><div className="muted">Thread {m.threadId} · {m.labelIds.includes('SENT')?'Sent outreach':'Incoming reply'}</div></div>)}</div>}</>;
}

function SettingsPage(){
  const [daily,setDaily]=useState('10'); const [style,setStyle]=useState('Professional and warm'); const [saved,setSaved]=useState('');
  const [gmail,setGmail]=useState<GmailStatus>({connected:false}); const [mapping,setMapping]=useState<Record<string,string>>({'bryant-cleaning':'info@bryantandcocleaning.co.uk'}); const [syncing,setSyncing]=useState(false);
  const [system,setSystem]=useState<SystemStatus|null>(null);
  useEffect(()=>{fetchIntegrationStatus().then(({gmailStatus,systemStatus})=>{setGmail(gmailStatus); setSystem({...systemStatus.statuses,connectedAccount:{ok:gmailStatus.connected,detail:gmailStatus.connected?`Connected · ${gmailStatus.emailAddress}`:'No Gmail account connected'},gmailApi:{ok:gmailStatus.connected,detail:gmailStatus.connected?'Profile check passed':gmailStatus.error??'Gmail status is unavailable'}});});},[]);
  useEffect(()=>{const savedMapping=localStorage.getItem('leadora-business-email-mappings'); if(savedMapping) try{setMapping(JSON.parse(savedMapping));}catch{}},[]);
  function save(){const limit=Number(daily); if(!Number.isInteger(limit)||limit<1){setSaved('Enter a positive whole number');return;} try { localStorage.setItem('leadora-outreach-settings',JSON.stringify({dailyLimit:limit,style})); setSaved('Saved'); } catch { setSaved('Unable to save preferences'); }}
  function saveMappings(){localStorage.setItem('leadora-business-email-mappings',JSON.stringify(mapping));setSaved('Mappings saved');}
  async function disconnect(){setSyncing(true);await fetch('/api/gmail/disconnect',{method:'POST'});setGmail({connected:false});setSyncing(false);}
  const checks=[['cloudflare','Cloudflare deployment'],['backend','Backend API'],['database','Database'],['googleOAuth','Google OAuth'],['gmailApi','Gmail API'],['connectedAccount','Connected account']] as const;
  return <><Header title="Settings" sub="Manage your workspace, account and security."/><div className="tabs">{['Profile','Team','Billing','Integrations','Preferences','Security'].map((x,i)=><div className={`tab ${i===5?'active':''}`} key={x}>{x}</div>)}</div><div className="card" style={{marginBottom:16}}><b>System Status</b><div className="grid" style={{gridTemplateColumns:'repeat(auto-fit,minmax(180px,1fr))',marginTop:12}}>{checks.map(([key,label])=>{const check=system?.[key]; return <div key={key} style={{display:'flex',gap:8,alignItems:'flex-start'}}><span style={{color:check?.ok?'#16803c':'#b42318',fontWeight:700}}>{check?.ok?'✓':'✕'}</span><div><b>{label}</b><div className="muted" style={{fontSize:12}}>{check?.detail??'Checking…'}</div></div></div>})}</div></div><div className="grid dashboard-grid"><div className="card"><b>Gmail integration</b><p className="muted">Send only approved outreach and synchronise incoming replies securely.</p>{gmail.connected?<><div className="badge" style={{margin:'8px 0'}}>Connected · {gmail.emailAddress}</div><p className="muted">Tokens are handled server-side. Last synchronisation is shown in Inbox.</p><button className="btn secondary" onClick={()=>location.href='/api/gmail/auth'}>Reconnect Gmail</button><button className="btn secondary" style={{marginLeft:8}} onClick={disconnect} disabled={syncing}>Disconnect</button></>:<button className="btn" onClick={()=>location.href='/api/gmail/auth'}>Connect Gmail</button>}{gmail.error&&<p style={{color:'#b42318',fontSize:12}}>{gmail.code&&<><b>{gmail.code}</b> — </>}{gmail.error}</p>}</div><div className="card"><b>Business email mappings</b><p className="muted">Use forwarded headers to identify the correct LEADORA business.</p>{['bryant-cleaning','bryant-construction','bryant-digital'].map(id=><label className="form-row" style={{display:'block',fontSize:12}} key={id}>{id==='bryant-cleaning'?'Bryant & Co Cleaning':id==='bryant-construction'?'Bryant Construction Group':'Bryant Digital Solutions'}<input className="field" value={mapping[id]??''} placeholder="info@example.com" onChange={e=>setMapping({...mapping,[id]:e.target.value})}/></label>)}<button className="btn" onClick={saveMappings}>Save mappings</button></div><div className="card"><b>AI outreach preferences</b><label className="form-row" style={{display:'block',fontSize:12}}>Daily prospect limit<input className="field" type="number" value={daily} onChange={e=>setDaily(e.target.value)}/></label><label className="form-row" style={{display:'block',fontSize:12}}>Writing style<select className="field" value={style} onChange={e=>setStyle(e.target.value)}><option>Professional and warm</option><option>Friendly and helpful</option><option>Clear and consultative</option></select></label><button className="btn" onClick={save}>Save preferences</button>{saved&&<span className="up" style={{marginLeft:10}}>{saved}</span>}</div><div className="card"><b>Change Password</b>{['Current Password','New Password','Confirm New Password'].map(x=><label className="form-row" style={{display:'block',fontSize:12}} key={x}>{x}<input className="field" type="password"/></label>)}<button className="btn">Update Password</button></div>{gmail.diagnostics&&<div className="card"><b>Developer diagnostics</b><p className="muted">Development only. Secret values are never displayed.</p>{gmail.diagnostics.map(item=><div key={item.name} style={{display:'flex',justifyContent:'space-between',fontSize:12,padding:'4px 0'}}><span>{item.name}</span><span style={{color:item.configured?'#16803c':'#b42318'}}>{item.configured?'Present':'Missing'}</span></div>)}</div>}</div></>}

function GenericPage({route}:{route:string}) { const config:Record<string,[string,string,string[]]>={
 'companies':['Companies','Manage organisations and account relationships.',['Company','Primary Contact','Industry','Revenue','Status']],
 'deals':['Deals','Track value, probability and expected close dates.',['Deal','Company','Value','Probability','Stage']],
 'email-outreach':['Email Outreach','Create, send and measure targeted campaigns.',['Campaign','Recipients','Open Rate','Reply Rate','Status']],
 'website-audits':['Website Audits','Run SEO, performance and conversion audits.',['Website','Score','SEO','Performance','Status']],
 'ai-agents':['AI Agents','Deploy autonomous agents across your sales operation.',['Agent','Purpose','Runs','Success Rate','Status']],
 };
 const [title,sub,headers]=config[route]??['LEADORA','Your sales operating system.',['Item','Owner','Performance','Status']];
 const rows=useMemo(()=>Array.from({length:6},(_,i)=>headers.map((h,j)=>j===0?(route==='website-audits'?<Link href="/">{`${title.slice(0,-1)} ${i+1}`}</Link>:`${title.slice(0,-1)} ${i+1}`):j===headers.length-1?<span className="badge" key={h}>Active</span>:j===2?`${82-i*4}%`:`${h} data`)),[headers,title,route]);
 return <><Header title={title} sub={sub} action={<button className="btn">+ New {title.slice(0,-1)}</button>}/><DataTable headers={headers} rows={rows}/></>;
}
