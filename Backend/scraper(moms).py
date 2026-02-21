from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import time

# 1. DB 연결 설정
DB_URL = "mysql+pymysql://root:0000@localhost:3306/OH_Burger"
engine = create_engine(DB_URL)
Session = sessionmaker(bind=engine)
session = Session()

def scrape_bulletproof_momstouch():
    print("🚀 [최종 진화] 맘스터치 스크래핑 불도저 모드 가동!!!")
    
    # 🔥 작성자님이 찾아내신 '진짜' 최신 완벽 주소를 아예 고정해버렸습니다! (입력창 삭제)
    target_url = "https://momstouch.co.kr/menu/new.php?pageNo=3&field=&keyword=&v_sect=&s_gubun=&s_level=&s_gender=&s_sect1=CG0005&s_sect2=&s_order="

    options = webdriver.ChromeOptions()
    # options.add_argument('--headless') # 크롬 창 안 띄우려면 주석 해제
    
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    
    try:
        print(f"\n🌐 [{target_url}] 접속 중...")
        driver.get(target_url)
        
        print("⏳ 웹페이지가 완전히 로딩될 때까지 여유롭게 5초 대기 중...")
        time.sleep(5)
        
        # 스크롤을 밑으로 쫙 내려서 숨겨진 햄버거까지 다 튀어나오게 만듦
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(2)
        
        print("🕵️‍♂️ 화면 전체를 뒤져서 '버거' 메뉴만 쏙쏙 뽑아냅니다...")
        elements = driver.find_elements(By.CSS_SELECTOR, "strong, h2, h3, h4, span, div, p")
        
        count = 0
        added_burgers = set() 
        
        for elem in elements:
            name = elem.text.strip()
            
            # 텍스트가 2글자 이상이고, '버거'라는 단어가 포함되어 있으면 무조건 수집!
            if "버거" in name and 2 < len(name) < 20 and name not in added_burgers:
                added_burgers.add(name)
                
                # DB 중복 체크
                exists = session.execute(
                    text("SELECT id FROM burgers WHERE name = :name"), 
                    {"name": name}
                ).fetchone()
                
                if not exists:
                    sql = text("""
                        INSERT INTO burgers (brand, name, price, tier, calories, carbs, protein, fat, image_url)
                        VALUES ('맘스터치', :name, 5000, 'B', 500, 40, 20, 20, '/momstouch/mom_cy.png')
                    """)
                    session.execute(sql, {"name": name})
                    count += 1
                    print(f"✅ DB 저장 완료: {name}")
                else:
                    print(f"⏩ 이미 있는 메뉴 패스: {name}")
                    
        session.commit()
        print(f"\n🎉 스크래핑 완벽 종료! 총 {count}개의 메뉴를 무사히 긁어왔습니다.")

    except Exception as e:
        print(f"🚨 에러 발생: {e}")
    finally:
        driver.quit()

if __name__ == "__main__":
    scrape_bulletproof_momstouch()