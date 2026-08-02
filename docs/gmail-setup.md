# Gmail integration setup

LeadRally uses server-side OAuth with `gmail.send` and `gmail.readonly` only. Tokens are never returned to client JavaScript; the encrypted token cookie is `HttpOnly` and protected with `GMAIL_TOKEN_ENCRYPTION_KEY`.

## Google Cloud Console

1. Create/select a Google Cloud project and enable **Gmail API**.
2. Configure the OAuth consent screen. Add `ajbryantsleads@gmail.com` as a test user while the app is in testing mode.
3. Create an OAuth **Web application** client.
4. Add `https://leadrally.co.uk` under Authorized JavaScript origins.
5. Add `https://leadrally.co.uk/api/gmail/callback` under Authorized redirect URIs.
6. Configure the production HTTPS URL and production callback before deployment.

Generate `GMAIL_TOKEN_ENCRYPTION_KEY` with `openssl rand -base64 32`. Set the public `GOOGLE_OAUTH_CLIENT_ID` and `GOOGLE_OAUTH_REDIRECT_URL` Worker variables in `wrangler.jsonc`. Add `GOOGLE_OAUTH_CLIENT_SECRET` and `GMAIL_TOKEN_ENCRYPTION_KEY` as encrypted secrets in the Cloudflare Worker settings; never commit their values.

The internal `leadora` Worker remains connected to this GitHub repository so the existing D1 binding, encrypted secrets and deployment history are preserved. Its public brand and custom domain are LeadRally. Cloudflare builds and deploys `main`; GitHub Actions is an optional manual validation only.

Google may require verification before external users can use Gmail restricted scopes. This integration deliberately does not request full mailbox access or `mail.google.com`.

The Gmail OAuth cookie is scoped to the domain where it was created. After moving from the `workers.dev` address to `leadrally.co.uk`, connect Gmail once on the new domain. Existing D1 records are unchanged.
