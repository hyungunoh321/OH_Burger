-- OH Burger 버거 초기 데이터
-- 각 브랜드 공식 홈페이지에서 2026-11-14 에 조회한 값. 단품 기준.
-- 실행: mysql -u root -p --default-character-set=utf8mb4 -e "source db/data_burger.sql"
-- 다시 실행해도 추천 · 조회수는 유지되고 버거 정보만 갱신된다.
--
-- 알아둘 점
--  * 가격은 롯데리아와 KFC(딜리버리 메뉴 기준)만 사이트에 공개돼 있어 나머지는 NULL
--  * 맘스터치 · KFC · 노브랜드버거 · 프랭크버거의 영양 정보는 이미지로 된 표를 눈으로 읽어 옮긴 값
--  * 롯데리아 한우불고기버거는 사이트에 열량 범위만 있어 영양 정보가 NULL
--  * 패티 종류(patty_type)는 공식 분류가 아니라 메뉴명 · 설명을 보고 정한 값

USE oh_burger;

-- 맥도날드 (21종)
-- 출처: https://www.mcdonalds.co.kr/kor/menu/information/nutrition
SET @b := (SELECT brand_id FROM brand WHERE name = '맥도날드');
INSERT INTO burger (brand_id, name, description, patty_type, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg) VALUES
  (@b, '빅맥', NULL, 'BEEF', NULL, 223, 582, 27.0, 11.0, 8.0, 902),
  (@b, '맥스파이시 상하이버거', NULL, 'CHICKEN', NULL, 246, 528, 22.0, 3.2, 9.0, 952),
  (@b, '1955 버거', NULL, 'BEEF', NULL, 264, 572, 29.0, 10.0, 15.0, 930),
  (@b, '맥치킨 모짜렐라', NULL, 'CHICKEN', NULL, 293, 735, 29.0, 7.0, 18.0, 1807),
  (@b, '맥치킨', NULL, 'CHICKEN', NULL, 206, 515, 19.0, 3.6, 7.0, 1148),
  (@b, '더블 불고기버거', NULL, 'ETC', NULL, 237, 635, 26.0, 13.0, 15.0, 997),
  (@b, '불고기버거', NULL, 'ETC', NULL, 167, 408, 14.0, 6.0, 14.0, 670),
  (@b, '슈슈버거', NULL, 'SEAFOOD', NULL, 225, 431, 13.0, 1.9, 13.0, 758),
  (@b, '슈비버거', NULL, 'SEAFOOD', NULL, 269, 573, 22.0, 6.0, 15.0, 951),
  (@b, '더블 쿼터파운더 치즈', NULL, 'BEEF', NULL, 275, 770, 50.0, 20.0, 10.0, 1151),
  (@b, '베이컨 토마토 디럭스', NULL, 'BEEF', NULL, 247, 570, 29.0, 11.0, 14.0, 933),
  (@b, '쿼터파운더 치즈', NULL, 'BEEF', NULL, 198, 536, 31.0, 13.0, 10.0, 966),
  (@b, '치즈버거', NULL, 'BEEF', NULL, 115, 318, 16.0, 6.0, 7.0, 612),
  (@b, '더블 치즈버거', NULL, 'BEEF', NULL, 167, 479, 27.0, 12.0, 8.0, 896),
  (@b, '햄버거', NULL, 'BEEF', NULL, 101, 266, 13.0, 3.5, 7.0, 450),
  (@b, '트리플 치즈버거', NULL, 'BEEF', NULL, 216, 640, 38.0, 18.0, 8.0, 1152),
  (@b, '토마토 치즈 비프 버거', NULL, 'BEEF', NULL, 200, 402, 18.0, 7.0, 11.0, 682),
  (@b, '더블 맥스파이시 상하이 버거', NULL, 'CHICKEN', NULL, 362, 867, 38.0, 6.0, 10.0, 1640),
  (@b, '맥크리스피 치킨 디럭스', NULL, 'CHICKEN', NULL, 275, 578, 23.0, 4.7, 13.0, 1297),
  (@b, '맥크리스피 치킨 클래식', NULL, 'CHICKEN', NULL, 209, 567, 23.0, 4.7, 11.0, 1295),
  (@b, '빅아치', NULL, 'BEEF', NULL, 370, 1036, 56.0, 26.0, 12.0, 1661)
