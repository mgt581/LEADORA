import { createHmac, timingSafeEqual, scryptSync } from 'node:crypto';
import { NextRequest, NextResponse } from 'next/server';

export const SESSION_COOKIE = 'leadrally-session';
export const OWNER_TENANT_ID = 'owner';
export const OWNER_USER_ID = 'owner-admin';
export type Session = { userId:string; tenantId:string; email:string; role:'admin'|'member'; exp:number };

function secret() {
  const value=process.env.LEADRALLY_SESSION_SECRET;
  if(!value || value.length<32) throw new Error('LEADRALLY_SESSION_SECRET must be at least 32 characters.');
  return value;
}
function signature(payload:string) { return createHmac('sha256',secret()).update(payload).digest('base64url'); }
export function createSessionForPrincipal(principal:Omit<Session,'exp'>, maxAge=60*60*12) {
  const payload=Buffer.from(JSON.stringify({...principal,email:principal.email.toLowerCase(),exp:Math.floor(Date.now()/1000)+maxAge} satisfies Session)).toString('base64url');
  return `${payload}.${signature(payload)}`;
}
export function createSession(email:string,maxAge=60*60*12){return createSessionForPrincipal({userId:OWNER_USER_ID,tenantId:OWNER_TENANT_ID,email,role:'admin'},maxAge);}
export function readSession(request:NextRequest):Session|null {
  try {
    const value=request.cookies.get(SESSION_COOKIE)?.value;
    if(!value)return null;
    const [payload,sig]=value.split('.'); if(!payload||!sig)return null;
    const expected=signature(payload), a=Buffer.from(sig), b=Buffer.from(expected);
    if(a.length!==b.length||!timingSafeEqual(a,b))return null;
    const session=JSON.parse(Buffer.from(payload,'base64url').toString()) as Session;
    if(session.exp<=Math.floor(Date.now()/1000)||!session.userId||!session.tenantId||!session.email||!['admin','member'].includes(session.role))return null;
    return session;
  } catch { return null; }
}
export function requireSession(request:NextRequest) {
  const session=readSession(request);
  return session ? {session} : {response:NextResponse.json({error:'Authentication required.'},{status:401})};
}
export function requireAdmin(request:NextRequest) {
  const auth=requireSession(request);
  if('response' in auth)return auth;
  return auth.session.role==='admin' ? auth : {response:NextResponse.json({error:'Administrator access required.'},{status:403})};
}
export function validMutationOrigin(request:NextRequest) {
  const origin=request.headers.get('origin');
  if(!origin)return true;
  try { return new URL(origin).origin===new URL(request.url).origin; } catch { return false; }
}
export function verifyPassword(password:string) {
  const stored=process.env.LEADRALLY_ADMIN_PASSWORD_HASH;
  if(!stored)return false;
  const [salt,hash]=stored.split(':'); if(!salt||!hash)return false;
  const actual=scryptSync(password,Buffer.from(salt,'base64url'),32);
  const expected=Buffer.from(hash,'base64url');
  return actual.length===expected.length&&timingSafeEqual(actual,expected);
}
export function ownerEmail(){return (process.env.LEADRALLY_ADMIN_EMAIL||'ajbryantsleads@gmail.com').toLowerCase();}
export function sessionCookieOptions(maxAge=60*60*12){return {httpOnly:true,secure:true,sameSite:'lax' as const,path:'/',domain:'leadrally.co.uk',maxAge};}
