const DIGITAL_WEBSITE = 'https://bryantdigitalsolutions.com';
const DIGITAL_LOGO = `${DIGITAL_WEBSITE}/assets/logo-bds.jpg`;

function escapeHtml(value: string) {
  return value.replace(/[&<>"']/g, character => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  })[character] ?? character);
}

function paragraphs(body: string) {
  return body.trim().split(/\n\s*\n/).map(paragraph =>
    `<p style="margin:0 0 16px;color:#24344d;font-size:15px;line-height:1.65;">${escapeHtml(paragraph).replace(/\n/g, '<br>')}</p>`,
  ).join('');
}

/** A compact, email-client-safe table layout with a useful plain-text fallback. */
export function digitalOutreachHtml(body: string, isFollowUp = false) {
  const offer = isFollowUp ? '' : `
    <tr><td style="padding:0 28px 20px;">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#eef6ff;border:1px solid #cfe3f8;border-radius:10px;">
        <tr><td style="padding:16px 18px;color:#083f7a;font-family:Arial,sans-serif;">
          <strong style="display:block;font-size:16px;margin-bottom:5px;">Free Website &amp; SEO Audit</strong>
          <span style="font-size:13px;line-height:1.5;">Normally £49. Practical findings, no obligation. Any recurring plan is month-to-month with no long contract.</span>
        </td></tr>
      </table>
    </td></tr>`;
  return `<!doctype html><html><body style="margin:0;padding:0;background:#f3f6fa;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f3f6fa;padding:24px 10px;">
    <tr><td align="center">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:620px;background:#ffffff;border:1px solid #dce5ef;border-radius:14px;overflow:hidden;box-shadow:0 5px 20px rgba(8,63,122,.08);">
        <tr><td style="background:#083f7a;padding:20px 28px;">
          <a href="${DIGITAL_WEBSITE}" style="text-decoration:none;"><img src="${DIGITAL_LOGO}" width="168" height="56" alt="Bryant Digital Solutions" style="display:block;width:168px;height:56px;object-fit:contain;border:0;"></a>
        </td></tr>
        <tr><td style="padding:26px 28px 8px;font-family:Arial,sans-serif;">${paragraphs(body)}</td></tr>
        ${offer}
        <tr><td align="center" style="padding:0 28px 24px;">
          <a href="${DIGITAL_WEBSITE}" style="display:inline-block;background:#0b69b7;color:#ffffff;text-decoration:none;font-family:Arial,sans-serif;font-size:14px;font-weight:bold;padding:12px 22px;border-radius:8px;">Visit Bryant Digital Solutions</a>
        </td></tr>
        <tr><td style="background:#f7f9fc;padding:16px 28px;color:#66758b;font-family:Arial,sans-serif;font-size:12px;line-height:1.5;text-align:center;">
          Part of Bryant Group Holdings &nbsp;·&nbsp; 07843 969254<br>
          <a href="${DIGITAL_WEBSITE}" style="color:#0b69b7;text-decoration:none;">bryantdigitalsolutions.com</a>
        </td></tr>
      </table>
    </td></tr>
  </table></body></html>`;
}
