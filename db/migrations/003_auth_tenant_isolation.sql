-- Preserve legacy app_state rows while copying them into the owner tenant.
CREATE TABLE IF NOT EXISTS tenant_app_state (
  tenant_id TEXT NOT NULL,
  state_key TEXT NOT NULL,
  value_json TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 1,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (tenant_id, state_key)
);
INSERT OR IGNORE INTO tenant_app_state (tenant_id,state_key,value_json,version,updated_at)
SELECT 'owner',state_key,value_json,1,updated_at FROM app_state;

CREATE TABLE IF NOT EXISTS auth_login_attempts (
  attempt_key TEXT PRIMARY KEY,
  failure_count INTEGER NOT NULL DEFAULT 0,
  window_started_at INTEGER NOT NULL,
  blocked_until INTEGER NOT NULL DEFAULT 0
);
