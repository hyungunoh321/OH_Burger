from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import time
import os
import requests
import urllib3

# SSL 경고 무시
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# 1. DB 연결
DB_URL = "mysql+pymysql://root:0000@localhost:3306/OH_Burger"
engine = create_engine(DB_URL)
Session = sessionmaker(bind=engine)
session = Session()

# 2. 이미지 저장 경로
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SAVE_DIR = os.path.join(BASE_DIR, "Frontend", "public", "burgerking")

if not os.path.exists(SAVE_DIR):
    os.makedirs(SAVE_DIR)

def scrape_burgerking_robust():
    print("🚀 [버거킹] 정밀 스크래핑 시작 (경로 단축 & 개별 탐색)")
    
    url = "https://www.burgerking.co.kr/menu/main"
    
    options = webdriver.ChromeOptions()
    # options.add_argument('--headless') # 브라우저 창 보고 싶으면 주석 처리
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    
    try:
        driver.get(url)
        
        # [핵심] 페이지 로딩을 확실하게 기다립니다 (최대 15초)
        # 'menu_list_wrap'이라는 클래스가 뜰 때까지 대기
        wait = WebDriverWait(driver, 15)
        wait.until(EC.presence_of_element_located((By.CLASS_NAME, "menu_list_wrap")))
        time.sleep(2) # 렌더링 안정화 대기

        # 스크롤 내려서 이미지 로딩 유도
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(1)

        # ✅ 사용자가 지정한 좌표 (하나씩 순회합니다)
        # Key: 섹션 번호(div:nth-child), Value: 메뉴 번호들(li:nth-child)
        targets = {
            2: [3, 5, 7, 10, 12],                                  # 프리미엄
            3: [3, 4, 8, 16, 20, 24, 27],                          # 와퍼
            4: [2, 6, 9, 12, 15, 16, 21, 22, 25, 30, 32, 34],      # 주니어/치킨
            5: [3, 5, 8, 11, 15, 17, 22],                          # 기타
            6: [11, 14, 18, 19, 22, 25]                            # 사이드/신메뉴
        }
        
        total_count = 0

        # [경로 단축] 불필요한 앞부분(#app > ion...)을 날리고 핵심부터 찾습니다.
        # 훨씬 튼튼한 경로입니다.
        base_selector = "div.menu_list_wrap"

        for section_idx, item_indices in targets.items():
            print(f"\n📂 섹션 {section_idx}번 탐색 중...")
            
            for item_idx in item_indices:
                try:
                    # 1. 요소 찾기 (반복문으로 하나씩 조립)
                    # 예: div.menu_list_wrap > div:nth-child(2) > ul > li:nth-child(3)
                    li_selector = f"{base_selector} > div:nth-child({section_idx}) > ul > li:nth-child({item_idx})"
                    
                    # 해당 메뉴(li) 찾기
                    li_element = driver.find_element(By.CSS_SELECTOR, li_selector)
                    
                    # 2. 이름 추출
                    try:
                        name_elem = li_element.find_element(By.CSS_SELECTOR, "div.cont > p > span")
                        name = name_elem.text.strip()
                    except:
                        # span 없으면 p 태그 전체
                        name_elem = li_element.find_element(By.CSS_SELECTOR, "div.cont > p")
                        name = name_elem.text.strip()

                    # 3. 이미지 추출
                    img_elem = li_element.find_element(By.CSS_SELECTOR, "div.prd_image > span > img")
                    img_url = img_elem.get_attribute("src")

                    if not name or not img_url:
                        print(f"   ⚠️ 데이터 비어있음 (섹션{section_idx}-항목{item_idx})")
                        continue

                    # 4. 이미지 다운로드
                    safe_name = "".join(c for c in name if c.isalnum() or c in (' ', '_', '-')).strip().replace(" ", "")
                    file_name = f"bk_{safe_name}.png"
                    save_path = os.path.join(SAVE_DIR, file_name)
                    db_img_path = f"/burgerking/{file_name}"

                    img_data = requests.get(img_url, verify=False, timeout=10).content
                    with open(save_path, 'wb') as f:
                        f.write(img_data)
                    
                    print(f"   ✅ [{section_idx}-{item_idx}] {name} 저장 완료")

                    # 5. DB 저장
                    existing = session.execute(text("SELECT id FROM burgers WHERE name = :name AND brand = '버거킹'"), {"name": name}).fetchone()

                    if existing:
                        session.execute(text("""
                            UPDATE burgers 
                            SET image_url = :img, brand = '버거킹'
                            WHERE id = :id
                        """), {"img": db_img_path, "id": existing.id})
                    else:
                        session.execute(text("""
                            INSERT INTO burgers (brand, name, price, description, image_url, tier, calories, carbs, protein, fat)
                            VALUES ('버거킹', :name, 0, '', :img, 'B', 0, 0, 0, 0)
                        """), {
                            "name": name, 
                            "img": db_img_path
                        })
                    
                    total_count += 1

                except Exception as e:
                    # 어떤 녀석이 문제인지 정확히 알려줍니다
                    print(f"   🚨 에러 발생 (섹션{section_idx} - {item_idx}번 항목): {e}")
                    continue

        session.commit()
        print(f"\n🎉 총 {total_count}개의 버거킹 메뉴 저장 성공!")

    finally:
        driver.quit()

if __name__ == "__main__":
    scrape_burgerking_robust()