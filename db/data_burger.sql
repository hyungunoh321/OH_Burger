-- OH Burger 버거 초기 데이터
-- 각 브랜드 공식 홈페이지에서 2026-11-14 에 조회한 값. 단품 기준. (가격 · 이미지 주소는 2026-11-15 보완)
-- 실행: mysql -u root -p --default-character-set=utf8mb4 -e "source db/data_burger.sql"
-- 다시 실행해도 추천 · 조회수는 유지되고 버거 정보만 갱신된다.
--
-- 알아둘 점
--  * 가격은 롯데리아와 KFC(딜리버리 메뉴 기준)만 공식 사이트에 공개돼 있다
--  * 맥도날드 · 버거킹 · 맘스터치 · 노브랜드버거의 가격은 공식 값이 아니라 나무위키 · 기사에서 옮긴 매장 가격이라
--    최신 값과 다를 수 있다 (브랜드별 출처는 아래 주석). 확인하지 못한 53종은 NULL (목록: db/prices_todo.csv)
--  * image_url 은 각 브랜드 공식 사이트의 제품 사진 주소다. 파일을 내려받지 않고 주소만 저장한다
--    (맥도날드는 사이트에 세트 사진만 있는 메뉴가 많아 세트 사진이다)
--  * 맘스터치 · KFC · 노브랜드버거 · 프랭크버거의 영양 정보는 이미지로 된 표를 눈으로 읽어 옮긴 값
--    (2026-11-15 에 72종을 표와 다시 대조했고 다른 값은 없었다)
--  * 롯데리아 한우불고기버거는 사이트에 열량 범위만 있어 영양 정보가 NULL
--  * 패티 종류(patty_type)는 공식 분류가 아니라 메뉴명 · 설명을 보고 정한 값

USE oh_burger;

