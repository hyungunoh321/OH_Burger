import time
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# DB 설정
DB_URL = "mysql+pymysql://root:0000@localhost:3306/OH_Burger"
engine = create_engine(DB_URL)
Session = sessionmaker(bind=engine)
session = Session()

def get_driver():
    options = webdriver.ChromeOptions()
    # 브라우저가 눈에 보이게 설정 (디버깅용)
    options.add_argument("--start-maximized") 
    service = Service(ChromeDriverManager().install())
    return webdriver.Chrome(service=service, options=options)

def scrape_momstouch(driver):
    url = "https://www.momstouch.co.kr/menu/list.php?category_id=1"
    print(f"\n[맘스터치] {url} 접속 중...")
    driver.get(url)
    
    try:
        # 1. 페이지가 뜰 때까지 최대 10초 기다림
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.CLASS_NAME, "list_card"))
        )
        print("[맘스터치] 페이지 로딩 성공!")

        # 2. 햄버거 찾기
        items = driver.find_elements(By.CLASS_NAME, "list_card")
        print(f"[맘스터치] 발견된 햄버거 개수: {len(items)}개")

        if len(items) == 0:
            print("🚨 햄버거를 하나도 못 찾았습니다! 사이트 구조가 바뀌었거나 로딩이 덜 된 것 같아요.")
            return

        count = 0
        for item in items:
            try:
                name = item.find_element(By.CSS_SELECTOR, ".title").text
                img = item.find_element(By.CSS_SELECTOR, "img").get_attribute("src")
                
                # DB 저장 (중복 체크)
                exists = session.execute(text("SELECT id FROM burgers WHERE name = :name"), {"name": name}).fetchone()
                if not exists:
                    session.execute(text("""
                        INSERT INTO burgers (brand, name, price, tier, calories, image_url)
                        VALUES ('맘스터치', :name, 0, 'B', 500, :img)
                    """), {"name": name, "img": img})
                    count += 1
            except Exception as e:
                print(f"❌ 데이터 추출 실패: {e}")

        session.commit()
        print(f"✅ [맘스터치] {count}개 저장 완료!")

    except Exception as e:
        print(f"🚨 [맘스터치] 에러 발생: {e}")

if __name__ == "__main__":
    driver = get_driver()
    try:
        scrape_momstouch(driver)
    finally:
        print("스크래핑 종료. 5초 뒤 브라우저가 꺼집니다.")
        time.sleep(5)
        driver.quit()