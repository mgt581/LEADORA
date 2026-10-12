import { NextResponse } from 'next/server';
import { getCloudflareContext } from '@opennextjs/cloudflare';
import { CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_PROJECTS, cloudflareDashboardUrl } from '@/lib/cloudflare-projects';

export const runtime = 'nodejs';
export const dynamic = 'force-dynamic';

type RuntimeEnv = { CLOUDFLARE_READ_TOKEN?: string; CLOUDFLARE_ACCOUNT_ID?: string };

function runtimeEnv(): RuntimeEnv {
  try { return getCloudflareContext().env as unknown as RuntimeEnv; }
  catch { return process.env as RuntimeEnv; }
}

async function publicHealth(url: string) {
  const started = Date.now();
  try {
    const response = await fetch(url, {
      method: 'HEAD',
      redirect: 'follow',
      signal: AbortSignal.timeout(6_000),
      headers: { 'user-agent': 'LeadRally/2.0 infrastructure monitor' },
      cache: 'no-store',
    });
    return { status: response.ok ? 'healthy' : 'warning', statusCode: response.status, responseMs: Date.now() - started } as const;
  } catch {
    return { status: 'offline', statusCode: null, responseMs: Date.now() - started } as const;
  }
}

async function cloudflareGet(path: string, token: string, accountId: string) {
  const response = await fetch(`https://api.cloudflare.com/client/v4/accounts/${accountId}${path}`, {
    headers: { authorization: `Bearer ${token}` },
    cache: 'no-store',
    signal: AbortSignal.timeout(8_000),
  });
  if (!response.ok) throw new Error(`Cloudflare API ${response.status}`);
  const payload = await response.json() as { success?: boolean; result?: unknown };
  if (!payload.success) throw new Error('Cloudflare API request failed');
  return payload.result;
}

function deploymentSummary(result: unknown, kind: 'worker' | 'pages' | 'external') {
  if (!result || typeof result !== 'object') return null;
  if (kind === 'pages') {
    const project = result as { latest_deployment?: { id?: string; created_on?: string; environment?: string; deployment_trigger?: { metadata?: { branch?: string } } } };
    const latest = project.latest_deployment;
    return latest ? { id: latest.id ?? null, createdAt: latest.created_on ?? null, environment: latest.environment ?? 'production', branch: latest.deployment_trigger?.metadata?.branch ?? null } : null;
  }
  const deployments = (result as { deployments?: Array<{ id?: string; created_on?: string; source?: string }> }).deployments;
  const latest = deployments?.[0];
  return latest ? { id: latest.id ?? null, createdAt: latest.created_on ?? null, environment: latest.source ?? 'production', branch: null } : null;
}

export async function GET() {
  const env = runtimeEnv();
  const token = env.CLOUDFLARE_READ_TOKEN?.trim();
  const accountId = env.CLOUDFLARE_ACCOUNT_ID?.trim() || CLOUDFLARE_ACCOUNT_ID;
  const projects = await Promise.all(CLOUDFLARE_PROJECTS.map(async project => {
    // This handler responding is the authoritative LeadRally health check.
    // A Worker fetching its own custom domain can create a false 522 signal.
    const health = project.id === 'leadrally'
      ? { status: 'healthy' as const, statusCode: 200, responseMs: 0 }
      : await publicHealth(project.publicUrl);
    let deployment = null;
    let database = project.database ? { name: project.database.name, sizeBytes: null as number | null, version: null as string | null } : null;
    let cloudflareError: string | null = null;
    if (token) {
      try {
        if (project.cloudflareKind === 'pages' && project.cloudflareName) {
          deployment = deploymentSummary(await cloudflareGet(`/pages/projects/${encodeURIComponent(project.cloudflareName)}`, token, accountId), 'pages');
        } else if (project.cloudflareKind === 'worker' && project.cloudflareName) {
          deployment = deploymentSummary(await cloudflareGet(`/workers/scripts/${encodeURIComponent(project.cloudflareName)}/deployments`, token, accountId), 'worker');
        }
        if (project.database) {
          const detail = await cloudflareGet(`/d1/database/${project.database.id}`, token, accountId) as { file_size?: number; version?: string };
          database = { name: project.database.name, sizeBytes: detail.file_size ?? null, version: detail.version ?? null };
        }
      } catch (error) {
        cloudflareError = error instanceof Error ? error.message : 'Private metrics unavailable';
      }
    }
    return {
      id: project.id,
      name: project.name,
      description: project.description,
      publicUrl: project.publicUrl,
      dashboardUrl: project.dashboardUrl,
      cloudflareUrl: cloudflareDashboardUrl(project),
      access: project.access,
      cloudflareKind: project.cloudflareKind,
      cloudflareName: project.cloudflareName ?? null,
      health,
      deployment,
      database,
      cloudflareError,
    };
  }));
  return NextResponse.json({
    checkedAt: new Date().toISOString(),
    connectionConfigured: Boolean(token),
    projects,
  }, { headers: {
    'cache-control': 'private, no-store, no-cache, must-revalidate, max-age=0',
    'cloudflare-cdn-cache-control': 'no-store',
  } });
}

