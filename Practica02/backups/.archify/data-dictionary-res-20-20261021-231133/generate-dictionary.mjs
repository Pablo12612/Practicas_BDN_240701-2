import fs from 'node:fs';
import path from 'node:path';

const source = path.resolve(process.argv[2] || 'RES 20.sql');
const destination = path.resolve(process.argv[3] || 'diccionario-datos-res-20.html');
const sql = fs.readFileSync(source, 'utf8');

const tableGlossary = {
  tb_users: 'Registro de las personas que pueden usar el sistema.',
  tb_products: 'Catálogo de los productos que se pueden ofrecer o vender.',
  tb_buyer_orders: 'Órdenes de compra registradas para un vendedor.',
  tb_carts: 'Carritos de compra activos de cada usuario.',
  tb_logs: 'Bitácora: historial de acciones realizadas en las tablas.',
  tbc_payment_methods_types: 'Catálogo de tipos de pago disponibles.',
  tbd_products_users_providers: 'Vincula cada producto con el usuario que lo provee.',
  tbd_user_payment_methods: 'Métodos de pago guardados por cada usuario.',
  tbd_users_wishlist_products: 'Productos que un usuario guardó en su lista de deseos.'
};
const fieldGlossary = {
  id: 'Identificador interno único del registro.',
  user_id: 'Identificador del usuario relacionado.',
  seller_id: 'Identificador del usuario que actúa como vendedor.',
  product_id: 'Identificador del producto relacionado.',
  payment_method_type_id: 'Identificador del tipo de método de pago.',
  sku: 'Clave comercial única para identificar el producto.',
  name: 'Nombre visible del producto.', nick: 'Nombre corto o alias del usuario.',
  email: 'Correo electrónico de contacto o acceso.', password: 'Contraseña del usuario; debe tratarse como información sensible.',
  price: 'Precio unitario registrado para el producto.', stock: 'Cantidad disponible en inventario.',
  subtotal: 'Importe de productos antes del envío.', shipping_cost: 'Costo de envío de la orden.',
  fulfillment_status: 'Etapa logística de la orden, desde pendiente hasta entregada o devuelta.',
  status: 'Indicador de vigencia: normalmente activo (1) o inactivo (0).',
  creation_date: 'Fecha y hora en que se creó el registro.', last_update: 'Fecha y hora de la última modificación.',
  table_name: 'Nombre de la tabla donde ocurrió la acción.', table_operation: 'Tipo de acción registrada: crear, consultar, modificar o eliminar.',
  db_user: 'Cuenta de base de datos que ejecutó la acción.', operation_date: 'Fecha y hora de la acción registrada.',
  table_description: 'Detalle legible de la acción realizada.', operation_status: 'Resultado o vigencia de la acción registrada.',
  provider: 'Empresa o plataforma que proporciona el método de pago.', provider_method_ref: 'Referencia del método en la plataforma proveedora.',
  label: 'Nombre breve con el que el usuario reconoce su método de pago.', last_four: 'Últimos cuatro dígitos de referencia; no almacena el número completo.',
  is_default: 'Indica si este es el método de pago principal del usuario.',
  description: 'Descripción legible del registro.', type: 'Clasificación o tipo del registro.'
};
const esc = value => String(value).replace(/[&<>"']/g, char => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[char]));
const escapeRegExp = value => value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
const words = name => name.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
function tupleCount(values) {
  let count = 0, depth = 0, quote = false, escaped = false;
  for (const char of values) {
    if (quote) { if (escaped) escaped = false; else if (char === '\\') escaped = true; else if (char === "'") quote = false; continue; }
    if (char === "'") quote = true;
    else if (char === '(') { if (depth++ === 0) count++; }
    else if (char === ')') depth--;
  }
  return count;
}
function labelFor(type) {
  const t = type.toLowerCase();
  if (/bit\(1\)|tinyint\(1\)|boolean/.test(t)) return ['✓ Sí/No', 'boolean'];
  if (/date|time|year/.test(t)) return ['◷ Fecha', 'date'];
  if (/int|decimal|float|double|numeric/.test(t)) return ['# Número', 'number'];
  if (/blob|binary/.test(t)) return ['▣ Binario', 'binary'];
  return ['Aa Texto', 'text'];
}
function inferField(name, type) {
  const key = name.toLowerCase();
  if (fieldGlossary[key]) return fieldGlossary[key];
  if (key.endsWith('_id')) return `Identificador del registro relacionado: ${words(name.slice(0, -3))}.`;
  if (key.includes('date')) return 'Fecha y hora relevante para este registro.';
  if (key.includes('status')) return 'Estado operativo del registro.';
  if (/enum/i.test(type)) return 'Opción controlada que clasifica el registro.';
  return `Dato de ${words(name)} usado por el proceso del sistema.`;
}
function parseTables(text) {
  const tables = [], create = /CREATE TABLE `([^`]+)` \(([\s\S]*?)\) ENGINE/g;
  let match;
  while ((match = create.exec(text))) {
    const [ , name, block] = match;
    const columns = [];
    for (const line of block.split(/\r?\n/)) {
      const col = line.match(/^\s*`([^`]+)`\s+(.+?)(?:,)?$/);
      if (!col) continue;
      const definition = col[2].replace(/,$/, '');
      const type = (definition.match(/^(enum\([^)]*\)|[a-z]+(?:\([^)]*\))?(?:\s+unsigned)?)/i) || [,'—'])[1];
      const isPK = new RegExp('PRIMARY KEY \\([^)]*`' + escapeRegExp(col[1]) + '`').test(block);
      const unique = new RegExp('UNIQUE KEY[^\\n]*`' + escapeRegExp(col[1]) + '`').test(block);
      const fk = block.match(new RegExp('FOREIGN KEY \\(`' + escapeRegExp(col[1]) + '`\\) REFERENCES `([^`]+)` \\(`([^`]+)`\\)'));
      columns.push({ name: col[1], type, required: !/\bDEFAULT NULL\b|\bNULL\b/i.test(definition.replace(/NOT NULL/i,'')), pk: isPK, unique, fk: fk && { table: fk[1], column: fk[2] }, definition });
    }
    let records = 0;
    const insert = new RegExp('INSERT INTO `' + escapeRegExp(name) + '` VALUES ([\\s\\S]*?);', 'g'); let row;
    while ((row = insert.exec(text))) records += tupleCount(row[1]);
    tables.push({ name, columns, records, description: tableGlossary[name] || `Información operativa almacenada en ${name}.` });
  }
  return tables;
}
const tables = parseTables(sql);
const totalRows = tables.reduce((sum, table) => sum + table.records, 0);
const relations = tables.flatMap(table => table.columns.filter(c => c.fk).map(c => ({ from: table.name, field: c.name, to: c.fk.table, toField: c.fk.column })));
const card = table => `<article class="table-card" data-search="${esc([table.name, table.description, ...table.columns.map(c => c.name + ' ' + inferField(c.name,c.type))].join(' ').toLowerCase())}">
  <button class="table-head" aria-expanded="false"><span><code>${esc(table.name)}</code><small>${esc(table.description)}</small></span><span class="record-count">${table.records.toLocaleString('es-MX')} registros</span><b class="chev">⌄</b></button>
  <div class="table-body"><div class="table-summary">${table.columns.length} campos · ${table.columns.filter(c=>c.pk).length} llave(s) primaria(s) · ${table.columns.filter(c=>c.fk).length} relación(es) saliente(s)</div>
  <div class="table-wrap"><table><thead><tr><th>Campo técnico</th><th>Tipo SQL</th><th>Qué significa en palabras sencillas</th><th>Atributos</th></tr></thead><tbody>
  ${table.columns.map(c => { const [badge, kind] = labelFor(c.type); const attrs = [c.pk && '🔑 Llave primaria', c.unique && 'Único', c.fk && `↗ Conecta con ${c.fk.table}.${c.fk.column}`, c.required ? '● Obligatorio' : '○ Puede quedar vacío'].filter(Boolean); return `<tr><td><code>${esc(c.name)}</code><span class="badge ${kind}">${badge}</span></td><td><code>${esc(c.type)}</code></td><td>${esc(inferField(c.name,c.type))}</td><td>${attrs.map(a=>`<span class="attr">${esc(a)}</span>`).join('')}</td></tr>`; }).join('')}
  </tbody></table></div></div></article>`;
