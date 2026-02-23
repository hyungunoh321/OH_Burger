from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import time
import os
import requests
import re
import urllib3

# SSL 경고 무시
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# 1. DB 연결 (비밀번호 0000)
DB_URL = "mysql+pymysql://root:0000@localhost:3306/OH_Burger"
engine = create_engine(DB_URL)
Session = sessionmaker(bind=engine)
session = Session()

# 2. 이미지 저장 경로 (Frontend/public/kfc)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SAVE_DIR = os.path.join(BASE_DIR, "Frontend", "public", "kfc")

if not os.path.exists(SAVE_DIR):
    os.makedirs(SAVE_DIR)
    print(f"📂 폴더 생성 완료: {SAVE_DIR}")

def scrape_kfc_specific_range():
    print("🚀 [KFC] 19번~25번 메뉴 스크래핑 시작!")
    
    url = "https://www.kfckorea.com/menu/burger"
    
    options = webdriver.ChromeOptions()
    # options.add_argument('--headless') 
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    
    try:
        driver.get(url)
        time.sleep(3) # 페이지 로딩 대기

        # 요청하신 범위: 19번부터 25번까지 (Python range는 끝번호 미포함이라 26으로 설정)
        target_indices = range(19, 26)
        
        success_count = 0

        for i in target_indices:
            try:
                # 1. CSS Selector 구성 (알려주신 경로 그대로 사용)
                # li:nth-child({i}) 부분만 숫자가 바뀝니다.
                base_selector = f"#app > div:nth-child(3) > div > section > div:nth-child(2) > div > ul > li:nth-child({i})"
                
                # 요소 찾기
                li_element = driver.find_element(By.CSS_SELECTOR, base_selector)
                
                # 2. 제품명 (h3)
                name_elem = li_element.find_element(By.CSS_SELECTOR, "h3")
                name = name_elem.text.strip()
                
                # 3. 이미지 태그 (div.contents > a > img)
                img_elem = li_element.find_element(By.CSS_SELECTOR, "div.contents > a > img")
                img_url = img_elem.get_attribute("src")

                if not name or not img_url:
                    print(f"   ⚠️ {i}번 항목 데이터 없음 (패스)")
                    continue

                # 4. 이미지 다운로드
                # 파일명: kfc_이름.png (특수문자 제거)
                safe_name = "".join(c for c in name if c.isalnum() or c in (' ', '_', '-')).strip().replace(" ", "")
                file_name = f"kfc_{safe_name}.png"
                save_path = os.path.join(SAVE_DIR, file_name)
                db_img_path = f"/kfc/{file_name}"

                # 다운로드 실행
                img_data = requests.get(img_url, verify=False, timeout=10).content
                with open(save_path, 'wb') as f:
                    f.write(img_data)

                print(f"   ✅ [{i}번] {name} 저장 완료")

                # 5. DB 저장 (설명란은 비워둠)
                # 가격, 칼로리 등은 일단 0으로 초기화
                existing = session.execute(text("SELECT id FROM burgers WHERE name = :name AND brand = 'KFC'"), {"name": name}).fetchone()

                if existing:
                    # 이미 있으면 이미지 경로만 업데이트
                    session.execute(text("""
                        UPDATE burgers 
                        SET image_url = :img, brand = 'KFC'
                        WHERE id = :id
                    """), {"img": db_img_path, "id": existing.id})
                else:
                    # 없으면 신규 추가 (설명란 description은 빈 문자열 '')
                    session.execute(text("""
                        INSERT INTO burgers (brand, name, price, description, image_url, tier, calories, carbs, protein, fat)
                        VALUES ('KFC', :name, 0, '', :img, 'B', 0, 0, 0, 0)
                    """), {
                        "name": name, 
                        "img": db_img_path
                    })
                
                success_count += 1

            except Exception as e:
                print(f"   🚨 {i}번 항목 처리 중 에러: {e}")
                continue

        session.commit()
        print(f"\n🎉 총 {success_count}개의 KFC 메뉴 저장 완료!")

    finally:
        driver.quit()

if __name__ == "__main__":
    scrape_kfc_specific_range()