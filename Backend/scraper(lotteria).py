from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import time
import os
import requests
import urllib3
import re  # 📌 정규표현식 모듈 추가 (URL 추출용)

# SSL 경고 무시
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# 1. DB 연결
DB_URL = "mysql+pymysql://root:0000@localhost:3306/OH_Burger"
engine = create_engine(DB_URL)
Session = sessionmaker(bind=engine)
session = Session()

# 2. 이미지 저장 경로
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SAVE_DIR = os.path.join(BASE_DIR, "Frontend", "public", "lotteria")

if not os.path.exists(SAVE_DIR):
    os.makedirs(SAVE_DIR)

def scrape_lotteria_final():
    print("🚀 [롯데리아] 버거 메뉴 스크래핑 시작 (배경 이미지 파싱 버전)")
    
    url = "https://www.lotteeatz.com/brand/ria"
    
    options = webdriver.ChromeOptions()
    # options.add_argument('--headless')
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    
    try:
        driver.get(url)
        
        # 1. 사이트 접속 대기
        wait = WebDriverWait(driver, 20)
        wait.until(EC.presence_of_element_located((By.ID, "productList")))
        time.sleep(2)

        # 2. '버거' 버튼 클릭
        try:
            print("🖱️ '버거' 카테고리 클릭 시도...")
            burger_btn = wait.until(EC.element_to_be_clickable((By.XPATH, '//*[@id="DCT_0000000000001153"]/a')))
            burger_btn.click()
            print("   ✅ 클릭 성공! 버거 메뉴 로딩 대기 중...")
            time.sleep(3) # 클릭 후 로딩 대기
            
        except Exception as e:
            print(f"   🚨 버거 버튼 클릭 실패: {e}")
            return

        # 3. 스크롤 내려서 이미지 로딩 유도
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(2)

        # 4. 스크래핑 시작
        base_selector = "#productList > div > ul"
        success_count = 0

        # 넉넉하게 1번부터 40번까지 돌면서 있는 것만 가져옴
        for i in range(1, 40):
            try:
                li_selector = f"{base_selector} > li:nth-child({i})"
                
                # 해당 순번의 메뉴가 없으면 에러가 나므로 try-except로 넘어감
                try:
                    li_element = driver.find_element(By.CSS_SELECTOR, li_selector)
                except:
                    # 더 이상 메뉴가 없으면 종료할 수도 있지만, 중간에 비어있을 수도 있으니 continue
                    if i > 30: break # 30번 넘어가서도 없으면 진짜 끝난 걸로 간주
                    continue
                
                # --- [이름 추출] ---
                try:
                    name_elem = li_element.find_element(By.CSS_SELECTOR, "div.prod-info-box > div.prod-tit")
                    name = name_elem.text.strip()
                    if not name:
                         name = li_element.find_element(By.CSS_SELECTOR, "div.prod-info-box > div.prod-tit > strong").text.strip()
                except:
                    continue # 이름 없으면 패스

                # --- [이미지 추출: background-image 파싱] ---
                img_url = ""
                try:
                    # div.thumb-img 요소 가져오기
                    thumb_div = li_element.find_element(By.CSS_SELECTOR, "div.thumb-box > div.thumb-img")
                    
                    # style 속성값 전체 가져오기 (예: "background-image: url(...)")
                    style_attr = thumb_div.get_attribute("style")
                    
                    # 정규표현식으로 url(...) 괄호 안의 주소만 쏙 빼내기
                    match = re.search(r'url\((.*?)\)', style_attr)
                    if match:
                        # 따옴표가 있을 수도 있으니 제거 (' 또는 " 제거)
                        img_url = match.group(1).strip('\'"')
                    
                except Exception as e:
                    print(f"   ⚠️ {name}: 이미지 파싱 에러 ({e})")
                    continue

                if not img_url:
                    print(f"   ⚠️ {name}: 이미지 URL 없음 (스타일: {style_attr[:30]}...)")
                    continue

                # --- [다운로드 및 저장] ---
                safe_name = "".join(c for c in name if c.isalnum() or c in (' ', '_', '-')).strip().replace(" ", "")
                file_name = f"lt_{safe_name}.png"
                save_path = os.path.join(SAVE_DIR, file_name)
                db_img_path = f"/lotteria/{file_name}"
                
                headers = {
                    "User-Agent": "Mozilla/5.0",
                    "Referer": "https://www.lotteeatz.com/"
                }
                
                # 이미지 다운로드
                img_data = requests.get(img_url, headers=headers, verify=False, timeout=10).content
                with open(save_path, 'wb') as f:
                    f.write(img_data)
                
                print(f"   ✅ [{i}번] {name} 저장 완료")
                
                # DB 업데이트
                existing = session.execute(text("SELECT id FROM burgers WHERE name = :name AND brand = '롯데리아'"), {"name": name}).fetchone()

                if existing:
                    session.execute(text("UPDATE burgers SET image_url = :img, brand = '롯데리아' WHERE id = :id"), {"img": db_img_path, "id": existing.id})
                else:
                    session.execute(text("INSERT INTO burgers (brand, name, price, description, image_url, tier, calories, carbs, protein, fat) VALUES ('롯데리아', :name, 0, '', :img, 'B', 0, 0, 0, 0)"), {"name": name, "img": db_img_path})
                
                success_count += 1

            except Exception as e:
                # print(f"   🚨 {i}번 처리 중 에러: {e}")
                continue

        session.commit()
        print(f"\n🎉 총 {success_count}개의 롯데리아 버거 저장 완료!")

    finally:
        driver.quit()

if __name__ == "__main__":
    scrape_lotteria_final()