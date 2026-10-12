import { NextRequest, NextResponse } from 'next/server';
import { readSession } from '@/lib/server/auth';
export const runtime='nodejs';
export async function GET(request:NextRequest){const session=readSession(request);return NextResponse.json(session?{authenticated:true,user:{email:session.email,role:session.role,tenantId:session.tenantId}}:{authenticated:false},{status:session?200:401,headers:{'cache-control':'no-store'}});}