AS new ON DUPLICATE KEY UPDATE
  description = new.description, patty_type = new.patty_type, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg;

-- 버거킹 (38종)
-- 출처: https://www.burgerking.co.kr/menu/main (메뉴 상세의 영양성분 표)
SET @b := (SELECT brand_id FROM brand WHERE name = '버거킹');
INSERT INTO burger (brand_id, name, description, patty_type, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg) VALUES
  (@b, '몬스터 맥시멈', NULL, 'BEEF', NULL, 376, 1067, 51.0, 19.0, 13.0, 2273),
  (@b, '몬스터 맥시멈2', NULL, 'BEEF', NULL, 457, 1305, 71.0, 23.0, 13.0, 2313),
  (@b, '몬스터 맥시멈3', NULL, 'BEEF', NULL, 559, 1619, 90.0, 35.0, 19.0, 2810),
  (@b, '더오치 맥시멈2', NULL, 'BEEF', NULL, 375, 1018, 53.0, 29.0, 9.0, 2045),
  (@b, '오리지널스 엘파소 치폴레', NULL, 'BEEF', NULL, 291, 911, 44.0, 25.0, 9.0, 1338),
  (@b, '오리지널스 뉴욕 스테이크', NULL, 'BEEF', NULL, 307, 826, 51.0, 22.0, 10.0, 1762),
  (@b, '블랙 트러플치즈 버거', NULL, 'BEEF', NULL, 281, 769, 34.0, 18.0, 9.0, 1430),
  (@b, '트러플 머쉬룸 와퍼', NULL, 'BEEF', NULL, 325, 761, 37.0, 16.0, 6.0, 1195),
  (@b, '핫 트러플 머쉬룸 와퍼', NULL, 'BEEF', NULL, 285, 724, 35.0, 14.0, 7.0, 1278),
  (@b, '메종 트러플치즈 버거', NULL, 'BEEF', NULL, 281, 744, 35.0, 19.0, 14.0, 1451),
  (@b, '몬스터와퍼', NULL, 'BEEF', NULL, 403, 1094, 52.0, 21.0, 8.0, 2146),
  (@b, '베이컨치즈와퍼', NULL, 'BEEF', NULL, 320, 844, 37.0, 19.0, 8.0, 1654),
  (@b, '콰트로치즈와퍼', NULL, 'BEEF', NULL, 331, 887, 43.0, 21.0, 6.0, 1647),
  (@b, '통새우와퍼', NULL, 'BEEF', NULL, 309, 714, 34.0, 12.0, 9.0, 1258),
  (@b, '와퍼', NULL, 'BEEF', NULL, 286, 706, 30.0, 12.0, 10.0, 1098),
  (@b, '치즈와퍼', NULL, 'BEEF', NULL, 310, 799, 35.0, 18.0, 7.0, 1571),
  (@b, '불고기와퍼', NULL, 'BEEF', NULL, 293, 738, 31.0, 13.0, 10.0, 1137),
  (@b, '갈릭불고기와퍼', NULL, 'BEEF', NULL, 293, 768, 31.0, 12.0, 9.0, 1007),
  (@b, '콰트로치즈 와퍼주니어', NULL, 'BEEF', NULL, 179, 470, 21.0, 10.0, 4.0, 833),
  (@b, '통새우와퍼주니어', NULL, 'BEEF', NULL, 168, 414, 17.0, 7.0, 5.0, 658),
  (@b, '더블비프불고기버거', NULL, 'BEEF', NULL, 190, 565, 26.0, 12.0, 6.0, 796),
  (@b, '와퍼주니어', NULL, 'BEEF', NULL, 156, 376, 17.0, 5.0, 4.0, 556),
  (@b, '치즈와퍼주니어', NULL, 'BEEF', NULL, 168, 422, 18.0, 7.0, 4.0, 778),
  (@b, '불고기와퍼주니어', NULL, 'BEEF', NULL, 160, 413, 16.0, 6.0, 5.0, 617),
  (@b, '비프불고기버거', NULL, 'BEEF', NULL, 136, 384, 15.0, 5.0, 5.0, 492),
  (@b, '치즈버거', NULL, 'BEEF', NULL, 130, 380, 16.0, 7.0, 6.0, 766),
  (@b, '쯔란로제 크리스퍼', NULL, 'CHICKEN', NULL, 233, 660, 27.0, 9.0, 11.0, 1694),
  (@b, '쯔란로제 딥 치즈 크리스퍼', NULL, 'CHICKEN', NULL, 288, 692, 31.0, 11.0, 9.0, 1779),
  (@b, '더 크리스퍼', NULL, 'CHICKEN', NULL, 225, 696, 26.0, 9.0, 5.0, 1392),
  (@b, '더 크리스퍼 베이컨&치즈', NULL, 'CHICKEN', NULL, 231, 727, 28.0, 10.0, 6.0, 1553),
  (@b, '치킨킹BLT', NULL, 'CHICKEN', NULL, 269, 739, 25.0, 11.0, 12.0, 1065),
  (@b, '치킨킹', NULL, 'CHICKEN', NULL, 224, 673, 24.0, 10.0, 8.0, 1037),
  (@b, '통새우슈림프버거', NULL, 'SEAFOOD', NULL, 190, 512, 16.0, 5.0, 8.0, 1077),
  (@b, '치킨 치즈 마요 버거', NULL, 'CHICKEN', NULL, 195, 640, 20.0, 10.0, 4.0, 1122),
  (@b, '치킨버거', NULL, 'CHICKEN', NULL, 179, 532, 18.0, 7.0, 4.0, 840),
  (@b, '롱치킨버거', NULL, 'CHICKEN', NULL, 206, 621, 23.0, 7.0, 7.0, 1235),
  (@b, '불고기 롱치킨버거', NULL, 'CHICKEN', NULL, 234, 691, 23.0, 7.0, 7.0, 1434),
  (@b, '몬스터 주니어', NULL, 'BEEF', NULL, 243, 687, 30.0, 13.0, 7.0, 1293)
