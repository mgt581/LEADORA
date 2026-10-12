import { NextRequest, NextResponse } from 'next/server';
import { SESSION_COOKIE, sessionCookieOptions, validMutationOrigin } from '@/lib/server/auth';
import { clearGmailTokens } from '@/lib/server/gmail';
export const runtime='nodejs';
export async function POST(request:NextRequest){if(!validMutationOrigin(request))return NextResponse.json({error:'Invalid request origin.'},{status:403});const response=NextResponse.json({ok:true});response.cookies.set(SESSION_COOKIE,'',sessionCookieOptions(0));clearGmailTokens(response,request.url);return response;}
