#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const input = path.resolve(process.argv[2] || path.join(HERE, 'db_test_7b.sql'));
const outDir = path.resolve(process.argv[3] || path.join(HERE, '.archify', 'erd-db-test-7b-20261015-131200'));
const cli = process.env.ARCHIFY_CLI || 'C:/Users/PC-28/.agents/skills/archify/bin/archify.mjs';
const sql = fs.readFileSync(input, 'utf8');

function splitTopLevel(source) {
  const parts = []; let start = 0, depth = 0, quote = '', escaped = false;
  for (let i = 0; i < source.length; i++) {
    const c = source[i];
    if (quote) {
      if (escaped) { escaped = false; continue; }
      if (c === '\\') { escaped = true; continue; }
      if (c === quote) { if (source[i + 1] === quote) { i++; continue; } quote = ''; }
      continue;
    }
    if (c === "'" || c === '"' || c === '`') { quote = c; continue; }
    if (c === '(') depth++;
    else if (c === ')') depth--;
    else if (c === ',' && depth === 0) { parts.push(source.slice(start, i).trim()); start = i + 1; }
  }
  parts.push(source.slice(start).trim());
  return parts;
}

function countTuples(values) {
  let depth = 0, quote = '', escaped = false, count = 0;
  for (let i = 0; i < values.length; i++) {
    const c = values[i];
    if (quote) {
      if (escaped) { escaped = false; continue; }
      if (c === '\\') { escaped = true; continue; }
      if (c === quote) { if (values[i + 1] === quote) { i++; continue; } quote = ''; }
      continue;
    }
    if (c === "'" || c === '"') { quote = c; continue; }
    if (c === '(') { if (depth === 0) count++; depth++; }
    else if (c === ')') depth--;
  }
  return count;
}

function scanInsertCounts(source) {
  const counts = new Map();
  const re = /INSERT\s+INTO\s+`([^`]+)`\s*(?:\([^)]*\)\s*)?VALUES\s+/gi;
  for (let m; (m = re.exec(source));) {
    const begin = re.lastIndex; let quote = '', escaped = false;
    for (let i = begin; i < source.length; i++) {
      const c = source[i];
      if (quote) {
        if (escaped) { escaped = false; continue; }
        if (c === '\\') { escaped = true; continue; }
        if (c === quote) { if (source[i + 1] === quote) { i++; continue; } quote = ''; }
      } else if (c === "'" || c === '"') quote = c;
      else if (c === ';') {
        counts.set(m[1], (counts.get(m[1]) || 0) + countTuples(source.slice(begin, i)));
        re.lastIndex = i + 1;
        break;
      }
    }
  }
  return counts;
}

function parseTable(name, body, count) {
  const parts = splitTopLevel(body);
  const primary = new Set(); const unique = new Set(); const fks = [];
  for (const part of parts) {
    let m = part.match(/^PRIMARY\s+KEY\s*\(([^)]+)\)/i);
    if (m) { for (const col of m[1].matchAll(/`([^`]+)`/g)) primary.add(col[1]); continue; }
    m = part.match(/^(?:CONSTRAINT\s+`[^`]+`\s+)?UNIQUE(?:\s+KEY|\s+INDEX)?\s*(?:`[^`]+`\s*)?\(([^)]+)\)/i);
    if (m) { for (const col of m[1].matchAll(/`([^`]+)`/g)) unique.add(col[1]); continue; }
    m = part.match(/^CONSTRAINT\s+`([^`]+)`\s+FOREIGN\s+KEY\s*\(([^)]+)\)\s+REFERENCES\s+`([^`]+)`\s*\(([^)]+)\)(.*)$/i);
    if (m) {
      const childCols = [...m[2].matchAll(/`([^`]+)`/g)].map(x => x[1]);
      const parentCols = [...m[4].matchAll(/`([^`]+)`/g)].map(x => x[1]);
      fks.push({ name: m[1], childCols, parent: m[3], parentCols, options: m[5].trim() });
    }
  }
  const columns = []; const properties = [];
  for (const part of parts) {
    const m = part.match(/^`([^`]+)`\s+(.+)$/s); if (!m) continue;
    const col = m[1], declaration = m[2].replace(/\s+/g, ' ').trim();
    const tm = declaration.match(/^([A-Za-z]+(?:\s*\([^)]*\))?(?:\s+unsigned)?(?:\s+zerofill)?)/i);
    const sqlType = tm ? tm[1].replace(/\s+/g, ' ').trim() : declaration.split(/\s+/)[0];
    const attrs = [];
    if (/\bNOT NULL\b/i.test(declaration)) attrs.push('NN'); else attrs.push('NULL');
    if (/\bAUTO_INCREMENT\b/i.test(declaration)) properties.push(`${col}: AUTO_INCREMENT`);
    const d = declaration.match(/\bDEFAULT\s+((?:'[^']*(?:''[^']*)*')|(?:\([^)]*\))|[^\s,]+)/i);
    if (d && !/^NULL$/i.test(d[1])) properties.push(`${col}: DEFAULT ${d[1]}`);
    const u = declaration.match(/\bON UPDATE\s+(.+)$/i); if (u) properties.push(`${col}: ON UPDATE ${u[1].trim()}`);
    const keys = [];
    if (primary.has(col)) keys.push('pk');
    if (unique.has(col) && !primary.has(col)) keys.push('uk');
    const fk = fks.find(x => x.childCols.includes(col)); if (fk) keys.push('fk');
    const attribute = { name: col, type: `${sqlType} [${attrs.join(' · ')}]` };
    if (keys.length) attribute.key = keys.length === 1 ? keys[0] : keys;
    if (fk) attribute.references = `${fk.parent}.${fk.parentCols[fk.childCols.indexOf(col)]}`;
    columns.push(attribute);
  }
  return { columns, fks, count, properties };
}

