import XLSX from 'xlsx';
import fs from 'fs';
import os from 'os';
import path from 'path';

const PROJECT = 'healthlife-e89fd';
const BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)`;
const XLSX_PATH = process.argv.find((a) => a.startsWith('--file='))?.slice(7)
  ?? 'C:/Users/Admin/Downloads/HLife_food_database_merged.xlsx';
const DRY = process.argv.includes('--dry-run');

const ID = 'id (tự sinh, để trống)';
const NS = 'name_search (tự sinh, để trống)';
const NUMERIC = ['serving_g', 'calo', 'protein', 'fat', 'carb', 'fiber',
  'cholesterol', 'calcium', 'phosphorus', 'iron', 'sodium', 'potassium',
  'beta_carotene', 'vitamin_a', 'vitamin_b1', 'vitamin_c'];

function token() {
  const cfgPath = path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json');
  const cfg = JSON.parse(fs.readFileSync(cfgPath, 'utf8'));
  const t = cfg.tokens;
  if (!t?.access_token) throw new Error('Không tìm thấy access_token trong ' + cfgPath);
  if (t.expires_at && Date.now() > t.expires_at - 120000) {
    throw new Error('Access token hết hạn gần mốc 2 phút, cần chạy lại `firebase login`.');
  }
  return t.access_token;
}

function toField(v) {
  if (typeof v === 'number' && Number.isFinite(v)) {
    return Number.isInteger(v) ? { integerValue: v } : { doubleValue: v };
  }
  return { stringValue: String(v) };
}

function toDoc(r) {
  const fields = { name: toField(String(r['name']).trim()), name_search: toField(String(r[NS]).trim()) };
  for (const k of ['type', 'group']) fields[k] = toField(String(r[k]).trim());
  for (const k of NUMERIC) {
    const v = r[k];
    if (typeof v === 'number' && Number.isFinite(v)) fields[k] = toField(v);
  }
  return { name: `projects/${PROJECT}/databases/(default)/documents/foods/${String(r[ID]).trim()}`, fields };
}

async function api(pathUrl, opts = {}) {
  const res = await fetch(pathUrl, {
    headers: { 'Authorization': `Bearer ${token()}`, 'Content-Type': 'application/json' },
    ...opts,
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`${res.status} ${res.statusText} — ${body.slice(0, 500)}`);
  }
  return res.json();
}

async function existingIds() {
  const ids = [];
  let pageToken = '';
  do {
    const q = `pageSize=300${pageToken ? `&pageToken=${encodeURIComponent(pageToken)}` : ''}`;
    const j = await api(`${BASE}/documents/foods?${q}`);
    for (const d of j.documents ?? []) ids.push(d.name.split('/').pop());
    pageToken = j.nextPageToken ?? '';
  } while (pageToken);
  return new Set(ids);
}

const wb = XLSX.readFile(XLSX_PATH);
const rows = XLSX.utils.sheet_to_json(wb.Sheets['foods'], { defval: null })
  .filter((r) => String(r[ID] ?? '').trim() !== 'stt');
console.log(`Đọc ${rows.length} dòng từ ${XLSX_PATH}`);

const existing = await existingIds();
console.log(`Đã có sẵn ${existing.size} doc trong collection foods`);

const toWrite = rows.filter((r) => !existing.has(String(r[ID]).trim()))
  .map(toDoc);
const skipped = rows.length - toWrite.length;
console.log(`Bỏ qua ${skipped} doc trùng, sẽ ghi ${toWrite.length} doc`);

if (DRY) { console.log('DRY RUN — không ghi.'); process.exit(0); }
if (toWrite.length === 0) { console.log('Không có gì để ghi.'); process.exit(0); }

const CHUNK = 450;
let done = 0;
for (let i = 0; i < toWrite.length; i += CHUNK) {
  const chunk = toWrite.slice(i, i + CHUNK);
  const j = await api(`${BASE}/documents:commit`, {
    method: 'POST',
    body: JSON.stringify({ writes: chunk.map((w) => ({ update: w })) }),
  });
  const n = (j.writeResults ?? []).length;
  done += n;
  console.log(`Commit ${i / CHUNK + 1}: đã ghi ${n} (tổng ${done}/${toWrite.length})`);
}
console.log('XONG import.');