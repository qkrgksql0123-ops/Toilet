// 앱 상태
let map, clusterer;
let allToilets = [];
let currentLat = 37.5665;
let currentLng = 126.9780;
let selectedToilet = null;
let currentFilter = 'all';

// 즐겨찾기 (localStorage)
function getFavs() {
  return JSON.parse(localStorage.getItem('favs') || '[]');
}
function isFav(id) {
  return getFavs().includes(id);
}
function toggleFav(id) {
  const favs = getFavs();
  const idx = favs.indexOf(id);
  if (idx === -1) favs.push(id);
  else favs.splice(idx, 1);
  localStorage.setItem('favs', JSON.stringify(favs));
  return idx === -1; // true면 추가됨
}
function toggleFavFromDetail() {
  if (!selectedToilet) return;
  const added = toggleFav(selectedToilet.id);
  const btn = document.getElementById('detail-fav-btn');
  btn.textContent = added ? '❤️' : '🤍';
  btn.classList.toggle('active', added);
  updateList();
}
function setFilter(type, el) {
  currentFilter = type;
  document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
  el.classList.add('active');
  updateList();
}

// 앱 초기화
function initApp() {
  initFirebase();
  initMap();
  locateUser();
  loadToilets();
}

// 카카오 지도 초기화
function initMap() {
  const container = document.getElementById('map');
  map = new kakao.maps.Map(container, {
    center: new kakao.maps.LatLng(currentLat, currentLng),
    level: 5,
  });

  // 지도 컨트롤
  map.addControl(new kakao.maps.ZoomControl(), kakao.maps.ControlPosition.RIGHT);

  // 마커 클러스터러
  clusterer = new kakao.maps.MarkerClusterer({
    map,
    averageCenter: true,
    minLevel: 6,
    gridSize: 80,
    styles: [{
      width: '48px', height: '48px',
      background: 'rgba(0,188,212,0.85)',
      borderRadius: '50%',
      color: '#fff',
      textAlign: 'center',
      lineHeight: '48px',
      fontSize: '14px',
      fontWeight: 'bold',
    }],
  });
}

// 현재 위치 가져오기
function locateUser() {
  if (!navigator.geolocation) return;
  navigator.geolocation.getCurrentPosition(
    pos => {
      currentLat = pos.coords.latitude;
      currentLng = pos.coords.longitude;
      const latlng = new kakao.maps.LatLng(currentLat, currentLng);
      map.setCenter(latlng);

      // 내 위치 마커
      new kakao.maps.CustomOverlay({
        map,
        position: latlng,
        content: '<div class="my-location-dot"></div>',
        zIndex: 10,
      });

      if (allToilets.length) updateMarkers();
    },
    () => {} // 위치 거부시 서울시청 기본값 유지
  );
}

// 화장실 데이터 로드
async function loadToilets() {
  showLoading(true);
  try {
    allToilets = await fetchAllToilets((loaded, total) => {
      document.getElementById('loading-text').textContent =
        `화장실 데이터 로딩 중... (${loaded}/${total})`;
    });
    updateMarkers();
    updateList();
  } catch (e) {
    showToast('데이터 로드 실패: ' + e.message);
  } finally {
    showLoading(false);
  }
}

// 마커 갱신 (현재 위치 기준 반경 내)
function updateMarkers() {
  clusterer.clear();

  const nearby = filterByRadius(allToilets, currentLat, currentLng, 3);
  const markers = nearby.map(toilet => {
    const marker = new kakao.maps.Marker({
      position: new kakao.maps.LatLng(toilet.lat, toilet.lng),
    });
    kakao.maps.event.addListener(marker, 'click', () => openDetail(toilet));
    return marker;
  });

  clusterer.addMarkers(markers);
  updateList(nearby);
}

