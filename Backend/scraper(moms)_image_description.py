from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import time
import re

# 1. DB 연결 설정 (0000으로 고정)
DB_URL = "mysql+pymysql://root:0000@localhost:3306/OH_Burger"
engine = create_engine(DB_URL)
Session = sessionmaker(bind=engine)
session = Session()

def scrape_unified_sniper():
    print("🎯 [통합 스나이퍼] 1번부터 13번까지 코드 하나로 자동 감지 시작!")
    
    target_url = "https://momstouch.co.kr/menu/new.php?pageNo=3&field=&keyword=&v_sect=&s_gubun=&s_level=&s_gender=&s_sect1=CG0005&s_sect2=&s_order="
    
    options = webdriver.ChromeOptions()
    # options.add_argument('--headless') 
    
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    
    try:
        print(f"🌐 사이트 접속 중...")
        driver.get(target_url)
        time.sleep(5)
        
        # 스크롤 끝까지 내리기 (중요)
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(2)
        
        # DB 이름 가져오기 & 이름 긴 순서대로 정렬 (버그 방지 필수!)
        db_burgers = session.execute(text("SELECT name FROM burgers WHERE brand='맘스터치'")).fetchall()
        burger_names = [b[0] for b in db_burgers]
        burger_names.sort(key=len, reverse=True)
        
        success_count = 0
        
        # 🔥 [핵심] 이제 i를 쪼개지 않고 1부터 13까지 한 번에 달립니다!
        for i in range(1, 14): 
            try:
                li_css = f"#momstouch-menu-burger > section > div.menu-list > ul > li:nth-child({i})"
                li_elem = driver.find_element(By.CSS_SELECTOR, li_css)
                full_text = li_elem.text
                
                # 1. 이름 매칭
                matched_name = None
                for b_name in burger_names:
                    if b_name in full_text:
                        matched_name = b_name
                        break
                        
                if not matched_name:
                    print(f"⚠️ {i}번째 카드는 DB 매칭 실패 (패스)")
                    continue
                
                # 2. 이미지 찾기 (공통 로직)
                img_url = ""
                try:
                    span_elem = driver.find_element(By.CSS_SELECTOR, f"{li_css} > a > figure > span")
                    try:
                        img_elem = span_elem.find_element(By.TAG_NAME, 'img')
                        img_url = img_elem.get_attribute('src')
                    except:
                        style = span_elem.get_attribute('style')
                        match = re.search(r'url\([\'"]?(.*?)[\'"]?\)', style)
                        if match:
                            img_url = match.group(1)
                except:
                    pass

                # 🔥 3. 설명 찾기 [통합 로직]
                # "5번째 줄(배지 O) 먼저 보고, 없으면 4번째 줄(배지 X) 봐라"
                description = ""
                potential_paths = [
                    f"{li_css} > a > p:nth-child(5)", # 1~4번 스타일 (우선순위 1)
                    f"{li_css} > a > p:nth-child(4)"  # 5~13번 스타일 (우선순위 2)
                ]
                
                for path in potential_paths:
                    try:
                        elem = driver.find_element(By.CSS_SELECTOR, path)
                        text_val = elem.text.strip()
                        if text_val: # 텍스트가 비어있지 않으면 그게 설명이다!
                            description = text_val
                            break # 찾았으니 탈출
                    except:
                        continue # 없으면 다음 후보(4번째 줄)로 넘어감

                # 4. DB 업데이트
                sql = text("""
                    UPDATE burgers 
                    SET image_url = :img_url, description = :desc 
                    WHERE name = :name AND brand = '맘스터치'
                """)
                session.execute(sql, {"img_url": img_url, "desc": description, "name": matched_name})
                
                success_count += 1
                print(f"🎯 [{matched_name}] 완료! (설명위치 자동감지 성공)")
                
            except Exception as ex:
                print(f"🚨 {i}번째 처리 중 에러: {ex}")
                
        session.commit()
        print(f"\n🎉 통합 스나이퍼 임무 완료! 총 {success_count}개 햄버거 업데이트 끝!")
        
    finally:
        driver.quit()

if __name__ == "__main__":
    scrape_unified_sniper()