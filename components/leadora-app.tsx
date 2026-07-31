'use client';

import { useEffect, useRef, useState } from 'react';
import Link from 'next/link';
import {
  LayoutDashboard, Users, ContactRound, Building2, Handshake, Columns3,
  Mail, SearchCheck, Bot, Workflow, ChartNoAxesCombined, FileChartColumn,
  Settings, Menu, Bell, Plus, LogOut, Target, ClipboardCheck, History, Sparkles, Trash2, Pencil, Send, Search, Inbox, RefreshCw
} from 'lucide-react';
import { getOutreachWorkflow, CLIENT_CONTACT_PHONE } from '@/lib/outreach-workflows';
import { decodeHtmlEntities } from '@/lib/text';
import { isPublicBusinessEmail } from '@/lib/leads/public-email';

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

const seedLeads: Lead[] = [];
const seedContacts: Contact[] = [];
const DEMO_EMAILS = new Set([
  'sarah@designco.com','david@techflow.com','james@marketplus.com',
  'emily@brightidea.com','michael@nextgen.com',
]);
const seedBusinesses: BusinessProfile[] = [
  {id:'bryant-construction',name:'Bryant Construction Group',description:'Trusted construction and renovation specialists.',services:['Extensions','Renovations','New builds'],serviceArea:'Bournemouth, Poole and Dorset',website:'bryantconstructiongroup.co.uk',signature:`Alex Bryant\nBryant Construction Group\n${CLIENT_CONTACT_PHONE}`,tone:'Professional and warm',idealCustomer:'Homeowners and property developers',industries:['Construction','Property'],dailyLimit:10,followUp:'3 days, then 7 days'},
  {id:'bryant-cleaning',name:'Bryant & Co Cleaning',description:'Reliable commercial and domestic cleaning teams.',services:['Commercial cleaning','End of tenancy','Deep cleaning'],serviceArea:'Bournemouth and surrounding areas',website:'bryantandcocleaning.co.uk',signature:`Alex Bryant\nBryant & Co Cleaning\n${CLIENT_CONTACT_PHONE}`,tone:'Friendly and helpful',idealCustomer:'Busy homeowners and local businesses',industries:['Hospitality','Property','Offices'],dailyLimit:10,followUp:'4 days, then 10 days'},
  {id:'bryant-digital',name:'Bryant Digital Solutions',description:'Practical digital marketing for growing businesses.',services:['Websites','SEO','Lead generation'],serviceArea:'UK-wide',website:'bryantdigital.co.uk',signature:`Alex Bryant\nBryant Digital Solutions\n${CLIENT_CONTACT_PHONE}`,tone:'Clear and consultative',idealCustomer:'Owner-led SMEs',industries:['Professional services','Retail','Hospitality'],dailyLimit:10,followUp:'3 days, then 7 days'},
  {id:'mr-white-teeth',name:'Mr White Teeth Whitening Bournemouth',description:'Safe, professional teeth whitening in Bournemouth.',services:['Teeth whitening','Smile consultations'],serviceArea:'Bournemouth and Poole',website:'teethwhiteningbournemouth.co.uk',signature:`Alex Bryant\nMr White Teeth Whitening Bournemouth\n${CLIENT_CONTACT_PHONE}`,tone:'Reassuring and upbeat',idealCustomer:'Adults seeking a brighter smile',industries:['Beauty','Healthcare'],dailyLimit:10,followUp:'5 days, then 10 days'},
];
const DEFAULT_BUSINESS_EMAIL_MAPPINGS: Record<string,string> = {
  'bryant-cleaning':'info@bryantandcocleaning.co.uk',
  'bryant-construction':'info@bryantconstructiongroup.co.uk',
  'bryant-digital':'info@bryantdigitalsolutions.com',
  'mr-white-teeth':'info@mrwhiteteeth.co.uk',
};

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
  const [globalSearch,setGlobalSearch] = useState('');

  useEffect(() => {
    const realLeads=leads.filter(item=>!DEMO_EMAILS.has(item.email.toLowerCase()));
    const realContacts=contacts.filter(item=>!DEMO_EMAILS.has(item.email.toLowerCase()));
    if(realLeads.length!==leads.length)setLeads(realLeads);
    if(realContacts.length!==contacts.length)setContacts(realContacts);
  },[leads,contacts,setLeads,setContacts]);
  useEffect(()=>{if(prospects.some(item=>item.email&&!isPublicBusinessEmail(item.email)))setProspects(prospects.map(item=>item.email&&!isPublicBusinessEmail(item.email)?{...item,email:'',reasons:[...item.reasons.filter(reason=>!/public.*email/i.test(reason)),'A valid public business email was not found.']}:item));},[prospects,setProspects]);

  if(route==='login' || !auth) return <Login onLogin={()=>setAuth(true)} />;
  const active = nav.find(n=>n[0]===route) ?? nav[0];
  function search(e:React.FormEvent) {
    e.preventDefault();
    const query=globalSearch.trim().toLowerCase(); if(!query)return;
    const destination=nav.find(([slug,label])=>slug.includes(query)||label.toLowerCase().includes(query));
    if(destination){location.href=`/${destination[0]}/`;return;}
    const matchesProspect=prospects.some(item=>[item.name,item.email,item.website].some(value=>value?.toLowerCase().includes(query)));
    const matchesContact=contacts.some(item=>[item.name,item.email,item.company].some(value=>value?.toLowerCase().includes(query)));
    location.href=matchesProspect?'/email-outreach/':matchesContact?'/contacts/':'/leads/';
  }
  const notifications=drafts.filter(draft=>draft.status==='pending'||draft.status==='send_failed').length+gmailMessages.filter(message=>message.isRead===false&&!message.labelIds.includes('SENT')).length;

  return <div className="shell">
    <aside className={`sidebar ${menu?'open':''}`}>
      <div className="brand"><div className="brand-mark">L◉</div><span>LEADORA</span></div>
      <nav className="nav">{nav.map(([slug,label,Icon])=><Link key={slug} href={`/${slug}/`} className={`nav-link ${route===slug?'active':''}`} onClick={()=>setMenu(false)}><Icon size={16}/><span>{label}</span></Link>)}</nav>
      <button className="sidebar-user" onClick={()=>setAuth(false)}><div className="avatar">AB</div><div><b>Alex Bryant</b><br/><span style={{color:'#8792a3'}}>Admin · Sign out</span></div><LogOut size={14}/></button>
    </aside>
    <main className="main">
      <header className="topbar">
        <button className="btn secondary mobile-menu" onClick={()=>setMenu(!menu)} aria-label="Open navigation"><Menu size={18}/></button>
        <form onSubmit={search} style={{flex:1,display:'flex',gap:8}}><input aria-label="Search LEADORA" className="search" value={globalSearch} onChange={e=>setGlobalSearch(e.target.value)} placeholder="Search pages, prospects and contacts…" /><button className="btn secondary" type="submit" aria-label="Run search" title="Search"><Search size={16}/></button></form>
        <div style={{display:'flex',alignItems:'center',gap:13}}><Link className="btn" href="/leads/" aria-label="Add a lead" title="Add a lead"><Plus size={16}/></Link><Link href="/inbox/" aria-label={`${notifications} notifications`} title="Open notifications" style={{position:'relative',display:'inline-flex',color:'inherit'}}><Bell size={18}/>{notifications>0&&<span className="notification-count">{Math.min(99,notifications)}</span>}</Link><div className="avatar">AB</div></div>
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
    <p className="muted" style={{textAlign:'center',marginTop:14}}>Your sign-in is remembered on this device.</p>
  </form></main>;
}

