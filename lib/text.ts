const namedEntities: Record<string, string> = {
  amp: '&', apos: "'", gt: '>', hellip: '…', laquo: '«', ldquo: '“',
  lsquo: '‘', lt: '<', mdash: '—', nbsp: ' ', ndash: '–', quot: '"',
  raquo: '»', rdquo: '”', rsquo: '’',
};

/** Decode text copied from public HTML without interpreting it as markup. */
export function decodeHtmlEntities(value: string) {
  return value.replace(/&(#x[0-9a-f]+|#\d+|[a-z]+);/gi, (entity, code: string) => {
    if (code[0] !== '#') return namedEntities[code.toLowerCase()] ?? entity;
    const numeric = code[1].toLowerCase() === 'x'
      ? Number.parseInt(code.slice(2), 16)
      : Number.parseInt(code.slice(1), 10);
    return Number.isFinite(numeric) && numeric > 0 && numeric <= 0x10ffff
      ? String.fromCodePoint(numeric)
      : entity;
  });
}
