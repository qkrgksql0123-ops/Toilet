// 서울시 공중화장실 Open API
const BATCH_SIZE = 1000;

async function fetchToiletBatch(start, end) {
  const res = await fetch(`/api/toilets?start=${start}&end=${end}`);
  if (!res.ok) throw new Error(`API 오류: ${res.status}`);
  const json = await res.json();
  const data = json.mgisToiletPoi;
  if (!data || data.RESULT.CODE !== 'INFO-000') {
    throw new Error(data?.RESULT?.MESSAGE || 'API 응답 오류');
  }
  return { total: data.list_total_count, rows: data.row };
}

async function fetchAllToilets(onProgress) {
  const { total, rows } = await fetchToiletBatch(1, BATCH_SIZE);
  if (onProgress) onProgress(rows.length, total);

  const remaining = [];
  for (let start = BATCH_SIZE + 1; start <= total; start += BATCH_SIZE) {
    const end = Math.min(start + BATCH_SIZE - 1, total);
    remaining.push(fetchToiletBatch(start, end));
  }

  const batches = await Promise.all(remaining);
  batches.forEach(b => {
    rows.push(...b.rows);
    if (onProgress) onProgress(rows.length, total);
  });

  return rows
    .filter(r => r.COORD_X && r.COORD_Y)
    .map(r => ({
      id: String(r.OBJECTID),
      name: r.CONTS_NAME || '공중화장실',
      lat: parseFloat(r.COORD_Y),
      lng: parseFloat(r.COORD_X),
      address: r.ADDR_NEW || r.ADDR_OLD || '',
      gu: r.GU_NAME || '',
      tel: r.TEL_NO || '',
      hours: r.VALUE_02 || '',
      type: r.VALUE_01 || '',
      status: r.VALUE_04 || '',
      disabled: r.VALUE_05 || '',
    }));
}

function filterByRadius(toilets, lat, lng, radiusKm) {
  return toilets.filter(t => {
    const d = haversine(lat, lng, t.lat, t.lng);
    return d <= radiusKm;
  });
}

function haversine(lat1, lng1, lat2, lng2) {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