function Page({route,leads,setLeads,contacts,setContacts,businesses,setBusinesses,prospects,setProspects,drafts,setDrafts,outreach,setOutreach,gmailMessages,setGmailMessages}:{route:string;leads:Lead[];setLeads:(v:Lead[])=>void;contacts:Contact[];setContacts:(v:Contact[])=>void;businesses:BusinessProfile[];setBusinesses:(v:BusinessProfile[])=>void;prospects:Prospect[];setProspects:(v:Prospect[])=>void;drafts:Draft[];setDrafts:(v:Draft[])=>void;outreach:Outreach[];setOutreach:(v:Outreach[])=>void;gmailMessages:GmailMessage[];setGmailMessages:(v:GmailMessage[])=>void}) {
  if(route==='dashboard') return <Dashboard prospects={prospects} drafts={drafts} outreach={outreach} gmailMessages={gmailMessages}/>;
  if(route==='leads') return <Leads leads={leads} setLeads={setLeads}/>;
  if(route==='contacts') return <Contacts contacts={contacts} setContacts={setContacts}/>;
  if(route==='pipelines') return <Pipelines leads={leads}/>;
  if(route==='automations') return <Automations/>;
  if(route==='analytics'||route==='reports') return <Reports title={route==='analytics'?'Analytics':'Reports'} prospects={prospects} drafts={drafts} outreach={outreach} gmailMessages={gmailMessages}/>;
  if(route==='settings') return <SettingsPage/>;
  if(route==='website-audits') return <AuditPage prospects={prospects}/>;
  if(route==='inbox') return <InboxPage messages={gmailMessages} setMessages={setGmailMessages} businesses={businesses}/>;
  if(route==='email-outreach') return <OutreachPage businesses={businesses} prospects={prospects} setProspects={setProspects} drafts={drafts} setDrafts={setDrafts} outreach={outreach} setOutreach={setOutreach}/>;
  if(route==='outreach-history') return <HistoryPage businesses={businesses} prospects={prospects} outreach={outreach}/>;
  return <GenericPage route={route}/>;
}

function Header({title,sub,action}:{title:string;sub:string;action?:React.ReactNode}){return <div className="heading-row"><div><h1>{title}</h1><div className="muted">{sub}</div></div>{action}</div>}
function Kpi({label,value,detail}:{label:string;value:string;detail:string}){return <div className="card"><div className="kpi-label">{label}</div><div className="kpi-value">{value}</div><div className="muted">{detail}</div></div>}
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

function Dashboard({prospects,drafts,outreach,gmailMessages}:{prospects:Prospect[];drafts:Draft[];outreach:Outreach[];gmailMessages:GmailMessage[]}) {
  const now=new Date(); const today=now.toDateString();
  const greeting=now.getHours()<12?'Good morning':now.getHours()<18?'Good afternoon':'Good evening';
  const days=Array.from({length:7},(_,index)=>{const date=new Date(now);date.setHours(0,0,0,0);date.setDate(date.getDate()-(6-index));return date;});
  const dayCounts=days.map(date=>prospects.filter(p=>new Date(p.discoveredAt).toDateString()===date.toDateString()).length);
  const maxDayCount=Math.max(0,...dayCounts);
  const audited=prospects.filter(p=>p.audit);
  const incoming=gmailMessages.filter(message=>!message.labelIds.includes('SENT'));
  const recent=[
    ...prospects.map(p=>({at:new Date(p.discoveredAt).getTime(),text:`Prospect found: ${p.name}`})),
    ...outreach.filter(o=>o.sentAt).map(o=>({at:new Date(o.sentAt!).getTime(),text:`Email sent: ${prospects.find(p=>p.id===o.prospectId)?.name||'Prospect'}`})),
    ...incoming.map(message=>({at:Number(message.internalDate)||new Date(message.internalDate).getTime(),text:`Reply received: ${message.from||message.subject||'Gmail message'}`})),
  ].filter(item=>Number.isFinite(item.at)).sort((a,b)=>b.at-a.at).slice(0,5);
  const relative=(timestamp:number)=>{const minutes=Math.max(0,Math.floor((Date.now()-timestamp)/60000));if(minutes<1)return 'now';if(minutes<60)return `${minutes}m`;const hours=Math.floor(minutes/60);if(hours<24)return `${hours}h`;return `${Math.floor(hours/24)}d`;};
  const todayProspects=prospects.filter(p=>new Date(p.discoveredAt).toDateString()===today).length;
  const todayDrafts=drafts.filter(d=>new Date(d.generatedAt).toDateString()===today).length;
  const sentToday=outreach.filter(o=>o.status==='sent'&&o.sentAt&&new Date(o.sentAt).toDateString()===today).length;
  const pending=drafts.filter(d=>d.status==='pending').length;
  const followUps=drafts.filter(d=>d.status==='pending'&&d.isFollowUp).length;
  const unreadReplies=incoming.filter(message=>message.isRead===false).length;
  const rangeLabel=`${days[0].toLocaleDateString('en-GB',{day:'numeric',month:'short'})} – ${days[6].toLocaleDateString('en-GB',{day:'numeric',month:'short',year:'numeric'})}`;
  const tasks=[pending?`${pending} email${pending===1?'':'s'} awaiting approval`:null,followUps?`${followUps} follow-up${followUps===1?'':'s'} ready to review`:null,unreadReplies?`${unreadReplies} unread repl${unreadReplies===1?'y':'ies'} in Inbox`:null].filter((task):task is string=>Boolean(task));
  return <><Header title={`${greeting}, Alex 👋`} sub="Live figures from your saved LEADORA activity." action={<span className="btn secondary">{rangeLabel}</span>}/>
    <div className="grid kpis"><Kpi label="Prospects Found Today" value={String(todayProspects)} detail="Recorded today"/><Kpi label="Awaiting Approval" value={String(pending)} detail="Current queue"/><Kpi label="Emails Sent" value={String(outreach.filter(o=>o.status==='sent').length)} detail="Recorded all time"/><Kpi label="Average Audit Score" value={audited.length?`${Math.round(audited.reduce((total,p)=>total+(p.audit?.overallScore??0),0)/audited.length)}/100`:'—'} detail={audited.length?`${audited.length} completed audit${audited.length===1?'':'s'}`:'No audits yet'}/></div>
    <div className="grid dashboard-grid"><div className="card"><b>Prospects Found · Last 7 Days</b>{maxDayCount===0?<p className="muted" style={{marginTop:28}}>No prospects recorded in this period.</p>:<><div className="chart-bars">{dayCounts.map((count,index)=><div key={days[index].toISOString()} className="bar" title={`${count} prospect${count===1?'':'s'}`} style={{height:`${Math.max(6,(count/maxDayCount)*100)}%`}}/>)}</div><div style={{display:'flex',justifyContent:'space-between'}}>{days.map(date=><span className="muted" key={date.toISOString()}>{date.toLocaleDateString('en-GB',{weekday:'short'})}</span>)}</div></>}</div>
    <div className="card"><b>Recent Activity</b>{recent.length?<div className="activity" style={{marginTop:18}}>{recent.map(item=><div className="activity-row" key={`${item.at}-${item.text}`}><i className="dot"/><span>{item.text}</span><span className="muted">{relative(item.at)}</span></div>)}</div>:<p className="muted" style={{marginTop:28}}>No recorded activity yet.</p>}</div></div>
    <div className="grid dashboard-grid"><div className="card"><b>Today’s Prospecting</b><div className="grid kpis" style={{gridTemplateColumns:'repeat(4,1fr)',marginTop:14}}><Kpi label="Prospects found" value={String(todayProspects)} detail="Today"/><Kpi label="Emails drafted" value={String(todayDrafts)} detail="Today"/><Kpi label="Pending approval" value={String(pending)} detail="Current queue"/><Kpi label="Sent today" value={String(sentToday)} detail="Today"/></div></div><div className="card"><b>Tasks Due Now</b>{tasks.length?tasks.map(task=><div key={task} style={{display:'flex',gap:10,marginTop:16,fontSize:12}}><ClipboardCheck size={15}/><span>{task}</span></div>):<p className="muted" style={{marginTop:28}}>No recorded tasks are currently due.</p>}</div></div>
  </>;
}

