-- OH Burger 사이드 메뉴 초기 데이터 (사이드 · 치킨 · 디저트)
-- 각 브랜드 공식 홈페이지에서 2026-11-21 에 조회한 값. 단품 기준.
-- 실행: mysql -u root -p --default-character-set=utf8mb4 -e "source db/data_side.sql"  (schema.sql 다음에)
-- 다시 실행해도 조회수는 유지되고 메뉴 정보만 갱신된다.
--
-- 넣는 기준 (DB설계.md 5번)
--  * 음료를 뺀 사이드 · 치킨 · 디저트 전부, 노브랜드버거 샐러드
--  * 소스 · 시즈닝 · 잼 · 치킨무, 세트 · 박스 · 1+1 행사 · 버킷, 쉐이크 · 플로트, 맘스터치 피자 · 또잇은 넣지 않는다
--  * 사이즈 · 조각 수가 여러 개인 메뉴는 한 줄만: 감자튀김은 기본 사이즈(M · R),
--    너겟 · 윙 · 텐더는 단독으로 살 수 있는 가장 작은 단위. 맛이 다른 메뉴는 따로 넣는다
--  * 종류(kind): 닭고기가 주재료인 튀김(치킨 · 윙 · 텐더 · 너겟)은 CHICKEN, 아이스크림 · 파이 같은 단 메뉴는 DESSERT, 나머지는 SIDE
--
-- 알아둘 점
--  * 사이트에 열량 범위만 있는 메뉴는 영양 정보를 NULL 로 둔다 (버거와 같은 규칙)
--  * '1g 미만' 으로만 표시된 값은 정확한 수를 알 수 없어 NULL
--  * image_url 은 각 브랜드 공식 사이트의 제품 사진 주소다. 파일을 내려받지 않고 주소만 저장한다
--  * 가격은 롯데리아 · KFC(딜리버리 메뉴 기준)만 공식 값이다. 맥도날드 · 버거킹은 나무위키에서 옮긴 매장 가격이라
--    최신 값과 다를 수 있고, 맘스터치 · 노브랜드버거 · 프랭크버거는 출처를 찾지 못해 NULL (146종 중 75종에 가격 있음)
--  * 치킨 · 너겟처럼 표에 100g 당 값이나 1조각 값만 있는 메뉴는 곱해서 계산했다. 계산식은 값 자리에 그대로 적어 두었다

USE oh_burger;

