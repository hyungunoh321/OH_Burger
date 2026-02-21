import { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

function App() {
  const [burgers, setBurgers] = useState([]);
  const [selectedBrand, setSelectedBrand] = useState("전체");
  const [sortOption, setSortOption] = useState("인기순");
  
  const [randomPick, setRandomPick] = useState("로딩중...");
  const [isAnimating, setIsAnimating] = useState(false);
  
  // 🔥 1. 검색어를 기억할 상태(State) 추가
  const [searchTerm, setSearchTerm] = useState("");

  const brands = ["전체", "맥도날드", "버거킹", "맘스터치", "롯데리아", "KFC", "노브랜드버거"];

  useEffect(() => {
    axios.get("http://localhost:8000/burgers")
      .then((response) => {
        const formattedData = response.data.map((burger) => ({
          ...burger,
          kcal: burger.calories,
          img: burger.image_url || "🍔"
        }));
        setBurgers(formattedData);
        
        if (formattedData.length > 0) {
          const randomIndex = Math.floor(Math.random() * formattedData.length);
          setRandomPick(formattedData[randomIndex].name);
        }
      })
      .catch((error) => console.error("데이터 로딩 실패:", error));
  }, []);

  // ==========================================
  // 🧠 데이터 가공 (필터링 -> 검색 -> 정렬 -> 순위)
  // ==========================================

  // 1. 브랜드 필터링
  let displayBurgers = selectedBrand === "전체" 
    ? [...burgers] 
    : burgers.filter(burger => burger.brand.includes(selectedBrand) || burger.brand === selectedBrand);

  // 🔥 2. 검색어 필터링 (사용자가 입력한 글자가 포함된 햄버거만 남기기)
  if (searchTerm.trim() !== "") {
    displayBurgers = displayBurgers.filter(burger => 
      burger.name.includes(searchTerm) || burger.brand.includes(searchTerm)
    );
  }

  // 3. 정렬 로직
  const tierScore = { 'S': 4, 'A': 3, 'B': 2, 'C': 1 }; // S를 4점으로, C를 1점으로

  displayBurgers.sort((a, b) => {
    if (sortOption === "인기순") return tierScore[b.tier] - tierScore[a.tier];
    if (sortOption === "칼로리순") return b.kcal - a.kcal;
    if (sortOption === "탄수화물순") return b.carbs - a.carbs;
    if (sortOption === "단백질순") return b.protein - a.protein;
    if (sortOption === "지방순") return b.fat - a.fat;
    return 0;
  });

  // 4. 순위 매기기
  displayBurgers = displayBurgers.map((burger, index) => ({
    ...burger,
    rank: index + 1
  }));

  // ==========================================

  const handleRandomClick = () => {
    if (burgers.length > 0) {
      const dingSound = new Audio("https://assets.mixkit.co/active_storage/sfx/2568/2568-preview.mp3");
      dingSound.play();

      const randomIndex = Math.floor(Math.random() * burgers.length);
      setRandomPick(burgers[randomIndex].name);
      
      setIsAnimating(true);
      setTimeout(() => {
        setIsAnimating(false);
      }, 700);
    }
  };

const getTierClass = (tier) => {
    if (tier === 'S') return 'badge-s'; // 빨강
    if (tier === 'A') return 'badge-a'; // 파랑 (또는 보라)
    if (tier === 'B') return 'badge-b'; // 초록
    return 'badge-c';                   // 그 외(C)는 노란색
  };

  return (
    <div className="app-container">
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

      <div className="search-section">
        <h1 className="main-title">OH! Burger!</h1>
        <div className="search-bar-wrapper">
          {/* 🔥 3. 검색창에 onChange 이벤트 연결 */}
          <input 
            type="text" 
            placeholder="궁금한 햄버거를 검색해보세요!" 
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
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
          <button className="nav-btn">👨‍🍳 추천 레시피 보기</button>
          
          <div className="card random-card">
            <div className={`slot-machine-icons ${isAnimating ? 'is-jumping' : ''}`}>
              <span>🍔</span>
              <span>🍟</span>
              <span>🍔</span>
            </div>
            
            <button className="btn-random" onClick={handleRandomClick}>
              🔀 랜덤 메뉴 추천
            </button>
            <div className="today-pick">
              <span className="pick-label">오늘의 추천 메뉴는</span>
              <strong className="pick-menu">{randomPick}</strong>
            </div>
          </div>
        </aside>

        <section className="content">
          <div className="content-header">
            <h2>햄버거 랭킹</h2>
            <select 
              className="sort-select" 
              value={sortOption} 
              onChange={(e) => setSortOption(e.target.value)}
            >
              <option value="인기순">인기순 (티어순)</option>
              <option value="칼로리순">칼로리순 (높은순)</option>
              <option value="탄수화물순">탄수화물순 (높은순)</option>
              <option value="단백질순">단백질순 (높은순)</option>
              <option value="지방순">지방순 (높은순)</option>
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
              <span className="col-val">탄수화물</span>
              <span className="col-val">단백질</span>
              <span className="col-val">지방</span>
              <span className="col-arrow"></span>
            </div>
            
            <div className="table-body">
              {displayBurgers.length > 0 ? (
                displayBurgers.map((burger) => (
                  <div key={burger.id} className="table-row">
                    <span className="col-rank">
                      <div className={`rank-circle ${burger.rank <= 3 ? 'top-rank' : 'normal-rank'}`}>
                        {burger.rank}
                      </div>
                    </span>
                    <span className="col-img">
                      {(burger.img.startsWith('http') || burger.img.startsWith('/')) ? 
                        <img src={burger.img} alt={burger.name} className="burger-thumb" /> 
                        : <div className="img-placeholder">{burger.img}</div>
                      }
                    </span>
                    <span className="col-name">
                      {burger.name}
                      <span className="brand-tag">{burger.brand}</span>
                    </span>
                    <span className="col-tier"><span className={`badge ${getTierClass(burger.tier)}`}>{burger.tier}</span></span>
                    
                    <span className="col-val">{burger.kcal}kcal</span>
                    <span className="col-val">{burger.carbs}g</span>
                    <span className="col-val">{burger.protein}g</span>
                    <span className="col-val">{burger.fat}g</span>
                    
                    <span className="col-arrow">›</span>
                  </div>
                ))
              ) : (
                <div style={{padding: "40px", textAlign: "center", color: "#888"}}>
                  검색 결과가 없습니다 ㅠㅠ 다른 햄버거를 찾아보세요!
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