AS new ON DUPLICATE KEY UPDATE
  description = new.description, patty_type = new.patty_type, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg;

-- 롯데리아 (29종)
-- 출처: https://www.lotteeatz.com/brand/ria
SET @b := (SELECT brand_id FROM brand WHERE name = '롯데리아');
INSERT INTO burger (brand_id, name, description, patty_type, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg) VALUES
  (@b, '리아 불고기 레드', '익숙한 불고기의 감칠맛에 청양고추 엑기스를 더해 맛있게 매운맛의 리아 불고기, 바삭한 감자채전 토핑으로 든든하게', 'BEEF', 6200, 238, 550, 22.0, 12.0, 20.0, 1110),
  (@b, '리아 불고기 더블 레드', '익숙한 불고기의 감칠맛에 청양고추 액기스를 더해 맛있게 매운맛의 리아 불고기, 더블패티 구성으로 든든하게', 'BEEF', 8000, 280, 731, 38.0, 23.0, 16.0, 1570),
  (@b, '리아 두툼새우', '탱글 두툼한 새우패티로 새우 본연의 풍미를 깔끔하게 끌어올린 리아 새우 한정판', 'SEAFOOD', 7900, 263, 549, 18.0, 3.2, 11.0, 1300),
  (@b, '리아 두툼새우 스파이시토마토', '매콤한 토마토소스에 딱새우의 머리부터 껍질까지 농축한 액기스를 더해 은은한 감칠맛을 끌어올린 리아 새우 한정판', 'SEAFOOD', 7900, 263, 516, 18.0, 4.0, 10.0, 1310),
  (@b, '하와이안 모짜렐라버거', '달콤한 파인애플과 쭉 늘어나는 모짜렐라, 나폴리탄 소스를 더해 완벽한 단짠 조합의 모짜렐라버거', 'BEEF', 8800, 290, 773, 26.0, 18.0, 14.0, 1150),
  (@b, '통다리 크리스피치킨버거(파이어핫)', '육즙 가득 통다리살에 버터밀크 외피로 입안을 가득 채우는 바삭함이 특징, 중독성 있는 갈릭핫소스로 강렬한 매운맛의 크리스피치킨버거', 'CHICKEN', 6900, 231, 594, 25.0, 4.4, 10.0, 1040),
  (@b, '통다리 크리스피치킨버거(그릭랜치)', '육즙 가득 통다리살에 버터밀크 외피로 입안을 가득 채우는 바삭함이 특징, 요거트 첨가된 그릭랜치소스로 마일드한 맛의 크리스피치킨버거', 'CHICKEN', 6900, 231, 618, 25.0, 5.0, 8.0, 1050),
  (@b, '나폴리 모짜렐라버거 발사믹바질', '바질의 신선함을 담은 바질마요소스에 레드와인 발사믹의 산뜻함을 더한 스페셜 모짜렐라버거', 'BEEF', 9300, 250, 733, 27.0, 18.0, 10.0, 1040),
  (@b, '나폴리 모짜렐라버거 토마토바질', '바질의 신선함을 담은 바질마요소스에 풍부하고 진한 토마토소스로 맛을 낸 스페셜 모짜렐라버거', 'BEEF', 9300, 240, 733, 27.0, 18.0, 10.0, 1080),
  (@b, '전주 비빔라이스 버거', '전주비빔밥을 담은 라이스번과 노른자가 터지는 반숙란,달콤한 고추장 소스가 어우러진 새로운 라이스 버거', 'BEEF', 7500, 285, 574, 17.0, 8.0, 8.0, 1450),
  (@b, '리아 새우 베이컨', '베이컨+토마토로 더욱 풍성해진 맛과 볼륨감의 새우버거 업그레이드 한정판', 'SEAFOOD', 6200, 211, 519, 18.0, 5.0, 6.0, 960),
  (@b, '리아 불고기 베이컨', '베이컨+토마토로 더욱 풍성해진 맛과 볼륨감의 불고기버거 업그레이드 한정판', 'BEEF', 6200, 224, 508, 23.0, 13.0, 11.0, 940),
  (@b, '더블 한우불고기버거', '국내산 한우를 사용한 패티 2장 구성으로 육즙 가득! 묵직한 육풍미를 특징으로 한 프리미엄 버거', 'BEEF', 13200, 352, 802, 39.0, 20.0, 18.0, 1150),
  (@b, '한우불고기버거', '브리오쉬번에 국내산 한우를 사용한 패티, 신선한 야채, 특제소스로 완성한 프리미엄 햄버거', 'BEEF', 9200, NULL, NULL, NULL, NULL, NULL, NULL),
  (@b, '더블 클래식치즈버거(버터번)', '두 장의 패티가 이루는 조화로운 맛에 든든함까지 추가된 더블 클래식치즈버거', 'BEEF', 7400, 213, 731, 25.0, 25.0, 6.0, 1110),
  (@b, '더블 치킨버거', '두 장의 패티가 이루는 조화로운 맛에 든든함까지 추가된 더블버거 시리즈', 'CHICKEN', 6000, 205, 478, 24.0, 5.0, 11.0, 950),
  (@b, '더블 데리버거', '두 장의 패티가 이루는 조화로운 맛에 든든함까지 추가된 더블버거 시리즈', 'BEEF', 5200, 170, 446, 19.0, 7.0, 10.0, 740),
  (@b, '더블엑스투버거', '비프패티2장, 치즈2장으로 깊고 풍부한맛의 정통 아메리칸버거', 'BEEF', 7400, 228, 716, 25.0, 25.0, 7.0, 1070),
  (@b, '리아 불고기 더블(빅불)', '불고기 특유의 소스와 쇠고기의 진함을 배로 느끼는 제품', 'BEEF', 7700, 274, 721, 38.0, 24.0, 12.0, 1480),
  (@b, '미라클버거', '100% 식물성 패티와 신선한 야채들이 조화된 대체육버거', 'ETC', 5900, 181, 382, 15.0, 4.6, 7.0, 600),
  (@b, '더블 미라클버거', '100% 식물성 패티와 신선한 야채들이 조화된 대체육버거', 'ETC', 7400, 245, 551, 25.0, 7.0, 10.0, 920),
  (@b, '모짜렐라 인 더 버거 베이컨', '자연산 모짜렐라 치즈와 고소한 베이컨이 만나 풍부한 맛의 버거', 'BEEF', 8200, 223, 696, 30.0, 16.0, 6.0, 1000),
  (@b, '핫크리스피치킨버거', '닭가슴살 패티로 만든 매콤 화끈한 프리미엄 치킨버거', 'CHICKEN', 6400, 190, 503, 22.0, 7.0, 5.0, 930),
  (@b, '리아 사각새우 더블', '미니새우패티 2장의 새우 매니아를 위한버거', 'SEAFOOD', 6200, 208, 556, 17.0, 5.0, 7.0, 960),
  (@b, '클래식치즈버거(버터번)', '부드러운 치즈와 호주산 쇠고기패티의 본연의 맛을 느낄수 있는 치즈버거', 'BEEF', 5700, 146, 492, 16.0, 14.0, 5.0, 770),
  (@b, '리아 불고기', '두툼한 쇠고기패티와 한국적인 맛의 소스가 잘 조화된 롯데리아 대표 버거', 'BEEF', 5100, 192, 462, 21.0, 11.0, 11.0, 880),
  (@b, '리아 새우', '새우살을 가득넣어 더 맛있어진 오리지널 새우버거', 'SEAFOOD', 5100, 179, 492, 15.0, 4.7, 7.0, 810),
  (@b, '치킨버거', '닭고기패티와 데리야끼 소스로 만든 담백하고 달콤한 맛의 치킨버거', 'CHICKEN', 4500, 141, 355, 15.0, 3.8, 8.0, 620),
  (@b, '데리버거', '쇠고기패티에 달콤 짭짤한 데리소스를 더한 가성비 버거', 'BEEF', 3800, 134, 348, 12.0, 4.9, 10.0, 590)
