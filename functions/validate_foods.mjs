import XLSX from 'xlsx';

const ID = 'id (tự sinh, để trống)';
const NS = 'name_search (tự sinh, để trống)';
const MICRO = ['cholesterol','calcium','phosphorus','iron','sodium','potassium','beta_carotene','vitamin_a','vitamin_b1','vitamin_c'];

const wb = XLSX.readFile('C:/Users/Admin/Downloads/HLife_food_database_merged.xlsx');
const ws = wb.Sheets['foods'];
const rows = XLSX.utils.sheet_to_json(ws, { defval: null });
const cleaned = rows.filter((r) => String(r[ID] ?? '').trim() !== 'stt');

console.log('raw rows =', rows.length, '| sau khi bỏ dòng rác =', cleaned.length);

const seenIds = new Map();
const problems = [];
let badNumeric = 0, dishNsMismatch = 0;
const typeCount = { dish: 0, ingredient: 0 };

for (const [i, r] of cleaned.entries()) {
  const n = i + 2 + (i >= 162 ? 1 : 0); // excel line (đã dịch sau khi bỏ dòng stt)
  const id = String(r[ID] ?? '').trim();
  const p = (lvl, msg) => problems.push(`${lvl} L${n} (${id}): ${msg}`);

  if (!id) { p('ERR', 'thiếu id'); continue; }
  if (seenIds.has(id)) p('ERR', `id trùng dòng ${seenIds.get(id)}`);
  seenIds.set(id, n);

  const type = String(r['type'] ?? '').trim();
  if (type === 'dish') typeCount.dish++;
  else if (type === 'ingredient') typeCount.ingredient++;
  else p('ERR', `type bất thường "${type}"`);

  const name = String(r['name'] ?? '').trim();
  if (!name) p('ERR', 'thiếu name');

  const ns = String(r[NS] ?? '').trim().toLowerCase();
  const expected = normalize(name);
  if (!ns) { p('ERR', 'thiếu name_search'); }
  else if (ns !== expected && type === 'ingredient') { dishNsMismatch++; p('WARN', `name_search "${ns}" != chuẩn "${expected}" (id khớp show) DUOC`); }

  const numericErr = [];
  for (const c of ['serving_g','calo','protein','fat','carb','fiber', ...MICRO]) {
    const v = r[c];
    if (v === null || v === undefined || v === '') continue; // dish lơ micrô = rỗng, hợp lệ
    if (typeof v !== 'number' || Number.isNaN(v)) { numericErr.push(`${c}=${JSON.stringify(v)}`); }
  }
  if (numericErr.length) p('ERR', `kiểu số: ${numericErr.join(', ')}`);
}

function normalize(s) {
  const src = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
  const dst = [
    ...Array(17).fill('a'), ...Array(11).fill('e'), ...Array(5).fill('i'),
    ...Array(17).fill('o'), ...Array(11).fill('u'), ...Array(5).fill('y'), 'd',
  ].join('');
  const map = new Map([...src].map((ch, i) => [ch, dst[i]]));
  return s.toLowerCase().split('').map((ch) => map.get(ch) ?? ch).join('')
    .split(/\s+/).filter((w) => w).join(' ');
}

console.log('type:', JSON.stringify(typeCount));
console.log('số id duy nhất:', new Set(cleaned.map((r) => String(r[ID]).trim())).size);
console.log(`name_search sai chuẩn (chỉ dish, không chặn):`, dishNsMismatch);
console.log('\n--- PROBLEMS ---');
console.log(problems.length ? problems.join('\n') : '(không có lỗi)');