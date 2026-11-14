// OH Burger 화면 설계용 프로토타입 공통 스크립트
// 아래 수치는 화면 확인용 예시 값이며 실제 영양 정보가 아니다.

const BRANDS = ['맥도날드', '버거킹', '롯데리아', '맘스터치', 'KFC', '노브랜드버거', '프랭크버거'];
const PATTY = { BEEF: '소고기', CHICKEN: '치킨', SEAFOOD: '새우·생선', ETC: '기타' };

// [id, 브랜드 번호, 이름, 패티, 가격, 열량, 단백질, 포화지방, 추천 수, 태그된 글 수, 조회수]
const RAW = [
  [1, 0, '빅맥', 'BEEF', 5500, 580, 27, 11, 42, 6, 310],
  [2, 0, '맥스파이시 상하이버거', 'CHICKEN', 5500, 500, 21, 5, 35, 4, 250],
  [3, 0, '더블 쿼터파운더 치즈', 'BEEF', 7700, 770, 51, 20, 18, 2, 140],
  [4, 0, '불고기버거', 'BEEF', 3600, 410, 15, 6, 9, 1, 90],
  [5, 1, '와퍼', 'BEEF', 7100, 660, 29, 12, 51, 7, 400],
  [6, 1, '콰트로치즈와퍼', 'BEEF', 7900, 790, 36, 18, 30, 3, 220],
  [7, 1, '통새우와퍼', 'SEAFOOD', 7900, 750, 31, 13, 14, 2, 130],
  [8, 1, '롱치킨버거', 'CHICKEN', 4900, 620, 22, 7, 6, 0, 60],
  [9, 2, '불고기버거', 'BEEF', 4700, 450, 17, 7, 20, 3, 180],
  [10, 2, '새우버거', 'SEAFOOD', 4700, 440, 14, 5, 27, 4, 210],
  [11, 2, '한우불고기버거', 'BEEF', 8400, 570, 25, 11, 8, 1, 100],
  [12, 2, '핫크리스피버거', 'CHICKEN', 5900, 530, 23, 6, 5, 0, 70],
  [13, 3, '싸이버거', 'CHICKEN', 4600, 590, 30, 6, 60, 9, 450],
  [14, 3, '딥치즈버거', 'CHICKEN', 4800, 620, 31, 9, 12, 1, 120],
  [15, 3, '그릴드비프버거', 'BEEF', 5100, 560, 26, 12, 4, 0, 50],
  [16, 3, '불싸이버거', 'CHICKEN', 4900, 610, 29, 6, 10, 2, 95],
  [17, 4, '징거버거', 'CHICKEN', 5900, 480, 24, 5, 33, 3, 260],
  [18, 4, '타워버거', 'CHICKEN', 6800, 640, 30, 9, 15, 1, 150],
  [19, 4, '불고기버거', 'BEEF', 4500, 430, 16, 6, 2, 0, 30],
  [20, 4, '클래식징거통다리버거', 'CHICKEN', 6200, 520, 28, 6, 7, 1, 85],
  [21, 5, 'NBB 시그니처', 'BEEF', 4800, 510, 22, 10, 11, 1, 110],
  [22, 5, '그릴드 불고기', 'BEEF', 2900, 380, 14, 5, 13, 2, 125],
  [23, 5, '메가바이트', 'BEEF', 5300, 690, 33, 15, 3, 0, 45],
  [24, 5, '코울슬로 치킨', 'CHICKEN', 4500, 470, 19, 4, 0, 0, 0],
  [25, 6, '프랭크버거', 'BEEF', 4600, 460, 21, 9, 16, 2, 160],
  [26, 6, '치즈버거', 'BEEF', 5200, 520, 24, 12, 9, 1, 105],
  [27, 6, '더블비프치즈버거', 'BEEF', 7600, 780, 42, 21, 5, 0, 65],
  [28, 6, '쉬림프버거', 'SEAFOOD', 5400, 490, 16, null, 1, 0, 20],
];

const BURGERS = RAW.map(([id, b, name, patty, price, kcal, protein, satfat, likes, posts, views]) => ({
  id, brand: BRANDS[b], name, patty, price, kcal, protein, satfat, likes, posts, views,
  popularity: likes * 5 + posts * 3 + views,
}));

// 티어표 4종: 기준 컬럼, 좋은 방향, 표시 단위
const METRICS = {
  popularity: { label: '인기', high: true, unit: '점', note: '추천×5 + 태그된 글×3 + 조회수' },
  protein: { label: '단백질', high: true, unit: 'g', note: '단백질이 많을수록 상위' },
  kcal: { label: '열량', high: false, unit: 'kcal', note: '열량이 낮을수록 상위' },
  satfat: { label: '포화지방', high: false, unit: 'g', note: '포화지방이 낮을수록 상위' },
};

