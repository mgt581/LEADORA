-- Apply this migration to the application's relational database before enabling Gmail.
CREATE TABLE IF NOT EXISTS gmail_connections (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL UNIQUE,
  gmail_address TEXT NOT NULL,
  encrypted_refresh_token TEXT NOT NULL,
  token_expiry TIMESTAMP NULL,
  history_id TEXT NULL,
  last_synced_at TIMESTAMP NULL,
  status TEXT NOT NULL DEFAULT 'connected',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS business_email_mappings (
  id TEXT PRIMARY KEY,
  business_id TEXT NOT NULL,
  email_address TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (business_id, email_address)
);
CREATE TABLE IF NOT EXISTS gmail_threads (
  id TEXT PRIMARY KEY,
  gmail_thread_id TEXT NOT NULL UNIQUE,
  business_id TEXT NULL,
  prospect_id TEXT NULL,
  subject TEXT NOT NULL DEFAULT '',
  unread BOOLEAN NOT NULL DEFAULT FALSE,
  last_activity_at TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS gmail_messages (
  id TEXT PRIMARY KEY,
  gmail_message_id TEXT NOT NULL UNIQUE,
  gmail_thread_id TEXT NOT NULL,
  direction TEXT NOT NULL CHECK (direction IN ('inbound', 'outbound')),
  business_id TEXT NULL,
  prospect_id TEXT NULL,
  outreach_draft_id TEXT NULL,
  sender TEXT NOT NULL DEFAULT '',
  recipients TEXT NOT NULL DEFAULT '',
  subject TEXT NOT NULL DEFAULT '',
  body TEXT NOT NULL DEFAULT '',
  sent_status TEXT NOT NULL DEFAULT 'received',
  error_details TEXT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  attachments_json TEXT NOT NULL DEFAULT '[]',
  internal_timestamp TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (gmail_message_id)
);
CREATE UNIQUE INDEX IF NOT EXISTS gmail_messages_thread_message_idx ON gmail_messages(gmail_thread_id, gmail_message_id);
CREATE INDEX IF NOT EXISTS gmail_messages_prospect_idx ON gmail_messages(prospect_id, internal_timestamp);
CREATE INDEX IF NOT EXISTS gmail_messages_business_idx ON gmail_messages(business_id, internal_timestamp);