-- 맥도날드 (20종)
-- 출처: https://www.mcdonalds.co.kr/kor/menu/information/nutrition (스낵 & 사이드, 디저트 영양 표)
--       사진은 https://www.mcdonalds.co.kr/kor/menu/sides (사이드 메뉴 18건, 디저트 메뉴 10건)
--  * 메뉴 목록의 열량이 영양 표와 조금 다른 메뉴(상하이 치킨 스낵랩 303 / 300, 치킨텐더 197 / 190)는 영양 표 값을 넣었다
--  * 홍천 우리쌀 칩은 영양 표가 비어 있어 메뉴 목록의 열량(117kcal)만 넣었다
-- 가격: 나무위키 '맥도날드/메뉴' 의 사이드 · 디저트 가격(2026-03-05 기준, 매장 가격), 2026-11-21 조회.
--       맥너겟 4조각 · 치킨 모짜렐라 스낵랩 · 홍천 우리쌀 칩은 문서에 '해피 스낵' 가격만 있어 그 값을 넣었다
SET @b := (SELECT brand_id FROM brand WHERE name = '맥도날드');
INSERT INTO side_menu (brand_id, name, description, kind, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg, image_url) VALUES
  (@b, '후렌치 후라이 미디엄', NULL, 'SIDE', 2500, 114, 324, 5.0, 1.0, 0.0, 282, 'https://www.mcdonalds.co.kr/upload/2025/08/%ED%9B%84%EB%A0%8C%EC%B9%98_%ED%9B%84%EB%9D%BC%EC%9D%B4_Medium.png'),
  (@b, '해쉬 브라운', NULL, 'SIDE', 1800, 57, 162, 2.0, 0.8, 0.0, 345, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1742426888535.png'),
  (@b, '골든 모짜렐라 치즈스틱 2조각', NULL, 'SIDE', 2800, 47, 165, 8.0, 4.2, 1.0, 288, 'https://www.mcdonalds.co.kr/uploadFolder/product/prov_201902080435496530.png'),
  (@b, '코울슬로', NULL, 'SIDE', 1900, 100, 179, 1.0, 1.0, 18.0, 307, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1680761626050.png'),
  (@b, '상하이 치킨 스낵랩', NULL, 'SIDE', 3500, 112, 300, 11.0, 3.9, 3.0, 823, 'https://www.mcdonalds.co.kr/uploadFolder/product/prov_201902080435011620.png'),
  (@b, '치킨 모짜렐라 스낵랩', NULL, 'SIDE', 3000, 131, 347, 14.0, 4.9, 7.0, 923, 'https://www.mcdonalds.co.kr/upload/2026/09/Corp_PC_VIEW_772x530_%EC%B9%98%ED%82%A8%EB%AA%A8%EC%A7%9C%EB%A0%90%EB%9D%BC%EC%8A%A4%EB%82%B5%EB%9E%A9.png'),
  (@b, '홍천 우리쌀 칩', NULL, 'SIDE', 3000, NULL, 117, NULL, NULL, NULL, NULL, 'https://www.mcdonalds.co.kr/upload/2026/07/Corp_PC_VIEW_772x530_%ED%99%8D%EC%B2%9C%EC%9A%B0%EB%A6%AC%EC%8C%80%EC%B9%A9_New%EB%A1%9C%EA%B3%A0_%EC%88%98%EC%A0%95.png'),
  (@b, '맥너겟 4조각', NULL, 'CHICKEN', 2000, 64, 163, 10.0, 1.1, 0.0, 369, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1612402131024.png'),
  (@b, '맥스파이시 치킨텐더 2조각', NULL, 'CHICKEN', 2700, 79, 190, 14.0, 1.2, 0.0, 763, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1612402252126.png'),
  (@b, '맥윙 2조각', NULL, 'CHICKEN', 3700, 84, 228, 14.0, 3.0, 0.0, 602, 'https://www.mcdonalds.co.kr/upload/2026/03/Corp_PC_view_772x530_%EB%A7%A5%EC%9C%99-2pc.png'),
  (@b, '애플 파이', NULL, 'DESSERT', 1500, 82, 236, 3.0, 2.9, 9.0, 199, 'https://www.mcdonalds.co.kr/upload/2026/09/Corp_PC_VIEW_772x530_%EC%95%A0%ED%94%8C%ED%8C%8C%EC%9D%B4.png'),
  (@b, '오레오 맥플러리', NULL, 'DESSERT', 3600, 168, 334, 6.0, 6.0, 36.0, 179, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1615378578396.png'),
  (@b, '딸기 오레오 맥플러리', NULL, 'DESSERT', 3600, 174, 305, 5.0, 4.7, 38.0, 138, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1615378509519.png'),
  (@b, '초코 오레오 맥플러리', NULL, 'DESSERT', 3600, 189, 390, 7.0, 8.0, 45.0, 218, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1615378451271.png'),
  (@b, '베리 스트로베리 맥플러리', NULL, 'DESSERT', 3600, 168, 327, 5.0, 6.0, 38.0, 228, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1617837982953.png'),
  (@b, '스트로베리콘', NULL, 'DESSERT', 1900, 90, 142, 3.0, 2.5, 16.0, 96, 'https://www.mcdonalds.co.kr/upload/2026/02/Corp_PC_VIEW_772x530_%EC%8A%A4%ED%8A%B8%EB%A1%9C%EB%B2%A0%EB%A6%AC%EC%BD%98.png'),
  (@b, '아이스크림콘', NULL, 'DESSERT', 1500, 90, 146, 3.0, 2.5, 15.0, 67, 'https://www.mcdonalds.co.kr/upload/2026/02/Corp_PC_VIEW_772x530_%EC%95%84%EC%9D%B4%EC%8A%A4%ED%81%AC%EB%A6%BC%EC%BD%98.png'),
  (@b, '초코 선데이 아이스크림', NULL, 'DESSERT', 2400, 175, 323, 6.0, 8.0, 39.0, 170, 'https://www.mcdonalds.co.kr/uploadFolder/product/prov_201901290248295110.png'),
  (@b, '딸기 선데이 아이스크림', NULL, 'DESSERT', 2400, 179, 277, 5.0, 3.9, 41.0, 96, 'https://www.mcdonalds.co.kr/uploadFolder/product/prov_201901290248522410.png'),
  (@b, '바닐라 선데이 아이스크림', NULL, 'DESSERT', 2200, 140, 201, 4.0, 3.9, 24.0, 83, 'https://www.mcdonalds.co.kr/upload/product/pcfile/1657246845162.png')
AS new ON DUPLICATE KEY UPDATE
  description = new.description, kind = new.kind, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg, image_url = new.image_url;

-- 버거킹 (19종)
-- 출처: https://www.burgerking.co.kr/menu/main (사이드, 음료&디저트) 와 메뉴 상세의 영양성분 표
--  * 영양성분 표에 줄이 없는 프렌치프라이(R) · 21치즈스틱은 메뉴 상세의 열량만 넣었다
--  * 리얼 어니언링(R)은 표의 '어니언링'(306kcal)이 메뉴 상세의 열량(238kcal)과 달라 다른 제품으로 보고 상세의 열량만 넣었다
--  * 딥 트러플 프라이는 표에 값이 다른 줄이 두 개 있어 메뉴 상세의 열량(410kcal)과 같은 줄을 넣었다
--  * 빅 딥 체다치즈는 디핑 소스라 넣지 않았다
-- 가격: 나무위키 '버거킹/메뉴'(2026-10-30 수정, 문서에 '2024년 8월 기준' 이라고 적힌 매장 가격) · '버거킹/기간 한정 메뉴'(2026-11-18 수정,
--       딥 트러플 프라이 · 트러플 머쉬룸 파이로얄), 2026-11-21 조회. 최신 값과 다를 수 있다.
--       어니언링(사이즈가 안 적힘) · 크리스퍼 랩(매장 할인가) · 밀크 선데(바닐라 선데와 같은 메뉴인지 불확실)와 문서에 없는 메뉴는 NULL
SET @b := (SELECT brand_id FROM brand WHERE name = '버거킹');
INSERT INTO side_menu (brand_id, name, description, kind, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg, image_url) VALUES
  (@b, '프렌치프라이(R)', NULL, 'SIDE', 2300, NULL, 279, NULL, NULL, NULL, NULL, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2024/12/05/cf43ee0a-7aea-4b30-9fce-f06927455489.png'),
  (@b, '딥 트러플 프라이', NULL, 'SIDE', 3000, 130, 410, 5.0, 7.0, 3.0, 584, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2026/09/14/a7db2cfa-112b-41b6-98f6-244ebaf9890d.png'),
  (@b, '쉐이킹프라이 매콤치즈', NULL, 'SIDE', 2500, 105, 287, 4.0, 3.1, 0.6, 687, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2025/02/05/abdcfc95-2cf7-42b5-a5e1-cd86053c3b7a.png'),
  (@b, '쉐이킹프라이 구운갈릭', NULL, 'SIDE', 2500, 105, 292, 4.0, 3.1, 0.5, 634, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2025/02/05/f047e2bf-1894-46d4-be18-f56d68cd2b0d.png'),
  (@b, '쉐이킹프라이 스윗어니언', NULL, 'SIDE', 2500, 105, 297, 4.0, 3.0, 1.3, 486, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2025/02/05/bfa43bf7-93eb-4b77-a197-276258eb970e.png'),
  (@b, '리얼 어니언링(R)', NULL, 'SIDE', NULL, NULL, 238, NULL, NULL, NULL, NULL, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2025/01/06/bf5a4034-89b2-4bbf-82ee-92bd5a79f794.png'),
  (@b, '21치즈스틱', NULL, 'SIDE', 2500, NULL, 136, NULL, NULL, NULL, NULL, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2025/01/06/a6b54faa-22a8-47a1-a051-644b6eac7373.png'),
  (@b, '코코넛슈림프(3조각)+스위트칠리소스', NULL, 'SIDE', 3900, 82, 216, 5.0, 4.0, 11.0, 505, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2025/01/06/fb25786c-80ec-4bcd-a4b1-647d20ea015b.png'),
  (@b, '트러플 머쉬룸 파이 로얄', NULL, 'SIDE', 2700, 65, 183, 3.0, 3.0, 2.0, 235, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2026/09/14/c50c7088-e7ed-4de6-8229-4a11ce4c0e29.png'),
  (@b, '비프 킹 랩', NULL, 'SIDE', NULL, 157, 357, 15.0, 7.0, 5.0, 741, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2026/08/06/cc8f2ffd-050a-4851-836c-23cc6c7ebfd1.png'),
  (@b, '크리스퍼 랩', NULL, 'SIDE', NULL, 133, 359, 12.0, 3.0, 4.0, 651, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2025/07/21/ae8574a2-e5f0-474d-b72b-b1bfdc54cbc2.png'),
  (@b, '코울슬로', NULL, 'SIDE', 2100, 95, 155, 1.0, 0.9, 9.0, 210, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2025/01/06/c2fc4018-13b1-4437-b1c1-5e198d635c14.png'),
  (@b, '콘샐러드', NULL, 'SIDE', 2100, 95, 127, 2.0, 1.0, 4.0, 230, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2024/12/05/d8d58d6a-5ae5-4a6a-ba49-6df6e53434ec.png'),
  (@b, '크리스퍼 텐더', NULL, 'CHICKEN', NULL, 80, 176, 11.0, 1.0, 1.0, 361, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2025/07/21/b1de962a-1d63-4183-ad55-40c5f2c7a231.png'),
  (@b, '바삭킹2조각', NULL, 'CHICKEN', 3100, 99, 272, 15.0, 5.0, 1.7, 497, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2025/01/06/b40301ca-19f6-4784-a952-367140861739.png'),
  (@b, '너겟킹 4조각', NULL, 'CHICKEN', 2300, 66, 147, 9.0, 2.0, 0.4, 422, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2025/01/06/bfa4ab37-4c08-4de3-aa9d-d6cad0d8595b.png'),
  (@b, '애플 파이 로얄', NULL, 'DESSERT', NULL, 61, 188, 2.0, 2.5, 6.0, 120, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2026/07/23/fb946611-0411-4f46-9585-11a7be4c2c0a.png'),
  (@b, '밀크 선데', NULL, 'DESSERT', NULL, 140, 165, 1.0, 3.0, 27.0, 116, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2025/04/28/e9aa83a2-9600-40b6-8671-8eed080a24cf.png'),
  (@b, '초코 선데', NULL, 'DESSERT', 2200, 165, 232, 2.0, 3.0, 38.0, 147, 'https://mob-prd.burgerking.co.kr/images/menu/app/main/2025/04/28/cb755dd7-c8c1-4453-960f-01506b641d09.png')
AS new ON DUPLICATE KEY UPDATE
  description = new.description, kind = new.kind, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg, image_url = new.image_url;

-- 롯데리아 (28종)
-- 출처: https://www.lotteeatz.com/brand/ria (디저트 · 치킨 · 아이스샷) 와 각 메뉴 상세의 영양소 정보. 가격도 공식 사이트 값
--  * 양념너겟 · 치킨너겟 · 양념감자 · 치킨휠레 · 순살치킨은 열량 범위만 있어 영양 정보가 NULL (순살치킨 중량은 구성 설명의 292g)
--  * 화이어윙은 상세에 '매장 내 고지물 확인' 안내가 있지만 영양소 표도 함께 있어 표 값을 넣었다
--  * 포테이토(L) · 순살치킨 (L) · 치킨다리 하프팩 · 보냉백 포함 빙수는 같은 메뉴의 다른 구성이라 넣지 않았다
--  * 순살치킨과 순살치킨N 은 사이트에 따로 올라 있는 메뉴라 둘 다 넣었다
SET @b := (SELECT brand_id FROM brand WHERE name = '롯데리아');
INSERT INTO side_menu (brand_id, name, description, kind, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg, image_url) VALUES
  (@b, '포테이토', '바로 튀겨낸 바삭바삭한 후렌치 포테이토', 'SIDE', 2100, 98, 284, 3.0, 2.8, 2.0, 500, 'https://img.lotteeatz.com/upload/product/2024/11/20/20241120200342965_4.png/dims/resize/x214/optimize'),
  (@b, '양념감자', '시즈닝(어니언, 치즈, 칠리) 한가지를 선택해 뿌려먹는 포테이토', 'SIDE', 2700, NULL, NULL, NULL, NULL, NULL, NULL, 'https://img.lotteeatz.com/upload/product/2024/11/20/20241120200429258_0.png/dims/resize/x214/optimize'),
  (@b, '치즈스틱', '통모짜렐라치즈에 튀김옷을 입혀 만든 바삭하고 고소한 롯데리아 대표 디저트 메뉴', 'SIDE', 2900, 49, 158, 8.0, 3.7, NULL, 270, 'https://img.lotteeatz.com/upload/product/2024/11/20/20241120200451610_3.png/dims/resize/x214/optimize'),
  (@b, '롱치즈스틱', '롯데리아 대표 디저트인 치즈스틱을 더 크고 더 맛있게', 'SIDE', 2500, 49, 158, 8.0, 4.0, 0.0, 230, 'https://img.lotteeatz.com/upload/product/2019/12/20/20191220164604550_2.png/dims/resize/x214/optimize'),
  (@b, '통오징어링', '통오징어로 리얼한 식감과 풍미가 가득한 디저트 (잠발라야 소스 1개 기본 제공)', 'SIDE', 2900, 97, 166, 8.0, 0.5, 8.0, 420, 'https://img.lotteeatz.com/upload/product/2023/02/10/20230210180512639_0.png/dims/resize/x214/optimize'),
  (@b, '디지게 매운 돈까스(디진다맛)', '신대방 온정돈까스 매운맛 10단계인 시그니처 메뉴 디진다돈까스를 핑거 디저트화한 제품으로 극강의 매운맛으로 한 입만 먹어도 강력하고 화끈한 매운맛', 'SIDE', 3500, 112, 280, 15.0, 2.1, 13.0, 520, 'https://img.lotteeatz.com/upload/product/2026/03/11/20260311110817134_1.png/dims/resize/x214/optimize'),
  (@b, '디지게 매운 돈까스(양념맛)', '신대방 온정돈까스 매운맛 2단계인 양념 돈까스를 핑거 디저트화한 제품으로 매콤달콤한 양념 소스로 누구나 맛있게 맵게 즐길 수 있는 매운맛', 'SIDE', 3500, 112, 290, 15.0, 2.0, 15.0, 670, 'https://img.lotteeatz.com/upload/product/2026/03/11/20260311111029815_9.png/dims/resize/x214/optimize'),
  (@b, '코울슬로', '아삭한 양상추와 상큼한 드레싱이 조화로운 간편 샐러드', 'SIDE', 2000, 100, 112, NULL, 1.0, 12.0, 130, 'https://img.lotteeatz.com/upload/product/2025/02/19/20250219202403231_5.png/dims/resize/x214/optimize'),
  (@b, '치킨너겟', '닭안심살과 닭가슴살로 만든 담백하고 촉촉한 치킨너겟 (8조각)', 'CHICKEN', 3300, NULL, NULL, NULL, NULL, NULL, NULL, 'https://img.lotteeatz.com/upload/product/2024/11/20/20241120195357957_4.png/dims/resize/x214/optimize'),
  (@b, '양념너겟', '담백하고 촉촉한 치킨너겟에 시즈닝을 뿌려 흔들어 먹는 디저트', 'CHICKEN', 3500, NULL, NULL, NULL, NULL, NULL, NULL, 'https://img.lotteeatz.com/upload/product/2024/11/20/20241120195418270_3.png/dims/resize/x214/optimize'),
  (@b, '화이어윙', '담백한 맛과 매콤한 맛이 잘 조화된 특별한 타입의 치킨', 'CHICKEN', 3400, 85, 178, 9.0, 2.5, 0.0, 270, 'https://img.lotteeatz.com/upload/product/2023/06/21/20230621175453874_9.png/dims/resize/x214/optimize'),
  (@b, '치킨휠레', '담백한 안심살의 Chicken fillet와 롯데리아만의 독특한 소스가 어우러진 디저트 메뉴', 'CHICKEN', 3300, NULL, NULL, NULL, NULL, NULL, NULL, 'https://img.lotteeatz.com/upload/product/2020/11/03/20201103152232421_6.png/dims/resize/x214/optimize'),
  (@b, '치킨다리 1조각', '담백함과 매콤한맛의 후라이드 치킨다리 1조각', 'CHICKEN', 3100, 82, 151, 11.0, 1.8, 0.0, 330, 'https://img.lotteeatz.com/upload/product/2024/10/30/20241030191751716_5.png/dims/resize/x214/optimize'),
  (@b, '지파이 하바네로(L)', '통가슴살로 만든 바삭하고 매콤한 빅사이즈 치킨 디저트', 'CHICKEN', 5800, 160, 566, 26.0, 4.2, 1.0, 1370, 'https://img.lotteeatz.com/upload/product/2025/10/31/20251031093246521_6.png/dims/resize/x214/optimize'),
  (@b, '지파이 고소한맛(S)', '바삭한 외피와 부드럽고 촉촉한 가슴살을 즐길 수 있는 대형 사이즈 디저트', 'CHICKEN', 4700, 128, 397, 18.0, 6.0, NULL, 620, 'https://img.lotteeatz.com/upload/product/2019/12/20/20191220165208212_3.png/dims/resize/x214/optimize'),
  (@b, '후라이드 순살치킨 (R)', '탱글한 닭다리살에 풍부한 컬과 바삭한 튀김 옷의 조화 순살로 편하게 즐기는 치킨 (순살치킨 292g + 소스 1개)', 'CHICKEN', 11300, 292, NULL, NULL, NULL, NULL, NULL, 'https://img.lotteeatz.com/upload/product/2026/04/07/20260407092338875_9.png/dims/resize/x214/optimize'),
  (@b, '후라이드순살치킨N (R)', '탱글한 닭다리살에 풍부한 컬과 바삭한 튀김 옷의 조화 순살로 편하게 즐기는 치킨 (순살치킨 292g + 소스 1개)', 'CHICKEN', 11300, 292, NULL, NULL, NULL, NULL, NULL, 'https://img.lotteeatz.com/upload/product/2026/06/04/20260604092514301_9.png/dims/resize/x214/optimize'),
  (@b, '팥빙수', '달달한 팥잼과 상큼한 후르츠칵테일, 연유와 아이스크림까지 풍성한 롯데리아 스타일 팥빙수', 'DESSERT', 6100, 511, 601, 10.0, 3.0, 99.0, 140, 'https://img.lotteeatz.com/upload/product/2026/05/14/20260514094819974_9.png/dims/resize/x214/optimize'),
  (@b, '말차빙수', '달콤쌉싸름한 말차와 팥, 연유와 아이스크림으로 건강하고 부드럽게 즐기는 롯데리아 스타일 말차빙수', 'DESSERT', 6100, 440, 634, 9.0, 3.0, 82.0, 220, 'https://img.lotteeatz.com/upload/product/2026/05/14/20260514094847883_1.png/dims/resize/x214/optimize'),
  (@b, '토네이도 말차쿠키', '달콤쌉싸름한 말차와 바삭한 초코쿠키가 조화로운 아이스크림 디저트', 'DESSERT', 3500, 190, 341, 5.0, 7.0, 40.0, 160, 'https://img.lotteeatz.com/upload/product/2026/05/14/20260514094959144_2.png/dims/resize/x214/optimize'),
  (@b, '토네이도 망고젤리', '쫄깃한 곤약젤리가 들어있는 달콤 상큼한 망고아이스크림', 'DESSERT', 3300, 190, 280, 4.0, 6.0, 40.0, 75, 'https://img.lotteeatz.com/upload/product/2025/05/22/20250522132239130_5.png/dims/resize/x214/optimize'),
  (@b, '토네이도 초코쿠키', '부드러운 아이스크림에 달콤한 초코쿠키를 넣어 만든 아이스크림', 'DESSERT', 3300, 175, 300, 5.0, 7.0, 32.0, 160, 'https://img.lotteeatz.com/upload/product/2025/05/22/20250522132322744_9.png/dims/resize/x214/optimize'),
  (@b, '토네이도 스트로베리', '부드러운 아이스크림에 바삭한 딸기 후레이크와 새콤달콤한 딸기잼을 넣어 만든 아이스크림', 'DESSERT', 3300, 177, 263, 4.0, 6.0, 36.0, 65, 'https://img.lotteeatz.com/upload/product/2025/05/22/20250522132336418_0.png/dims/resize/x214/optimize'),
  (@b, '토네이도 더블초코', '달콤한 초콜렛시럽과 바삭한 초코쿠키가 조화로운 아이스크림', 'DESSERT', 3300, 190, 338, 5.0, 7.0, 39.0, 160, 'https://img.lotteeatz.com/upload/product/2025/05/22/20250522132309707_2.png/dims/resize/x214/optimize'),
  (@b, '선데아이스크림 플레인', '본연의 맛에 충실한 부드럽고 깔끔한 소프트 아이스크림', 'DESSERT', 2200, 150, 214, 3.0, 5.0, 26.0, 55, 'https://img.lotteeatz.com/upload/product/2025/05/22/20250522132349844_6.png/dims/resize/x214/optimize'),
  (@b, '선데아이스크림 스트로베리', '부드러운 아이스크림에 진한 천연과일 소스를 얹어 향긋한 과일의 맛과 향을 더불어 즐길수있는 과일 아이스크림', 'DESSERT', 2400, 165, 242, 3.0, 5.0, 33.0, 60, 'https://img.lotteeatz.com/upload/product/2025/05/22/20250522132414156_0.png/dims/resize/x214/optimize'),
  (@b, '선데 허쉬초코', '허쉬의 진하고 부드러운 초코맛이 특징인 아이스크림', 'DESSERT', 2400, 170, 265, 4.0, 5.0, 36.0, 65, 'https://img.lotteeatz.com/upload/product/2025/05/22/20250522132401853_0.png/dims/resize/x214/optimize'),
  (@b, '소프트콘', '부드러운 맛과 시원한 소프트 타입의 아이스콘 제품', 'DESSERT', 1400, 90, 141, 2.0, 3.1, 15.0, 40, 'https://img.lotteeatz.com/upload/product/2025/05/22/20250522132436353_0.png/dims/resize/x214/optimize')
AS new ON DUPLICATE KEY UPDATE
  description = new.description, kind = new.kind, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg, image_url = new.image_url;

-- 맘스터치 (30종)
-- 출처: https://www.momstouch.co.kr/menu/new.php?s_sect1=CG0002 (사이드), s_sect1=CG0004 (치킨)
--       영양성분 표 이미지 https://www.momstouch.co.kr/upload_file/delv_guide/1795048755-ABYAE.png (배포일자 2026.11.19)
--  * 치킨류는 표에 100g 당 값과 총중량만 있어 '100g 당 값 × 총중량 ÷ 100' 으로 계산했다 (식을 그대로 적어 둠)
--  * 뼈 · 순살이 다 있는 치킨은 뼈 치킨 줄을 넣었다. 순살만 있는 치킨은 맥스가 아닌 첫 순살 줄
--    (후덕죽XO사천치킨 = 빅싸이순살, 갓빠삭치킨 = 와우순살)
--  * 떡강정은 S 사이즈 · 가슴살 줄, 조각 수가 여러 개인 사이드는 가장 작은 단위(2조각 · 4조각 · 중) 줄을 넣었다
--  * 코울슬로 · 콘샐러드는 표의 '(소포장)' 줄, 팝콘볼은 '오리지널팝콘볼' 줄
--  * 스낵박스 · 스낵업 · 반반치킨 · 닭강정트리오는 다른 메뉴를 묶은 것이라 넣지 않았다
-- 가격: 공식 사이트에 없고 나무위키 '맘스터치/메뉴'(2026-11-14 수정)에도 사이드 · 치킨 가격이 없어 NULL
SET @b := (SELECT brand_id FROM brand WHERE name = '맘스터치');
INSERT INTO side_menu (brand_id, name, description, kind, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg, image_url) VALUES
  (@b, '케이준양념감자(중)', '케이준스타일의 바삭한 양념감자 맘스터치의 베스트 사이드 메뉴!', 'SIDE', NULL, 85, 279, 4.0, 3.3, 1.0, 470, 'https://www.momstouch.co.kr/upload_file/product_info/1765239967-OXHVA.png'),
  (@b, '치즈감자', '케이준 양념감자와 깊고 진한 딥치즈 소스', 'SIDE', NULL, 135, 419, 6.0, 6.2, 2.0, 838, 'https://www.momstouch.co.kr/upload_file/product_info/1616982123-EWMXK.png'),
  (@b, '미트칠리감자', '톡 쏘는 칠리 소스로 먹을 때마다 중독적인 감자튀김', 'SIDE', NULL, 169, 440, 9.0, 4.4, 3.0, 1021, 'https://www.momstouch.co.kr/upload_file/product_info/1771826774-WBTDZ.png'),
  (@b, '빠삭어니언링(4조각)', '빠삭하고 양파 풍미가 가득한 어니언링', 'SIDE', NULL, 56, 225, 3.0, 1.6, 1.0, 381, 'https://www.momstouch.co.kr/upload_file/product_info/1793235342-MTVVV.png'),
  (@b, '치즈스틱(2조각)', '고단백 영양 만점의 모짜렐라 치즈스틱', 'SIDE', NULL, 40, 129, 6.0, 2.7, 1.0, 217, 'https://www.momstouch.co.kr/upload_file/product_info/1765239996-ESIPD.png'),
  (@b, '바삭크림치즈볼(2조각)', '바삭하고 쫀득하게 즐기는 치즈볼', 'SIDE', NULL, 60, 209, 3.0, 4.1, 4.0, 238, 'https://www.momstouch.co.kr/upload_file/product_info/1616054523-YFWKG.png'),
  (@b, '고구마치즈팝콘볼', '한입에 쏙쏙~~ 달콤한 고구마볼과 시원한 음료의 환상적인 만남!', 'SIDE', NULL, 120, 375, 8.0, 5.1, 11.0, 680, 'https://www.momstouch.co.kr/upload_file/product_info/1765240082-XXFZA.png'),
  (@b, '갈릭김떡만', '바삭한 김말이 쫄깃한 떡 강정과 팝콘만두를 갈릭 소스에 버무려 맵지 않게 즐기는 갈릭김떡만', 'SIDE', NULL, 190, 499, 7.0, 2.5, 19.0, 459, 'https://www.momstouch.co.kr/upload_file/product_info/1675071100-BMWVN.png'),
  (@b, '매콤김떡만', '바삭한 김말이 쫄깃한 떡 강정과 팝콘만두를 매콤한 소스에 맛있게 버무린 매콤김떡만', 'SIDE', NULL, 190, 469, 10.0, 3.2, 5.0, 848, 'https://www.momstouch.co.kr/upload_file/product_info/1675071135-MAHDL.png'),
  (@b, '코울슬로', '입맛을 돋우는 양배추의 아삭한 식감과 상큼한 맛의 코울슬로', 'SIDE', NULL, 120, 147, 1.0, 0.8, 22.0, 291, 'https://www.momstouch.co.kr/upload_file/product_info/1763456292-PZWZQ.png'),
  (@b, '콘샐러드', '달콤한 스위트콘에 신선한 야채까지', 'SIDE', NULL, 100, 140, 1.0, 1.2, 13.0, 370, 'https://www.momstouch.co.kr/upload_file/product_info/1765240033-TSZCW.png'),
  (@b, '팝콘볼', '한입에 쏘옥~들어가는 팝콘 모양의 치킨볼!', 'CHICKEN', NULL, 95, 248, 14.0, 3.1, 2.0, 484, 'https://www.momstouch.co.kr/upload_file/product_info/1765240067-SYJGQ.png'),
  (@b, '할라피뇨너겟(4조각)', '콕콕 박힌 할라피뇨로 매콤하게 즐기는 할라피뇨 너겟', 'CHICKEN', NULL, 65, 186, 8.0, 2.2, 0.0, 301, 'https://www.momstouch.co.kr/upload_file/product_info/1616054732-QTVZC.png'),
  (@b, '치킨치즈스틱', '겉은 바삭한 치킨의 식감, 속은 부드럽게 녹아드는 치즈의 진한 풍미!', 'CHICKEN', NULL, 100, 278, 18.0, 3.9, 1.0, 448, 'https://www.momstouch.co.kr/upload_file/product_info/1771826675-KDBFK.png'),
  (@b, '후라이드통다리(1조각)', '후라이드의 고소함과 바삭함을 통다리로 크게 즐기는 치킨', 'CHICKEN', NULL, 200, ROUND(302 * 200 / 100), ROUND(21 * 200 / 100, 1), ROUND(5.0 * 200 / 100, 1), ROUND(1 * 200 / 100, 1), ROUND(436 * 200 / 100), 'https://www.momstouch.co.kr/upload_file/product_info/1616054932-KRCAV.png'),
  (@b, '후라이드치킨(뼈)', '싸이버거 스타일 케이준 양념레시피로 더 바삭하고 스파이시한 핫크리스피 치킨(뼈)', 'CHICKEN', NULL, 754, ROUND(319 * 754 / 100), ROUND(23 * 754 / 100, 1), ROUND(3.9 * 754 / 100, 1), ROUND(0 * 754 / 100, 1), ROUND(392 * 754 / 100), 'https://www.momstouch.co.kr/upload_file/product_info/1616053678-XUQPV.png'),
  (@b, '맘스양념치킨(뼈)', '매콤달콤 특제 양념소스로 만든 엄마표 맘스양념치킨(뼈)', 'CHICKEN', NULL, 1083, ROUND(269 * 1083 / 100), ROUND(19 * 1083 / 100, 1), ROUND(2.2 * 1083 / 100, 1), ROUND(10 * 1083 / 100, 1), ROUND(552 * 1083 / 100), 'https://www.momstouch.co.kr/upload_file/product_info/1616118072-VGNNE.png'),
  (@b, '간장마늘치킨(뼈)', '알싸한 마늘 향의 매콤함, 특제 간장소스의 단짠이 조화로운 치킨(뼈)', 'CHICKEN', NULL, 936, ROUND(304 * 936 / 100), ROUND(23 * 936 / 100, 1), ROUND(3.1 * 936 / 100, 1), ROUND(6 * 936 / 100, 1), ROUND(521 * 936 / 100), 'https://www.momstouch.co.kr/upload_file/product_info/1616118035-RABFL.png'),
  (@b, '핫치즈치킨(뼈)', '매운 핫소스와 부드러운 치즈소스의 중독성 강한 맛으로 즐길 수 있는 치킨(뼈)', 'CHICKEN', NULL, 1160, ROUND(279 * 1160 / 100), ROUND(20 * 1160 / 100, 1), ROUND(3.3 * 1160 / 100, 1), ROUND(8 * 1160 / 100, 1), ROUND(423 * 1160 / 100), 'https://www.momstouch.co.kr/upload_file/product_info/1751267345-XKNFQ.png'),
  (@b, '핫치즈밤치킨(뼈)', '핫치즈치킨 위에 피자치즈 폭탄을 뿌려, 맛과 비주얼을 모두 극대화한 스페셜 신메뉴(뼈)', 'CHICKEN', NULL, 1260, ROUND(279 * 1260 / 100), ROUND(19 * 1260 / 100, 1), ROUND(3.4 * 1260 / 100, 1), ROUND(7 * 1260 / 100, 1), ROUND(429 * 1260 / 100), 'https://www.momstouch.co.kr/upload_file/product_info/1779409395-ZKJDF.png'),
  (@b, '매직풍치킨(뼈)', '달콤한 파인애플 소스에 고소한 코코넛플레이크를 더해 풍성한 맛과 식감, 매콤한 삼발 디핑 소스에 찍어 즐기는 치킨(뼈). 영양 정보는 디핑 소스 포함', 'CHICKEN', NULL, 1040, ROUND(288 * 1040 / 100), ROUND(19 * 1040 / 100, 1), ROUND(4.8 * 1040 / 100, 1), ROUND(8 * 1040 / 100, 1), ROUND(574 * 1040 / 100), 'https://www.momstouch.co.kr/upload_file/product_info/1775471223-VCEUJ.png'),
  (@b, '셰프스 버번치킨(뼈)', '진한 버번 소스의 맛과 풍미를 넘치게 즐길 수 있는 치킨(뼈)', 'CHICKEN', NULL, 970, ROUND(311 * 970 / 100), ROUND(19 * 970 / 100, 1), ROUND(3.3 * 970 / 100, 1), ROUND(5 * 970 / 100, 1), ROUND(423 * 970 / 100), 'https://www.momstouch.co.kr/upload_file/product_info/1751267237-RLQXU.png'),
  (@b, '후덕죽XO사천치킨(순살)', '후덕죽 XO소스의 깊은 감칠맛과 산초의 알싸함을 더한 특제 크럼블로 화끈한 사천 풍미를 구현한 닭다리살 치킨', 'CHICKEN', NULL, 542, ROUND(310 * 542 / 100), ROUND(17 * 542 / 100, 1), ROUND(4.1 * 542 / 100, 1), ROUND(4 * 542 / 100, 1), ROUND(536 * 542 / 100), 'https://www.momstouch.co.kr/upload_file/product_info/1792628041-RAKRE.png'),
  (@b, '갓빠삭치킨(순살)', '1시간이 지나도 무너지지 않는 극강의 바삭함을 지닌 치킨의 등장!', 'CHICKEN', NULL, 481, ROUND(285 * 481 / 100), ROUND(20 * 481 / 100, 1), ROUND(1.7 * 481 / 100, 1), ROUND(0 * 481 / 100, 1), ROUND(528 * 481 / 100), 'https://www.momstouch.co.kr/upload_file/product_info/1784687322-ZMHDY.png'),
  (@b, '케이준떡강정', '쫀득한 가래떡, 매콤달콤한 케이준소스로 즐기는 순살떡강정. 영양 정보는 S 사이즈 · 가슴살 기준', 'CHICKEN', NULL, 210, ROUND(277 * 210 / 100), ROUND(13 * 210 / 100, 1), ROUND(1.0 * 210 / 100, 1), ROUND(8 * 210 / 100, 1), ROUND(474 * 210 / 100), 'https://www.momstouch.co.kr/upload_file/product_info/1616054007-PZNFA.png'),
  (@b, '간장마늘떡강정', '알싸한 마늘 향의 매콤함 특제 간장소스의 단짠이 조화로운 순살떡강정! 영양 정보는 S 사이즈 · 가슴살 기준', 'CHICKEN', NULL, 210, ROUND(283 * 210 / 100), ROUND(12 * 210 / 100, 1), ROUND(0.7 * 210 / 100, 1), ROUND(9 * 210 / 100, 1), ROUND(504 * 210 / 100), 'https://www.momstouch.co.kr/upload_file/product_info/1616054065-FRPXA.png'),
  (@b, '치파오떡강정', '라유에 볶아 은은한 파향 흑임자와 매콤달콤한 사천식 소스가 일품인 중화식 순살떡강정! 영양 정보는 S 사이즈 · 가슴살 기준', 'CHICKEN', NULL, 210, ROUND(285 * 210 / 100), ROUND(13 * 210 / 100, 1), ROUND(1.0 * 210 / 100, 1), ROUND(6 * 210 / 100, 1), ROUND(523 * 210 / 100), 'https://www.momstouch.co.kr/upload_file/product_info/1616054122-GTPRB.png'),
  (@b, '솔티카라멜볼(2조각)', '바삭한 찹살도넛에 카라멜크림 가득', 'DESSERT', NULL, 60, 263, 2.0, 3.1, 9.0, 213, 'https://www.momstouch.co.kr/upload_file/product_info/1793235186-AGHFJ.png'),
  (@b, '헤이즐넛초코볼(2조각)', '진한 초코가 듬뿍 들어간 쫀득볼', 'DESSERT', NULL, 60, 264, 2.0, 3.5, 11.0, 140, 'https://www.momstouch.co.kr/upload_file/product_info/1793235262-QQWXH.png'),
  (@b, '당근빵', '진짜 당근 비주얼 속에 달콤고소한 당근크림치즈가 가득 들어있는 당근빵', 'DESSERT', NULL, 60, 204, 2.0, 2.3, 7.0, 86, 'https://www.momstouch.co.kr/upload_file/product_info/1778803519-WIVSX.png')
AS new ON DUPLICATE KEY UPDATE
  description = new.description, kind = new.kind, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg, image_url = new.image_url;

-- KFC (14종)
-- 출처: https://www.kfckorea.com/delivery/snack , https://www.kfckorea.com/delivery/chicken (가격은 딜리버리 메뉴 기준)
--       영양 정보표 이미지 https://www.kfckorea.com/nas/kfcimg/info/info_nutrition.png (Ver. 20261110)
--  * 너겟 4조각 · 텐더 2조각은 표에 1조각 값(치킨너겟 21g, 텐더 34g)만 있어 조각 수를 곱했다 (식을 그대로 적어 둠)
--  * 치킨 1조각 4종은 표에 100g(가식부) 당 값만 있고 조각마다 무게가 달라 영양 정보가 NULL
--  * 통다리는 1+1 행사 · 시즈닝 묶음으로만 팔아서, 둠프라이 · 둠너겟은 프렌치프라이(L) · 너겟 10조각의 다른 구성이라,
--    빅그레이비는 소스라서 넣지 않았다
SET @b := (SELECT brand_id FROM brand WHERE name = 'KFC');
INSERT INTO side_menu (brand_id, name, description, kind, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg, image_url) VALUES
  (@b, '프렌치프라이M', NULL, 'SIDE', 3000, 85, 144, 2.0, 1.0, 0.0, 366, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1346016_20260803103525349.png'),
  (@b, '해쉬브라운', NULL, 'SIDE', 2300, 52, 107, 1.0, 1.6, 1.0, 203, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1346023_20260803105403910.png'),
  (@b, '코울슬로', NULL, 'SIDE', 2900, 100, 139, 1.0, 1.9, 15.0, 190, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1346050_20260803105330578.png'),
  (@b, '매쉬포테이토 그레이비', NULL, 'SIDE', 3800, 120, 163, 2.0, 6.0, 3.0, 424, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1346020_20260803105133190.png'),
  (@b, '버터비스켓', NULL, 'SIDE', 3400, 70, 300, 5.0, 13.1, 8.0, 342, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_2343125_20260803105210452.png'),
  (@b, '너겟 4조각', NULL, 'CHICKEN', 3200, 21 * 4, 44 * 4, 3 * 4, 0.9 * 4, 0 * 4, 196 * 4, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_2343126_20260803103957402.png'),
  (@b, '텐더 2조각', NULL, 'CHICKEN', 3700, 34 * 2, 72 * 2, 7 * 2, 0.9 * 2, 0 * 2, 279 * 2, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_2177637_20260803103733376.png'),
  (@b, '핫윙 2조각', NULL, 'CHICKEN', 3300, 59, 182, 10.0, 3.9, 0.0, 445, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_2177640_20260803112335052.png'),
  (@b, '오리지널 치킨 1조각', NULL, 'CHICKEN', 3800, NULL, NULL, NULL, NULL, NULL, NULL, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1172199_20261029112036645.png'),
  (@b, '핫크리스피 치킨 1조각', NULL, 'CHICKEN', 3700, NULL, NULL, NULL, NULL, NULL, NULL, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1172198_20261029111725575.png'),
  (@b, '갓양념 치킨 1조각', NULL, 'CHICKEN', 3900, NULL, NULL, NULL, NULL, NULL, NULL, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1172201_20261029112841997.png'),
  (@b, '갓쏘이 치킨 1조각', NULL, 'CHICKEN', 3900, NULL, NULL, NULL, NULL, NULL, NULL, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1172204_20261029142510293.png'),
  (@b, '에그타르트', NULL, 'DESSERT', 3100, 61, 219, 3.0, 8.8, 10.0, 95, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1346022_20260803105307683.png'),
  (@b, '둠에그타르트', NULL, 'DESSERT', 3100, 56, 195, 3.0, 7.2, 10.0, 96, 'https://kfcapi.inicis.com/kfcs_api_img/KFCS/goods/DL_1346138_20261109180908839.png')
AS new ON DUPLICATE KEY UPDATE
  description = new.description, kind = new.kind, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg, image_url = new.image_url;

-- 노브랜드버거 (19종)
-- 출처: https://www.shinsegaefood.com/nobrandburger/index.sf (사이드 & 디저트, 샐러드)
--       영양성분 이미지 https://shinsegaefood.com/images/pop/nobrandburger_foodinfo.png?v=261120 (2026.11.20 판)
--  * 감자튀김 · 허브순살치킨런은 M, 크리스피 너겟은 3조각, 크런치 윙은 2조각 줄을 넣었다 (사이트 사진은 다른 구성일 수 있음)
-- 가격: 공식 사이트에 없고 다른 출처에서도 확인하지 못해 NULL
SET @b := (SELECT brand_id FROM brand WHERE name = '노브랜드버거');
INSERT INTO side_menu (brand_id, name, description, kind, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg, image_url) VALUES
  (@b, '감자튀김 M', NULL, 'SIDE', NULL, 90, 224, 3.0, 2.0, 1.0, 574, 'https://www.shinsegaefood.com/uimages/2025/05/07/(%EC%82%AC%EC%9D%B4%EC%A6%88)NBB_%EC%82%AC%EC%9D%B4%EB%93%9C_%EA%B0%90%EC%9E%90%ED%8A%80%EA%B9%80M,L_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80(1).png'),
  (@b, '슈가버터 프라이', NULL, 'SIDE', NULL, 145, 405, 5.0, 5.0, 20.0, 952, 'https://www.shinsegaefood.com/uimages/2025/05/07/(%EC%82%AC%EC%9D%B4%EC%A6%88)NBB_%EC%82%AC%EC%9D%B4%EB%93%9C_%EC%8A%88%EA%B0%80%EB%B2%84%ED%84%B0_%ED%94%84%EB%9D%BC%EC%9D%B4_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '쉐킷 프라이', NULL, 'SIDE', NULL, 95, 244, 3.0, 2.0, 2.0, 855, 'https://www.shinsegaefood.com/uimages/2026/02/26/%EC%89%90%ED%82%B7_%ED%94%84%EB%9D%BC%EC%9D%B4_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '메이플 고구마', NULL, 'SIDE', NULL, 86, 287, 3.0, 3.0, 8.0, 359, 'https://www.shinsegaefood.com/uimages/2026/06/30/%EB%A9%94%EC%9D%B4%ED%94%8C_%EA%B3%A0%EA%B5%AC%EB%A7%88_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '해쉬브라운', NULL, 'SIDE', NULL, 45, 158, 1.0, 1.0, 0.0, 230, 'https://www.shinsegaefood.com/uimages/2026/11/20/%EC%82%AC%EC%9D%B4%EB%93%9C_%ED%95%B4%EC%89%AC%EB%B8%8C%EB%9D%BC%EC%9A%B4_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '어니언 링', NULL, 'SIDE', NULL, 72, 218, 2.0, 2.0, 3.0, 325, 'https://www.shinsegaefood.com/uimages/2025/05/07/(%EC%82%AC%EC%9D%B4%EC%A6%88)NBB_%EC%82%AC%EC%9D%B4%EB%93%9C_%EC%96%B4%EB%8B%88%EC%96%B8%EB%A7%81_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '치즈스틱', NULL, 'SIDE', NULL, 45, 152, 4.0, 3.0, 1.0, 216, 'https://www.shinsegaefood.com/uimages/2026/06/30/%EC%B9%98%EC%A6%88%EC%8A%A4%ED%8B%B1_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '인절미 치즈볼', NULL, 'SIDE', NULL, 102, 370, 10.0, 5.0, 8.0, 385, 'https://www.shinsegaefood.com/uimages/2025/05/07/(%EC%82%AC%EC%9D%B4%EC%A6%88)NBB_%EC%82%AC%EC%9D%B4%EB%93%9C_%EC%9D%B8%EC%A0%88%EB%AF%B8_%EC%B9%98%EC%A6%88%EB%B3%BC_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '크런치 새우볼', NULL, 'SIDE', NULL, 61, 147, 6.0, 1.0, 1.0, 282, 'https://www.shinsegaefood.com/uimages/2026/06/30/NBB_%EC%82%AC%EC%9D%B4%EB%93%9C_%ED%81%AC%EB%9F%B0%EC%B9%98_%EC%83%88%EC%9A%B0%EB%B3%BC_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '레몬 크림 새우', NULL, 'SIDE', NULL, 86, 195, 4.0, 2.0, 8.0, 348, 'https://www.shinsegaefood.com/uimages/2026/04/01/%EB%A0%88%EB%AA%AC%ED%81%AC%EB%A6%BC%EC%83%88%EC%9A%B0_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '치킨 시저 샐러드', NULL, 'SIDE', NULL, 204, 171, 11.0, 2.0, 7.0, 485, 'https://www.shinsegaefood.com/uimages/2025/05/07/%EC%B9%98%ED%82%A8%EC%8B%9C%EC%A0%80%EC%83%90%EB%9F%AC%EB%93%9C_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80_460x315.png'),
  (@b, '풀드포크 샐러드', NULL, 'SIDE', NULL, 171, 99, 10.0, 2.0, 7.0, 219, 'https://www.shinsegaefood.com/uimages/2026/08/13/%ED%92%80%EB%93%9C%ED%8F%AC%ED%81%AC_%EC%83%90%EB%9F%AC%EB%93%9C_%EB%8B%A8%ED%92%88_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '그린 샐러드', NULL, 'SIDE', NULL, 145, 29, 1.0, 0.0, 5.0, 37, 'https://www.shinsegaefood.com/uimages/2025/05/07/%EA%B7%B8%EB%A6%B0%EC%83%90%EB%9F%AC%EB%93%9C_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80_460x315.png'),
  (@b, '그린 샐러드 미니', NULL, 'SIDE', NULL, 70, 14, 1.0, 0.0, 2.0, 18, 'https://www.shinsegaefood.com/uimages/2026/01/06/%EC%A0%9C%EB%AA%A9%EC%9D%84_%EC%9E%85%EB%A0%A5%ED%95%B4%EC%A3%BC%EC%84%B8%EC%9A%94..png'),
  (@b, '크리스피 너겟 3조각', NULL, 'CHICKEN', NULL, 48, 118, 7.0, 1.0, 0.0, 308, 'https://www.shinsegaefood.com/uimages/2025/05/07/(%EC%82%AC%EC%9D%B4%EC%A6%88)NBB_%EC%82%AC%EC%9D%B4%EB%93%9C_%ED%81%AC%EB%A6%AC%EC%8A%A4%ED%94%BC_%EB%84%88%EA%B2%9F_5%EC%A1%B0%EA%B0%81_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '크런치 윙 2조각', NULL, 'CHICKEN', NULL, 70, 187, 13.0, 2.0, 0.0, 432, 'https://www.shinsegaefood.com/uimages/2025/05/07/(%EC%82%AC%EC%9D%B4%EC%A6%88)NBB_%EC%82%AC%EC%9D%B4%EB%93%9C_%ED%81%AC%EB%9F%B0%EC%B9%98%EC%9C%99_2%EC%A1%B0%EA%B0%81_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png'),
  (@b, '허브순살치킨런 M', NULL, 'CHICKEN', NULL, 245, 784, 34.0, 8.0, 0.0, 1035, 'https://www.shinsegaefood.com/uimages/2025/07/31/06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80_%ED%97%88%EB%B8%8C%EC%88%9C%EC%82%B4_%EC%B9%98%ED%82%A8%EB%9F%B0M.png'),
  (@b, '와플 치킨', NULL, 'CHICKEN', NULL, 133, 383, 22.0, 4.0, 2.0, 684, 'https://www.shinsegaefood.com/uimages/2026/04/30/image.png'),
  (@b, '슈크림 츄러스', NULL, 'DESSERT', NULL, 57, 205, 2.0, 2.0, 7.0, 119, 'https://www.shinsegaefood.com/uimages/2026/06/30/%EC%8A%88%ED%81%AC%EB%A6%BC_%EC%B8%84%EB%9F%AC%EC%8A%A4_06.%ED%99%88%ED%8E%98%EC%9D%B4%EC%A7%80.png')
AS new ON DUPLICATE KEY UPDATE
  description = new.description, kind = new.kind, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg, image_url = new.image_url;

-- 프랭크버거 (16종)
-- 출처: https://frankburger.co.kr/html/menu_1.html , https://frankburger.co.kr/html/ingredient.html (영양성분표 이미지)
--  * 표의 소수 둘째 자리 값을 열량 · 나트륨은 정수, 나머지는 소수 첫째 자리로 반올림했다 (버거와 같은 방식)
--  * 순살치킨 3종은 메뉴 이름에 200g 이 붙어 있지만 영양성분표의 중량(140 · 169 · 166g)을 넣었다
-- 가격: 공식 사이트에 없고 다른 출처에서도 확인하지 못해 NULL
SET @b := (SELECT brand_id FROM brand WHERE name = '프랭크버거');
INSERT INTO side_menu (brand_id, name, description, kind, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg, image_url) VALUES
  (@b, '프렌치 프라이', '크리스피 슈스트링 감자의 바삭함이 일품인 감자튀김', 'SIDE', NULL, 95, 285, 4.4, 2.0, 0.4, 295, 'https://frankburger.co.kr/img/page/2022_menu/01/menu2_img1.jpg'),
  (@b, '치즈 프렌치 프라이', '바삭한 감자튀김에 꾸덕한 체다치즈가 더해져 깊은 풍미를 느낄 수 있는 치즈 감자튀김', 'SIDE', NULL, 145, 389, 11.4, 6.8, 1.2, 672, 'https://frankburger.co.kr/img/page/2022_menu/01/menu2_img2.jpg'),
  (@b, '해쉬 포테이토', '바삭한 크런치함 속에 고소하고 담백한 포테이토 맛이 일품인 메뉴', 'SIDE', NULL, 51, 157, 1.6, 0.7, 0.1, 153, 'https://frankburger.co.kr/img/page/2022_menu/01/menu2_img26_noicon.jpg'),
  (@b, '바삭 어니언링', '통양파를 크런치하게 튀겨 바삭함과 달콤함을 극대화한 어니언링', 'SIDE', NULL, 116, 399, 5.1, 4.3, 4.0, 393, 'https://frankburger.co.kr/img/page/2022_menu/01/menu2_img35.jpg'),
  (@b, '오징어링 (3개)', '겉은 바삭하게 튀겨 쫄깃한 식감을 그대로 느낄 수 있는 오징어링', 'SIDE', NULL, 48, 183, 4.8, 1.8, 0.2, 256, 'https://frankburger.co.kr/img/page/2022_menu/01/menu2_img13.png'),
  (@b, '치즈스틱 (3개)', '100% 모짜렐라 치즈로 속이 꽉 찬 바삭한 치즈스틱', 'SIDE', NULL, 75, 247, 8.5, 6.3, 1.2, 336, 'https://frankburger.co.kr/img/page/2022_menu/01/menu2_img4.jpg'),
  (@b, '더 치즈볼 (3개)', '치즈의 고소함과 깊은 풍미가 가득한 치즈볼', 'SIDE', NULL, 90, 286, 9.4, 3.8, 8.9, 310, 'https://frankburger.co.kr/img/page/2022_menu/01/menu2_img7.jpg'),
  (@b, '콘샐러드', '스위트콘의 톡톡튀는 식감과 달콤하고 고소한 맛의 조화 버거와 함께 먹으면 너무 잘 어울리는 콘샐러드', 'SIDE', NULL, 100, 140, 1.0, 1.2, 13.0, 370, 'https://frankburger.co.kr/img/page/2022_menu/01/menu2_img16.jpg'),
  (@b, '코울슬로 샐러드', '양배추의 아삭아삭 신선함과 상큼한 맛이 일품인 코울슬로', 'SIDE', NULL, 100, 185, 1.0, 1.6, 18.0, 330, 'https://frankburger.co.kr/img/page/2022_menu/01/menu2_img17.jpg'),
  (@b, '순살치킨 후라이드 (200g)', '껍질의 바삭함과 육즙 가득한 부드러운 속살을 동시에 느낄 수 있는 맛', 'CHICKEN', NULL, 140, 455, 19.6, 5.2, 1.9, 838, 'https://frankburger.co.kr/img/page/2022_menu/01/menu2_img28.jpg'),
  (@b, '순살치킨 양념 (200g)', '특제 고추양념소스로 버무린 매콤달콤함의 정석을 느낄 수 있는 맛', 'CHICKEN', NULL, 166, 495, 28.8, 5.3, 12.0, 871, 'https://frankburger.co.kr/img/page/2022_menu/01/menu2_img31.jpg'),
  (@b, '순살치킨 청양마요 (200g)', '매콤하고 크리미한 청양마요소스에 할라피뇨가 더해진 매력적인 맛', 'CHICKEN', NULL, 169, 525, 22.0, 5.9, 9.3, 942, 'https://frankburger.co.kr/img/page/2022_menu/01/menu2_img30.jpg'),
  (@b, '자이언트 통닭다리', '거대한 닭다리 한쪽을 통째로 바삭하게 튀겨 육즙은 살리고 짭쪼름한 맛을 더한 통닭다리살', 'CHICKEN', NULL, 167, 368, 34.7, 4.6, 1.5, 935, 'https://frankburger.co.kr/img/page/2022_menu/01/menu2_img13.jpg'),
  (@b, '치킨텐더 (2개)', '스파이시 시즈닝을 입힌 부드러운 닭안심살을 매콤 바삭하게 튀겨낸 치킨 텐더', 'CHICKEN', NULL, 60, 179, 9.4, 1.5, 1.1, 257, 'https://frankburger.co.kr/img/page/2022_menu/01/menu2_img6.jpg'),
  (@b, '통가슴살 후라이드', '순살 닭가슴살을 납작하게 튀겨 겉은 바삭, 속은 촉촉하게 튀겨낸 치킨 파이 스타일', 'CHICKEN', NULL, 103, 284, 15.5, 2.8, 0.5, 780, 'https://frankburger.co.kr/img/page/2022_menu/01/menu2_img8.jpg'),
  (@b, '버팔로윙봉 (4개)', '뉴욕 버팔로 스타일로 겉은 바삭, 속은 촉촉하게 튀겨 짭짤한 맛이 일품인 버팔로 치킨', 'CHICKEN', NULL, 132, 310, 32.8, 3.9, 4.0, 925, 'https://frankburger.co.kr/img/page/2022_menu/01/menu2_img11.jpg')
AS new ON DUPLICATE KEY UPDATE
  description = new.description, kind = new.kind, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg, image_url = new.image_url;