// 하단 목록 갱신
function updateList(toilets) {
  const nearby = toilets || filterByRadius(allToilets, currentLat, currentLng, 3);
  const list = document.getElementById('toilet-list');
  const countEl = document.getElementById('toilet-count');

  // 거리 계산 후 정렬
  let base = nearby.map(t => ({ ...t, dist: haversine(currentLat, currentLng, t.lat, t.lng) }));
  if (currentFilter === 'fav') base = base.filter(t => isFav(t.id));
  const sorted = base.sort((a, b) => a.dist - b.dist);

  countEl.textContent = currentFilter === 'fav'
    ? `즐겨찾기 ${sorted.length}개`
    : `주변 화장실 ${sorted.length}개`;

  list.innerHTML = sorted.slice(0, 100).map(t => `
    <div class="toilet-item" onclick="openDetail(allToilets.find(x=>x.id==='${t.id}'))">
      <div class="toilet-item-icon">🚻</div>
      <div class="toilet-item-info">
        <div class="toilet-item-name">${t.name}</div>
        <div class="toilet-item-addr">${t.address || t.gu}</div>
      </div>
      <div class="toilet-item-dist">${(t.dist * 1000).toFixed(0)}m</div>
      <button class="fav-btn ${isFav(t.id) ? 'active' : ''}"
        onclick="event.stopPropagation(); toggleFavInList('${t.id}', this)">❤️</button>
    </div>
  `).join('');
}

// 화장실 상세 패널 열기
async function openDetail(toilet) {
  if (!toilet) return;
  selectedToilet = toilet;

  const panel = document.getElementById('detail-panel');
  panel.classList.add('open');

  // 즐겨찾기 버튼 상태
  const favBtn = document.getElementById('detail-fav-btn');
  const faved = isFav(toilet.id);
  favBtn.textContent = faved ? '❤️' : '🤍';
  favBtn.classList.toggle('active', faved);

  document.getElementById('detail-name').textContent = toilet.name;
  document.getElementById('detail-addr').textContent = toilet.address || toilet.gu;
  document.getElementById('detail-hours').textContent = toilet.hours ? `⏰ ${toilet.hours}` : '';
  document.getElementById('detail-tel').textContent = toilet.tel ? `📞 ${toilet.tel}` : '';
  document.getElementById('detail-status').textContent = toilet.status ? `🚽 ${toilet.status}` : '';
  document.getElementById('detail-disabled').textContent = toilet.disabled ? `♿ ${toilet.disabled}` : '';

  // 지도 이동
  map.setCenter(new kakao.maps.LatLng(toilet.lat, toilet.lng));
  map.setLevel(3);

  // Firebase 데이터 로드
  loadReviews(toilet.id);
  loadPasswords(toilet.id);

  // 평점 표시
  try {
    const meta = await getToiletMeta(toilet.id);
    const avg = meta.avgRating || 0;
    document.getElementById('detail-rating').innerHTML =
      renderStars(avg) + (avg ? ` ${avg.toFixed(1)}` : ' 평가 없음');
  } catch (_) {}
}

function toggleFavInList(id, btn) {
  const added = toggleFav(id);
  btn.classList.toggle('active', added);
  if (currentFilter === 'fav') updateList();
}

function closeDetail() {
  document.getElementById('detail-panel').classList.remove('open');
  selectedToilet = null;
}

// 탭 전환
function switchTab(tab) {
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
  document.querySelector(`.tab-btn[data-tab="${tab}"]`).classList.add('active');
  document.getElementById(`tab-${tab}`).classList.add('active');
}

// 리뷰 로드
async function loadReviews(toiletId) {
  const container = document.getElementById('reviews-container');
  container.innerHTML = '<div class="loading-sm">로딩 중...</div>';
  try {
    const reviews = await getReviews(toiletId);
    if (!reviews.length) {
      container.innerHTML = '<div class="empty-msg">아직 리뷰가 없어요</div>';
      return;
    }
    container.innerHTML = reviews.map(r => `
      <div class="review-card">
        <div class="review-stars">${renderStars(r.rating)}</div>
        <div class="review-comment">${escapeHtml(r.comment)}</div>
        <div class="review-date">${formatDate(r.createdAt)}</div>
      </div>
    `).join('');
  } catch (_) {
    container.innerHTML = '<div class="empty-msg">리뷰를 불러올 수 없어요</div>';
  }
}

// 리뷰 제출
let selectedRating = 0;

