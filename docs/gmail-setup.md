# Gmail integration setup

LEADORA uses server-side OAuth with `gmail.send` and `gmail.readonly` only. Tokens are never returned to client JavaScript; the short-lived encrypted token cookie is `HttpOnly` and is encrypted with `GMAIL_TOKEN_ENCRYPTION_KEY`. For multi-user production deployments, persist the encrypted refresh token and sync cursor using `db/migrations/001_gmail.sql`.

## Google Cloud Console

1. Create/select a Google Cloud project and enable **Gmail API**.
2. Configure the OAuth consent screen. Add the LEADORA owner as a test user while the app is in testing mode.
3. Create an OAuth **Web application** client.
4. Add the origin (`NEXT_PUBLIC_APP_URL`) under Authorized JavaScript origins.
5. Add the exact redirect URL from `GOOGLE_OAUTH_REDIRECT_URL` under Authorized redirect URIs. The default is `http://localhost:3000/api/gmail/callback`.
6. Configure the production HTTPS URL and production callback before deployment.

Run `openssl rand -base64 32` for `GMAIL_TOKEN_ENCRYPTION_KEY`, then configure every variable in `.env.example` in the deployment environment. Never commit the client secret or encryption key.

Google may require verification before external users can use Gmail restricted scopes. This integration deliberately does not request full mailbox access or `mail.google.com`.

## Current hosting limitation

The repository's existing GitHub Pages deployment is static and cannot execute OAuth callbacks or Gmail API routes. Deploy the Next.js server (for example on Vercel) with `output: 'export'` disabled, or place these routes behind an authenticated server deployment. Pub/Sub push is not enabled here; use the authenticated **Sync now** action until a server-side scheduler and database are configured.
