const emailPattern = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i;
const placeholderMailbox = /^(user|username|name|yourname|email|example|test|someone|person|you|your)\d*$/i;
const placeholderHost = /^(domain\.com|email\.com|example\.|yourdomain\.|test\.)|wixpress|sentry|cloudflare/i;

/** Accept only a plausible public business mailbox, never sample form content. */
export function isPublicBusinessEmail(value: string) {
  const email = value.trim().toLowerCase();
  if (!emailPattern.test(email)) return false;
  const [mailbox, host] = email.split('@');
  return !placeholderMailbox.test(mailbox) && !placeholderHost.test(host) && !/^(no-?reply|do-?not-?reply)$/i.test(mailbox);
}
