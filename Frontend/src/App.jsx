import { useState } from 'react';
import './App.css';

function App() {
  // 디자인과 똑같은 더미 데이터
  const [burgers] = useState([
    { id: 1, rank: 1, name: "지거버거", tier: "S", kcal: 750, carbs: 45, protein: 35, fat: 42, img: "🍔" },
    { id: 2, rank: 2, name: "버거킹 와퍼", tier: "S", kcal: 680, carbs: 52, protein: 30, fat: 38, img: "🍔" },
    { id: 3, rank: 3, name: "맥도날드 빅맥", tier: "A", kcal: 563, carbs: 46, protein: 26, fat: 33, img: "🍔" },
    { id: 4, rank: 4, name: "쉑쉑버거", tier: "A", kcal: 590, carbs: 41, protein: 28, fat: 36, img: "🍔" },
    { id: 5, rank: 5, name: "파이브가이즈", tier: "A", kcal: 840, carbs: 48, protein: 42, fat: 52, img: "🍔" },
    { id: 6, rank: 6, name: "롯데리아 불고기버거", tier: "B", kcal: 480, carbs: 44, protein: 22, fat: 24, img: "🍔" },
    { id: 7, rank: 7, name: "모스버거", tier: "B", kcal: 520, carbs: 47, protein: 24, fat: 28, img: "🍔" },
    { id: 8, rank: 8, name: "크라제버거", tier: "B", kcal: 645, carbs: 43, protein: 31, fat: 38, img: "🍔" },
  ]);

  const getTierClass = (tier) => {
    if (tier === 'S') return 'badge-s';
    if (tier === 'A') return 'badge-a';
    return 'badge-b';
  };

  return (
    <div className="app-container">
      {/* 헤더 */}
      <header className="header">
        <div className="header-inner">
          <div className="logo">OH! Burger!</div>
          <nav className="nav-menu">
            <a href="#" className="active">햄버거 목록</a>
            <a href="#">햄버거 맛집</a>
            <a href="#">추천 레시피</a>
            <a href="#">리뷰게시판</a>
          </nav>
          <div className="user-actions">
            <button className="btn-login">➜] 로그인</button>
            <button className="btn-mypage">👤 마이페이지</button>
          </div>
        </div>
      </header>

      {/* 메인 타이틀 & 검색창 */}
      <div className="search-section">
        <h1 className="main-title">OH! Burger!</h1>
        <div className="search-bar-wrapper">
          <input type="text" placeholder="궁금한 햄버거를 검색해보세요!" />
          <button className="search-btn">🔍</button>
        </div>
      </div>

      <main className="main-layout">
        {/* 왼쪽 사이드바 */}
        <aside className="sidebar">
          {/* 프로필 카드 */}
          <div className="card profile-card">
            <div className="profile-icon">🍔</div>
            <p className="profile-text">
              안녕! 나는 햄버거이고 레비!<br/>
              근처 맛집이나 추천 레시피를<br/>
              소개해줄게!!
            </p>
          </div>
          
          {/* 네비게이션 버튼 */}
          <button className="nav-btn">📍 근처 맛집 보러가기</button>
          <button className="nav-btn">👨‍🍳 추천 레시피 보기</button>

          {/* 랜덤 메뉴 카드 */}
          <div className="card random-card">
            <div className="slot-machine-icons">🍔 🍟 🍔</div>
            <button className="btn-random">🔀 랜덤 햄버거 메뉴 정하기</button>
            <div className="today-pick">
              <span className="pick-label">오늘의 추천 메뉴는</span>
              <strong className="pick-menu">베이컨버거</strong>
            </div>
          </div>
        </aside>

        {/* 오른쪽 랭킹 리스트 */}
        <section className="content">
          <div className="content-header">
            <h2>햄버거 랭킹</h2>
            <select className="sort-select">
              <option>인기순</option>
              <option>칼로리순</option>
            </select>
          </div>

          <div className="ranking-card">
            <div className="table-header">
              <span className="col-rank">순위</span>
              <span className="col-img">사진</span>
              <span className="col-name">이름</span>
              <span className="col-tier">티어</span>
              <span className="col-val">칼로리</span>
              <span className="col-val">탄수화물</span>
              <span className="col-val">단백질</span>
              <span className="col-val">지방</span>
              <span className="col-arrow"></span>
            </div>
            
            <div className="table-body">
              {burgers.map((burger) => (
                <div key={burger.id} className="table-row">
                  <span className="col-rank">
                    <div className={`rank-circle ${burger.rank <= 3 ? 'top-rank' : 'normal-rank'}`}>
                      {burger.rank}
                    </div>
                  </span>
                  <span className="col-img"><div className="img-placeholder">{burger.img}</div></span>
                  <span className="col-name">{burger.name}</span>
                  <span className="col-tier"><span className={`badge ${getTierClass(burger.tier)}`}>{burger.tier}</span></span>
                  <span className="col-val">{burger.kcal}kcal</span>
                  <span className="col-val">{burger.carbs}g</span>
                  <span className="col-val">{burger.protein}g</span>
                  <span className="col-val">{burger.fat}g</span>
                  <span className="col-arrow">›</span>
                </div>
              ))}
            </div>
          </div>
        </section>
      </main>
    </div>
  );
}

export default App;