function Leads({leads,setLeads}:{leads:Lead[];setLeads:(v:Lead[])=>void}) {
  const [filter,setFilter]=useState('All Leads'); const filters=['All Leads','New','Contacted','Qualified','Proposal','Won','Lost'];
  function add(){const name=prompt('Lead name')?.trim(); if(!name)return; const email=prompt('Email')?.trim()||''; if(email&&!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)){alert('Enter a valid email address.');return;} setLeads([{name,email,company:prompt('Company')?.trim()||'New company',status:'New',source:'Manual',created:new Date().toLocaleString('en-GB')},...leads]);}
  const visible=filter==='All Leads'?leads:leads.filter(lead=>lead.status===filter);
  return <><Header title="Leads" sub="Manage and track all your leads." action={<button className="btn" onClick={add}>+ Add Lead</button>}/><div className="tabs">{filters.map(x=><button className={`tab ${filter===x?'active':''}`} onClick={()=>setFilter(x)} key={x}>{x}</button>)}</div><DataTable headers={['Name','Email','Company','Status','Source','Created']} rows={visible.map(l=>[l.name,l.email||'—',l.company,<span className="badge" key={`${l.email}-${l.status}`}>{l.status}</span>,l.source,l.created])}/></>;
}

function Contacts({contacts,setContacts}:{contacts:Contact[];setContacts:(v:Contact[])=>void}) {
 function add(){const name=prompt('Contact name')?.trim(); if(!name)return; const email=prompt('Email')?.trim()||''; if(email&&!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)){alert('Enter a valid email address.');return;} setContacts([{name,email,company:prompt('Company')?.trim()||'',phone:prompt('Phone')?.trim()||'',status:'Active'},...contacts]);}
 return <><Header title="Contacts" sub="Your complete customer and prospect directory." action={<button className="btn" onClick={add}>+ Add Contact</button>}/><DataTable headers={['Name','Email','Company','Phone','Status']} rows={contacts.map(c=>[c.name,c.email,c.company,c.phone,<span className="badge" key={c.name}>{c.status}</span>])}/></>;
}

function DataTable({headers,rows}:{headers:string[];rows:React.ReactNode[][]}) {return <div className="card table-wrap"><table><thead><tr>{headers.map(h=><th key={h}>{h}</th>)}</tr></thead><tbody>{rows.length?rows.map((r,i)=><tr key={i}>{r.map((v,j)=><td key={j}>{v}</td>)}</tr>):<tr><td colSpan={headers.length} className="muted" style={{textAlign:'center',padding:28}}>No records to show.</td></tr>}</tbody></table></div>}

function Pipelines({leads}:{leads:Lead[]}) { const stages=['New','Contacted','Qualified','Proposal']; return <><Header title="Pipeline" sub="Live stages from your saved CRM leads."/><div className="grid pipeline">{stages.map(stage=>{const stageLeads=leads.filter(lead=>lead.status===stage);return <div className="pipeline-col" key={stage}><div className="pipeline-title"><span>{stage}</span><span>{stageLeads.length}</span></div>{stageLeads.map((lead,index)=><div className="deal" key={`${lead.email}-${index}`}><b>{lead.company}</b><p className="muted">{lead.name}</p></div>)}{stageLeads.length===0&&<p className="muted" style={{fontSize:12}}>No leads in this stage.</p>}</div>})}</div></> }

function Automations(){return <><Header title="Automations" sub="Automation runs will appear here when configured."/><div className="card" style={{textAlign:'center',padding:40}}><Workflow size={30} color="#c9a84c"/><p><b>No automations configured</b></p><p className="muted">No template runs or invented performance figures are shown.</p></div></>}

function Reports({title,prospects,drafts,outreach,gmailMessages}:{title:string;prospects:Prospect[];drafts:Draft[];outreach:Outreach[];gmailMessages:GmailMessage[]}){
  const now=new Date();const days=Array.from({length:7},(_,index)=>{const date=new Date(now);date.setHours(0,0,0,0);date.setDate(date.getDate()-(6-index));return date;});
  const counts=days.map(date=>prospects.filter(p=>new Date(p.discoveredAt).toDateString()===date.toDateString()).length);const max=Math.max(0,...counts);
  const sent=outreach.filter(item=>item.status==='sent').length;const replies=gmailMessages.filter(message=>!message.labelIds.includes('SENT')).length;const replyRate=sent?`${Math.min(100,Math.round((replies/sent)*1000)/10)}%`:'0%';
  const rangeLabel=`${days[0].toLocaleDateString('en-GB',{day:'numeric',month:'short'})} – ${days[6].toLocaleDateString('en-GB',{day:'numeric',month:'short',year:'numeric'})}`;
  const pending=drafts.filter(draft=>draft.status==='pending').length;const approved=drafts.filter(draft=>draft.status==='approved').length;
  return <><Header title={title} sub="Recorded outreach performance only—no template figures." action={<span className="btn secondary">{rangeLabel}</span>}/><div className="grid kpis"><Kpi label="Total Prospects" value={String(prospects.length)} detail="Recorded all time"/><Kpi label="Emails Sent" value={String(sent)} detail="Accepted by Gmail"/><Kpi label="Replies" value={String(replies)} detail="Imported from Gmail"/><Kpi label="Reply Rate" value={replyRate} detail="Replies ÷ emails sent"/></div><div className="grid dashboard-grid"><div className="card"><b>Prospects Found · Last 7 Days</b>{max===0?<p className="muted" style={{marginTop:28}}>No prospects recorded in this period.</p>:<><div className="chart-bars">{counts.map((count,index)=><div className="bar" key={days[index].toISOString()} title={`${count} prospect${count===1?'':'s'}`} style={{height:`${Math.max(6,(count/max)*100)}%`}}/>)}</div><div style={{display:'flex',justifyContent:'space-between'}}>{days.map(date=><span className="muted" key={date.toISOString()}>{date.toLocaleDateString('en-GB',{weekday:'short'})}</span>)}</div></>}</div><div className="card"><b>Current Outreach Funnel</b><div style={{display:'grid',gap:16,marginTop:24}}>{[['Prospects',prospects.length],['Drafts',drafts.length],['Awaiting approval',pending],['Approved',approved],['Sent',sent],['Replies',replies]].map(([label,value])=><div key={String(label)} style={{display:'flex',justifyContent:'space-between',borderBottom:'1px solid #eee',paddingBottom:10}}><span className="muted">{label}</span><b>{value}</b></div>)}</div></div></div></>}

