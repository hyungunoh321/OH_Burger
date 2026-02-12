import { useState, useEffect } from 'react';
import axios from 'axios'; // 1. Axios 불러오기
import './App.css';

function App() {
  // 2. 처음엔 빈 배열로 시작 (데이터 오기 전)
  const [burgers, setBurgers] = useState([]);

  // 3. 화면이 켜지면 딱 한 번 실행되는 함수
  useEffect(() => {
    axios.get("http://localhost:8000/burgers") // 백엔드 주소로 요청
      .then((response) => {
        // 성공하면 실행
        console.log("데이터 가져오기 성공!", response.data);
        
        // DB 컬럼명(영어)을 프론트엔드 변수명으로 매칭해주기
        const formattedData = response.data.map((burger, index) => ({
          ...burger,
          rank: index + 1,          // 랭킹은 순서대로 1, 2, 3... 부여
          kcal: burger.calories,    // DB: calories -> Front: kcal
          img: burger.image_url || "🍔" // 이미지가 없으면 기본 아이콘
        }));

        setBurgers(formattedData); // 가져온 데이터를 상태에 저장!
      })
      .catch((error) => {
        console.error("데이터 가져오기 실패 ㅠㅠ", error);
      });
  }, []);

  // 티어별 색상 함수
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
              {burgers.length > 0 ? (
                burgers.map((burger) => (
                  <div key={burger.id} className="table-row">
                    <span className="col-rank">
                      <div className={`rank-circle ${burger.rank <= 3 ? 'top-rank' : 'normal-rank'}`}>
                        {burger.rank}
                      </div>
                    </span>
                    <span className="col-img">
                      {/* 이미지가 http로 시작하면 진짜 이미지 태그를, 아니면 이모지 출력 */}
                      {burger.img.startsWith('http') ? 
                        <img src={burger.img} alt={burger.name} style={{width:'40px', borderRadius:'4px'}} /> 
                        : <div className="img-placeholder">{burger.img}</div>
                      }
                    </span>
                    <span className="col-name">{burger.name}</span>
                    <span className="col-tier"><span className={`badge ${getTierClass(burger.tier)}`}>{burger.tier}</span></span>
                    <span className="col-val">{burger.kcal}kcal</span>
                    <span className="col-val">{burger.carbs}g</span>
                    <span className="col-val">{burger.protein}g</span>
                    <span className="col-val">{burger.fat}g</span>
                    <span className="col-arrow">›</span>
                  </div>
                ))
              ) : (
                <div style={{padding: "20px", textAlign: "center"}}>데이터를 불러오는 중입니다... (혹시 서버 켜셨나요?)</div>
              )}
            </div>
          </div>
        </section>
      </main>
    </div>
  );
}

export default App;