const tables = new Map();
const tableRe = /CREATE\s+TABLE\s+`([^`]+)`\s*\(([\s\S]*?)\)\s*ENGINE=/gi;
for (let m; (m = tableRe.exec(sql));) tables.set(m[1], parseTable(m[1], m[2], 0));
const counts = scanInsertCounts(sql);
for (const [name, table] of tables) table.count = counts.get(name) || 0;
if (!tables.size) throw new Error('No se encontraron sentencias CREATE TABLE en el respaldo.');

const domains = {
  identidad: ['tb_users', 'tb_carts'],
  catalogo: ['tb_products', 'tbc_categories'],
  relaciones: ['tbd_products_categories', 'tbd_products_users_providers', 'tbd_users_wishlist_products'],
  auditoria: ['tb_logs']
};
const entities = [];
const positions = new Map();
for (const [tag, names] of Object.entries(domains)) {
  let row = 0;
  for (const name of names) {
    if (!tables.has(name)) continue;
    const pos = { row: row++, col: Object.keys(domains).indexOf(tag) };
    positions.set(name, pos);
    const table = tables.get(name);
    const rowCount = table.count.toLocaleString('es-MX');
    entities.push({ id: name, label: `${name} · ${rowCount} filas`, tag, ...pos, sublabel: `Total registros: ${rowCount}`, attributes: table.columns });
  }
}
for (const [name, table] of tables) {
  if (!positions.has(name)) {
    const col = Object.keys(domains).length; positions.set(name, { row: 0, col });
    const rowCount = table.count.toLocaleString('es-MX');
    entities.push({ id: name, label: `${name} · ${rowCount} filas`, tag: 'otros', row: 0, col, sublabel: `Total registros: ${rowCount}`, attributes: table.columns });
  }
}

const relationships = [];
for (const [child, table] of tables) for (const fk of table.fks) {
  if (!tables.has(fk.parent)) continue;
  if (child === fk.parent) continue;
  const isUnique = fk.childCols.every(c => table.columns.some(a => a.name === c && (a.key === 'uk' || Array.isArray(a.key) && a.key.includes('uk')))) || fk.childCols.every(c => table.columns.some(a => a.name === c && (a.key === 'pk' || Array.isArray(a.key) && a.key.includes('pk')))) && table.columns.filter(a => a.key === 'pk' || Array.isArray(a.key) && a.key.includes('pk')).length === fk.childCols.length;
  const nullable = fk.childCols.some(c => { const a = table.columns.find(x => x.name === c); return a && a.type.includes('NULLABLE'); });
  relationships.push({ id: `rel_${relationships.length + 1}`, from: fk.parent, to: child, label: `${fk.parentCols.join('+')} → ${fk.childCols.join('+')}`, fromCardinality: 'one', toCardinality: isUnique ? 'one' : 'many', fromOptional: nullable, toOptional: true, identifying: fk.childCols.every(c => table.columns.some(a => a.name === c && (a.key === 'pk' || Array.isArray(a.key) && a.key.includes('pk')))) });
}

const candidate = {
  schema_version: 1,
  diagram_type: 'erd',
  meta: {
    title: 'Modelo EERD · db_test_7b', locale: 'es',
    output: path.relative(HERE, path.join(outDir, 'eerd-db-test-7b.html')).split(path.sep).join('/'),
    quality_profile: 'standard',
    subtitle: `${tables.size} tablas · ${relationships.length} relaciones entre tablas · conteos leídos de INSERT INTO`,
    views: [
      { id: 'nucleo', label: 'Usuarios y carrito', focus: ['tb_users', 'tb_carts'] },
      { id: 'catalogo', label: 'Catálogo', focus: ['tb_products', 'tbc_categories'] },
      { id: 'relaciones', label: 'Relaciones y propiedad', focus: ['tbd_products_categories', 'tbd_products_users_providers', 'tbd_users_wishlist_products'] },
      { id: 'auditoria', label: 'Auditoría', focus: ['tb_logs'] }
    ]
  },
  layout: { mode: 'grid', gapX: 64, gapY: 42, entityW: 330 },
  entities: entities.map(entity => ({ ...entity, width: entity.id === 'tbd_products_users_providers' ? 480 : entity.id === 'tb_logs' ? 470 : 330 })), relationships,
  cards: [
    { dot: 'violet', title: 'Relación recursiva', items: ['tbc_categories.sup_id_category → tbc_categories.ID (FK autorreferente; nullable; ON DELETE SET NULL, ON UPDATE CASCADE). Archify ERD no permite conectar una entidad consigo misma, por eso se documenta aquí.'] },
    ...[...tables].filter(([, table]) => table.properties.length).map(([name, table]) => ({ dot: 'cyan', title: `${name} · defaults y generación`, items: table.properties })),
    { dot: 'slate', title: 'Restricciones del respaldo', items: ['No hay restricciones CHECK declaradas. La nulabilidad aparece junto al tipo y las claves PK, FK y UNIQUE se marcan en cada atributo.', 'tb_logs.table_name almacena nombres de tabla, pero no tiene una FOREIGN KEY declarada.'] }
  ]
};

fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(path.join(outDir, 'candidate.json'), JSON.stringify(candidate, null, 2) + '\n', 'utf8');
console.log(`Analizadas ${tables.size} tablas y ${relationships.length} claves foráneas:`);
for (const [name, table] of tables) console.log(`  ${name}: ${table.columns.length} columnas, ${table.count.toLocaleString('es-MX')} registros`);
if (process.argv.includes('--render')) {
  const artifact = path.join(outDir, 'eerd-db-test-7b.html');
  const args = [cli, 'finalize', 'erd', path.join(outDir, 'candidate.json'), artifact, '--quality', 'standard', '--json'];
  if (fs.existsSync(artifact)) {
    let revision = 2;
    while (fs.existsSync(path.join(outDir, `review-${revision}`))) revision++;
    args.splice(args.length - 1, 0, '--out-dir', path.join(outDir, `review-${revision}`));
  }
  const result = spawnSync(process.execPath, args, { stdio: 'inherit', cwd: HERE });
  if (result.error) throw result.error;
  process.exitCode = result.status ?? 1;
}
