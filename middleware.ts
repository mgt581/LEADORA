import { NextRequest, NextResponse } from 'next/server';

function bytes(value:string){return Uint8Array.from(atob(value.replace(/-/g,'+').replace(/_/g,'/')),c=>c.charCodeAt(0));}
async function authenticated(request:NextRequest){
  try{
    const secret=process.env.LEADRALLY_SESSION_SECRET;if(!secret||secret.length<32)return false;
    const value=request.cookies.get('leadrally-session')?.value;if(!value)return false;
    const [payload,sig]=value.split('.');if(!payload||!sig)return false;
    const key=await crypto.subtle.importKey('raw',new TextEncoder().encode(secret),{name:'HMAC',hash:'SHA-256'},false,['verify']);
    if(!await crypto.subtle.verify('HMAC',key,bytes(sig),new TextEncoder().encode(payload)))return false;
    const session=JSON.parse(new TextDecoder().decode(bytes(payload)));
    return session.exp>Math.floor(Date.now()/1000)&&typeof session.tenantId==='string'&&session.tenantId.length>0&&['admin','member'].includes(session.role);
  }catch{return false;}
}
export async function middleware(request:NextRequest){
  if(request.nextUrl.pathname==='/api/auth/login'||request.nextUrl.pathname==='/api/auth/session')return NextResponse.next();
  if(!await authenticated(request))return NextResponse.json({error:'Authentication required.'},{status:401,headers:{'cache-control':'no-store'}});
  if(!['GET','HEAD','OPTIONS'].includes(request.method)){
    const origin=request.headers.get('origin');
    if(origin&&origin!==request.nextUrl.origin)return NextResponse.json({error:'Invalid request origin.'},{status:403});
  }
  return NextResponse.next();
}
export const config={matcher:'/api/:path*'};
