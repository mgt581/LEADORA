import { NextRequest, NextResponse } from 'next/server';
import { database } from '@/lib/server/d1';

export const runtime = 'edge';
const allowed = new Set(['leadora-prospects','leadora-drafts','leadora-outreach','leadora-contacts','leadora-leads']);
function valid(key:string) { return allowed.has(key); }

export async function GET(_:NextRequest, { params }:{params:Promise<{key:string}>}) {
  const {key}=await params; if(!valid(key)) return NextResponse.json({error:'Unknown state collection.'},{status:404});
  try { const row=await database().prepare('SELECT value_json, updated_at FROM app_state WHERE state_key = ?').bind(key).first<{value_json:string;updated_at:string}>(); return NextResponse.json({value:row?JSON.parse(row.value_json):null,updatedAt:row?.updated_at??null}); }
  catch(error) { return NextResponse.json({error:error instanceof Error?error.message:'Database unavailable.'},{status:503}); }
}
export async function PUT(request:NextRequest, { params }:{params:Promise<{key:string}>}) {
  const {key}=await params; if(!valid(key)) return NextResponse.json({error:'Unknown state collection.'},{status:404});
  try { const {value}=await request.json(); const json=JSON.stringify(value); if(json.length>1_000_000)return NextResponse.json({error:'Record collection is too large.'},{status:413}); await database().prepare("INSERT INTO app_state (state_key,value_json,updated_at) VALUES (?, ?, CURRENT_TIMESTAMP) ON CONFLICT(state_key) DO UPDATE SET value_json=excluded.value_json,updated_at=CURRENT_TIMESTAMP").bind(key,json).run(); return NextResponse.json({ok:true}); }
  catch(error) { return NextResponse.json({error:error instanceof Error?error.message:'Database write failed.'},{status:503}); }
}
