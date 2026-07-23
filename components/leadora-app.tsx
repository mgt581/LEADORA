'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import {
  LayoutDashboard, Users, ContactRound, Building2, Handshake, Columns3,
  Mail, SearchCheck, Bot, Workflow, ChartNoAxesCombined, FileChartColumn,
  Settings, Menu, Bell, Plus, LogOut, Target
} from 'lucide-react';

const BASE = process.env.NODE_ENV === 'production' && typeof window !== 'undefined' && window.location.pathname.startsWith('/LEADORA') ? '/LEADORA' : '';

type Lead = { name:string; email:string; company:string; status:string; source:string; created:string };
type Contact = { name:string; email:string; company:string; phone:string; status:string };

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

const nav = [
  ['dashboard','Dashboard',LayoutDashboard],['leads','Leads',Users],['contacts','Contacts',ContactRound],
  ['companies','Companies',Building2],['deals','Deals',Handshake],['pipelines','Pipelines',Columns3],
  ['email-outreach','Email Outreach',Mail],['website-audits','Website Audits',SearchCheck],
  ['ai-agents','AI Agents',Bot],['automations','Automations',Workflow],['analytics','Analytics',ChartNoAxesCombined],
  ['reports','Reports',FileChartColumn],['settings','Settings',Settings],
] as const;

function useStoredState<T>(key:string, initial:T) {
  const [value,setValue] = useState<T>(initial);
  useEffect(() => { const saved=localStorage.getItem(key); if(saved) try { setValue(JSON.parse(saved)); } catch {} },[key]);
  useEffect(() => { localStorage.setItem(key,JSON.stringify(value)); },[key,value]);
  return [value,setValue] as const;
}