function OutreachPage({businesses,prospects,setProspects,drafts,setDrafts,outreach,setOutreach}:{businesses:BusinessProfile[];prospects:Prospect[];setProspects:(v:Prospect[])=>void;drafts:Draft[];setDrafts:(v:Draft[])=>void;outreach:Outreach[];setOutreach:(v:Outreach[])=>void}) {
  const [businessId,setBusinessId]=useState(businesses[0]?.id||''); const [busy,setBusy]=useState(false); const [sending,setSending]=useState<string|null>(null); const [sendError,setSendError]=useState(''); const [website,setWebsite]=useState(''); const [progress,setProgress]=useState('');
  const workflow=getOutreachWorkflow(businessId) ?? getOutreachWorkflow('bryant-digital');
  const pending=drafts.filter(d=>(d.status==='pending'||d.status==='edited')&&d.businessId===businessId);
  const readyToSend=drafts.filter(d=>(d.status==='approved'||d.status==='send_failed')&&d.businessId===businessId);
  function selectBusiness(nextBusinessId:string) { setBusinessId(nextBusinessId); setBusy(false); setSending(null); setSendError(''); setWebsite(''); setProgress(''); }
  useEffect(()=>{
    const due = outreach.filter(o => o.status==='sent' && o.sentAt && Date.now()-new Date(o.sentAt).getTime() >= 3*24*60*60*1000 && !drafts.some(d=>d.prospectId===o.prospectId&&d.isFollowUp));
    if(!due.length)return;
    const followUps=due.map((o):Draft|null=>{const p=prospects.find(item=>item.id===o.prospectId);const b=businesses.find(item=>item.id===o.businessId);if(!p||!b)return null;const signature=b.signature.includes(CLIENT_CONTACT_PHONE)?b.signature:`${b.signature}\n${CLIENT_CONTACT_PHONE}`;return {id:`follow-up-${o.id}`,prospectId:p.id,businessId:b.id,subject:`Following up — ${p.name}`,body:`Hi there,\n\nI wanted to follow up on my earlier note. If improving ${b.services[0].toLowerCase()} is on your radar, I’d be happy to share a few relevant ideas — no pressure at all.\n\nWould a quick call be useful?\n\n${signature}`,callToAction:'Would a quick call be useful?',generatedAt:new Date().toISOString(),status:'pending',isFollowUp:true};}).filter((draft):draft is Draft=>Boolean(draft));
    if(followUps.length)setDrafts([...drafts,...followUps]);
  },[outreach,drafts,prospects,businesses,setDrafts]);
  const withClientContact=(body:string,business:BusinessProfile)=>body.includes(CLIENT_CONTACT_PHONE)?body:`${body.trim()}\n\n${business.signature.includes(CLIENT_CONTACT_PHONE)?business.signature:`${business.signature}\n${CLIENT_CONTACT_PHONE}`}`;
  const digitalOfferBody=(business:BusinessProfile,name:string,finding?:string)=>withClientContact(`Hi there,\n\nI took a quick look at the website for ${name}${finding?` and spotted one quick win: ${finding.replace(/\.$/,'').toLowerCase()}`:''}.\n\nHere’s my offer: a website and SEO audit, normally £49, free — with practical actions you can use straight away.\n\nIf you want help putting them into action, our recurring plans are month-to-month, with no long contract and low risk.\n\nWorth me sending the free audit over?\n\nhttps://bryantdigitalsolutions.com`,business);
  const cleaningOfferBody=(business:BusinessProfile,name:string,place:string)=>withClientContact(`Hi there,\n\nI came across ${name} in ${place||'Dorset'} and thought this might be useful.\n\nBryant & Co Cleaning provides reliable commercial cleaning with a tailored plan built around your opening hours and requirements.\n\nI can put together a free, no-obligation quote, with replies normally within one hour during business hours.\n\nWould you like me to price up an option?\n\nhttps://www.bryantandcocleaning.co.uk`,business);
  const constructionOfferBody=(business:BusinessProfile,name:string,place:string)=>withClientContact(`Hi there,\n\nI came across ${name} in ${place||'Dorset'} and thought this might be useful.\n\nBryant Construction Group handles repairs, maintenance and refurbishment across Bournemouth, Poole and Christchurch.\n\nWe can provide a free, clear quote before work starts, with no hidden extras.\n\nDo you have any upcoming property work we could quote for?\n\nhttps://bryantconstructiongroup.co.uk`,business);
  const teethPartnershipBody=(business:BusinessProfile,name:string,place:string)=>withClientContact(`Hi there,\n\nI came across ${name} in ${place||'Dorset'} and thought there could be a good local partnership fit.\n\nMr White provides professional, pain-free teeth whitening in Bournemouth from £69. I would love to explore a simple referral or cross-promotion partnership that could benefit both of our clients.\n\nWould you be open to a quick, no-obligation chat?\n\nhttps://teethwhiteningbournemouth.co.uk`,business);
  const legacyDigitalDraftCount=drafts.filter(draft=>draft.businessId==='bryant-digital'&&['pending','edited'].includes(draft.status)&&!draft.body.includes('month-to-month')).length;
  const legacyCleaningDraftCount=drafts.filter(draft=>draft.businessId==='bryant-cleaning'&&['pending','edited'].includes(draft.status)&&!draft.body.includes('within one hour during business hours')).length;
  const legacyConstructionDraftCount=drafts.filter(draft=>draft.businessId==='bryant-construction'&&['pending','edited'].includes(draft.status)&&!draft.body.includes('no hidden extras')).length;
  const legacyTeethDraftCount=drafts.filter(draft=>draft.businessId==='mr-white-teeth'&&['pending','edited'].includes(draft.status)&&!draft.body.includes('cross-promotion partnership')).length;
  function refreshDigitalDrafts(){
    const business=businesses.find(item=>item.id==='bryant-digital');if(!business)return;
    setDrafts(drafts.map(draft=>{if(draft.businessId!=='bryant-digital'||!['pending','edited'].includes(draft.status)||draft.body.includes('month-to-month'))return draft;const prospect=prospects.find(item=>item.id===draft.prospectId);if(!prospect)return draft;return {...draft,subject:`A quick website win for ${prospect.name}`,body:digitalOfferBody(business,prospect.name,prospect.audit?.notes[0]),callToAction:'Worth me sending the free audit over?',status:'pending' as const};}));
  }
  function refreshCleaningDrafts(){
    const business=businesses.find(item=>item.id==='bryant-cleaning');if(!business)return;
    setDrafts(drafts.map(draft=>{if(draft.businessId!=='bryant-cleaning'||!['pending','edited'].includes(draft.status)||draft.body.includes('within one hour during business hours'))return draft;const prospect=prospects.find(item=>item.id===draft.prospectId);if(!prospect)return draft;return {...draft,subject:`A cleaner, easier option for ${prospect.name}`,body:cleaningOfferBody(business,prospect.name,prospect.location),callToAction:'Would you like me to price up an option?',status:'pending' as const};}));
  }
  function refreshConstructionDrafts(){
    const business=businesses.find(item=>item.id==='bryant-construction');if(!business)return;
    setDrafts(drafts.map(draft=>{if(draft.businessId!=='bryant-construction'||!['pending','edited'].includes(draft.status)||draft.body.includes('no hidden extras'))return draft;const prospect=prospects.find(item=>item.id===draft.prospectId);if(!prospect)return draft;return {...draft,subject:`A clear quote for upcoming work at ${prospect.name}`,body:constructionOfferBody(business,prospect.name,prospect.location),callToAction:'Do you have any upcoming property work we could quote for?',status:'pending' as const};}));
  }
  function refreshTeethDrafts(){
    const business=businesses.find(item=>item.id==='mr-white-teeth');if(!business)return;
    setDrafts(drafts.map(draft=>{if(draft.businessId!=='mr-white-teeth'||!['pending','edited'].includes(draft.status)||draft.body.includes('cross-promotion partnership'))return draft;const prospect=prospects.find(item=>item.id===draft.prospectId);if(!prospect)return draft;return {...draft,subject:`A local partnership idea for ${prospect.name}`,body:teethPartnershipBody(business,prospect.name,prospect.location),callToAction:'Would you be open to a quick, no-obligation chat?',status:'pending' as const};}));
  }
  async function discoverDigitalProspects() {
    const business=businesses.find(b=>b.id===businessId); if(!business)return;
    setBusy(true); setSendError(''); setProgress('Finding public Dorset prospects…');
    try {
      const existingForBusiness=prospects.filter(p=>p.businessId===business.id);
      const response=await fetch('/api/prospects/discover',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({limit:10,companyId:business.id,excludeEmails:existingForBusiness.map(p=>p.email).filter(Boolean),excludeWebsites:existingForBusiness.map(p=>p.website).filter(Boolean)})}); const result=await response.json(); if(!response.ok)throw new Error(result.error||'Public directory search failed.');
      const known=new Set(prospects.map(p=>p.website.toLowerCase())); const candidates=(result.prospects as Array<{name:string;email:string;website:string;phone:string;location:string;industry:string;contactUrl:string;googleMapsUrl:string}>).filter(item=>!known.has(item.website.toLowerCase())); const created:Prospect[]=[];
      for(let offset=0;offset<candidates.length&&created.length<10;offset+=4){
        const batch=candidates.slice(offset,offset+4);setProgress(`Checking websites ${offset+1}–${Math.min(offset+batch.length,candidates.length)} of ${candidates.length} · ${created.length} prospects ready…`);
        const checked=await Promise.all(batch.map(async item=>{try {const auditResponse=await fetch('/api/leads/audit',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({website:item.website})});const audited=await auditResponse.json();if(!auditResponse.ok)throw new Error();const contactEmail=audited.contactEmail||item.email;if(!contactEmail)return null;const audit=audited.audit as Audit;const opportunity=audit.notes.length?`The audit found ${audit.notes.slice(0,2).join(' and ').toLowerCase()}.`:'The website has a solid foundation and may benefit from a focused growth review.';return {id:`${business.id}-${crypto.randomUUID()}`,businessId:business.id,name:audited.businessName||item.name,website:audited.website||item.website,email:contactEmail,phone:audited.phoneNumber||item.phone,location:item.location,industry:item.industry,contactUrl:audited.contactPageUrl||item.contactUrl,googleMapsUrl:item.googleMapsUrl,score:audit.overallScore,reasons:[opportunity,'A public business email was found on the website or its contact page.'],discoveredAt:new Date().toISOString(),contacted:false,audit,recommendedService:workflow.recommendedService,confidence:Math.max(40,Math.min(95,100-audit.overallScore))} satisfies Prospect;}catch{if(!item.email)return null;return {id:`${business.id}-${crypto.randomUUID()}`,businessId:business.id,name:item.name,website:item.website,email:item.email,phone:item.phone,location:item.location,industry:item.industry,contactUrl:item.contactUrl,googleMapsUrl:item.googleMapsUrl,score:50,reasons:['Public business contact details were published in an OpenStreetMap listing.','The website audit was unavailable, so this draft makes no audit claim.'],discoveredAt:new Date().toISOString(),contacted:false,recommendedService:workflow.recommendedService,confidence:50} satisfies Prospect;}}));
        const available=checked.filter(Boolean) as Prospect[];
        created.push(...available.slice(0,10-created.length));
      }
      if(!created.length){setSendError('No additional new Dorset prospects are available from the current public directory results. Existing businesses were skipped to prevent duplicates.');return;}
      const newDrafts=created.map(p=>{const note=p.audit?.notes[0];return {id:`draft-${p.id}`,prospectId:p.id,businessId:business.id,subject:`A quick website win for ${p.name}`,body:digitalOfferBody(business,p.name,note),callToAction:'Worth me sending the free audit over?',generatedAt:new Date().toISOString(),status:'pending'} satisfies Draft});
      setProspects([...prospects,...created]);setDrafts([...drafts,...newDrafts]);
    }catch(error){setSendError(error instanceof Error?error.message:'Public directory search failed.');}finally{setBusy(false);setProgress('');}
  }
  async function discover() {
    const business=businesses.find(b=>b.id===businessId); if(!business)return;
    if(workflow.workflowType==='dorset-prospecting'){
      setBusy(true); setSendError('');
      try {
        const existingForBusiness=prospects.filter(p=>p.businessId===business.id);
        const response=await fetch('/api/prospects/discover',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({limit:10,companyId:business.id,excludeEmails:existingForBusiness.map(p=>p.email).filter(Boolean),excludeWebsites:existingForBusiness.map(p=>p.website).filter(Boolean)})});
        const result=await response.json(); if(!response.ok) throw new Error(result.error||'Public directory search failed.');
        const existingEmails=new Set(prospects.map(p=>p.email.toLowerCase()));
        const found=(result.prospects as Array<{name:string;email:string;website:string;phone:string;location:string;industry:string;contactUrl:string;googleMapsUrl:string;proposal:{subject:string;body:string;callToAction:string}}>).filter(item=>!existingEmails.has(item.email.toLowerCase()));
        if(!found.length){setSendError('No additional new Dorset prospects are available from the current public directory results. Existing businesses were skipped to prevent duplicates.');return;}
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
      const draft:Draft={id:`draft-${prospect.id}`,prospectId:prospect.id,businessId:business.id,subject:`A quick website win for ${prospect.name}`,body:digitalOfferBody(business,prospect.name,audit.notes[0]),callToAction:'Worth me sending the free audit over?',generatedAt:new Date().toISOString(),status:'pending'};
      setProspects([...prospects,prospect]); setDrafts([...drafts,draft]);
    } catch(error) { setSendError(error instanceof Error?error.message:'Website analysis failed.'); } finally {setBusy(false);}
  }
  function approve(id:string){setSendError('');setDrafts(drafts.map(d=>d.id===id?{...d,status:'approved',lastError:undefined}:d));}
  function edit(draft:Draft){const subject=prompt('Edit subject',decodeHtmlEntities(draft.subject));if(subject===null)return;const body=prompt('Edit email body',decodeHtmlEntities(draft.body));if(body===null)return;if(!subject.trim()||!body.trim()){setSendError('Subject and email body cannot be empty.');return;}setDrafts(drafts.map(item=>item.id===draft.id?{...item,subject:subject.trim(),body:body.trim(),status:'pending',lastError:undefined}:item));}
  function remove(id:string){if(confirm('Delete this draft from the approval queue?'))setDrafts(drafts.filter(d=>d.id!==id));}
  async function send(id:string){
    const d=drafts.find(x=>x.id===id); const p=prospects.find(x=>x.id===d?.prospectId);
    if(!d||!p)return;
    if(!['approved','send_failed'].includes(d.status)||sending)return;
    if(!isPublicBusinessEmail(p.email)){setSendError('A valid public business email is required before sending.');return;}
    const mappings=JSON.parse(localStorage.getItem('leadora-business-email-mappings')||'{}') as Record<string,string>;
    const from=mappings[d.businessId]?.trim()||DEFAULT_BUSINESS_EMAIL_MAPPINGS[d.businessId]; if(!from){setSendError('Add a mapped business email in Settings before sending.');return;}
    setSending(id);setSendError('');
    try {
      const cleanSubject=decodeHtmlEntities(d.subject); const cleanBody=decodeHtmlEntities(d.body);
      const response=await fetch('/api/gmail/send',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({from,to:p.email,subject:cleanSubject,body:cleanBody,brandId:d.businessId,isFollowUp:d.isFollowUp})});
      const result=await response.json(); if(!response.ok)throw new Error(result.error||'Gmail send failed.');
      if(drafts.some(x=>x.status==='sent'&&x.id===id))return;
      const now=new Date();
      const record:Outreach={id:`out-${crypto.randomUUID()}`,prospectId:p.id,businessId:d.businessId,date:now.toLocaleDateString(),time:now.toLocaleTimeString([], {hour:'2-digit',minute:'2-digit'}),status:'sent',gmailMessageId:result.id,sentAt:now.toISOString()};
      setDrafts(drafts.map(x=>x.id===id?{...x,subject:cleanSubject,body:cleanBody,status:'sent',gmailMessageId:result.id,lastError:undefined}:x)); setProspects(prospects.map(x=>x.id===p.id?{...x,name:decodeHtmlEntities(x.name),contacted:true}:x)); setOutreach([...outreach,record]);
    } catch(e) { const message=e instanceof Error?e.message:'Gmail send failed.'; setSendError(message); setDrafts(drafts.map(x=>x.id===id?{...x,status:'send_failed',lastError:message}:x)); } finally { setSending(null); }
  }
  const prospectMap = new Map(prospects.map(p=>[p.id,p])); const businessMap = new Map(businesses.map(b=>[b.id,b]));
  const selected=businesses.find(b=>b.id===businessId);
  const workflowInputs=workflow.inputFields.map(field=><label className="form-row" key={field.id} style={{display:'block',margin:0,minWidth:260,fontSize:12}}>{field.label}<input className="field" type="url" value={website} placeholder={field.placeholder} onChange={e=>setWebsite(e.target.value)}/></label>);
  return <><Header title={workflow.title} sub={workflow.description} action={<div style={{display:'flex',gap:8,alignItems:'flex-end',flexWrap:'wrap'}}><select aria-label="Outreach company" className="field" style={{margin:0,width:220}} value={businessId} onChange={e=>selectBusiness(e.target.value)}>{businesses.map(b=><option key={b.id} value={b.id}>{b.name}</option>)}</select>{workflowInputs}{businessId==='bryant-digital'&&legacyDigitalDraftCount>0&&<button className="btn secondary" onClick={refreshDigitalDrafts}>Apply new template to {legacyDigitalDraftCount} draft{legacyDigitalDraftCount===1?'':'s'}</button>}{businessId==='bryant-cleaning'&&legacyCleaningDraftCount>0&&<button className="btn secondary" onClick={refreshCleaningDrafts}>Apply cleaning template to {legacyCleaningDraftCount} draft{legacyCleaningDraftCount===1?'':'s'}</button>}{businessId==='bryant-construction'&&legacyConstructionDraftCount>0&&<button className="btn secondary" onClick={refreshConstructionDrafts}>Apply construction template to {legacyConstructionDraftCount} draft{legacyConstructionDraftCount===1?'':'s'}</button>}{businessId==='mr-white-teeth'&&legacyTeethDraftCount>0&&<button className="btn secondary" onClick={refreshTeethDrafts}>Apply teeth template to {legacyTeethDraftCount} draft{legacyTeethDraftCount===1?'':'s'}</button>}{businessId==='bryant-digital'&&<button className="btn secondary" onClick={discoverDigitalProspects} disabled={busy}>Find up to 10 Dorset prospects</button>}<button className="btn" onClick={discover} disabled={busy}>{busy?(progress|| (workflow.websiteAuditEnabled?'Analysing…':'Finding…')):workflow.buttonText}</button></div>}/>
  <div className="card" style={{marginBottom:16}}><b>{selected?.name} workflow</b><p className="muted" style={{marginBottom:8}}>Lead source: {workflow.leadSource} · Proposal: {workflow.proposalTemplate.replace('-', ' ')} · Website audit: {workflow.websiteAuditEnabled?'enabled':'disabled'}</p><ol style={{margin:'0 0 0 18px',padding:0,fontSize:13,lineHeight:1.7}}>{workflow.steps.map(step=><li key={step}>{step}</li>)}</ol></div>
  {sendError&&<div role="alert" className="card" style={{color:'#b42318',marginBottom:16}}>{sendError}</div>}<div className="card" style={{marginBottom:16}}><b><Sparkles size={15} style={{verticalAlign:'middle',marginRight:6}}/>Approval queue</b><span className="muted" style={{marginLeft:10}}>{pending.length} pending for {workflow.companyName} · emails are never sent automatically</span></div>{pending.length===0?<div className="card" style={{textAlign:'center',padding:40}}><ClipboardCheck size={30} color="#c9a84c"/><p><b>No emails awaiting approval</b></p><p className="muted">{workflow.websiteAuditEnabled?'Analyse a public business website to create the first audit and proposal.':'Find public Dorset prospects to draft the first proposal.'}</p></div>:<div className="grid">{pending.map(d=>{const p=prospectMap.get(d.prospectId);const b=businessMap.get(d.businessId);if(!p||!b)return null;const validEmail=isPublicBusinessEmail(p.email);return <div className="card" key={d.id}><div style={{display:'flex',justifyContent:'space-between',gap:15}}><div><b>{decodeHtmlEntities(p.name)}</b><div className="muted">{b.name} · {validEmail?p.email:'No valid public email'} · {p.audit?`Audit ${p.score}/100`:`Opportunity ${p.score}/100`}</div></div><span className="badge">Pending approval</span></div>{d.businessId==='bryant-digital'&&<div className="digital-email-preview"><img src="https://bryantdigitalsolutions.com/assets/logo-bds.jpg" width="168" height="56" alt="Bryant Digital Solutions"/><div><b>Free Website &amp; SEO Audit</b><span>Normally £49 · Month-to-month plans · No long contract</span></div></div>}{d.businessId==='bryant-cleaning'&&<div className="cleaning-email-preview"><img src="https://www.bryantandcocleaning.co.uk/images/logo.png" width="92" height="92" alt="Bryant & Co Cleaning"/><div><b>Free Commercial Cleaning Quote</b><span>No obligation · Tailored around your hours · Reply within one hour during business hours</span></div></div>}{d.businessId==='bryant-construction'&&<div className="construction-email-preview"><img src="https://bryantconstructiongroup.co.uk/assets/logo.png" width="112" height="96" alt="Bryant Construction Group"/><div><b>Free, Clear Construction Quote</b><span>No obligation · Clear pricing before work starts · No hidden extras</span></div></div>}{d.businessId==='mr-white-teeth'&&<div className="teeth-email-preview"><img src="https://teethwhiteningbournemouth.co.uk/images/logo.png" width="104" height="104" alt="Mr White Teeth Whitening"/><div><b>A Local Smile Partnership</b><span>Professional, pain-free whitening from £69 · No-obligation partnership chat</span></div></div>}<h3 style={{fontSize:14,marginBottom:8}}>{decodeHtmlEntities(d.subject)}</h3><p style={{whiteSpace:'pre-line',fontSize:13,lineHeight:1.6}}>{decodeHtmlEntities(d.body)}</p><div className="muted" style={{marginBottom:12}}>Opportunity: {p.recommendedService} · Confidence {p.confidence}% · {p.reasons.map(decodeHtmlEntities).join(' ')}</div><div style={{display:'flex',gap:8,flexWrap:'wrap'}}><button className="btn" onClick={()=>approve(d.id)} disabled={!validEmail}><ClipboardCheck size={14}/> Approve</button><button className="btn secondary" onClick={()=>edit(d)}><Pencil size={14}/> Edit</button><button className="btn secondary" onClick={()=>remove(d.id)}><Trash2 size={14}/> Delete</button></div>{!validEmail&&<p style={{color:'#b42318',fontSize:12}}>A valid public recipient email is required before approval.</p>}</div>})}</div>}{readyToSend.length>0&&<div className="card" style={{marginTop:16}}><b>Approved and ready to send</b>{readyToSend.map(d=>{const readyProspect=prospectMap.get(d.prospectId);const validEmail=isPublicBusinessEmail(readyProspect?.email||'');return <div key={d.id} style={{display:'flex',alignItems:'center',justifyContent:'space-between',gap:16,padding:'12px 0',borderBottom:'1px solid #eee'}}><span>{decodeHtmlEntities(readyProspect?.name||'Prospect')}<span className="muted"> · {decodeHtmlEntities(d.subject)}</span>{!validEmail&&<span style={{display:'block',color:'#b42318',fontSize:12}}>No valid public recipient email. Sending is blocked.</span>}{d.status==='send_failed'&&<span style={{display:'block',color:'#b42318',fontSize:12}}>Last send failed: {d.lastError||'Please retry.'}</span>}</span><button className="btn" onClick={()=>send(d.id)} disabled={sending!==null||!validEmail}><Send size={14}/> {sending===d.id?'Sending…':d.status==='send_failed'?'Retry send':'Send now'}</button></div>})}</div>}</>;

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
      const stored=JSON.parse(localStorage.getItem('leadora-business-email-mappings')||'{}') as Record<string,string>; const mappings={...DEFAULT_BUSINESS_EMAIL_MAPPINGS,...stored};
      const response=await fetch('/api/gmail/sync',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({mappings:Object.fromEntries(Object.entries(mappings).map(([id,address])=>[id,address?[address]:[]]))})});
      const data=await response.json(); if(!response.ok) throw new Error(data.error||'Synchronisation failed.');
      const existing=new Map(messages.map(m=>[m.id,m])); (data.messages as GmailMessage[]).forEach(m=>existing.set(m.id,m)); setMessages([...existing.values()]);
    } catch (e) { setError(e instanceof Error?e.message:'Synchronisation failed.'); } finally { setBusy(false); }
  }
  const visible=messages.filter(m=>filter==='all'||filter==='unread'&&!m.isRead||filter==='replies'&&!m.labelIds.includes('SENT')||filter==='unassigned'&&!m.businessId);
  return <><Header title="Inbox & conversations" sub="Gmail conversations matched to your prospects and businesses." action={<button className="btn" onClick={sync} disabled={busy}><RefreshCw size={14}/> {busy?'Syncing…':'Sync now'}</button>}/>{error&&<div role="alert" className="card" style={{color:'#b42318',marginBottom:16}}>{error}</div>}<div className="tabs">{[['all','All'],['unread','Unread'],['replies','Replies'],['unassigned','Unassigned']].map(([key,label])=><button className={`tab ${filter===key?'active':''}`} key={key} onClick={()=>setFilter(key)}>{label}</button>)}</div>{visible.length===0?<div className="card" style={{textAlign:'center',padding:40}}><Inbox size={30} color="#c9a84c"/><p><b>No matching conversations</b></p><p className="muted">{filter==='all'?'Connect Gmail in Settings, then choose Sync now.':'Try another filter or synchronise Gmail again.'}</p></div>:<div className="grid">{visible.map(m=><div className="card" key={m.id}><div style={{display:'flex',justifyContent:'space-between',gap:12}}><div><b>{decodeHtmlEntities(m.subject||'(no subject)')}</b><div className="muted">{m.from} · {new Date(Number(m.internalDate)||m.internalDate).toLocaleString()}</div></div><span className="badge">{businesses.find(b=>b.id===m.businessId)?.name||'Business not identified'}</span></div><p style={{whiteSpace:'pre-line',fontSize:13,lineHeight:1.5}}>{decodeHtmlEntities(m.body.slice(0,320))}{m.body.length>320?'…':''}</p><div className="muted">Thread {m.threadId} · {m.labelIds.includes('SENT')?'Sent outreach':'Incoming reply'}</div></div>)}</div>}</>;
}

