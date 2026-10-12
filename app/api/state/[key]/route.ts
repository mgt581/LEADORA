import { NextRequest, NextResponse } from 'next/server';
import { database } from '@/lib/server/d1';
import { requireSession, validMutationOrigin } from '@/lib/server/auth';

// This route shares the default server function with Gmail and D1. OpenNext
// currently requires Edge handlers to be emitted as a separate function.
export const runtime = 'nodejs';
const allowed = new Set(['leadora-prospects','leadora-drafts','leadora-outreach','leadora-contacts','leadora-leads','leadora-google-profiles','leadora-gmail-messages','leadora-businesses']);
function valid(key:string) { return allowed.has(key); }

export async function GET(request:NextRequest, { params }:{params:Promise<{key:string}>}) {
  const auth=requireSession(request); if('response' in auth)return auth.response;
  const {key}=await params; if(!valid(key)) return NextResponse.json({error:'Unknown state collection.'},{status:404});
  try { const row=await database().prepare('SELECT value_json, updated_at, version FROM tenant_app_state WHERE tenant_id = ? AND state_key = ?').bind(auth.session.tenantId,key).first<{value_json:string;updated_at:string;version:number}>(); return NextResponse.json({value:row?JSON.parse(row.value_json):null,updatedAt:row?.updated_at??null,version:row?.version??0}); }
  catch(error) { return NextResponse.json({error:error instanceof Error?error.message:'Database unavailable.'},{status:503}); }
}
export async function PUT(request:NextRequest, { params }:{params:Promise<{key:string}>}) {
  const auth=requireSession(request); if('response' in auth)return auth.response;
  if(!validMutationOrigin(request))return NextResponse.json({error:'Invalid request origin.'},{status:403});
  const {key}=await params; if(!valid(key)) return NextResponse.json({error:'Unknown state collection.'},{status:404});
  try { const {value,version}=await request.json(); if(!Array.isArray(value))return NextResponse.json({error:'State collections must be arrays.'},{status:400}); if(!Number.isInteger(version)||version<0)return NextResponse.json({error:'A valid record version is required.'},{status:400}); const json=JSON.stringify(value); if(json.length>1_000_000)return NextResponse.json({error:'Record collection is too large.'},{status:413}); const next=version+1; const updated=await database().prepare("INSERT INTO tenant_app_state (tenant_id,state_key,value_json,version,updated_at) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP) ON CONFLICT(tenant_id,state_key) DO UPDATE SET value_json=excluded.value_json,version=excluded.version,updated_at=CURRENT_TIMESTAMP WHERE tenant_app_state.version = ? RETURNING version").bind(auth.session.tenantId,key,json,next,version).first<{version:number}>(); if(!updated)return NextResponse.json({error:'These records changed in another session. Reload before saving.'},{status:409}); return NextResponse.json({ok:true,version:updated.version}); }
  catch(error) { return NextResponse.json({error:error instanceof Error?error.message:'Database write failed.'},{status:503}); }
}
