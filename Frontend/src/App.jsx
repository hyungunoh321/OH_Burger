import { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

function App() {
  const [burgers, setBurgers] = useState([]);
  const [selectedBrand, setSelectedBrand] = useState("전체");
  const [sortOption, setSortOption] = useState("인기순");
  
  const [randomPick, setRandomPick] = useState("로딩중...");
  const [isAnimating, setIsAnimating] = useState(false);

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

  let displayBurgers = selectedBrand === "전체" 
    ? [...burgers] 
    : burgers.filter(burger => burger.brand.includes(selectedBrand) || burger.brand === selectedBrand);

  const tierScore = { 'S': 3, 'A': 2, 'B': 1 };

  displayBurgers.sort((a, b) => {
    if (sortOption === "인기순") {
      return tierScore[b.tier] - tierScore[a.tier];
    } else if (sortOption === "칼로리순") {
      return b.kcal - a.kcal;
    } else if (sortOption === "탄수화물순") {
      return b.carbs - a.carbs;
    } else if (sortOption === "단백질순") {
      return b.protein - a.protein;
    } else if (sortOption === "지방순") {
      return b.fat - a.fat;
    }
    return 0;
  });

  displayBurgers = displayBurgers.map((burger, index) => ({
    ...burger,
    rank: index + 1
  }));

  // 🔥 랜덤 버튼 클릭 함수 (소리 재생 추가!)
  const handleRandomClick = () => {
    if (burgers.length > 0) {
      // 1) 띵! 소리 재생 (무료 효과음 URL 사용)
      const dingSound = new Audio("https://assets.mixkit.co/active_storage/sfx/2568/2568-preview.mp3");
      dingSound.play();

      // 2) 랜덤 메뉴 뽑기
      const randomIndex = Math.floor(Math.random() * burgers.length);
      setRandomPick(burgers[randomIndex].name);
      
      // 3) 점프 애니메이션 실행
      setIsAnimating(true);
      setTimeout(() => {
        setIsAnimating(false);
      }, 700);
    }
  };

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
                    
                    <span className="col-val">{burger.kcal}kcal</span>
                    <span className="col-val">{burger.carbs}g</span>
                    <span className="col-val">{burger.protein}g</span>
                    <span className="col-val">{burger.fat}g</span>
                    
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