from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import time
import re

# 1. DB 연결 설정
DB_URL = "mysql+pymysql://root:0000@localhost:3306/OH_Burger"
engine = create_engine(DB_URL)
Session = sessionmaker(bind=engine)
session = Session()

def scrape_images_and_desc():
    print("🎯 [스나이퍼 모드 V4] 이름 겹침(Substring) 버그 완벽 해결 버전!")
    
    target_url = "https://momstouch.co.kr/menu/new.php?pageNo=1&field=&keyword=&v_sect=&s_gubun=&s_level=&s_gender=&s_sect1=CG0005&s_sect2=&s_order="
    
    options = webdriver.ChromeOptions()
    # options.add_argument('--headless') 
    
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    
    try:
        print(f"🌐 사이트 접속 중...")
        driver.get(target_url)
        time.sleep(5)
        
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(2)
        
        db_burgers = session.execute(text("SELECT name FROM burgers WHERE brand='맘스터치'")).fetchall()
        burger_names = [b[0] for b in db_burgers]
        
        # 💥 [핵심 버그 픽스] 이름이 긴 것부터 먼저 검사하도록 내림차순 정렬!
        # 이렇게 하면 '불불불불싸이버거'를 '싸이버거'로 오해하는 일이 절대 안 생깁니다.
        burger_names.sort(key=len, reverse=True)
        
        success_count = 0
        
        for i in range(5, 13): 
            try:
                li_css = f"#momstouch-menu-burger > section > div.menu-list > ul > li:nth-child({i})"
                li_elem = driver.find_element(By.CSS_SELECTOR, li_css)
                full_text = li_elem.text
                
                matched_name = None
                for b_name in burger_names:
                    if b_name in full_text:
                        matched_name = b_name
                        break
                        
                if not matched_name:
                    print(f"⚠️ {i}번째 카드는 DB에 없는 메뉴라 건너뜁니다.")
                    continue
                    
                # 📸 [좌표 1] 이미지 찾기
                img_url = ""
                span_elem = driver.find_element(By.CSS_SELECTOR, f"{li_css} > a > figure > span")
                try:
                    img_elem = span_elem.find_element(By.TAG_NAME, 'img')
                    img_url = img_elem.get_attribute('src')
                except:
                    style = span_elem.get_attribute('style')
                    match = re.search(r'url\([\'"]?(.*?)[\'"]?\)', style)
                    if match:
                        img_url = match.group(1)

                # 📝 [좌표 2] 설명 찾기 (p:nth-child(4) 고정)
                desc_elem = driver.find_element(By.CSS_SELECTOR, f"{li_css} > a > p:nth-child(4)")
                description = desc_elem.text.strip()
                
                # 💾 DB 업데이트
                sql = text("""
                    UPDATE burgers 
                    SET image_url = :img_url, description = :desc 
                    WHERE name = :name AND brand = '맘스터치'
                """)
                session.execute(sql, {"img_url": img_url, "desc": description, "name": matched_name})
                
                success_count += 1
                print(f"🎯 저격 성공: [{matched_name}] (설명: {description[:15]}...)")
                
            except Exception as ex:
                print(f"🚨 {i}번째 데이터 치명적 에러: {ex}")
                
        session.commit()
        print(f"\n🎉 5~12번 스나이퍼 임무 완벽 완료! 총 {success_count}개 햄버거 업데이트 완료!")
        
    finally:
        driver.quit()

if __name__ == "__main__":
    scrape_images_and_desc()