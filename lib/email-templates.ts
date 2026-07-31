const DIGITAL_WEBSITE = 'https://bryantdigitalsolutions.com';
const DIGITAL_LOGO = `${DIGITAL_WEBSITE}/assets/logo-bds.jpg`;
const CLEANING_WEBSITE = 'https://www.bryantandcocleaning.co.uk';
const CLEANING_LOGO = `${CLEANING_WEBSITE}/images/logo.png`;
const CONSTRUCTION_WEBSITE = 'https://bryantconstructiongroup.co.uk';
const CONSTRUCTION_LOGO = `${CONSTRUCTION_WEBSITE}/assets/logo.png`;
const TEETH_WEBSITE = 'https://teethwhiteningbournemouth.co.uk';
const TEETH_LOGO = `${TEETH_WEBSITE}/images/logo.png`;
const HOLDINGS_COMPANY_NUMBER = '13671131';

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
          Bryant Group Holdings Ltd &nbsp;·&nbsp; Company No. ${HOLDINGS_COMPANY_NUMBER} &nbsp;·&nbsp; 07843 969254<br>
          <a href="${DIGITAL_WEBSITE}" style="color:#0b69b7;text-decoration:none;">bryantdigitalsolutions.com</a>
        </td></tr>
      </table>
    </td></tr>
  </table></body></html>`;
}

export function cleaningOutreachHtml(body: string, isFollowUp = false) {
  const offer = isFollowUp ? '' : `
    <tr><td style="padding:0 28px 20px;">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#ecfbff;border:1px solid #bde8f2;border-radius:10px;">
        <tr><td style="padding:16px 18px;color:#103542;font-family:Arial,sans-serif;">
          <strong style="display:block;font-size:16px;margin-bottom:5px;">Free Commercial Cleaning Quote</strong>
          <span style="font-size:13px;line-height:1.5;">No obligation · Tailored around your hours · Reply within one hour during business hours</span>
        </td></tr>
      </table>
    </td></tr>`;
  return `<!doctype html><html><body style="margin:0;padding:0;background:#f3f7f8;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f3f7f8;padding:24px 10px;">
    <tr><td align="center">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:620px;background:#ffffff;border:1px solid #d7e5e9;border-radius:14px;overflow:hidden;box-shadow:0 5px 20px rgba(16,53,66,.08);">
        <tr><td style="background:#103542;padding:18px 28px;">
          <a href="${CLEANING_WEBSITE}" style="text-decoration:none;"><img src="${CLEANING_LOGO}" width="92" height="92" alt="Bryant and Co Cleaning" style="display:block;width:92px;height:92px;object-fit:contain;border:0;background:#ffffff;border-radius:10px;"></a>
        </td></tr>
        <tr><td style="padding:26px 28px 8px;font-family:Arial,sans-serif;">${paragraphs(body)}</td></tr>
        ${offer}
        <tr><td align="center" style="padding:0 28px 24px;">
          <a href="${CLEANING_WEBSITE}" style="display:inline-block;background:#20a9d6;color:#ffffff;text-decoration:none;font-family:Arial,sans-serif;font-size:14px;font-weight:bold;padding:12px 22px;border-radius:8px;">Request a Free Quote</a>
        </td></tr>
        <tr><td style="background:#f5f9fa;padding:16px 28px;color:#60747b;font-family:Arial,sans-serif;font-size:12px;line-height:1.5;text-align:center;">
          Bryant Group Holdings Ltd &nbsp;·&nbsp; Company No. ${HOLDINGS_COMPANY_NUMBER} &nbsp;·&nbsp; 07843 969254<br>
          <a href="${CLEANING_WEBSITE}" style="color:#1485aa;text-decoration:none;">bryantandcocleaning.co.uk</a>
        </td></tr>
      </table>
    </td></tr>
  </table></body></html>`;
}

export function constructionOutreachHtml(body: string, isFollowUp = false) {
  const offer = isFollowUp ? '' : `
    <tr><td style="padding:0 28px 20px;">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#eef4f9;border:1px solid #cad9e6;border-radius:10px;">
        <tr><td style="padding:16px 18px;color:#123756;font-family:Arial,sans-serif;">
          <strong style="display:block;font-size:16px;margin-bottom:5px;">Free, Clear Construction Quote</strong>
          <span style="font-size:13px;line-height:1.5;">No obligation · Clear pricing before work starts · No hidden extras</span>
        </td></tr>
      </table>
    </td></tr>`;
  return `<!doctype html><html><body style="margin:0;padding:0;background:#f3f6f8;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f3f6f8;padding:24px 10px;">
    <tr><td align="center">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:620px;background:#ffffff;border:1px solid #d7e0e8;border-radius:14px;overflow:hidden;box-shadow:0 5px 20px rgba(18,55,86,.08);">
        <tr><td style="background:#123756;padding:18px 28px;">
          <a href="${CONSTRUCTION_WEBSITE}" style="text-decoration:none;"><img src="${CONSTRUCTION_LOGO}" width="132" height="112" alt="Bryant Construction Group" style="display:block;width:132px;height:112px;object-fit:contain;border:0;background:#ffffff;border-radius:10px;"></a>
        </td></tr>
        <tr><td style="padding:26px 28px 8px;font-family:Arial,sans-serif;">${paragraphs(body)}</td></tr>
        ${offer}
        <tr><td align="center" style="padding:0 28px 24px;">
          <a href="${CONSTRUCTION_WEBSITE}" style="display:inline-block;background:#123756;color:#ffffff;text-decoration:none;font-family:Arial,sans-serif;font-size:14px;font-weight:bold;padding:12px 22px;border-radius:8px;">Request a Free Quote</a>
        </td></tr>
        <tr><td style="background:#f5f7f9;padding:16px 28px;color:#607080;font-family:Arial,sans-serif;font-size:12px;line-height:1.5;text-align:center;">
          Bryant Group Holdings Ltd &nbsp;·&nbsp; Company No. ${HOLDINGS_COMPANY_NUMBER} &nbsp;·&nbsp; 07843 969254<br>
          <a href="${CONSTRUCTION_WEBSITE}" style="color:#123756;text-decoration:none;">bryantconstructiongroup.co.uk</a>
        </td></tr>
      </table>
    </td></tr>
  </table></body></html>`;
}

export function teethWhiteningOutreachHtml(body: string, isFollowUp = false) {
  const offer = isFollowUp ? '' : `
    <tr><td style="padding:0 28px 20px;">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#eef7ff;border:1px solid #c6dff3;border-radius:10px;">
        <tr><td style="padding:16px 18px;color:#12649c;font-family:Arial,sans-serif;">
          <strong style="display:block;font-size:16px;margin-bottom:5px;">A Local Smile Partnership</strong>
          <span style="font-size:13px;line-height:1.5;">Professional, pain-free teeth whitening from £69 · No-obligation partnership chat</span>
        </td></tr>
      </table>
    </td></tr>`;
  return `<!doctype html><html><body style="margin:0;padding:0;background:#f3f7fb;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f3f7fb;padding:24px 10px;">
    <tr><td align="center">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:620px;background:#ffffff;border:1px solid #d6e4ef;border-radius:14px;overflow:hidden;box-shadow:0 5px 20px rgba(18,100,156,.09);">
        <tr><td style="background:#12649c;padding:18px 28px;">
          <a href="${TEETH_WEBSITE}" style="text-decoration:none;"><img src="${TEETH_LOGO}" width="130" height="130" alt="Mr White Teeth Whitening" style="display:block;width:130px;height:130px;object-fit:contain;border:0;border-radius:10px;"></a>
        </td></tr>
        <tr><td style="padding:26px 28px 8px;font-family:Arial,sans-serif;">${paragraphs(body)}</td></tr>
        ${offer}
        <tr><td align="center" style="padding:0 28px 24px;">
          <a href="${TEETH_WEBSITE}" style="display:inline-block;background:#ef476f;color:#ffffff;text-decoration:none;font-family:Arial,sans-serif;font-size:14px;font-weight:bold;padding:12px 22px;border-radius:8px;">Explore a Local Partnership</a>
        </td></tr>
        <tr><td style="background:#f5f8fb;padding:16px 28px;color:#62778a;font-family:Arial,sans-serif;font-size:12px;line-height:1.5;text-align:center;">
          Bryant Group Holdings Ltd &nbsp;·&nbsp; Company No. ${HOLDINGS_COMPANY_NUMBER} &nbsp;·&nbsp; 07843 969254<br>
          <a href="${TEETH_WEBSITE}" style="color:#12649c;text-decoration:none;">teethwhiteningbournemouth.co.uk</a>
        </td></tr>
      </table>
    </td></tr>
  </table></body></html>`;
}