AS new ON DUPLICATE KEY UPDATE
  description = new.description, patty_type = new.patty_type, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg;

-- 맘스터치 (25종)
-- 출처: https://www.momstouch.co.kr/menu/new.php?s_sect1=CG0005 (영양성분 표 이미지, 배포일자 2026.10.22)
SET @b := (SELECT brand_id FROM brand WHERE name = '맘스터치');
INSERT INTO burger (brand_id, name, description, patty_type, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg) VALUES
  (@b, '후덕죽쿵파오싸이버거', NULL, 'CHICKEN', NULL, 283, 779, 29.0, 7.4, 16.0, 1169),
  (@b, '후덕죽XO통모짜새우버거', NULL, 'SEAFOOD', NULL, 276, 716, 23.0, 9.2, 14.0, 1273),
  (@b, '후덕죽XO쉬림프싸이플렉스버거', NULL, 'CHICKEN', NULL, 303, 763, 33.0, 7.6, 13.0, 1554),
  (@b, '아라비아따치즈버거', NULL, 'ETC', NULL, 309, 791, 41.0, 12.0, 10.0, 1622),
  (@b, '딥치즈싸이버거', NULL, 'CHICKEN', NULL, 246, 655, 30.0, 12.1, 10.0, 1196),
  (@b, '화이트갈릭싸이버거', NULL, 'CHICKEN', NULL, 263, 759, 37.0, 13.0, 10.0, 1345),
  (@b, '쉬림프싸이플렉스버거', NULL, 'CHICKEN', NULL, 301, 858, 29.0, 11.8, 12.0, 1392),
  (@b, '싸이플렉스버거', NULL, 'CHICKEN', NULL, 406, 991, 44.0, 15.2, 14.0, 2024),
  (@b, '싸이버거', NULL, 'CHICKEN', NULL, 230, 594, 28.0, 8.6, 14.0, 1009),
  (@b, '불싸이버거', NULL, 'CHICKEN', NULL, 230, 543, 28.0, 6.9, 15.0, 1152),
  (@b, '휠렛버거', NULL, 'CHICKEN', NULL, 248, 545, 32.0, 4.2, 13.0, 939),
  (@b, '딥치즈버거', NULL, 'CHICKEN', NULL, 259, 543, 33.0, 7.1, 9.0, 1087),
  (@b, '언빌리버블버거', NULL, 'CHICKEN', NULL, 327, 702, 40.0, 6.3, 13.0, 1423),
  (@b, '화이트갈릭버거', NULL, 'CHICKEN', NULL, 280, 638, 40.0, 9.0, 13.0, 1268),
  (@b, '새우불고기버거', NULL, 'SEAFOOD', NULL, 252, 601, 19.0, 6.3, 20.0, 1054),
  (@b, '불고기버거', NULL, 'BEEF', NULL, 164, 403, 14.0, 5.1, 14.0, 615),
  (@b, '더블불고기버거', NULL, 'BEEF', NULL, 236, 614, 24.0, 9.3, 16.0, 1197),
  (@b, '통새우버거', NULL, 'SEAFOOD', NULL, 178, 449, 12.0, 12.4, 9.0, 707),
  (@b, '그릴드버거', NULL, 'BEEF', NULL, 138, 409, 17.0, 5.7, 9.0, 507),
  (@b, '그릴드베이컨버거', NULL, 'BEEF', NULL, 198, 486, 19.0, 7.6, 12.0, 679),
  (@b, '스모키스매쉬버거', NULL, 'BEEF', NULL, 252, 634, 32.0, 12.1, 11.0, 945),
  (@b, '더블스매쉬버거', NULL, 'BEEF', NULL, 281, 700, 38.0, 16.0, 5.0, 927),
  (@b, '스매쉬버거', NULL, 'BEEF', NULL, 208, 477, 22.0, 9.2, 6.0, 658),
  (@b, '햄치즈휠렛버거', NULL, 'CHICKEN', NULL, 276, 617, 36.0, 9.4, 10.0, 1188),
  (@b, '베이컨치폴레싸이버거', NULL, 'CHICKEN', NULL, 259, 671, 31.0, 8.3, 14.0, 1281)
