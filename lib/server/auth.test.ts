import assert from 'node:assert/strict';
import test from 'node:test';
import { NextRequest } from 'next/server';
import { createSession, createSessionForPrincipal, readSession, SESSION_COOKIE } from './auth';
import { middleware } from '../../middleware';

process.env.LEADRALLY_SESSION_SECRET='test-session-secret-that-is-longer-than-32-characters';
function request(cookie=''){return new NextRequest('https://leadrally.co.uk/api/state/leadora-contacts',{headers:{cookie}});}

test('signed sessions identify the owner tenant and reject tampering',()=>{
  const token=createSession('ajbryantsleads@gmail.com');
  assert.equal(readSession(request(`${SESSION_COOKIE}=${token}`))?.tenantId,'owner');
  assert.equal(readSession(request(`${SESSION_COOKIE}=${token}x`)),null);
  assert.equal(readSession(request()),null);
});

test('signed customer sessions preserve separate tenant identities',()=>{
  const a=createSessionForPrincipal({userId:'user-a',tenantId:'tenant-a',email:'a@example.test',role:'member'});
  const b=createSessionForPrincipal({userId:'user-b',tenantId:'tenant-b',email:'b@example.test',role:'member'});
  assert.equal(readSession(request(`${SESSION_COOKIE}=${a}`))?.tenantId,'tenant-a');
  assert.equal(readSession(request(`${SESSION_COOKIE}=${b}`))?.tenantId,'tenant-b');
});

test('private API middleware denies anonymous and accepts a valid session',async()=>{
  const denied=await middleware(request()); assert.equal(denied.status,401);
  const token=createSession('ajbryantsleads@gmail.com');
  const allowed=await middleware(request(`${SESSION_COOKIE}=${token}`)); assert.equal(allowed.status,200);
});
