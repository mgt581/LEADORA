import { getCloudflareContext } from '@opennextjs/cloudflare';

type D1Statement = { bind(...values: unknown[]): D1Statement; first<T>(): Promise<T | null>; run(): Promise<unknown> };
export type D1Database = { prepare(query: string): D1Statement };

/** Fails closed: records must not silently fall back to temporary browser-only storage in production. */
export function database(): D1Database {
  const env = getCloudflareContext().env as unknown as { LEADORA_DB?: D1Database };
  if (!env.LEADORA_DB) throw new Error('LEADORA_DB is not bound to this Cloudflare Worker.');
  return env.LEADORA_DB;
}