AS new ON DUPLICATE KEY UPDATE
  description = new.description, patty_type = new.patty_type, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg;

-- KFC (10종)
-- 출처: https://www.kfckorea.com/menu/burger (영양 정보표 이미지, Ver. 20261110 / 가격은 딜리버리 메뉴 기준)
SET @b := (SELECT brand_id FROM brand WHERE name = 'KFC');
INSERT INTO burger (brand_id, name, description, patty_type, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg) VALUES
  (@b, '둠트리플다운', NULL, 'CHICKEN', 13800, 524, 1235, 83.0, 21.9, 10.0, 2641),
  (@b, '징거더블다운', NULL, 'CHICKEN', 10200, 368, 842, 67.0, 13.9, 5.0, 1868),
  (@b, '둠징거', NULL, 'CHICKEN', 9400, 290, 699, 35.0, 9.9, 22.0, 1463),
  (@b, '칰폴레맵징거타워', NULL, 'CHICKEN', 8100, 348, 803, 37.0, 11.8, 16.0, 1386),
  (@b, '치즈징거통다리', NULL, 'CHICKEN', 8100, 270, 713, 28.0, 15.1, 9.0, 1386),
  (@b, '징거BLT', NULL, 'CHICKEN', 8000, 281, 696, 39.0, 11.2, 6.0, 1164),
  (@b, '징거타워', NULL, 'CHICKEN', 7800, 303, 720, 36.0, 11.0, 9.0, 1343),
  (@b, '칰폴레맵징거통다리', NULL, 'CHICKEN', 7700, 285, 695, 24.0, 10.1, 18.0, 1125),
  (@b, '클래식징거통다리', NULL, 'CHICKEN', 7400, 234, 606, 24.0, 9.2, 12.0, 1010),
  (@b, '징거', NULL, 'CHICKEN', 6800, 225, 553, 33.0, 7.4, 5.0, 866)