function SettingsPage(){
  const [daily,setDaily]=useState('10'); const [style,setStyle]=useState('Professional and warm'); const [saved,setSaved]=useState('');
  const [gmail,setGmail]=useState<GmailStatus>({connected:false}); const [mapping,setMapping]=useState<Record<string,string>>(DEFAULT_BUSINESS_EMAIL_MAPPINGS); const [syncing,setSyncing]=useState(false);
  const [system,setSystem]=useState<SystemStatus|null>(null);
  useEffect(()=>{fetchIntegrationStatus().then(({gmailStatus,systemStatus})=>{setGmail(gmailStatus); setSystem({...systemStatus.statuses,connectedAccount:{ok:gmailStatus.connected,detail:gmailStatus.connected?`Connected · ${gmailStatus.emailAddress}`:'No Gmail account connected'},gmailApi:{ok:gmailStatus.connected,detail:gmailStatus.connected?'Profile check passed':gmailStatus.error??'Gmail status is unavailable'}});});},[]);
  useEffect(()=>{const savedMapping=localStorage.getItem('leadora-business-email-mappings'); if(savedMapping) try{setMapping({...DEFAULT_BUSINESS_EMAIL_MAPPINGS,...JSON.parse(savedMapping)});}catch{}},[]);
  useEffect(()=>{const preferences=localStorage.getItem('leadora-outreach-settings');if(preferences)try{const parsed=JSON.parse(preferences) as {dailyLimit?:number;style?:string};if(parsed.dailyLimit)setDaily(String(parsed.dailyLimit));if(parsed.style)setStyle(parsed.style);}catch{}},[]);
  function save(){const limit=Number(daily); if(!Number.isInteger(limit)||limit<1){setSaved('Enter a positive whole number');return;} try { localStorage.setItem('leadora-outreach-settings',JSON.stringify({dailyLimit:limit,style})); setSaved('Saved'); } catch { setSaved('Unable to save preferences'); }}
  function saveMappings(){if(Object.values(mapping).some(address=>!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(address.trim()))){setSaved('Enter a valid email address for every company');return;}localStorage.setItem('leadora-business-email-mappings',JSON.stringify(mapping));setSaved('Mappings saved');}
  async function disconnect(){if(!confirm('Disconnect Gmail from LEADORA? Approved drafts will remain saved.'))return;setSyncing(true);setSaved('');try{const response=await fetch('/api/gmail/disconnect',{method:'POST'});if(!response.ok)throw new Error();setGmail({connected:false});setSaved('Gmail disconnected');}catch{setSaved('Unable to disconnect Gmail');}finally{setSyncing(false);}}
  const checks=[['cloudflare','Cloudflare deployment'],['backend','Backend API'],['database','Database'],['googleOAuth','Google OAuth'],['gmailApi','Gmail API'],['connectedAccount','Connected account']] as const;
  return <><Header title="Settings" sub="Manage integrations, sender identities and outreach preferences."/><div className="card" style={{marginBottom:16}}><b>System Status</b><div className="grid" style={{gridTemplateColumns:'repeat(auto-fit,minmax(180px,1fr))',marginTop:12}}>{checks.map(([key,label])=>{const check=system?.[key]; return <div key={key} style={{display:'flex',gap:8,alignItems:'flex-start'}}><span style={{color:check?.ok?'#16803c':'#b42318',fontWeight:700}}>{check?.ok?'✓':'✕'}</span><div><b>{label}</b><div className="muted" style={{fontSize:12}}>{check?.detail??'Checking…'}</div></div></div>})}</div></div><div className="grid dashboard-grid"><div className="card"><b>Gmail integration</b><p className="muted">Send only approved outreach and synchronise incoming replies securely.</p>{gmail.connected?<><div className="badge" style={{margin:'8px 0'}}>Connected · {gmail.emailAddress}</div><p className="muted">Tokens are handled server-side. Last synchronisation is shown in Inbox.</p><button className="btn secondary" onClick={()=>location.href='/api/gmail/auth'}>Reconnect Gmail</button><button className="btn secondary" style={{marginLeft:8}} onClick={disconnect} disabled={syncing}>{syncing?'Disconnecting…':'Disconnect'}</button></>:<button className="btn" onClick={()=>location.href='/api/gmail/auth'}>Connect Gmail</button>}{gmail.error&&<p style={{color:'#b42318',fontSize:12}}>{gmail.code&&<><b>{gmail.code}</b> — </>}{gmail.error}</p>}</div><div className="card"><b>Business email mappings</b><p className="muted">Choose the verified Gmail alias used to send for each company.</p>{seedBusinesses.map(({id,name})=><label className="form-row" style={{display:'block',fontSize:12}} key={id}>{name}<input className="field" type="email" value={mapping[id]??''} placeholder="info@example.com" onChange={e=>setMapping({...mapping,[id]:e.target.value})}/></label>)}<button className="btn" onClick={saveMappings}>Save mappings</button></div><div className="card"><b>Outreach preferences</b><label className="form-row" style={{display:'block',fontSize:12}}>Daily prospect limit<input className="field" type="number" min="1" max="100" value={daily} onChange={e=>setDaily(e.target.value)}/></label><label className="form-row" style={{display:'block',fontSize:12}}>Writing style<select className="field" value={style} onChange={e=>setStyle(e.target.value)}><option>Professional and warm</option><option>Friendly and helpful</option><option>Clear and consultative</option></select></label><button className="btn" onClick={save}>Save preferences</button>{saved&&<span role="status" className="up" style={{marginLeft:10}}>{saved}</span>}</div><div className="card"><b>Workspace access</b><p className="muted">This deployment does not provide an in-app password-management service. Access protection should be managed at the Cloudflare deployment layer.</p><p className="muted">No password form is shown because it would not change a real account.</p></div>{gmail.diagnostics&&<div className="card"><b>Developer diagnostics</b><p className="muted">Development only. Secret values are never displayed.</p>{gmail.diagnostics.map(item=><div key={item.name} style={{display:'flex',justifyContent:'space-between',fontSize:12,padding:'4px 0'}}><span>{item.name}</span><span style={{color:item.configured?'#16803c':'#b42318'}}>{item.configured?'Present':'Missing'}</span></div>)}</div>}</div></>}

function GenericPage({route}:{route:string}) { const config:Record<string,[string,string,string[]]>={
 'companies':['Companies','Manage organisations and account relationships.',['Company','Primary Contact','Industry','Revenue','Status']],
 'deals':['Deals','Track value, probability and expected close dates.',['Deal','Company','Value','Probability','Stage']],
 'email-outreach':['Email Outreach','Create, send and measure targeted campaigns.',['Campaign','Recipients','Open Rate','Reply Rate','Status']],
 'website-audits':['Website Audits','Run SEO, performance and conversion audits.',['Website','Score','SEO','Performance','Status']],
 'ai-agents':['AI Agents','Deploy autonomous agents across your sales operation.',['Agent','Purpose','Runs','Success Rate','Status']],
 };
 const [title,sub,headers]=config[route]??['LEADORA','Your sales operating system.',['Item','Owner','Performance','Status']];
 return <><Header title={title} sub={sub}/><DataTable headers={headers} rows={[]}/><div className="card" style={{textAlign:'center',marginTop:16,padding:32}}><p><b>No recorded {title.toLowerCase()} yet</b></p><p className="muted">Real records will appear here when this module is connected.</p></div></>;
}