// 기능 명세서 4.3의 티어 규칙. 반환값: { 버거 id: 'S' | 'A' | 'B' | 'C' | 'D' }
function calcTiers(key) {
  const m = METRICS[key];
  const target = BURGERS.filter(b => b[key] != null && !(key === 'popularity' && b[key] === 0));
  const sorted = [...target].sort((x, y) => (m.high ? y[key] - x[key] : x[key] - y[key]));
  const result = {};
  let rank = 1;
  sorted.forEach((b, i) => {
    if (i > 0 && b[key] !== sorted[i - 1][key]) rank = i + 1; // 값이 같으면 공동 순위
    const p = (rank - 1) / sorted.length;
    result[b.id] = p < 0.1 ? 'S' : p < 0.3 ? 'A' : p < 0.7 ? 'B' : p < 0.9 ? 'C' : 'D';
  });
  return result;
}

const POSTS = [
  { id: 8, cat: '꿀조합', title: '싸이버거 + 치즈스틱 넣어 먹기', burgers: [13], writer: '버거왕', date: '2026-11-13', views: 152, likes: 24, comments: 5 },
  { id: 7, cat: '꿀팁', title: '와퍼 주문할 때 올엑스트라 꼭 말하세요', burgers: [5], writer: '와퍼러버', date: '2026-11-12', views: 301, likes: 41, comments: 9 },
  { id: 6, cat: '꿀팁', title: '빅맥 소스 추가하면 생기는 일', burgers: [1], writer: '맥날죽돌이', date: '2026-11-12', views: 98, likes: 12, comments: 2 },
  { id: 5, cat: '꿀조합', title: '새우버거 + 불고기버거 반반 조합', burgers: [10, 9], writer: '롯리단골', date: '2026-11-11', views: 77, likes: 8, comments: 3 },
  { id: 4, cat: '자유', title: '다들 최애 버거가 뭔가요', burgers: [], writer: '햄최몇', date: '2026-11-10', views: 210, likes: 6, comments: 14 },
  { id: 3, cat: '꿀팁', title: '징거버거는 포장보다 매장이 낫습니다', burgers: [17], writer: '치킨패티파', date: '2026-11-09', views: 64, likes: 5, comments: 1 },
  { id: 2, cat: '꿀조합', title: '그릴드 불고기 두 개가 세트보다 든든함', burgers: [22], writer: '가성비장인', date: '2026-11-08', views: 120, likes: 17, comments: 4 },
  { id: 1, cat: '자유', title: 'OH Burger 오픈 축하합니다', burgers: [], writer: '운영자', date: '2026-11-07', views: 55, likes: 3, comments: 0 },
];

const byId = id => BURGERS.find(b => b.id === Number(id));
const won = n => n.toLocaleString('ko-KR') + '원';
const param = name => new URLSearchParams(location.search).get(name);
const thumb = (cls = '') => `<div class="thumb ${cls}" aria-hidden="true">🍔</div>`;
// 티어가 없는 경우: 인기는 점수 0이라 "집계 중", 영양 지표는 값이 없어 "정보 없음"
const tierBadge = (t, key) => (t
  ? `<span class="badge tier-${t}">${t}</span>`
  : `<span class="badge none">${key === 'popularity' ? '집계 중' : '정보 없음'}</span>`);

// 공통 헤더 · 푸터 (실제 구현에서는 JSP include로 대체)
function layout(active) {
  const nav = [['index.html', '티어표'], ['burgers.html', '버거 도감'], ['posts.html', '게시판'], ['roulette.html', '룰렛']];
  document.body.insertAdjacentHTML('afterbegin', `
    <header class="site-header"><div class="container">
      <a class="logo" href="index.html">OH <span>Burger</span></a>
      <nav class="nav">${nav.map(([h, t]) => `<a href="${h}" class="${h === active ? 'active' : ''}">${t}</a>`).join('')}</nav>
      <div class="auth"><a class="btn ghost" href="login.html">로그인</a><a class="btn primary" href="join.html">회원가입</a></div>
    </div></header>`);
  document.body.insertAdjacentHTML('beforeend', `
    <footer class="site-footer"><div class="container">
      OH Burger · 화면 설계용 프로토타입 · 표시된 수치는 예시 값입니다
    </div></footer>`);
}