AS new ON DUPLICATE KEY UPDATE
  description = new.description, patty_type = new.patty_type, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg;

-- 노브랜드버거 (22종)
-- 출처: https://shinsegaefood.com/popup/nobrandburger_02.html (영양성분 이미지)
SET @b := (SELECT brand_id FROM brand WHERE name = '노브랜드버거');
INSERT INTO burger (brand_id, name, description, patty_type, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg) VALUES
  (@b, '어메이징 더블 업', NULL, 'BEEF', NULL, 282, 725, 32.0, 15.0, 9.0, 1433),
  (@b, '시그니처', NULL, 'BEEF', NULL, 213, 531, 21.0, 9.0, 9.0, 1138),
  (@b, '오리지널', NULL, 'BEEF', NULL, 189, 439, 17.0, 6.0, 8.0, 642),
  (@b, '미트 마니아', NULL, 'BEEF', NULL, 305, 749, 37.0, 13.0, 9.0, 1796),
  (@b, '그릴드 불고기', NULL, 'BEEF', NULL, 164, 426, 16.0, 5.0, 12.0, 699),
  (@b, '메가바이트', NULL, 'BEEF', NULL, 216, 657, 19.0, 7.0, 7.0, 989),
  (@b, '크런치 치킨', NULL, 'CHICKEN', NULL, 218, 530, 27.0, 6.0, 9.0, 1307),
  (@b, '치폴레 치킨', NULL, 'CHICKEN', NULL, 198, 388, 18.0, 7.0, 9.0, 918),
  (@b, '오리지널 새우', NULL, 'SEAFOOD', NULL, 176, 429, 13.0, 5.0, 9.0, 926),
  (@b, '더블 그릴드 불고기', NULL, 'BEEF', NULL, 231, 577, 28.0, 8.0, 17.0, 990),
  (@b, '치즈', NULL, 'BEEF', NULL, 140, 423, 14.0, 8.0, 7.0, 816),
  (@b, '통새우 감바스', NULL, 'SEAFOOD', NULL, 187, 439, 16.0, 5.0, 9.0, 1091),
  (@b, '그릴드 불고기 라이트', NULL, 'BEEF', NULL, 150, 372, 15.0, 5.0, 10.0, 423),
  (@b, '모짜 치폴레 베이컨', NULL, 'BEEF', NULL, 270, 703, 27.0, 17.0, 14.0, 1345),
  (@b, '에그 치즈 불고기', NULL, 'BEEF', NULL, 217, 527, 21.0, 13.0, 12.0, 1083),
  (@b, '스모크 바비큐', NULL, 'BEEF', NULL, 200, 455, 20.0, 6.0, 17.0, 978),
  (@b, '버크셔K 카츠', NULL, 'ETC', NULL, 212, 462, 17.0, 9.0, 7.0, 940),
  (@b, '버크셔K 카츠 어니언', NULL, 'ETC', NULL, 240, 524, 16.0, 9.0, 8.0, 1003),
  (@b, '데일리 치킨', NULL, 'CHICKEN', NULL, 182, 429, 20.0, 4.0, 11.0, 957),
  (@b, 'NBB 훅', NULL, 'ETC', NULL, 201, 487, 23.0, 8.0, 9.0, 1202),
  (@b, 'NBB 펀치', NULL, 'ETC', NULL, 205, 509, 26.0, 9.0, 8.0, 1476),
  (@b, '진짜 비빔밥 버거', NULL, 'ETC', NULL, 260, 674, 20.0, 8.0, 13.0, 1351)
