import { NextRequest, NextResponse } from 'next/server';
import { createSession, ownerEmail, SESSION_COOKIE, sessionCookieOptions, validMutationOrigin, verifyPassword } from '@/lib/server/auth';
import { database } from '@/lib/server/d1';
import { createHash } from 'node:crypto';
export const runtime='nodejs';
export async function POST(request:NextRequest){
  if(!validMutationOrigin(request))return NextResponse.json({error:'Invalid request origin.'},{status:403});
  const body=await request.json().catch(()=>({})) as {email?:string;password?:string};
  const now=Math.floor(Date.now()/1000), ip=request.headers.get('cf-connecting-ip')||'unknown';
  const attemptKey=createHash('sha256').update(`${ip}:${body.email?.trim().toLowerCase()||''}`).digest('hex');
  try{
    const attempt=await database().prepare('SELECT failure_count,window_started_at,blocked_until FROM auth_login_attempts WHERE attempt_key = ?').bind(attemptKey).first<{failure_count:number;window_started_at:number;blocked_until:number}>();
    if(attempt&&attempt.blocked_until>now)return NextResponse.json({error:'Too many sign-in attempts. Try again later.'},{status:429,headers:{'retry-after':String(attempt.blocked_until-now)}});
    if(body.email?.trim().toLowerCase()!==ownerEmail()||!body.password||!verifyPassword(body.password)){
      const within=Boolean(attempt&&now-attempt.window_started_at<900), failures=within?(attempt!.failure_count+1):1, blockedUntil=failures>=5?now+900:0;
      await database().prepare('INSERT INTO auth_login_attempts (attempt_key,failure_count,window_started_at,blocked_until) VALUES (?, ?, ?, ?) ON CONFLICT(attempt_key) DO UPDATE SET failure_count=excluded.failure_count,window_started_at=excluded.window_started_at,blocked_until=excluded.blocked_until').bind(attemptKey,failures,within?attempt!.window_started_at:now,blockedUntil).run();
      return NextResponse.json({error:'Invalid email or password.'},{status:401});
    }
    await database().prepare('DELETE FROM auth_login_attempts WHERE attempt_key = ?').bind(attemptKey).run();
  }catch{return NextResponse.json({error:'Secure sign-in is temporarily unavailable.'},{status:503});}
  const response=NextResponse.json({ok:true,user:{email:ownerEmail(),role:'admin',tenantId:'owner'}});
  response.cookies.set(SESSION_COOKIE,createSession(ownerEmail()),sessionCookieOptions());
  response.headers.set('cache-control','no-store'); return response;
}
