import { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

function App() {
  const [burgers, setBurgers] = useState([]);
  const [selectedBrand, setSelectedBrand] = useState("전체");

  const brands = ["전체", "맥도날드", "버거킹", "맘스터치", "롯데리아", "KFC", "노브랜드버거"];

  useEffect(() => {
    axios.get("http://localhost:8000/burgers")
      .then((response) => {
        const formattedData = response.data.map((burger, index) => ({
          ...burger,
          rank: index + 1,
          kcal: burger.calories,
          img: burger.image_url || "🍔"
        }));
        setBurgers(formattedData);
      })
      .catch((error) => console.error("데이터 로딩 실패:", error));
  }, []);

  const filteredBurgers = selectedBrand === "전체" 
    ? burgers 
    : burgers.filter(burger => burger.brand.includes(selectedBrand) || burger.brand === selectedBrand);

  const getTierClass = (tier) => {
    if (tier === 'S') return 'badge-s';
    if (tier === 'A') return 'badge-a';
    return 'badge-b';
  };

  return (
    <div className="app-container">
      <header className="header">
        <div className="header-inner">
          <div className="logo">OH! Burger!</div>
          <nav className="nav-menu">
            <a href="#" className="active">햄버거 목록</a>
            <a href="#">햄버거 맛집</a>
            <a href="#">추천 레시피</a> {/* 유지 */}
            <a href="#">리뷰게시판</a> {/* 유지 */}
          </nav>
          <div className="user-actions">
            <button className="btn-login">➜] 로그인</button>
            <button className="btn-mypage">👤 마이페이지</button>
          </div>
        </div>
      </header>

      <div className="search-section">
        <h1 className="main-title">OH! Burger!</h1>
        <div className="search-bar-wrapper">
          <input type="text" placeholder="궁금한 햄버거를 검색해보세요!" />
          <button className="search-btn">🔍</button>
        </div>
      </div>

      <main className="main-layout">
        <aside className="sidebar">
          <div className="card profile-card">
            <div className="profile-icon">🍔</div>
            <p className="profile-text">
              안녕! 나는 햄버거이고 레비!<br/>
              근처 맛집이나 추천 레시피를<br/>
              소개해줄게!!
            </p>
          </div>
          
          <button className="nav-btn">📍 근처 맛집 보러가기</button>
          <button className="nav-btn">👨‍🍳 추천 레시피 보기</button> {/* 유지 */}
          
          <div className="card random-card">
            <div className="slot-machine-icons">🍔 🍟 🍔</div>
            <button className="btn-random">🔀 랜덤 메뉴 추천</button>
            <div className="today-pick">
              <span className="pick-label">오늘의 추천 메뉴는</span>
              <strong className="pick-menu">
                {burgers.length > 0 ? burgers[Math.floor(Math.random() * burgers.length)].name : "로딩중..."}
              </strong>
            </div>
          </div>
        </aside>

        <section className="content">
          <div className="content-header">
            <h2>햄버거 랭킹</h2>
            <select className="sort-select">
              <option>인기순</option>
              <option>칼로리순</option>
            </select>
          </div>

          <div className="brand-filter">
            {brands.map((brand) => (
              <button 
                key={brand}
                className={`brand-btn ${selectedBrand === brand ? 'active' : ''}`}
                onClick={() => setSelectedBrand(brand)}
              >
                {brand}
              </button>
            ))}
          </div>

          <div className="ranking-card">
            <div className="table-header">
              <span className="col-rank">순위</span>
              <span className="col-img">사진</span>
              <span className="col-name">이름 (브랜드)</span>
              <span className="col-tier">티어</span>
              <span className="col-val">칼로리</span>
              <span className="col-val">탄수화물</span> {/* ✅ 복구 */}
              <span className="col-val">단백질</span>
              <span className="col-val">지방</span>     {/* ✅ 복구 */}
              <span className="col-arrow"></span>
            </div>
            
            <div className="table-body">
              {filteredBurgers.length > 0 ? (
                filteredBurgers.map((burger) => (
                  <div key={burger.id} className="table-row">
                    <span className="col-rank">
                      <div className={`rank-circle ${burger.rank <= 3 ? 'top-rank' : 'normal-rank'}`}>
                        {burger.rank}
                      </div>
                    </span>
                    <span className="col-img">
                      {burger.img.startsWith('http') ? 
                        <img src={burger.img} alt={burger.name} className="burger-thumb" /> 
                        : <div className="img-placeholder">{burger.img}</div>
                      }
                    </span>
                    <span className="col-name">
                      {burger.name}
                      <span className="brand-tag">{burger.brand}</span>
                    </span>
                    <span className="col-tier"><span className={`badge ${getTierClass(burger.tier)}`}>{burger.tier}</span></span>
                    
                    {/* 👇 여기 데이터 칸도 다시 복구했습니다! */}
                    <span className="col-val">{burger.kcal}kcal</span>
                    <span className="col-val">{burger.carbs}g</span> {/* ✅ 복구 */}
                    <span className="col-val">{burger.protein}g</span>
                    <span className="col-val">{burger.fat}g</span>   {/* ✅ 복구 */}
                    
                    <span className="col-arrow">›</span>
                  </div>
                ))
              ) : (
                <div style={{padding: "40px", textAlign: "center", color: "#888"}}>
                  해당 브랜드의 햄버거 데이터가 없습니다 ㅠㅠ
                </div>
              )}
            </div>
          </div>
        </section>
      </main>
    </div>
  );
}

export default App;