AS new ON DUPLICATE KEY UPDATE
  description = new.description, patty_type = new.patty_type, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg;

-- 프랭크버거 (15종)
-- 출처: https://frankburger.co.kr/html/menu_1.html , https://frankburger.co.kr/html/ingredient.html (영양성분표 이미지)
SET @b := (SELECT brand_id FROM brand WHERE name = '프랭크버거');
INSERT INTO burger (brand_id, name, description, patty_type, price, weight_g, calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg) VALUES
  (@b, '프랭크 버거', '육즙 가득한 수제패티와 신선한 야채가 잘 어우러져 기본에 충실한 미국 동부식 오리지널 버거', 'BEEF', NULL, 157, 438, 17.9, 10.1, 5.3, 604),
  (@b, '치즈버거', '대표메뉴로서 100% 수제패티와 체다 치즈의 깊은 풍미를 이룬 시그니처 버거', 'BEEF', NULL, 170, 472, 20.2, 12.1, 4.3, 750),
  (@b, '베이컨 치즈버거', '수제패티에 하와이안 스타일의 구운 파인애플과 베이컨의 조화를 이룬 스페셜 버거', 'BEEF', NULL, 234, 605, 28.4, 15.3, 11.4, 984),
  (@b, '쉬림프 버거', '탱탱한 새우가 들어간 새우패티를 바삭하게 튀겨 새콤달콤한 특제소스와 조화를 이룬 프리미엄 새우 버거', 'SEAFOOD', NULL, 201, 568, 13.5, 8.5, 8.6, 878),
  (@b, '비프 앤 쉬림프 버거', '탱탱한 새우가 들어간 새우 패티와 소고기패티의 육향이 절묘하게 조화를 이룬 프리미엄 버거', 'BEEF', NULL, 257, 730, 27.5, 13.5, 9.2, 1144),
  (@b, 'JG버거', '정통 아메리칸 스타일에 구운 베이컨에 꾸덕한 치즈소스가 듬뿍 들어가 풍만함이 최상인 마지막 종결 버거', 'BEEF', NULL, 222, 726, 36.7, 20.6, 6.6, 1415),
  (@b, '더블 비프 치즈 버거', '더블패티에 생양파와 피클을 더해 미국식 수제버거의 풍미를 최상으로 느낄 수 있는 버거', 'BEEF', NULL, 249, 713, 28.7, 17.8, 8.6, 1116),
  (@b, 'K 불고기 버거', '전통 궁중식 너비아니 스타일의 패티에 불고기 양념을 가미한 한국의 대표 불고기 버거', 'BEEF', NULL, 195, 492, 20.0, 10.3, 10.6, 657),
  (@b, 'K 핫불고기 버거', '매콤한 특제소스로 한국 특유의 매운맛을 살린 화끈한 불고기 버거', 'BEEF', NULL, 189, 511, 20.0, 9.7, 6.4, 688),
  (@b, '청양마요 쉬림프 버거', '핫 렐리쉬 마요소스와 탱글탱글한 새우 패티가 어우러져 새우의 풍미가 깔끔하게 마무리 되는 버거', 'SEAFOOD', NULL, 220, 578, 14.7, 7.4, 10.6, 958),
  (@b, '100% 한우 갈릭 버거', '100% 순수 한우 패티에 블랙갈릭소스의 깊고 진한 맛을 더한 한우 버거', 'BEEF', NULL, 246, 554, 25.6, 12.3, 11.8, 1004),
  (@b, '100% 한우 버거', '100% 순수 한우 패티에 데미글라스 브라운 소스를 더한 리얼 한우 버거', 'BEEF', NULL, 192, 443, 21.8, 8.8, 9.0, 638),
  (@b, '파닭파닭 치킨버거', '고소한 땅콩과 고추와 대파의 풍미가 살아있는 중화풍 버거', 'CHICKEN', NULL, 218, 649, 28.0, 10.5, 10.8, 1067),
  (@b, '깐쇼새우 비프버거', '육즙 가득한 비프패티와 바삭한 새우패티를 함께 즐기는 두가지 패티맛의 버거', 'BEEF', NULL, 272, 772, 27.9, 14.3, 12.9, 1252),
  (@b, '맥앤치즈 비프버거', '진한 체다치즈로 만든 크리미한 맥앤치즈와 육즙 가득한 비프패티의 완벽하게 조화로 만들어진 버거', 'BEEF', NULL, 324, 910, 35.9, 21.6, 5.4, 1759)
AS new ON DUPLICATE KEY UPDATE
  description = new.description, patty_type = new.patty_type, price = new.price, weight_g = new.weight_g,
  calories_kcal = new.calories_kcal, protein_g = new.protein_g, sat_fat_g = new.sat_fat_g,
  sugar_g = new.sugar_g, sodium_mg = new.sodium_mg;