function setRating(val) {
  selectedRating = val;
  document.querySelectorAll('.star-input').forEach((s, i) => {
    s.classList.toggle('active', i < val);
  });
}

async function submitReview() {
  if (!selectedToilet) return;
  const comment = document.getElementById('review-input').value.trim();
  if (!selectedRating) { showToast('별점을 선택해주세요'); return; }
  if (!comment) { showToast('리뷰 내용을 입력해주세요'); return; }

  try {
    await addReview(selectedToilet.id, selectedRating, comment);
    document.getElementById('review-input').value = '';
    selectedRating = 0;
    setRating(0);
    showToast('리뷰가 등록됐어요!');
    loadReviews(selectedToilet.id);

    // 평점 갱신
    const meta = await getToiletMeta(selectedToilet.id);
    document.getElementById('detail-rating').innerHTML =
      renderStars(meta.avgRating) + ` ${meta.avgRating.toFixed(1)}`;
  } catch (_) {
    showToast('리뷰 등록에 실패했어요');
  }
}

// 비밀번호 로드
async function loadPasswords(toiletId) {
  const container = document.getElementById('passwords-container');
  container.innerHTML = '<div class="loading-sm">로딩 중...</div>';
  try {
    const passwords = await getPasswords(toiletId);
    if (!passwords.length) {
      container.innerHTML = '<div class="empty-msg">공유된 비밀번호가 없어요</div>';
      return;
    }
    container.innerHTML = passwords.map(p => `
      <div class="password-card">
        <div class="password-value">${escapeHtml(p.password)}</div>
        <button class="like-btn" onclick="handleLike('${toiletId}','${p.id}',this)">
          👍 ${p.likes || 0}
        </button>
      </div>
    `).join('');
  } catch (_) {
    container.innerHTML = '<div class="empty-msg">비밀번호를 불러올 수 없어요</div>';
  }
}

async function handleLike(toiletId, passwordId, btn) {
  try {
    await likePassword(toiletId, passwordId);
    const cur = parseInt(btn.textContent.match(/\d+/)[0]);
    btn.textContent = `👍 ${cur + 1}`;
  } catch (_) {}
}

// 비밀번호 제출
async function submitPassword() {
  if (!selectedToilet) return;
  const pw = document.getElementById('password-input').value.trim();
  if (!pw) { showToast('비밀번호를 입력해주세요'); return; }

  try {
    await addPassword(selectedToilet.id, pw);
    document.getElementById('password-input').value = '';
    showToast('비밀번호가 공유됐어요!');
    loadPasswords(selectedToilet.id);
  } catch (_) {
    showToast('비밀번호 공유에 실패했어요');
  }
}

// 내 위치로 이동
function goToMyLocation() {
  map.setCenter(new kakao.maps.LatLng(currentLat, currentLng));
  map.setLevel(5);
  updateMarkers();
}

// 유틸
function renderStars(rating) {
  const full = Math.round(rating);
  return Array.from({ length: 5 }, (_, i) =>
    `<span class="${i < full ? 'star filled' : 'star'}">★</span>`
  ).join('');
}

function formatDate(ts) {
  if (!ts) return '';
  const d = ts.toDate ? ts.toDate() : new Date(ts);
  return d.toLocaleDateString('ko-KR');
}

function escapeHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function showToast(msg) {
  const t = document.getElementById('toast');
  t.textContent = msg;
  t.classList.add('show');
  setTimeout(() => t.classList.remove('show'), 2500);
}

function showLoading(show) {
  document.getElementById('loading').style.display = show ? 'flex' : 'none';
}

// 하단 시트 드래그
let sheetStartY = 0;
const sheet = document.getElementById('bottom-sheet');

document.getElementById('sheet-handle').addEventListener('touchstart', e => {
  sheetStartY = e.touches[0].clientY;
});
document.getElementById('sheet-handle').addEventListener('touchend', e => {
  const dy = e.changedTouches[0].clientY - sheetStartY;
  if (dy < -30) sheet.classList.add('expanded');
  if (dy > 30) sheet.classList.remove('expanded');
});
document.getElementById('sheet-handle').addEventListener('click', () => {
  sheet.classList.toggle('expanded');
});