const relationCards = relations.length ? relations.map(r => `<li><code>${esc(r.from)}.${esc(r.field)}</code> → <code>${esc(r.to)}.${esc(r.toField)}</code><p>Los registros de <code>${esc(r.from)}</code> se conectan con <code>${esc(r.to)}</code> mediante <code>${esc(r.field)}</code>. Cada registro conserva así la referencia a su ${esc(r.field.replace(/_ID$/i,'').replace(/_/g,' '))} específico.</p></li>`).join('') : '<li>No se declararon llaves foráneas en el respaldo.</li>';
const html = `<!doctype html><html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Diccionario de Datos — RES 20</title><style>
:root{--ink:#172033;--muted:#667085;--paper:#f7f9fc;--line:#e4e8f0;--brand:#4f46e5;--brand2:#0ea5e9;--good:#087f5b}*{box-sizing:border-box}body{margin:0;background:var(--paper);color:var(--ink);font:15px/1.5 Inter,ui-sans-serif,system-ui,sans-serif}.hero{padding:64px max(24px,calc((100vw - 1160px)/2));color:white;background:radial-gradient(circle at 85% 18%,#38bdf8 0,transparent 25%),linear-gradient(125deg,#172554,#4338ca)}.eyebrow{text-transform:uppercase;letter-spacing:.12em;font-size:.75rem;font-weight:800;opacity:.75}.hero h1{font-size:clamp(2rem,5vw,3.8rem);line-height:1.05;margin:.3rem 0 1rem}.hero p{max-width:760px;font-size:1.05rem;opacity:.9}.facts{display:flex;flex-wrap:wrap;gap:12px;margin-top:25px}.fact{background:#ffffff1c;border:1px solid #ffffff30;border-radius:12px;padding:10px 14px}.fact b{display:block;font-size:1.3rem}.shell{max-width:1160px;margin:0 auto;padding:34px 24px 72px}.notice{background:#eef6ff;border-left:4px solid var(--brand2);padding:15px 18px;border-radius:8px;margin-bottom:28px}.controls{display:flex;gap:12px;align-items:center;margin:26px 0 16px}.search{flex:1;position:relative}.search input{width:100%;border:1px solid var(--line);border-radius:12px;padding:14px 16px;font:inherit;box-shadow:0 4px 14px #1e293b0a}.button{border:1px solid #c7d2fe;background:white;color:#3730a3;border-radius:10px;padding:11px 13px;font:inherit;font-weight:700;cursor:pointer}.button:hover{background:#eef2ff}.table-card{background:white;border:1px solid var(--line);border-radius:15px;margin:12px 0;overflow:hidden;box-shadow:0 5px 18px #24304a08;transition:transform .2s,box-shadow .2s}.table-card:hover{transform:translateY(-2px);box-shadow:0 10px 26px #24304a14}.table-head{width:100%;display:flex;align-items:center;gap:16px;text-align:left;border:0;background:white;padding:19px 20px;cursor:pointer;color:inherit}.table-head>span:first-child{flex:1}.table-head code{font-size:1rem;font-weight:800;color:#312e81}.table-head small{display:block;color:var(--muted);margin-top:3px}.record-count{background:#eef2ff;color:#4338ca;font-weight:800;border-radius:999px;padding:5px 10px;white-space:nowrap}.chev{font-size:1.4rem;transition:transform .25s}.open .chev{transform:rotate(180deg)}.table-body{max-height:0;overflow:hidden;transition:max-height .45s ease}.open .table-body{max-height:4000px}.table-summary{padding:13px 20px;background:#fafbff;color:var(--muted);font-size:.88rem;border-top:1px solid var(--line)}.table-wrap{overflow:auto}table{width:100%;border-collapse:collapse;min-width:800px}th{background:#f8fafc;text-align:left;color:#475467;font-size:.76rem;text-transform:uppercase;letter-spacing:.05em}th,td{padding:13px 16px;border-top:1px solid var(--line);vertical-align:top}td code{font-size:.87rem}.badge,.attr{display:inline-block;border-radius:999px;padding:3px 7px;font-size:.74rem;white-space:nowrap;margin:4px 4px 0 0}.badge{background:#f2f4f7;color:#344054}.badge.number{background:#eff8ff;color:#175cd3}.badge.date{background:#fdf2fa;color:#c11574}.badge.boolean{background:#ecfdf3;color:#027a48}.badge.binary{background:#fff6ed;color:#c4320a}.attr{background:#f8f9fc;color:#475467;border:1px solid #e4e7ec}.relations{margin-top:40px;background:white;border:1px solid var(--line);border-radius:15px;padding:22px}.relations h2{margin-top:0}.relations ul{padding:0;list-style:none}.relations li{padding:14px 0;border-top:1px solid var(--line)}.relations li:first-child{border-top:0}.relations p{margin:.35rem 0 0;color:var(--muted)}.empty{color:var(--muted);padding:22px;text-align:center}.footer{color:var(--muted);font-size:.86rem;margin-top:28px}@media(max-width:600px){.hero{padding:42px 22px}.shell{padding:24px 16px}.table-head{padding:16px;align-items:flex-start}.record-count{font-size:.75rem}.controls{align-items:stretch;flex-direction:column}}</style></head><body>
<header class="hero"><div class="eyebrow">Respaldo analizado · ${esc(path.basename(source))}</div><h1>Diccionario de Datos<br>claro y navegable</h1><p>Una guía para entender qué información guarda el sistema, sin perder los nombres y tipos técnicos originales.</p><div class="facts"><div class="fact"><b>${tables.length}</b>tablas</div><div class="fact"><b>${totalRows.toLocaleString('es-MX')}</b>registros en el respaldo</div><div class="fact"><b>${relations.length}</b>relaciones declaradas</div></div></header>
<main class="shell"><div class="notice"><b>Cómo leerlo:</b> los nombres y tipos SQL se conservan tal cual están en el respaldo. Las explicaciones funcionales fueron inferidas a partir de la estructura, las llaves y los datos disponibles; confírmelas con el responsable del proceso antes de convertirlas en política oficial.</div><section aria-label="Tablas"><div class="controls"><div class="search"><input id="search" type="search" placeholder="Buscar una tabla, campo o significado…" aria-label="Buscar en el diccionario"></div><button class="button" id="toggleAll">Expandir todo</button></div><div id="empty" class="empty" hidden>No hay coincidencias. Prueba otro término.</div><div id="tables">${tables.map(card).join('')}</div></section><section class="relations"><h2>Relaciones explicadas sin jerga</h2><p>Estas conexiones provienen de las llaves foráneas declaradas en el archivo SQL.</p><ul>${relationCards}</ul></section><p class="footer">Generado desde <code>${esc(path.basename(source))}</code>. Conteos calculados sobre las sentencias <code>INSERT</code> incluidas en el respaldo.</p></main><script>const cards=[...document.querySelectorAll('.table-card')];const setOpen=(c,on)=>{c.classList.toggle('open',on);c.querySelector('.table-head').setAttribute('aria-expanded',on)};cards.forEach(c=>c.querySelector('.table-head').addEventListener('click',()=>setOpen(c,!c.classList.contains('open'))));const all=document.querySelector('#toggleAll');all.addEventListener('click',()=>{const open=cards.some(c=>!c.hidden&&!c.classList.contains('open'));cards.filter(c=>!c.hidden).forEach(c=>setOpen(c,open));all.textContent=open?'Contraer todo':'Expandir todo'});document.querySelector('#search').addEventListener('input',e=>{const q=e.target.value.trim().toLowerCase();let n=0;cards.forEach(c=>{const hit=c.dataset.search.includes(q);c.hidden=!hit;if(hit){n++;if(q)setOpen(c,true)}});document.querySelector('#empty').hidden=!!n;all.textContent='Expandir todo'});</script></body></html>`;
fs.mkdirSync(path.dirname(destination), { recursive: true });
fs.writeFileSync(destination, html, 'utf8');
console.log(`Generated ${destination} with ${tables.length} tables, ${totalRows} rows, and ${relations.length} foreign-key relations.`);
