# Gmail integration setup

LEADORA uses server-side OAuth with `gmail.send` and `gmail.readonly` only. Tokens are never returned to client JavaScript; the short-lived encrypted token cookie is `HttpOnly` and is encrypted with `GMAIL_TOKEN_ENCRYPTION_KEY`. For multi-user production deployments, persist the encrypted refresh token and sync cursor using `db/migrations/001_gmail.sql`.

## Google Cloud Console

1. Create/select a Google Cloud project and enable **Gmail API**.
2. Configure the OAuth consent screen. Add the LEADORA owner as a test user while the app is in testing mode.
3. Create an OAuth **Web application** client.
4. Add the deployed Worker origin under Authorized JavaScript origins.
5. Add the exact redirect URL from `GOOGLE_OAUTH_REDIRECT_URL` under Authorized redirect URIs. The default is `http://localhost:3000/api/gmail/callback`.
6. Configure the production HTTPS URL and production callback before deployment.

Generate `GMAIL_TOKEN_ENCRYPTION_KEY` with `openssl rand -base64 32`. Add `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`, `GOOGLE_OAUTH_REDIRECT_URL`, and `GMAIL_TOKEN_ENCRYPTION_KEY` as GitHub Actions secrets; never commit their values. `GOOGLE_OAUTH_REDIRECT_URL` must be the exact deployed Worker callback URL.

Add `CLOUDFLARE_ACCOUNT_ID` and `CLOUDFLARE_API_TOKEN` as GitHub Actions secrets for deployment only. They are deliberately not exposed to the running application. Push to `main` or manually run **Deploy LEADORA to Cloudflare**, then make the Worker URL the canonical LEADORA URL instead of the static GitHub Pages site.

Google may require verification before external users can use Gmail restricted scopes. This integration deliberately does not request full mailbox access or `mail.google.com`.

## Current hosting limitation

The repository's existing GitHub Pages deployment is static and cannot execute OAuth callbacks or Gmail API routes. Use the Cloudflare Worker deployment as the app URL. Pub/Sub push is not enabled here; use **Sync now** until a server-side scheduler and database are configured.
