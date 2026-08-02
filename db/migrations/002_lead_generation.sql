-- LeadRally V1 core records. Provider IDs keep public, free and paid discovery interchangeable.
CREATE TABLE IF NOT EXISTS prospects (
  id TEXT PRIMARY KEY, business_id TEXT NOT NULL, name TEXT NOT NULL, website TEXT NOT NULL,
  email TEXT, phone TEXT, location TEXT, google_maps_url TEXT, industry TEXT, contact_page_url TEXT,
  source_provider TEXT NOT NULL DEFAULT 'public_website', status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, last_contact_at TIMESTAMP, next_follow_up_at TIMESTAMP,
  UNIQUE (business_id, website)
);
CREATE TABLE IF NOT EXISTS website_audits (
  id TEXT PRIMARY KEY, prospect_id TEXT NOT NULL, audit_json TEXT NOT NULL,
  overall_score INTEGER NOT NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (prospect_id) REFERENCES prospects(id)
);
CREATE TABLE IF NOT EXISTS opportunities (
  id TEXT PRIMARY KEY, prospect_id TEXT NOT NULL UNIQUE, recommended_business_id TEXT NOT NULL,
  recommended_service TEXT NOT NULL, rationale TEXT NOT NULL, estimated_value INTEGER, confidence_score INTEGER NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (prospect_id) REFERENCES prospects(id)
);
CREATE TABLE IF NOT EXISTS outreach_drafts (
  id TEXT PRIMARY KEY, prospect_id TEXT NOT NULL, business_id TEXT NOT NULL, subject TEXT NOT NULL, body TEXT NOT NULL,
  call_to_action TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'pending', is_follow_up BOOLEAN NOT NULL DEFAULT FALSE,
  scheduled_for TIMESTAMP, sent_at TIMESTAMP, gmail_message_id TEXT, retry_count INTEGER NOT NULL DEFAULT 0,
  last_error TEXT, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (prospect_id) REFERENCES prospects(id)
);
CREATE INDEX IF NOT EXISTS prospects_filters_idx ON prospects (business_id, status, industry, location, created_at);
CREATE INDEX IF NOT EXISTS outreach_drafts_queue_idx ON outreach_drafts (status, scheduled_for, created_at);

-- Browser state is a cache only; this is the durable source for the current single-account V1.
CREATE TABLE IF NOT EXISTS app_state (
  state_key TEXT PRIMARY KEY,
  value_json TEXT NOT NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