-- 맥도날드 (21종)
-- 출처: https://www.mcdonalds.co.kr/kor/menu/information/nutrition
-- 가격: 나무위키 '맥도날드/메뉴' 의 가격표(2026-03-05 기준, 매장 가격), 2026-11-15 조회
SET @b := (SELECT brand_id FROM brand WHERE name = '맥도날드');
INSERT INTO burger (brand_id, name, description, patty_type, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg, image_url) VALUES
  (@b, '빅맥', NULL, 'BEEF', 5700, 223, 582, 27.0, 11.0, 8.0, 902, 'https://www.mcdonalds.co.kr/upload/2025/08/%EB%B9%85%EB%A7%A5%C2%AE_%EC%84%B8%ED%8A%B8.png'),
  (@b, '맥스파이시 상하이버거', NULL, 'CHICKEN', 5900, 246, 528, 22.0, 3.2, 9.0, 952, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1723562660091.png'),
  (@b, '1955 버거', NULL, 'BEEF', 6700, 264, 572, 29.0, 10.0, 15.0, 930, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1723564262197.png'),
  (@b, '맥치킨 모짜렐라', NULL, 'CHICKEN', 5000, 293, 735, 29.0, 7.0, 18.0, 1807, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1723563301214.png'),
  (@b, '맥치킨', NULL, 'CHICKEN', 3500, 206, 515, 19.0, 3.6, 7.0, 1148, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1723563415066.png'),
  (@b, '더블 불고기버거', NULL, 'ETC', 4700, 237, 635, 26.0, 13.0, 15.0, 997, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1723563975095.png'),
  (@b, '불고기버거', NULL, 'ETC', 3800, 167, 408, 14.0, 6.0, 14.0, 670, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1723564031536.png'),
  (@b, '슈슈버거', NULL, 'SEAFOOD', 4700, 225, 431, 13.0, 1.9, 13.0, 758, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1723563590522.png'),
  (@b, '슈비버거', NULL, 'SEAFOOD', 6200, 269, 573, 22.0, 6.0, 15.0, 951, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1723564188909.png'),
  (@b, '더블 쿼터파운더 치즈', NULL, 'BEEF', 7700, 275, 770, 50.0, 20.0, 10.0, 1151, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1723563759418.png'),
  (@b, '베이컨 토마토 디럭스', NULL, 'BEEF', 5800, 247, 570, 29.0, 11.0, 14.0, 933, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1723563896442.png'),
  (@b, '쿼터파운더 치즈', NULL, 'BEEF', 5900, 198, 536, 31.0, 13.0, 10.0, 966, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1723563812629.png'),
  (@b, '치즈버거', NULL, 'BEEF', 3200, 115, 318, 16.0, 6.0, 7.0, 612, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1723563067813.png'),
  (@b, '더블 치즈버거', NULL, 'BEEF', 5000, 167, 479, 27.0, 12.0, 8.0, 896, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1723563512104.png'),
  (@b, '햄버거', NULL, 'BEEF', 2800, 101, 266, 13.0, 3.5, 7.0, 450, 'https://www.mcdonalds.co.kr/upload/2025/08/%ED%96%84%EB%B2%84%EA%B1%B0.png'),
  (@b, '트리플 치즈버거', NULL, 'BEEF', 6100, 216, 640, 38.0, 18.0, 8.0, 1152, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1744956010637.png'),
  (@b, '토마토 치즈 비프 버거', NULL, 'BEEF', 4000, 200, 402, 18.0, 7.0, 11.0, 682, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1742426716721.png'),
  (@b, '더블 맥스파이시 상하이 버거', NULL, 'CHICKEN', 9300, 362, 867, 38.0, 6.0, 10.0, 1640, 'https://www.mcdonalds.co.kr/upload/2026/02/Corp_PC_VIEW_772x530_%EB%8D%94%EB%B8%94%EC%83%81%ED%95%98%EC%9D%B4_EVM.png'),
  (@b, '맥크리스피 치킨 디럭스', NULL, 'CHICKEN', 6800, 275, 578, 23.0, 4.7, 13.0, 1297, 'https://www.mcdonalds.co.kr/upload/2026/02/Corp_PC_VIEW_%EB%A7%A5%ED%81%AC%EB%A6%AC%ED%94%BC_%EC%B9%98%ED%82%A8_%EB%94%94%EB%9F%AD%EC%8A%A4_772x530_new.png'),
  (@b, '맥크리스피 치킨 클래식', NULL, 'CHICKEN', 5900, 209, 567, 23.0, 4.7, 11.0, 1295, 'https://www.mcdonalds.co.kr/upload/2026/02/Corp_PC_VIEW_%EB%A7%A5%ED%81%AC%EB%A6%AC%ED%94%BC_%EC%B9%98%ED%82%A8_%ED%81%B4%EB%9E%98%EC%8B%9D_772x530_new.png'),
  (@b, '빅아치', NULL, 'BEEF', 12400, 370, 1036, 56.0, 26.0, 12.0, 1661, 'https://www.mcdonalds.co.kr/upload/2026/10/Corp_PC_VIEW_772x530_%EB%B9%85%EC%95%84%EC%B9%98_EVM.png')
AS new ON DUPLICATE KEY UPDATE
  description = new.description, patty_type = new.patty_type, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg, image_url = new.image_url;

-- 버거킹 (38종)
-- 출처: https://www.burgerking.co.kr/menu/main (메뉴 상세의 영양성분 표)
-- 가격: 나무위키 '버거킹/메뉴'(2026-10-30 수정) · '버거킹/기간 한정 메뉴'(2026-11-15 수정) 의 매장 단품 가격, 2026-11-15 조회
--       2026년 2월 가격 인상 전에 적힌 것으로 보이는 한정 메뉴(맥시멈, 치킨 치즈 마요 등 6종)는 넣지 않았다
SET @b := (SELECT brand_id FROM brand WHERE name = '버거킹');
INSERT INTO burger (brand_id, name, description, patty_type, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg, image_url) VALUES
  (@b, '몬스터 맥시멈', NULL, 'BEEF', NULL, 376, 1067, 51.0, 19.0, 13.0, 2273, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2026/08/11/d6d143b1-6d4e-42cf-b155-e0746eac89d0.png'),
  (@b, '몬스터 맥시멈2', NULL, 'BEEF', NULL, 457, 1305, 71.0, 23.0, 13.0, 2313, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2026/08/11/cbcc591c-4fa1-4409-a1b6-3f2088214eb5.png'),
  (@b, '몬스터 맥시멈3', NULL, 'BEEF', NULL, 559, 1619, 90.0, 35.0, 19.0, 2810, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2026/08/11/f7f790ce-3ad4-485b-9807-9ef26948c192.png'),
  (@b, '더오치 맥시멈2', NULL, 'BEEF', NULL, 375, 1018, 53.0, 29.0, 9.0, 2045, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/08/07/d426a52d-4137-4406-9e9c-a7d8b252c281.png'),
  (@b, '오리지널스 엘파소 치폴레', NULL, 'BEEF', 10900, 291, 911, 44.0, 25.0, 9.0, 1338, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2026/05/20/ea8f8fca-c784-4795-ab83-cad5bb16ad0b.png'),
  (@b, '오리지널스 뉴욕 스테이크', NULL, 'BEEF', 10900, 307, 826, 51.0, 22.0, 10.0, 1762, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/05/16/de79cfd1-e414-4bf7-9e5f-c7a5afcd80c5.png'),
  (@b, '블랙 트러플치즈 버거', NULL, 'BEEF', 10700, 281, 769, 34.0, 18.0, 9.0, 1430, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2026/10/13/cb8a79e9-8506-4ce9-bcc3-a5c476291591.png'),
  (@b, '트러플 머쉬룸 와퍼', NULL, 'BEEF', 9700, 325, 761, 37.0, 16.0, 6.0, 1195, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2026/09/07/e160391f-9dda-4d94-a81e-0db7c82f8f2b.png'),
  (@b, '핫 트러플 머쉬룸 와퍼', NULL, 'BEEF', 9700, 285, 724, 35.0, 14.0, 7.0, 1278, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2026/09/07/a5db9372-c8d1-4d94-8bce-8be2be3c2506.png'),
  (@b, '메종 트러플치즈 버거', NULL, 'BEEF', 10500, 281, 744, 35.0, 19.0, 14.0, 1451, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2026/09/07/a6526eec-6344-443a-b0b1-c7f3bbbd9543.png'),
  (@b, '몬스터와퍼', NULL, 'BEEF', 9600, 403, 1094, 52.0, 21.0, 8.0, 2146, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/ffefc938-62f3-4bc0-8a54-bad31db5d63a.png'),
  (@b, '베이컨치즈와퍼', NULL, 'BEEF', 9200, 320, 844, 37.0, 19.0, 8.0, 1654, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/cafd8a5d-fbed-42c6-946d-c2f9cf009446.png'),
  (@b, '콰트로치즈와퍼', NULL, 'BEEF', 8200, 331, 887, 43.0, 21.0, 6.0, 1647, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/fe3b84c2-1e1c-47c1-aea2-a8a7f6d5a069.png'),
  (@b, '통새우와퍼', NULL, 'BEEF', 8200, 309, 714, 34.0, 12.0, 9.0, 1258, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/b29489df-fafb-43f1-b0e1-21ab7b0c19e3.png'),
  (@b, '와퍼', NULL, 'BEEF', 7400, 286, 706, 30.0, 12.0, 10.0, 1098, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/c9811022-3678-4988-9fa4-1d3fc6a69bf5.png'),
  (@b, '치즈와퍼', NULL, 'BEEF', 8000, 310, 799, 35.0, 18.0, 7.0, 1571, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/d14c3a22-568d-41f8-ba30-02ee39bfe647.png'),
  (@b, '불고기와퍼', NULL, 'BEEF', 7400, 293, 738, 31.0, 13.0, 10.0, 1137, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/fc969a33-3281-4601-91bb-b3aa789afc11.png'),
  (@b, '갈릭불고기와퍼', NULL, 'BEEF', 7700, 293, 768, 31.0, 12.0, 9.0, 1007, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/c84d6cc7-298a-440f-8328-1839031ef46e.png'),
  (@b, '콰트로치즈 와퍼주니어', NULL, 'BEEF', 5600, 179, 470, 21.0, 10.0, 4.0, 833, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/c46f1544-d3a5-4d68-8692-737c2cbb3da5.png'),
  (@b, '통새우와퍼주니어', NULL, 'BEEF', 5600, 168, 414, 17.0, 7.0, 5.0, 658, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2024/12/04/f9899937-0f95-4d89-9a9a-5fef132a7346.png'),
  (@b, '더블비프불고기버거', NULL, 'BEEF', 5000, 190, 565, 26.0, 12.0, 6.0, 796, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/d8688732-ccfa-41b1-8afa-ff3646d45c2a.png'),
  (@b, '와퍼주니어', NULL, 'BEEF', 5000, 156, 376, 17.0, 5.0, 4.0, 556, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2024/12/04/da324f38-2864-4382-ae9a-a97faf5bd265.png'),
  (@b, '치즈와퍼주니어', NULL, 'BEEF', 5300, 168, 422, 18.0, 7.0, 4.0, 778, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/b1b8de28-8b85-450a-9c58-c40a9a2fad3d.png'),
  (@b, '불고기와퍼주니어', NULL, 'BEEF', 5000, 160, 413, 16.0, 6.0, 5.0, 617, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/b3cc4d6e-7a84-472a-ae04-061151ba70d1.png'),
  (@b, '비프불고기버거', NULL, 'BEEF', 4000, 136, 384, 15.0, 5.0, 5.0, 492, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/e8510c49-b02b-4f6f-97e3-e0f5b7ed649c.png'),
  (@b, '치즈버거', NULL, 'BEEF', 3500, 130, 380, 16.0, 7.0, 6.0, 766, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/d7977b8b-93c0-403f-834b-d9164f06cad6.png'),
  (@b, '쯔란로제 크리스퍼', NULL, 'CHICKEN', 6200, 233, 660, 27.0, 9.0, 11.0, 1694, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2026/10/29/b0cfe423-69ab-4463-8e19-b85d7b27ed5f.png'),
  (@b, '쯔란로제 딥 치즈 크리스퍼', NULL, 'CHICKEN', 7200, 288, 692, 31.0, 11.0, 9.0, 1779, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2026/10/29/eeef974b-2fcf-4e8a-b1c0-7d2ead12d431.png'),
  (@b, '더 크리스퍼', NULL, 'CHICKEN', 5700, 225, 696, 26.0, 9.0, 5.0, 1392, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2026/01/13/d895878b-82cf-4563-8b0e-ae369eabd10f.png'),
  (@b, '더 크리스퍼 베이컨&치즈', NULL, 'CHICKEN', 6700, 231, 727, 28.0, 10.0, 6.0, 1553, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2026/01/13/e7067ea7-1992-4fae-bb9e-8ab039e5d72e.png'),
  (@b, '치킨킹BLT', NULL, 'CHICKEN', 7400, 269, 739, 25.0, 11.0, 12.0, 1065, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/fd99206f-4072-4c2f-955c-12386291073a.png'),
  (@b, '치킨킹', NULL, 'CHICKEN', 6400, 224, 673, 24.0, 10.0, 8.0, 1037, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/b24d04e3-96d6-4cc1-b07d-fc171a7fc6b8.png'),
  (@b, '통새우슈림프버거', NULL, 'SEAFOOD', 6000, 190, 512, 16.0, 5.0, 8.0, 1077, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/b14f9d55-6932-4b58-8bfe-2a21ed63f376.png'),
  (@b, '치킨 치즈 마요 버거', NULL, 'CHICKEN', NULL, 195, 640, 20.0, 10.0, 4.0, 1122, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/07/22/bed42084-4793-41bc-b89f-9cae7bc211d7.png'),
  (@b, '치킨버거', NULL, 'CHICKEN', 3700, 179, 532, 18.0, 7.0, 4.0, 840, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/01/06/eea3248f-3d79-4618-a87d-c9e07b61c432.png'),
  (@b, '롱치킨버거', NULL, 'CHICKEN', 4700, 206, 621, 23.0, 7.0, 7.0, 1235, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2026/06/01/db0cc305-f7e3-4feb-a5e3-740ded880c2a.png'),
  (@b, '불고기 롱치킨버거', NULL, 'CHICKEN', NULL, 234, 691, 23.0, 7.0, 7.0, 1434, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2026/06/01/a1ee1a78-7098-496d-bdf5-bfc1120e6fa4.png'),
  (@b, '몬스터 주니어', NULL, 'BEEF', 5200, 243, 687, 30.0, 13.0, 7.0, 1293, 'https://mob-prd.burgerking.co.kr/images/menu/web/main/2025/06/11/aa9ef4a9-ec10-4664-9080-d9b07f368867.png')
AS new ON DUPLICATE KEY UPDATE
  description = new.description, patty_type = new.patty_type, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg, image_url = new.image_url;

-- 롯데리아 (29종)
-- 출처: https://www.lotteeatz.com/brand/ria
SET @b := (SELECT brand_id FROM brand WHERE name = '롯데리아');
INSERT INTO burger (brand_id, name, description, patty_type, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg, image_url) VALUES
  (@b, '리아 불고기 레드', '익숙한 불고기의 감칠맛에 청양고추 엑기스를 더해 맛있게 매운맛의 리아 불고기, 바삭한 감자채전 토핑으로 든든하게', 'BEEF', 6200, 238, 550, 22.0, 12.0, 20.0, 1110, 'https://img.lotteeatz.com/upload/product/2026/08/27/20260827141828795_6.png/dims/resize/x400/optimize'),
  (@b, '리아 불고기 더블 레드', '익숙한 불고기의 감칠맛에 청양고추 액기스를 더해 맛있게 매운맛의 리아 불고기, 더블패티 구성으로 든든하게', 'BEEF', 8000, 280, 731, 38.0, 23.0, 16.0, 1570, 'https://img.lotteeatz.com/upload/product/2026/08/27/20260827141846348_9.png/dims/resize/x400/optimize'),
  (@b, '리아 두툼새우', '탱글 두툼한 새우패티로 새우 본연의 풍미를 깔끔하게 끌어올린 리아 새우 한정판', 'SEAFOOD', 7900, 263, 549, 18.0, 3.2, 11.0, 1300, 'https://img.lotteeatz.com/upload/product/2026/07/15/20260715141202435_8.png/dims/resize/x400/optimize'),
  (@b, '리아 두툼새우 스파이시토마토', '매콤한 토마토소스에 딱새우의 머리부터 껍질까지 농축한 액기스를 더해 은은한 감칠맛을 끌어올린 리아 새우 한정판', 'SEAFOOD', 7900, 263, 516, 18.0, 4.0, 10.0, 1310, 'https://img.lotteeatz.com/upload/product/2026/07/15/20260715141146741_5.png/dims/resize/x400/optimize'),
  (@b, '하와이안 모짜렐라버거', '달콤한 파인애플과 쭉 늘어나는 모짜렐라, 나폴리탄 소스를 더해 완벽한 단짠 조합의 모짜렐라버거', 'BEEF', 8800, 290, 773, 26.0, 18.0, 14.0, 1150, 'https://img.lotteeatz.com/upload/product/2026/06/17/20260617080434865_4.jpg/dims/resize/x400/optimize'),
  (@b, '통다리 크리스피치킨버거(파이어핫)', '육즙 가득 통다리살에 버터밀크 외피로 입안을 가득 채우는 바삭함이 특징, 중독성 있는 갈릭핫소스로 강렬한 매운맛의 크리스피치킨버거', 'CHICKEN', 6900, 231, 594, 25.0, 4.4, 10.0, 1040, 'https://img.lotteeatz.com/upload/product/2026/10/27/20261027134726413_7.png/dims/resize/x400/optimize'),
  (@b, '통다리 크리스피치킨버거(그릭랜치)', '육즙 가득 통다리살에 버터밀크 외피로 입안을 가득 채우는 바삭함이 특징, 요거트 첨가된 그릭랜치소스로 마일드한 맛의 크리스피치킨버거', 'CHICKEN', 6900, 231, 618, 25.0, 5.0, 8.0, 1050, 'https://img.lotteeatz.com/upload/product/2026/10/27/2026102713364243_8.png/dims/resize/x400/optimize'),
  (@b, '나폴리 모짜렐라버거 발사믹바질', '바질의 신선함을 담은 바질마요소스에 레드와인 발사믹의 산뜻함을 더한 스페셜 모짜렐라버거', 'BEEF', 9300, 250, 733, 27.0, 18.0, 10.0, 1040, 'https://img.lotteeatz.com/upload/product/2026/10/27/20261027140001478_9.png/dims/resize/x400/optimize'),
  (@b, '나폴리 모짜렐라버거 토마토바질', '바질의 신선함을 담은 바질마요소스에 풍부하고 진한 토마토소스로 맛을 낸 스페셜 모짜렐라버거', 'BEEF', 9300, 240, 733, 27.0, 18.0, 10.0, 1080, 'https://img.lotteeatz.com/upload/product/2026/10/27/20261027135739308_5.png/dims/resize/x400/optimize'),
  (@b, '전주 비빔라이스 버거', '전주비빔밥을 담은 라이스번과 노른자가 터지는 반숙란,달콤한 고추장 소스가 어우러진 새로운 라이스 버거', 'BEEF', 7500, 285, 574, 17.0, 8.0, 8.0, 1450, 'https://img.lotteeatz.com/upload/product/2023/02/03/20230203180810686_7.png/dims/resize/x400/optimize'),
  (@b, '리아 새우 베이컨', '베이컨+토마토로 더욱 풍성해진 맛과 볼륨감의 새우버거 업그레이드 한정판', 'SEAFOOD', 6200, 211, 519, 18.0, 5.0, 6.0, 960, 'https://img.lotteeatz.com/upload/product/2026/10/29/2026102915474399_0.png/dims/resize/x400/optimize'),
  (@b, '리아 불고기 베이컨', '베이컨+토마토로 더욱 풍성해진 맛과 볼륨감의 불고기버거 업그레이드 한정판', 'BEEF', 6200, 224, 508, 23.0, 13.0, 11.0, 940, 'https://img.lotteeatz.com/upload/product/2026/10/29/20261029152318554_6.png/dims/resize/x400/optimize'),
  (@b, '더블 한우불고기버거', '국내산 한우를 사용한 패티 2장 구성으로 육즙 가득! 묵직한 육풍미를 특징으로 한 프리미엄 버거', 'BEEF', 13200, 352, 802, 39.0, 20.0, 18.0, 1150, 'https://img.lotteeatz.com/upload/product/2026/10/27/20261027144453296_4.png/dims/resize/x400/optimize'),
  (@b, '한우불고기버거', '브리오쉬번에 국내산 한우를 사용한 패티, 신선한 야채, 특제소스로 완성한 프리미엄 햄버거', 'BEEF', 9200, NULL, NULL, NULL, NULL, NULL, NULL, 'https://img.lotteeatz.com/upload/product/2026/10/27/20261027145304632_8.png/dims/resize/x400/optimize'),
  (@b, '더블 클래식치즈버거(버터번)', '두 장의 패티가 이루는 조화로운 맛에 든든함까지 추가된 더블 클래식치즈버거', 'BEEF', 7400, 213, 731, 25.0, 25.0, 6.0, 1110, 'https://img.lotteeatz.com/upload/product/2023/03/21/20230321152358223_1.png/dims/resize/x400/optimize'),
  (@b, '더블 치킨버거', '두 장의 패티가 이루는 조화로운 맛에 든든함까지 추가된 더블버거 시리즈', 'CHICKEN', 6000, 205, 478, 24.0, 5.0, 11.0, 950, 'https://img.lotteeatz.com/upload/product/2025/12/03/20251203084906466_7.png/dims/resize/x400/optimize'),
  (@b, '더블 데리버거', '두 장의 패티가 이루는 조화로운 맛에 든든함까지 추가된 더블버거 시리즈', 'BEEF', 5200, 170, 446, 19.0, 7.0, 10.0, 740, 'https://img.lotteeatz.com/upload/product/2023/03/21/20230321151944859_2.png/dims/resize/x400/optimize'),
  (@b, '더블엑스투버거', '비프패티2장, 치즈2장으로 깊고 풍부한맛의 정통 아메리칸버거', 'BEEF', 7400, 228, 716, 25.0, 25.0, 7.0, 1070, 'https://img.lotteeatz.com/upload/product/2026/10/29/20261029145224946_0.png/dims/resize/x400/optimize'),
  (@b, '리아 불고기 더블(빅불)', '불고기 특유의 소스와 쇠고기의 진함을 배로 느끼는 제품', 'BEEF', 7700, 274, 721, 38.0, 24.0, 12.0, 1480, 'https://img.lotteeatz.com/upload/product/2026/10/27/20261027150621614_1.png/dims/resize/x400/optimize'),
  (@b, '미라클버거', '100% 식물성 패티와 신선한 야채들이 조화된 대체육버거', 'ETC', 5900, 181, 382, 15.0, 4.6, 7.0, 600, 'https://img.lotteeatz.com/upload/product/2025/10/16/20251016134637371_3.png/dims/resize/x400/optimize'),
  (@b, '더블 미라클버거', '100% 식물성 패티와 신선한 야채들이 조화된 대체육버거', 'ETC', 7400, 245, 551, 25.0, 7.0, 10.0, 920, 'https://img.lotteeatz.com/upload/product/2025/10/16/20251016134709789_6.png/dims/resize/x400/optimize'),
  (@b, '모짜렐라 인 더 버거 베이컨', '자연산 모짜렐라 치즈와 고소한 베이컨이 만나 풍부한 맛의 버거', 'BEEF', 8200, 223, 696, 30.0, 16.0, 6.0, 1000, 'https://img.lotteeatz.com/upload/product/2026/10/27/20261027150025813_8.png/dims/resize/x400/optimize'),
  (@b, '핫크리스피치킨버거', '닭가슴살 패티로 만든 매콤 화끈한 프리미엄 치킨버거', 'CHICKEN', 6400, 190, 503, 22.0, 7.0, 5.0, 930, 'https://img.lotteeatz.com/upload/product/2026/10/29/20261029151353843_3.png/dims/resize/x400/optimize'),
  (@b, '리아 사각새우 더블', '미니새우패티 2장의 새우 매니아를 위한버거', 'SEAFOOD', 6200, 208, 556, 17.0, 5.0, 7.0, 960, 'https://img.lotteeatz.com/upload/product/2026/10/29/20261029160428445_2.png/dims/resize/x400/optimize'),
  (@b, '클래식치즈버거(버터번)', '부드러운 치즈와 호주산 쇠고기패티의 본연의 맛을 느낄수 있는 치즈버거', 'BEEF', 5700, 146, 492, 16.0, 14.0, 5.0, 770, 'https://img.lotteeatz.com/upload/product/2022/05/19/20220519092203878_5.png/dims/resize/x400/optimize'),
  (@b, '리아 불고기', '두툼한 쇠고기패티와 한국적인 맛의 소스가 잘 조화된 롯데리아 대표 버거', 'BEEF', 5100, 192, 462, 21.0, 11.0, 11.0, 880, 'https://img.lotteeatz.com/upload/product/2026/10/29/20261029161308281_8.png/dims/resize/x400/optimize'),
  (@b, '리아 새우', '새우살을 가득넣어 더 맛있어진 오리지널 새우버거', 'SEAFOOD', 5100, 179, 492, 15.0, 4.7, 7.0, 810, 'https://img.lotteeatz.com/upload/product/2026/10/29/20261029170603761_7.png/dims/resize/x400/optimize'),
  (@b, '치킨버거', '닭고기패티와 데리야끼 소스로 만든 담백하고 달콤한 맛의 치킨버거', 'CHICKEN', 4500, 141, 355, 15.0, 3.8, 8.0, 620, 'https://img.lotteeatz.com/upload/product/2025/12/03/20251203084852773_5.png/dims/resize/x400/optimize'),
  (@b, '데리버거', '쇠고기패티에 달콤 짭짤한 데리소스를 더한 가성비 버거', 'BEEF', 3800, 134, 348, 12.0, 4.9, 10.0, 590, 'https://img.lotteeatz.com/upload/product/2020/01/02/20200102234537645_5.png/dims/resize/x400/optimize')
AS new ON DUPLICATE KEY UPDATE
  description = new.description, patty_type = new.patty_type, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg, image_url = new.image_url;

-- 맘스터치 (25종)
-- 출처: https://www.momstouch.co.kr/menu/new.php?s_sect1=CG0005 (영양성분 표 이미지, 배포일자 2026.10.22)
-- 가격: 나무위키 '맘스터치/메뉴'(2026-11-14 수정) 의 단품 가격, 2026-11-15 조회. 이름이 정확히 같은 메뉴만 넣었고,
--       다른 출처와 값이 엇갈린 통새우버거와 문서에 없는 신메뉴는 NULL
SET @b := (SELECT brand_id FROM brand WHERE name = '맘스터치');
INSERT INTO burger (brand_id, name, description, patty_type, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg, image_url) VALUES
  (@b, '후덕죽쿵파오싸이버거', NULL, 'CHICKEN', NULL, 283, 779, 29.0, 7.4, 16.0, 1169, 'https://www.momstouch.co.kr/upload_file/product_info/1792627653-GHKBJ.png'),
  (@b, '후덕죽XO통모짜새우버거', NULL, 'SEAFOOD', NULL, 276, 716, 23.0, 9.2, 14.0, 1273, 'https://www.momstouch.co.kr/upload_file/product_info/1792627805-IHCLV.png'),
  (@b, '후덕죽XO쉬림프싸이플렉스버거', NULL, 'CHICKEN', NULL, 303, 763, 33.0, 7.6, 13.0, 1554, 'https://www.momstouch.co.kr/upload_file/product_info/1792627886-THWRJ.png'),
  (@b, '아라비아따치즈버거', NULL, 'ETC', 7400, 309, 791, 41.0, 12.0, 10.0, 1622, 'https://www.momstouch.co.kr/upload_file/product_info/1674626662-ITQZP.png'),
  (@b, '딥치즈싸이버거', NULL, 'CHICKEN', 5400, 246, 655, 30.0, 12.1, 10.0, 1196, 'https://www.momstouch.co.kr/upload_file/product_info/1647845468-DPBRA.png'),
  (@b, '화이트갈릭싸이버거', NULL, 'CHICKEN', 5500, 263, 759, 37.0, 13.0, 10.0, 1345, 'https://www.momstouch.co.kr/upload_file/product_info/1647844626-SKNGP.png'),
  (@b, '쉬림프싸이플렉스버거', NULL, 'CHICKEN', 7600, 301, 858, 29.0, 11.8, 12.0, 1392, 'https://www.momstouch.co.kr/upload_file/product_info/1647845660-MZBRZ.png'),
  (@b, '싸이플렉스버거', NULL, 'CHICKEN', 8300, 406, 991, 44.0, 15.2, 14.0, 2024, 'https://www.momstouch.co.kr/upload_file/product_info/1616480109-NHROT.png'),
  (@b, '싸이버거', NULL, 'CHICKEN', 5200, 230, 594, 28.0, 8.6, 14.0, 1009, 'https://www.momstouch.co.kr/upload_file/product_info/1781574164-JCDWG.png'),
  (@b, '불싸이버거', NULL, 'CHICKEN', 5400, 230, 543, 28.0, 6.9, 15.0, 1152, 'https://www.momstouch.co.kr/upload_file/product_info/1616055291-RNIEC.png'),
  (@b, '휠렛버거', NULL, 'CHICKEN', 5000, 248, 545, 32.0, 4.2, 13.0, 939, 'https://www.momstouch.co.kr/upload_file/product_info/1616055945-EJEVO.png'),
  (@b, '딥치즈버거', NULL, 'CHICKEN', 5400, 259, 543, 33.0, 7.1, 9.0, 1087, 'https://www.momstouch.co.kr/upload_file/product_info/1616055336-FOPBZ.png'),
  (@b, '언빌리버블버거', NULL, 'CHICKEN', 6500, 327, 702, 40.0, 6.3, 13.0, 1423, 'https://www.momstouch.co.kr/upload_file/product_info/1616055649-ICSFA.png'),
  (@b, '화이트갈릭버거', NULL, 'CHICKEN', 5500, 280, 638, 40.0, 9.0, 13.0, 1268, 'https://www.momstouch.co.kr/upload_file/product_info/1616055799-QYDPW.png'),
  (@b, '새우불고기버거', NULL, 'SEAFOOD', 6300, 252, 601, 19.0, 6.3, 20.0, 1054, 'https://www.momstouch.co.kr/upload_file/product_info/1616389716-CPORN.png'),
  (@b, '불고기버거', NULL, 'BEEF', 4200, 164, 403, 14.0, 5.1, 14.0, 615, 'https://www.momstouch.co.kr/upload_file/product_info/1616389576-MRVGX.png'),
  (@b, '더블불고기버거', NULL, 'BEEF', NULL, 236, 614, 24.0, 9.3, 16.0, 1197, 'https://www.momstouch.co.kr/upload_file/product_info/1616055844-YQCMH.png'),
  (@b, '통새우버거', NULL, 'SEAFOOD', NULL, 178, 449, 12.0, 12.4, 9.0, 707, 'https://www.momstouch.co.kr/upload_file/product_info/1616055758-NMXVZ.png'),
  (@b, '그릴드버거', NULL, 'BEEF', NULL, 138, 409, 17.0, 5.7, 9.0, 507, 'https://www.momstouch.co.kr/upload_file/product_info/1788943693-ALLSM.png'),
  (@b, '그릴드베이컨버거', NULL, 'BEEF', NULL, 198, 486, 19.0, 7.6, 12.0, 679, 'https://www.momstouch.co.kr/upload_file/product_info/1788943774-DBAOJ.png'),
  (@b, '스모키스매쉬버거', NULL, 'BEEF', NULL, 252, 634, 32.0, 12.1, 11.0, 945, 'https://www.momstouch.co.kr/upload_file/product_info/1788943522-HYTZH.png'),
  (@b, '더블스매쉬버거', NULL, 'BEEF', NULL, 281, 700, 38.0, 16.0, 5.0, 927, 'https://www.momstouch.co.kr/upload_file/product_info/1788943613-HXFVG.png'),
  (@b, '스매쉬버거', NULL, 'BEEF', NULL, 208, 477, 22.0, 9.2, 6.0, 658, 'https://www.momstouch.co.kr/upload_file/product_info/1788943438-AGMGE.png'),
  (@b, '햄치즈휠렛버거', NULL, 'CHICKEN', NULL, 276, 617, 36.0, 9.4, 10.0, 1188, 'https://www.momstouch.co.kr/upload_file/product_info/1791987709-UEMKL.png'),
  (@b, '베이컨치폴레싸이버거', NULL, 'CHICKEN', NULL, 259, 671, 31.0, 8.3, 14.0, 1281, 'https://www.momstouch.co.kr/upload_file/product_info/1791987633-HJARR.png')
AS new ON DUPLICATE KEY UPDATE
  description = new.description, patty_type = new.patty_type, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg, image_url = new.image_url;

-- KFC (10종)
-- 출처: https://www.kfckorea.com/menu/burger (영양 정보표 이미지, Ver. 20261110 / 가격은 딜리버리 메뉴 기준)
SET @b := (SELECT brand_id FROM brand WHERE name = 'KFC');
INSERT INTO burger (brand_id, name, description, patty_type, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg, image_url) VALUES
  (@b, '둠트리플다운', NULL, 'CHICKEN', 13800, 524, 1235, 83.0, 21.9, 10.0, 2641, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1249686_20261110174616912.png'),
  (@b, '징거더블다운', NULL, 'CHICKEN', 10200, 368, 842, 67.0, 13.9, 5.0, 1868, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1249664_20261019114906871.png'),
  (@b, '둠징거', NULL, 'CHICKEN', 9400, 290, 699, 35.0, 9.9, 22.0, 1463, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1249687_20261110174541943.png'),
  (@b, '칰폴레맵징거타워', NULL, 'CHICKEN', 8100, 348, 803, 37.0, 11.8, 16.0, 1386, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1249605_20260803101341576.png'),
  (@b, '치즈징거통다리', NULL, 'CHICKEN', 8100, 270, 713, 28.0, 15.1, 9.0, 1386, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1249520_20260803092743816.png'),
  (@b, '징거BLT', NULL, 'CHICKEN', 8000, 281, 696, 39.0, 11.2, 6.0, 1164, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1249522_20260803093837916.png'),
  (@b, '징거타워', NULL, 'CHICKEN', 7800, 303, 720, 36.0, 11.0, 9.0, 1343, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1249524_20260803094557160.png'),
  (@b, '칰폴레맵징거통다리', NULL, 'CHICKEN', 7700, 285, 695, 24.0, 10.1, 18.0, 1125, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1249601_20260803100911037.png'),
  (@b, '클래식징거통다리', NULL, 'CHICKEN', 7400, 234, 606, 24.0, 9.2, 12.0, 1010, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1249521_20260803093124188.png'),
  (@b, '징거', NULL, 'CHICKEN', 6800, 225, 553, 33.0, 7.4, 5.0, 866, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1249525_20260803095034459.png')
AS new ON DUPLICATE KEY UPDATE
  description = new.description, patty_type = new.patty_type, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg, image_url = new.image_url;

-- 노브랜드버거 (22종)
-- 출처: https://shinsegaefood.com/popup/nobrandburger_02.html (영양성분 이미지)
-- 가격: NBB 훅 · NBB 펀치만 출시 기사(지디넷코리아 2026-10-15, 단품 4,900원)에서 확인.
--       나머지는 2026-08-28 가격 인상 뒤의 값을 찾지 못해 NULL
SET @b := (SELECT brand_id FROM brand WHERE name = '노브랜드버거');
INSERT INTO burger (brand_id, name, description, patty_type, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg, image_url) VALUES
  (@b, '어메이징 더블 업', NULL, 'BEEF', NULL, 282, 725, 32.0, 15.0, 9.0, 1433, 'https://www.shinsegaefood.com/uimages/2025/05/07/NBB_%EC%96%B4%EB%A9%94%EC%9D%B4%EC%A7%95_%EB%8D%94%EB%B8%94_%EC%97%85_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80_460x315%281%29.png'),
  (@b, '시그니처', NULL, 'BEEF', NULL, 213, 531, 21.0, 9.0, 9.0, 1138, 'https://www.shinsegaefood.com/uimages/2025/05/07/%EC%8B%9C%EA%B7%B8%EB%8B%88%EC%B2%98_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80_460x315.png'),
  (@b, '오리지널', NULL, 'BEEF', NULL, 189, 439, 17.0, 6.0, 8.0, 642, 'https://www.shinsegaefood.com/uimages/2025/05/07/%EC%98%A4%EB%A6%AC%EC%A7%80%EB%84%90_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80_460x315.png'),
  (@b, '미트 마니아', NULL, 'BEEF', NULL, 305, 749, 37.0, 13.0, 9.0, 1796, 'https://www.shinsegaefood.com/uimages/2025/05/08/%EB%AF%B8%ED%8A%B8%EB%A7%88%EB%8B%88%EC%95%84_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80_460x315.png'),
  (@b, '그릴드 불고기', NULL, 'BEEF', NULL, 164, 426, 16.0, 5.0, 12.0, 699, 'https://www.shinsegaefood.com/uimages/2025/05/07/%EA%B7%B8%EB%A6%B4%EB%93%9C%EB%B6%88%EA%B3%A0%EA%B8%B0_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80_460x315.png'),
  (@b, '메가바이트', NULL, 'BEEF', NULL, 216, 657, 19.0, 7.0, 7.0, 989, 'https://www.shinsegaefood.com/uimages/2025/05/07/%EB%A9%94%EA%B0%80%EB%B0%94%EC%9D%B4%ED%8A%B8_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80_460x315.png'),
  (@b, '크런치 치킨', NULL, 'CHICKEN', NULL, 218, 530, 27.0, 6.0, 9.0, 1307, 'https://www.shinsegaefood.com/uimages/2025/05/07/%EC%BD%94%EC%9A%B8%EC%8A%AC%EB%A1%9C%EC%B9%98%ED%82%A8_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80_460x315.png'),
  (@b, '치폴레 치킨', NULL, 'CHICKEN', NULL, 198, 388, 18.0, 7.0, 9.0, 918, 'https://www.shinsegaefood.com/uimages/2026/01/05/%EC%B9%98%ED%8F%B4%EB%A0%88_%ED%95%AB_%EC%B9%98%ED%82%A8_%ED%95%AB.png'),
  (@b, '오리지널 새우', NULL, 'SEAFOOD', NULL, 176, 429, 13.0, 5.0, 9.0, 926, 'https://www.shinsegaefood.com/uimages/2025/05/07/%EC%98%A4%EB%A6%AC%EC%A7%80%EB%84%90%EC%83%88%EC%9A%B0_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80_460x315.png'),
  (@b, '더블 그릴드 불고기', NULL, 'BEEF', NULL, 231, 577, 28.0, 8.0, 17.0, 990, 'https://www.shinsegaefood.com/uimages/2025/05/07/%EB%8D%94%EB%B8%94%EA%B7%B8%EB%A6%B4%EB%93%9C%EB%B6%88%EA%B3%A0%EA%B8%B0_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80_460x315.png'),
  (@b, '치즈', NULL, 'BEEF', NULL, 140, 423, 14.0, 8.0, 7.0, 816, 'https://www.shinsegaefood.com/uimages/2025/05/07/%EC%B9%98%EC%A6%88_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80_460x315.png'),
  (@b, '통새우 감바스', NULL, 'SEAFOOD', NULL, 187, 439, 16.0, 5.0, 9.0, 1091, 'https://www.shinsegaefood.com/uimages/2025/09/15/06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80_NBB_%EC%96%B4%EB%A9%94%EC%9D%B4%EC%A7%95_%EA%B0%90%EB%B0%94%EC%8A%A4_%EC%83%88%EC%9A%B0_%EB%8B%A8%ED%92%88.png'),
  (@b, '그릴드 불고기 라이트', NULL, 'BEEF', NULL, 150, 372, 15.0, 5.0, 10.0, 423, 'https://www.shinsegaefood.com/uimages/2026/02/26/%EA%B7%B8%EB%A6%B4%EB%93%9C_%EB%B6%88%EA%B3%A0%EA%B8%B0_%EC%A3%BC%EB%8B%88%EC%96%B4_%EB%8B%A8%ED%92%88_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '모짜 치폴레 베이컨', NULL, 'BEEF', NULL, 270, 703, 27.0, 17.0, 14.0, 1345, 'https://www.shinsegaefood.com/uimages/2026/02/26/%EB%AA%A8%EC%A7%9C%EC%B9%98%ED%8F%B4%EB%A0%88%EB%B2%A0%EC%9D%B4%EC%BB%A8_%EB%8B%A8%ED%92%88_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '에그 치즈 불고기', NULL, 'BEEF', NULL, 217, 527, 21.0, 13.0, 12.0, 1083, 'https://www.shinsegaefood.com/uimages/2026/04/30/%EC%97%90%EA%B7%B8_%EC%B9%98%EC%A6%88_%EB%B6%88%EA%B3%A0%EA%B8%B0_%EB%8B%A8%ED%92%88_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '스모크 바비큐', NULL, 'BEEF', NULL, 200, 455, 20.0, 6.0, 17.0, 978, 'https://www.shinsegaefood.com/uimages/2026/06/12/%EC%8A%A4%EB%AA%A8%ED%81%AC_%EB%B0%94%EB%B9%84%ED%81%90_%EB%8B%A8%ED%92%88_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '버크셔K 카츠', NULL, 'ETC', NULL, 212, 462, 17.0, 9.0, 7.0, 940, 'https://www.shinsegaefood.com/uimages/2026/07/29/%EB%B2%84%ED%81%AC%EC%85%94K%EC%B9%B4%EC%B8%A0_%EB%8B%A8%ED%92%88_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80%28%EB%B3%B4%EC%A0%95%EB%B3%B8%29.png'),
  (@b, '버크셔K 카츠 어니언', NULL, 'ETC', NULL, 240, 524, 16.0, 9.0, 8.0, 1003, 'https://www.shinsegaefood.com/uimages/2026/07/29/%EB%B2%84%ED%81%AC%EC%85%94K%EC%B9%B4%EC%B8%A0_%EC%96%B4%EB%8B%88%EC%96%B8_%EB%8B%A8%ED%92%88_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80%28%EB%B3%B4%EC%A0%95%EB%B3%B8%29.png'),
  (@b, '데일리 치킨', NULL, 'CHICKEN', NULL, 182, 429, 20.0, 4.0, 11.0, 957, 'https://www.shinsegaefood.com/uimages/2026/07/28/%EB%8D%B0%EC%9D%BC%EB%A6%AC%EC%B9%98%ED%82%A8_%EB%8B%A8%ED%92%88_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, 'NBB 훅', NULL, 'ETC', 4900, 201, 487, 23.0, 8.0, 9.0, 1202, 'https://www.shinsegaefood.com/uimages/2026/10/15/NBB_%ED%9B%85_%EB%8B%A8%ED%92%88_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, 'NBB 펀치', NULL, 'ETC', 4900, 205, 509, 26.0, 9.0, 8.0, 1476, 'https://www.shinsegaefood.com/uimages/2026/10/15/NBB_%ED%8E%80%EC%B9%98_%EB%8B%A8%ED%92%88_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '진짜 비빔밥 버거', NULL, 'ETC', NULL, 260, 674, 20.0, 8.0, 13.0, 1351, 'https://www.shinsegaefood.com/uimages/2026/10/30/%EC%A7%84%EC%A7%9C_%EB%B9%84%EB%B9%94%EB%B0%A5_%EB%8B%A8%ED%92%88_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png')
AS new ON DUPLICATE KEY UPDATE
  description = new.description, patty_type = new.patty_type, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg, image_url = new.image_url;

-- 프랭크버거 (15종)
-- 출처: https://frankburger.co.kr/html/menu_1.html , https://frankburger.co.kr/html/ingredient.html (영양성분표 이미지)
SET @b := (SELECT brand_id FROM brand WHERE name = '프랭크버거');
INSERT INTO burger (brand_id, name, description, patty_type, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg, image_url) VALUES
  (@b, '프랭크 버거', '육즙 가득한 수제패티와 신선한 야채가 잘 어우러져 기본에 충실한 미국 동부식 오리지널 버거', 'BEEF', NULL, 157, 438, 17.9, 10.1, 5.3, 604, 'https://frankburger.co.kr/img/page/2022_menu/01/menu1_img1_v2.jpg'),
  (@b, '치즈버거', '대표메뉴로서 100% 수제패티와 체다 치즈의 깊은 풍미를 이룬 시그니처 버거', 'BEEF', NULL, 170, 472, 20.2, 12.1, 4.3, 750, 'https://frankburger.co.kr/img/page/2022_menu/01/menu1_img2_v2.jpg'),
  (@b, '베이컨 치즈버거', '수제패티에 하와이안 스타일의 구운 파인애플과 베이컨의 조화를 이룬 스페셜 버거', 'BEEF', NULL, 234, 605, 28.4, 15.3, 11.4, 984, 'https://frankburger.co.kr/img/page/2022_menu/01/menu1_img3_v2.jpg'),
  (@b, '쉬림프 버거', '탱탱한 새우가 들어간 새우패티를 바삭하게 튀겨 새콤달콤한 특제소스와 조화를 이룬 프리미엄 새우 버거', 'SEAFOOD', NULL, 201, 568, 13.5, 8.5, 8.6, 878, 'https://frankburger.co.kr/img/page/2022_menu/01/menu1_img5_v2.jpg'),
  (@b, '비프 앤 쉬림프 버거', '탱탱한 새우가 들어간 새우 패티와 소고기패티의 육향이 절묘하게 조화를 이룬 프리미엄 버거', 'BEEF', NULL, 257, 730, 27.5, 13.5, 9.2, 1144, 'https://frankburger.co.kr/img/page/2022_menu/01/menu1_img17.jpg'),
  (@b, 'JG버거', '정통 아메리칸 스타일에 구운 베이컨에 꾸덕한 치즈소스가 듬뿍 들어가 풍만함이 최상인 마지막 종결 버거', 'BEEF', NULL, 222, 726, 36.7, 20.6, 6.6, 1415, 'https://frankburger.co.kr/img/page/2022_menu/01/menu1_img7_v2.jpg'),
  (@b, '더블 비프 치즈 버거', '더블패티에 생양파와 피클을 더해 미국식 수제버거의 풍미를 최상으로 느낄 수 있는 버거', 'BEEF', NULL, 249, 713, 28.7, 17.8, 8.6, 1116, 'https://frankburger.co.kr/img/page/2022_menu/01/menu1_img18.jpg'),
  (@b, 'K 불고기 버거', '전통 궁중식 너비아니 스타일의 패티에 불고기 양념을 가미한 한국의 대표 불고기 버거', 'BEEF', NULL, 195, 492, 20.0, 10.3, 10.6, 657, 'https://frankburger.co.kr/img/page/2022_menu/01/menu1_img21.jpg'),
  (@b, 'K 핫불고기 버거', '매콤한 특제소스로 한국 특유의 매운맛을 살린 화끈한 불고기 버거', 'BEEF', NULL, 189, 511, 20.0, 9.7, 6.4, 688, 'https://frankburger.co.kr/img/page/2022_menu/01/menu1_img22.jpg'),
  (@b, '청양마요 쉬림프 버거', '핫 렐리쉬 마요소스와 탱글탱글한 새우 패티가 어우러져 새우의 풍미가 깔끔하게 마무리 되는 버거', 'SEAFOOD', NULL, 220, 578, 14.7, 7.4, 10.6, 958, 'https://frankburger.co.kr/img/page/2022_menu/01/menu1_img26.jpg'),
  (@b, '100% 한우 갈릭 버거', '100% 순수 한우 패티에 블랙갈릭소스의 깊고 진한 맛을 더한 한우 버거', 'BEEF', NULL, 246, 554, 25.6, 12.3, 11.8, 1004, 'https://frankburger.co.kr/img/page/2022_menu/01/menu1_img32.jpg'),
  (@b, '100% 한우 버거', '100% 순수 한우 패티에 데미글라스 브라운 소스를 더한 리얼 한우 버거', 'BEEF', NULL, 192, 443, 21.8, 8.8, 9.0, 638, 'https://frankburger.co.kr/img/page/2022_menu/01/menu1_img33.jpg'),
  (@b, '파닭파닭 치킨버거', '고소한 땅콩과 고추와 대파의 풍미가 살아있는 중화풍 버거', 'CHICKEN', NULL, 218, 649, 28.0, 10.5, 10.8, 1067, 'https://frankburger.co.kr/img/page/2022_menu/01/menu1_img39.jpg'),
  (@b, '깐쇼새우 비프버거', '육즙 가득한 비프패티와 바삭한 새우패티를 함께 즐기는 두가지 패티맛의 버거', 'BEEF', NULL, 272, 772, 27.9, 14.3, 12.9, 1252, 'https://frankburger.co.kr/img/page/2022_menu/01/menu1_img40.jpg'),
  (@b, '맥앤치즈 비프버거', '진한 체다치즈로 만든 크리미한 맥앤치즈와 육즙 가득한 비프패티의 완벽하게 조화로 만들어진 버거', 'BEEF', NULL, 324, 910, 35.9, 21.6, 5.4, 1759, 'https://frankburger.co.kr/img/page/2022_menu/01/menu1_img41.jpg')
AS new ON DUPLICATE KEY UPDATE
  description = new.description, patty_type = new.patty_type, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg, image_url = new.image_url;