export function LeadoraApp({ route='dashboard' }: { route?:string }) {
  const [auth,setAuth] = useStoredState('leadora-auth',false);
  const [leads,setLeads] = useStoredState<Lead[]>('leadora-leads',seedLeads);
  const [contacts,setContacts] = useStoredState<Contact[]>('leadora-contacts',seedContacts);
  const [menu,setMenu] = useState(false);

  if(route==='login' || !auth) return <Login onLogin={()=>setAuth(true)} />;
  const active = nav.find(n=>n[0]===route) ?? nav[0];

  return <div className="shell">
    <aside className={`sidebar ${menu?'open':''}`}>
      <div className="brand"><div className="brand-mark">L◉</div><span>LEADORA</span></div>
      <nav className="nav">{nav.map(([slug,label,Icon])=><Link key={slug} href={`${BASE}/${slug}/`} className={`nav-link ${route===slug?'active':''}`} onClick={()=>setMenu(false)}><Icon size={16}/><span>{label}</span></Link>)}</nav>
      <button className="sidebar-user" onClick={()=>setAuth(false)}><div className="avatar">AB</div><div><b>Alex Bryant</b><br/><span style={{color:'#8792a3'}}>Admin · Sign out</span></div><LogOut size={14}/></button>
    </aside>
    <main className="main">
      <header className="topbar">
        <button className="btn secondary mobile-menu" onClick={()=>setMenu(!menu)} aria-label="Open navigation"><Menu size={18}/></button>
        <input className="search" placeholder="Search everything…" />
        <div style={{display:'flex',alignItems:'center',gap:13}}><button className="btn" aria-label="Create"><Plus size={16}/></button><Bell size={18}/><div className="avatar">AB</div></div>
      </header>
      <section className="content"><Page route={active[0]} leads={leads} setLeads={setLeads} contacts={contacts} setContacts={setContacts}/></section>
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

function Page({route,leads,setLeads,contacts,setContacts}:{route:string;leads:Lead[];setLeads:(v:Lead[])=>void;contacts:Contact[];setContacts:(v:Contact[])=>void}) {
  if(route==='dashboard') return <Dashboard leads={leads}/>;
  if(route==='leads') return <Leads leads={leads} setLeads={setLeads}/>;
  if(route==='contacts') return <Contacts contacts={contacts} setContacts={setContacts}/>;
  if(route==='pipelines') return <Pipelines leads={leads}/>;
  if(route==='automations') return <Automations/>;
  if(route==='analytics'||route==='reports') return <Reports title={route==='analytics'?'Analytics':'Reports'}/>;
  if(route==='settings') return <SettingsPage/>;
  return <GenericPage route={route}/>;
}

function Header({title,sub,action}:{title:string;sub:string;action?:React.ReactNode}){return <div className="heading-row"><div><h1>{title}</h1><div className="muted">{sub}</div></div>{action}</div>}
function Kpi({label,value,change}:{label:string;value:string;change:string}){return <div className="card"><div className="kpi-label">{label}</div><div className="kpi-value">{value}</div><div className="up">↑ {change} vs last 7 days</div></div>}

function Dashboard({leads}:{leads:Lead[]}) {
  const bars=[48,72,55,79,62,88,42];
  return <><Header title="Good morning, Alex 👋" sub="Here’s what’s happening with your business today." action={<button className="btn secondary">Jul 14 – Jul 21, 2026</button>}/>
    <div className="grid kpis"><Kpi label="New Leads" value={String(248+leads.length)} change="18%"/><Kpi label="Open Deals" value="67" change="12%"/><Kpi label="Conversions" value="23" change="8%"/><Kpi label="Revenue" value="£12,540" change="22%"/></div>
    <div className="grid dashboard-grid"><div className="card"><b>Leads Overview</b><div className="chart-bars">{bars.map((h,i)=><div key={i} className="bar" style={{height:`${h}%`}}/>)}</div><div style={{display:'flex',justifyContent:'space-between'}}>{['Mon','Tue','Wed','Thu','Fri','Sat','Sun'].map(x=><span className="muted" key={x}>{x}</span>)}</div></div>
    <div className="card"><b>Recent Activity</b><div className="activity" style={{marginTop:18}}>{['New lead: Sarah Johnson','Email opened: Proposal Follow-up','Deal won: ACME Solutions','Task completed: Call with James','New lead: David Williams'].map((x,i)=><div className="activity-row" key={x}><i className="dot"/><span>{x}</span><span className="muted">{i+1}h</span></div>)}</div></div></div>
    <div className="grid dashboard-grid"><div className="card"><b>Top Performing Campaigns</b>{['Summer Promotion','Email Outreach','Social Media Ads'].map((x,i)=><div className="activity-row" style={{marginTop:17}} key={x}><Target size={16} color="#c9a84c"/><span>{x}<br/><span className="muted">{121-i*28} leads</span></span><span className="up">↑ {24-i*4}%</span></div>)}</div><div className="card"><b>Tasks Due Today</b>{['Follow up with Sarah','Call David Williams','Email proposal to ACME','Team meeting'].map((x,i)=><label key={x} style={{display:'flex',gap:10,marginTop:16,fontSize:12}}><input type="checkbox"/>{x}<span className="muted" style={{marginLeft:'auto'}}>{9+i}:00</span></label>)}</div></div>
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

function SettingsPage(){return <><Header title="Settings" sub="Manage your workspace, account and security."/><div className="tabs">{['Profile','Team','Billing','Integrations','Preferences','Security'].map((x,i)=><div className={`tab ${i===5?'active':''}`} key={x}>{x}</div>)}</div><div className="grid dashboard-grid"><div className="card"><b>Change Password</b>{['Current Password','New Password','Confirm New Password'].map(x=><label className="form-row" style={{display:'block',fontSize:12}} key={x}>{x}<input className="field" type="password"/></label>)}<button className="btn">Update Password</button></div><div className="card"><b>Two-Factor Authentication</b><p className="muted">Add an extra layer of security to your account.</p><span className="badge">Enabled</span><hr style={{border:0,borderTop:'1px solid #eee',margin:'24px 0'}}/><b>Active Sessions</b><p className="muted">Manage your active sessions across devices.</p><button className="btn secondary">Manage Sessions</button></div></div></>}

function GenericPage({route}:{route:string}) { const config:Record<string,[string,string,string[]]>={
 'companies':['Companies','Manage organisations and account relationships.',['Company','Primary Contact','Industry','Revenue','Status']],
 'deals':['Deals','Track value, probability and expected close dates.',['Deal','Company','Value','Probability','Stage']],
 'email-outreach':['Email Outreach','Create, send and measure targeted campaigns.',['Campaign','Recipients','Open Rate','Reply Rate','Status']],
 'website-audits':['Website Audits','Run SEO, performance and conversion audits.',['Website','Score','SEO','Performance','Status']],
 'ai-agents':['AI Agents','Deploy autonomous agents across your sales operation.',['Agent','Purpose','Runs','Success Rate','Status']],
 };
 const [title,sub,headers]=config[route]??['LEADORA','Your sales operating system.',['Item','Owner','Performance','Status']];
 const rows=useMemo(()=>Array.from({length:6},(_,i)=>headers.map((h,j)=>j===0?(route==='website-audits'?<a href={`${BASE}/index.html`}>{`${title.slice(0,-1)} ${i+1}`}</a>:`${title.slice(0,-1)} ${i+1}`):j===headers.length-1?<span className="badge" key={h}>Active</span>:j===2?`${82-i*4}%`:`${h} data`)),[headers,title,route]);
 return <><Header title={title} sub={sub} action={<button className="btn">+ New {title.slice(0,-1)}</button>}/><DataTable headers={headers} rows={rows}/></>;
}
