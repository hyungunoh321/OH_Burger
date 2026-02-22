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

# 1. DB 연결 (0000)
DB_URL = "mysql+pymysql://root:0000@localhost:3306/OH_Burger"
engine = create_engine(DB_URL)
Session = sessionmaker(bind=engine)
session = Session()

# 2. 이미지 저장 경로
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SAVE_DIR = os.path.join(BASE_DIR, "Frontend", "public", "nobrand")

if not os.path.exists(SAVE_DIR):
    os.makedirs(SAVE_DIR)

def scrape_nobrand_final():
    print("🚀 [노브랜드버거] HTML 구조 분석 완료! 스크래핑 시작...")
    
    url = "https://www.shinsegaefood.com/nobrandburger/menu/menu.sf"
    
    options = webdriver.ChromeOptions()
    # options.add_argument('--headless') 
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    
    try:
        driver.get(url)
        time.sleep(3)

        # 공략할 카테고리 ID (알려주신 2개)
        target_categories = ['cate_218', 'cate_246']
        
        # 기본 이미지 URL 앞부분 (HTML 분석 결과 data-img는 뒷부분만 있음)
        # img src="/uimages/..." 형태이므로 도메인 + /uimages/ 가 필요함
        BASE_IMG_URL = "https://www.shinsegaefood.com/uimages/"

        total_count = 0

        for cate_id in target_categories:
            print(f"\n📂 카테고리 진입: #{cate_id}")
            
            try:
                # 1. 탭 클릭 (혹시 모르니)
                try:
                    tab = driver.find_element(By.CSS_SELECTOR, f"a[href='#{cate_id}']")
                    driver.execute_script("arguments[0].click();", tab)
                    time.sleep(1)
                except:
                    pass

                # 2. 핵심: div ID 안의 'button.menu_anch' 를 직접 찾습니다!
                # 구조: div#cate_xxx > ul > li > button.menu_anch
                buttons = driver.find_elements(By.CSS_SELECTOR, f"div#{cate_id} ul.menu_list li button.menu_anch")
                
                if not buttons:
                    print(f"   ⚠️ 메뉴를 찾을 수 없습니다.")
                    continue
                
                print(f"   👉 {len(buttons)}개의 메뉴 발견!")

                for btn in buttons:
                    try:
                        # 3. 요청하신 데이터 추출 (data-*)
                        raw_name = btn.get_attribute('data-name')   # 이름 (줄바꿈 포함됨)
                        raw_img = btn.get_attribute('data-img')     # 이미지 경로 (2025/...)
                        raw_story = btn.get_attribute('data-story') # 설명 (HTML 태그 포함됨)

                        if not raw_name: continue

                        # 4. 데이터 정제 (Cleaning)
                        # 이름: "NBB 어메이징 더블 </br> NBB Amazing Double" -> "NBB 어메이징 더블"
                        # <br> 태그 앞부분(한글)만 가져오기
                        clean_name = raw_name.split('<')[0].split('&')[0].strip()
                        
                        # 설명: HTML 태그(<span> 등) 제거하고 순수 텍스트만
                        clean_story = re.sub(r'<[^>]+>', '', raw_story).strip()
                        clean_story = clean_story.replace('&nbsp;', ' ').replace('&amp;', '&')

                        # 이미지 URL 완성
                        if raw_img.startswith('http'):
                            full_img_url = raw_img
                        else:
                            # data-img는 "2026/..." 로 시작하므로 앞에 도메인과 폴더 붙여줌
                            full_img_url = BASE_IMG_URL + raw_img

                        # 5. 이미지 다운로드
                        safe_name = "".join(c for c in clean_name if c.isalnum() or c in (' ', '_', '-')).strip().replace(" ", "")
                        file_name = f"nb_{safe_name}.png"
                        save_path = os.path.join(SAVE_DIR, file_name)
                        db_img_path = f"/nobrand/{file_name}"

                        # 다운로드
                        img_data = requests.get(full_img_url, verify=False, timeout=10).content
                        with open(save_path, 'wb') as f:
                            f.write(img_data)
                        
                        print(f"      ✅ 저장: {clean_name}")

                        # 6. DB 저장 (기존 거 있으면 업데이트)
                        # ID, Tier, 영양성분은 일단 기본값(0, 'B')으로 넣습니다.
                        existing = session.execute(text("SELECT id FROM burgers WHERE name = :name AND brand = '노브랜드'"), {"name": clean_name}).fetchone()

                        if existing:
                            session.execute(text("""
                                UPDATE burgers 
                                SET description = :desc, image_url = :img, brand = '노브랜드'
                                WHERE id = :id
                            """), {"desc": clean_story, "img": db_img_path, "id": existing.id})
                        else:
                            session.execute(text("""
                                INSERT INTO burgers (brand, name, price, description, image_url, tier, calories, carbs, protein, fat)
                                VALUES ('노브랜드', :name, 0, :desc, :img, 'B', 0, 0, 0, 0)
                            """), {
                                "name": clean_name, 
                                "desc": clean_story, 
                                "img": db_img_path
                            })
                        
                        total_count += 1

                    except Exception as e:
                        print(f"      🚨 개별 항목 에러: {e}")
                        continue

            except Exception as e:
                print(f"   ⚠️ 카테고리 에러: {e}")

        session.commit()
        print(f"\n🎉 노브랜드버거 총 {total_count}개 메뉴 저장 완료!")

    finally:
        driver.quit()

if __name__ == "__main__":
    scrape_nobrand_final()