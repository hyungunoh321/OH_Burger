-- OH Burger 시연용 예시 데이터 (회원 · 게시글 · 댓글 · 추천)
-- 데모 영상을 찍고 화면을 확인하려고 만든 가상의 데이터다. 실제 사용자가 쓴 글이 아니다.
-- 실행: mysql -u root -p --default-character-set=utf8mb4 -e "source db/data_demo.sql"  (schema.sql, data_burger.sql 다음에)
-- 다시 실행하면 아래 시연용 계정과 그 계정이 쓴 글 · 댓글 · 추천을 지우고 처음 상태로 다시 넣는다.
-- 다른 계정의 데이터와 버거 조회수는 건드리지 않는다. 글 · 댓글 시각은 실행한 때를 기준으로 몇 시간 ~ 며칠 전으로 넣는다.
--
-- 시연용 계정 (비밀번호는 모두 burger1234. 이 시연 데이터에서만 쓰는 값이다)
--   아이디      닉네임      비고
--   demoadmin   관리자      관리자 권한 (머리글에 "버거 관리" 메뉴가 보인다)
--   demo01      버거탐험가
--   demo02      단백질러
--   demo03      가성비왕
--   demo04      치즈덕후
--   demo05      야식요정
--   demonew     새내기      넣지 않는다. 영상에서 회원가입할 때 쓰는 아이디라서, 다시 실행하면 이 계정도 함께 지운다
--
-- 글에 적은 영양 정보 · 가격 · 티어는 data_burger.sql 의 값(2026-11-27 기준)과 맞춰 썼다.
-- 비밀번호 해시는 PasswordUtil 과 같은 SHA-256(솔트 + 비밀번호) 16진수다. 솔트는 아이디로 정해지는 값(MD5)을 쓴다.

USE oh_burger;

-- 1. 전에 넣은 시연용 데이터 지우기 -----------------------------------------------------------------
CREATE TEMPORARY TABLE demo_login (login_id VARCHAR(20) PRIMARY KEY);
INSERT INTO demo_login VALUES ('demoadmin'), ('demo01'), ('demo02'), ('demo03'), ('demo04'), ('demo05'), ('demonew');

-- 남의 글에 단 댓글 → 직접 쓴 글(그 글의 댓글 · 추천 · 태그는 CASCADE) → 계정(버거 추천 · 글 추천은 CASCADE) 순서로 지운다.
-- post · post_comment 의 작성자 외래키에는 CASCADE 가 없어서 계정을 먼저 지울 수 없다.
DELETE FROM post_comment
 WHERE member_id IN (SELECT member_id FROM member WHERE login_id IN (SELECT login_id FROM demo_login));
DELETE FROM post
 WHERE member_id IN (SELECT member_id FROM member WHERE login_id IN (SELECT login_id FROM demo_login));
DELETE FROM member WHERE login_id IN (SELECT login_id FROM demo_login);
DROP TEMPORARY TABLE demo_login;

-- 2. 회원 -----------------------------------------------------------------------------------------
SET @now := NOW();

INSERT INTO member (login_id, password_hash, salt, nickname, role, created_at)
SELECT login_id,
       SHA2(CONCAT(MD5(CONCAT('oh-burger-demo:', login_id)), 'burger1234'), 256),
       MD5(CONCAT('oh-burger-demo:', login_id)),
       nickname, role, @now - INTERVAL days DAY
  FROM (SELECT 'demoadmin' AS login_id, '관리자' AS nickname, 'ADMIN' AS role, 30 AS days
        UNION ALL SELECT 'demo01', '버거탐험가', 'USER', 21
        UNION ALL SELECT 'demo02', '단백질러',   'USER', 20
        UNION ALL SELECT 'demo03', '가성비왕',   'USER', 18
        UNION ALL SELECT 'demo04', '치즈덕후',   'USER', 16
        UNION ALL SELECT 'demo05', '야식요정',   'USER', 15) d;

SET @admin := (SELECT member_id FROM member WHERE login_id = 'demoadmin');
SET @m1    := (SELECT member_id FROM member WHERE login_id = 'demo01');   -- 버거탐험가
SET @m2    := (SELECT member_id FROM member WHERE login_id = 'demo02');   -- 단백질러
SET @m3    := (SELECT member_id FROM member WHERE login_id = 'demo03');   -- 가성비왕
SET @m4    := (SELECT member_id FROM member WHERE login_id = 'demo04');   -- 치즈덕후
SET @m5    := (SELECT member_id FROM member WHERE login_id = 'demo05');   -- 야식요정

-- 3. 글에 태그하고 추천할 버거 (브랜드 + 이름으로 찾는다. 못 찾으면 NULL 이라 그 태그 · 추천만 빠진다) ----------
SET @b_monster3     := (SELECT b.burger_id FROM burger b JOIN brand br ON br.brand_id = b.brand_id WHERE br.name = '버거킹'   AND b.name = '몬스터 맥시멈3');
SET @b_doom         := (SELECT b.burger_id FROM burger b JOIN brand br ON br.brand_id = b.brand_id WHERE br.name = 'KFC'      AND b.name = '둠트리플다운');
SET @b_zingerdouble := (SELECT b.burger_id FROM burger b JOIN brand br ON br.brand_id = b.brand_id WHERE br.name = 'KFC'      AND b.name = '징거더블다운');
SET @b_whitegarlic  := (SELECT b.burger_id FROM burger b JOIN brand br ON br.brand_id = b.brand_id WHERE br.name = '맘스터치' AND b.name = '화이트갈릭버거');
SET @b_thigh        := (SELECT b.burger_id FROM burger b JOIN brand br ON br.brand_id = b.brand_id WHERE br.name = '맘스터치' AND b.name = '싸이버거');
SET @b_fillet       := (SELECT b.burger_id FROM burger b JOIN brand br ON br.brand_id = b.brand_id WHERE br.name = '맘스터치' AND b.name = '휠렛버거');
SET @b_hamburger    := (SELECT b.burger_id FROM burger b JOIN brand br ON br.brand_id = b.brand_id WHERE br.name = '맥도날드' AND b.name = '햄버거');
SET @b_bigmac       := (SELECT b.burger_id FROM burger b JOIN brand br ON br.brand_id = b.brand_id WHERE br.name = '맥도날드' AND b.name = '빅맥');
SET @b_shushu       := (SELECT b.burger_id FROM burger b JOIN brand br ON br.brand_id = b.brand_id WHERE br.name = '맥도날드' AND b.name = '슈슈버거');
SET @b_deri         := (SELECT b.burger_id FROM burger b JOIN brand br ON br.brand_id = b.brand_id WHERE br.name = '롯데리아' AND b.name = '데리버거');
SET @b_riabulgogi   := (SELECT b.burger_id FROM burger b JOIN brand br ON br.brand_id = b.brand_id WHERE br.name = '롯데리아' AND b.name = '리아 불고기');
SET @b_riashrimp    := (SELECT b.burger_id FROM burger b JOIN brand br ON br.brand_id = b.brand_id WHERE br.name = '롯데리아' AND b.name = '리아 새우');
SET @b_whopper      := (SELECT b.burger_id FROM burger b JOIN brand br ON br.brand_id = b.brand_id WHERE br.name = '버거킹'   AND b.name = '와퍼');
SET @b_whopperjr    := (SELECT b.burger_id FROM burger b JOIN brand br ON br.brand_id = b.brand_id WHERE br.name = '버거킹'   AND b.name = '와퍼주니어');
SET @b_quattro      := (SELECT b.burger_id FROM burger b JOIN brand br ON br.brand_id = b.brand_id WHERE br.name = '버거킹'   AND b.name = '콰트로치즈와퍼');

-- 4. 게시글 12개 (오래된 글부터). 한 쪽에 10개씩이라 목록이 2쪽이 된다. 글 번호는 LAST_INSERT_ID() 로 받아 둔다 ----
INSERT INTO post (member_id, category, title, content, view_count, created_at) VALUES
(@admin, 'TIP', '티어 매기는 기준 정리',
 '티어표가 어떻게 매겨지는지 정리해 둡니다.\n\n- 티어는 저장해 두지 않고 화면을 열 때마다 다시 계산합니다.\n- 기준마다 상위 10%는 S, 30%까지 A, 70%까지 B, 90%까지 C, 나머지는 D입니다.\n- 인기 점수는 추천 수 × 5 + 그 버거가 태그된 글 수 × 3 + 조회수입니다.\n- 영양 정보나 가격이 없는 버거는 그 기준의 티어표에서 빠집니다.\n\n궁금한 점은 댓글로 남겨 주세요.',
 48, @now - INTERVAL 330 HOUR);
SET @pA := LAST_INSERT_ID();

INSERT INTO post (member_id, category, title, content, view_count, created_at) VALUES
(@m2, 'TIP', '단백질 탭 위쪽은 열량도 같이 보세요',
 '운동 끝나고 먹을 버거를 찾다가 단백질 탭을 봤어요. 1위가 버거킹 몬스터 맥시멈3(90g), 2위가 KFC 둠트리플다운(83g)이에요.\n\n다만 위쪽에는 이름에 맥시멈 · 트리플 · 더블이 붙은 큰 메뉴가 많아서 열량도 같이 높아요. 몬스터 맥시멈3은 열량 탭에서 D티어(1,619kcal)더라고요.\n\n저는 단백질 40g인 맘스터치 화이트갈릭버거를 자주 먹습니다.',
 37, @now - INTERVAL 290 HOUR);
SET @pB := LAST_INSERT_ID();

INSERT INTO post (member_id, category, title, content, view_count, created_at) VALUES
(@m4, 'COMBO', '싸이버거 + 치즈감자',
 '맘스터치 가면 싸이버거 단품에 치즈감자를 같이 시켜요.\n짭짤한 치즈감자랑 바삭한 싸이버거가 생각보다 잘 어울립니다. 치즈 좋아하시면 한 번 드셔 보세요.',
 22, @now - INTERVAL 250 HOUR);
SET @pC := LAST_INSERT_ID();

INSERT INTO post (member_id, category, title, content, view_count, created_at) VALUES
(@m3, 'TIP', '가성비 탭 1위는 화이트갈릭버거',
 '가성비 탭은 1,000원당 단백질로 순위를 매겨요. 지금 1위는 맘스터치 화이트갈릭버거(7.3g)이고, 같은 맘스터치 휠렛버거(6.4g)도 S티어예요.\n\n가격 정보가 있는 버거만 순위에 들어가니까, 찾는 버거가 안 보이면 가격 정보가 아직 없는 경우예요.',
 31, @now - INTERVAL 210 HOUR);
SET @pD := LAST_INSERT_ID();

INSERT INTO post (member_id, category, title, content, view_count, created_at) VALUES
(@m1, 'FREE', '다이어트 중이라 열량 탭 S티어만 먹는 중',
 '요즘 열량 탭 S티어에서 하나씩 골라 먹고 있어요. 제일 낮은 건 맥도날드 햄버거(266kcal)이고, 롯데리아 데리버거(348kcal)랑 버거킹 와퍼주니어(376kcal)도 S티어예요.\n\n그런데 데리버거는 단백질 탭에서는 D티어라 그런지 배가 금방 꺼지네요.',
 19, @now - INTERVAL 170 HOUR);
SET @pE := LAST_INSERT_ID();

INSERT INTO post (member_id, category, title, content, view_count, created_at) VALUES
(@m5, 'FREE', '룰렛으로 점심 정했어요',
 '메뉴 고르기 귀찮아서 룰렛에서 롯데리아만 체크하고 6,000원 이하로 돌렸더니 리아 불고기가 나왔어요.\n오랜만에 먹으니 맛있었어요. 결정 못 하시는 분들께 추천합니다.',
 15, @now - INTERVAL 130 HOUR);
SET @pF := LAST_INSERT_ID();

INSERT INTO post (member_id, category, title, content, view_count, created_at) VALUES
(@m2, 'COMBO', '휠렛버거엔 콘샐러드',
 '맘스터치 휠렛버거는 단백질 32g에 포화지방 탭에서도 S티어(4.2g)라 자주 먹어요.\n감자튀김 대신 콘샐러드를 같이 먹으면 덜 느끼해서 좋습니다.',
 12, @now - INTERVAL 100 HOUR);
SET @pG := LAST_INSERT_ID();

INSERT INTO post (member_id, category, title, content, view_count, created_at) VALUES
(@m4, 'FREE', '사이드 티어표도 생겼네요',
 '사이드 · 치킨 · 디저트도 티어표가 생겼어요. 종류를 고르면 그 종류 안에서만 순위를 매겨서 치킨은 치킨끼리, 디저트는 디저트끼리 비교할 수 있어요.\n치즈스틱은 거의 모든 브랜드에 있어서 비교해 보는 재미가 있네요.',
 17, @now - INTERVAL 76 HOUR);
SET @pH := LAST_INSERT_ID();

INSERT INTO post (member_id, category, title, content, view_count, created_at) VALUES
(@m1, 'TIP', '버거 상세에서 글 쓰면 태그가 자동으로 붙어요',
 '버거 상세 화면에서 ''이 버거로 글쓰기''를 누르면 그 버거가 태그된 채로 글쓰기 화면이 열려요.\n태그는 글 하나에 3개까지 달 수 있고, 태그한 글은 그 버거 상세 화면 아래에도 보여요.',
 14, @now - INTERVAL 52 HOUR);
SET @pI := LAST_INSERT_ID();

INSERT INTO post (member_id, category, title, content, view_count, created_at) VALUES
(@m5, 'COMBO', '새우버거엔 코울슬로',
 '새우버거 먹을 때는 코울슬로를 꼭 같이 시켜요. 롯데리아 리아 새우에 코울슬로 조합이 제일 무난했어요.',
 9, @now - INTERVAL 30 HOUR);
SET @pJ := LAST_INSERT_ID();

INSERT INTO post (member_id, category, title, content, view_count, created_at) VALUES
(@m2, 'TIP', '포화지방 탭은 낮을수록 위예요',
 '포화지방 탭은 값이 낮을수록 위에 있어요. 제일 낮은 건 맥도날드 슈슈버거(1.9g)이고, 맨 아래 D티어에는 버거킹 몬스터 맥시멈3(35g)이 있어요.\n''S 티어부터'' 버튼을 누르면 D티어부터 거꾸로 볼 수 있습니다.',
 8, @now - INTERVAL 18 HOUR);
SET @pK := LAST_INSERT_ID();

INSERT INTO post (member_id, category, title, content, view_count, created_at) VALUES
(@m3, 'FREE', '브랜드마다 최애 버거 하나씩 적어 봐요',
 '저는 맘스터치는 휠렛버거, 맥도날드는 빅맥, 버거킹은 와퍼예요.\n다른 브랜드도 댓글로 하나씩 남겨 주세요.',
 21, @now - INTERVAL 6 HOUR);
SET @pL := LAST_INSERT_ID();

-- 5. 버거 태그 (글 하나에 최대 3개) -------------------------------------------------------------------
INSERT INTO post_burger (post_id, burger_id)
SELECT post_id, burger_id
  FROM (SELECT @pB AS post_id, @b_monster3 AS burger_id
        UNION ALL SELECT @pB, @b_doom
        UNION ALL SELECT @pB, @b_whitegarlic
        UNION ALL SELECT @pC, @b_thigh
        UNION ALL SELECT @pD, @b_whitegarlic
        UNION ALL SELECT @pD, @b_fillet
        UNION ALL SELECT @pE, @b_hamburger
        UNION ALL SELECT @pE, @b_deri
        UNION ALL SELECT @pE, @b_whopperjr
        UNION ALL SELECT @pF, @b_riabulgogi
        UNION ALL SELECT @pG, @b_fillet
        UNION ALL SELECT @pI, @b_bigmac
        UNION ALL SELECT @pJ, @b_riashrimp
        UNION ALL SELECT @pK, @b_shushu
        UNION ALL SELECT @pL, @b_fillet
        UNION ALL SELECT @pL, @b_bigmac
        UNION ALL SELECT @pL, @b_whopper) t
 WHERE burger_id IS NOT NULL;

-- 6. 댓글 (글보다 뒤 시각) -------------------------------------------------------------------------------
INSERT INTO post_comment (post_id, member_id, content, created_at) VALUES
(@pA, @m4,    '인기 점수 계산 방식이 궁금했는데 정리 감사합니다.', @now - INTERVAL 320 HOUR),
(@pA, @m1,    '브랜드 필터를 걸어도 티어가 그대로인 게 좋네요. 전체 기준 순위라서 그런 거죠?', @now - INTERVAL 300 HOUR),
(@pA, @admin, '네, 순위는 전체 버거로 매기고 브랜드 필터는 보여 주는 것만 거릅니다.', @now - INTERVAL 298 HOUR),
(@pB, @m3,    '화이트갈릭버거는 가성비 탭에서도 1위라 저도 자주 먹어요.', @now - INTERVAL 280 HOUR),
(@pB, @m1,    '몬스터 맥시멈3은 열량 보고 바로 내려놨어요.', @now - INTERVAL 270 HOUR),
(@pC, @m5,    '치즈감자 조합 인정합니다.', @now - INTERVAL 240 HOUR),
(@pC, @m2,    '싸이버거 단백질도 28g이라 든든해요.', @now - INTERVAL 230 HOUR),
(@pD, @m2,    '휠렛버거는 포화지방도 낮아서 더 좋아요.', @now - INTERVAL 200 HOUR),
(@pD, @m1,    '가격 정보가 없는 버거는 가성비 탭에 안 나오는 거였군요.', @now - INTERVAL 190 HOUR),
(@pE, @m5,    '맥도날드 햄버거가 266kcal밖에 안 되는 줄 몰랐어요.', @now - INTERVAL 160 HOUR),
(@pE, @m3,    '와퍼주니어 저도 자주 먹어요.', @now - INTERVAL 150 HOUR),
(@pF, @m4,    '저도 같은 조건으로 돌렸는데 데리버거 나왔어요.', @now - INTERVAL 120 HOUR),
(@pH, @m3,    '치킨만 따로 순위를 볼 수 있어서 좋네요.', @now - INTERVAL 70 HOUR),
(@pI, @m2,    '몰랐어요. 다음 글부터 이렇게 써야겠네요.', @now - INTERVAL 48 HOUR),
(@pJ, @m1,    '리아 새우에 코울슬로 저도 좋아합니다.', @now - INTERVAL 25 HOUR),
(@pK, @m4,    '슈슈버거가 제일 낮은 건 의외네요.', @now - INTERVAL 15 HOUR),
(@pL, @m1,    '롯데리아는 리아 불고기요.', @now - INTERVAL 5 HOUR),
(@pL, @m2,    'KFC는 징거더블다운이요.', @now - INTERVAL 4 HOUR),
(@pL, @m4,    '버거킹은 콰트로치즈와퍼 고정입니다.', @now - INTERVAL 3 HOUR),
(@pL, @m5,    '노브랜드버거는 그릴드 불고기요.', @now - INTERVAL 2 HOUR),
(@pL, @m3,    '다들 취향이 확실하시네요.', @now - INTERVAL 1 HOUR);

-- 7. 게시글 추천 (자기 글은 추천하지 않는다. 화면에서도 막혀 있다) -----------------------------------------
INSERT INTO post_like (member_id, post_id, created_at) VALUES
(@m1, @pA, @now - INTERVAL 325 HOUR), (@m2, @pA, @now - INTERVAL 318 HOUR), (@m3, @pA, @now - INTERVAL 305 HOUR),
(@m4, @pA, @now - INTERVAL 320 HOUR), (@m5, @pA, @now - INTERVAL 296 HOUR),
(@m3, @pB, @now - INTERVAL 282 HOUR), (@m1, @pB, @now - INTERVAL 271 HOUR), (@m4, @pB, @now - INTERVAL 260 HOUR),
(@m5, @pC, @now - INTERVAL 241 HOUR), (@m2, @pC, @now - INTERVAL 231 HOUR),
(@m2, @pD, @now - INTERVAL 205 HOUR), (@m1, @pD, @now - INTERVAL 191 HOUR), (@m5, @pD, @now - INTERVAL 180 HOUR),
(@m4, @pD, @now - INTERVAL 175 HOUR),
(@m5, @pE, @now - INTERVAL 161 HOUR),
(@m4, @pF, @now - INTERVAL 121 HOUR),
(@m3, @pH, @now - INTERVAL 71 HOUR),
(@m2, @pI, @now - INTERVAL 49 HOUR), (@m3, @pI, @now - INTERVAL 45 HOUR),
(@m1, @pJ, @now - INTERVAL 26 HOUR),
(@m1, @pL, @now - INTERVAL 5 HOUR), (@m2, @pL, @now - INTERVAL 4 HOUR), (@m4, @pL, @now - INTERVAL 3 HOUR);

-- 8. 버거 추천 (인기 탭 점수와 마이페이지 "내가 추천한 버거"에 쓰인다) ------------------------------------
INSERT INTO burger_like (member_id, burger_id, created_at)
SELECT member_id, burger_id, @now - INTERVAL h HOUR
  FROM (SELECT @m1 AS member_id, @b_hamburger AS burger_id, 168 AS h
        UNION ALL SELECT @m1, @b_deri,         167
        UNION ALL SELECT @m1, @b_whopperjr,    166
        UNION ALL SELECT @m1, @b_riabulgogi,   120
        UNION ALL SELECT @m1, @b_bigmac,        60
        UNION ALL SELECT @m2, @b_whitegarlic,  288
        UNION ALL SELECT @m2, @b_thigh,        229
        UNION ALL SELECT @m2, @b_zingerdouble, 150
        UNION ALL SELECT @m2, @b_fillet,        99
        UNION ALL SELECT @m3, @b_whitegarlic,  209
        UNION ALL SELECT @m3, @b_fillet,       208
        UNION ALL SELECT @m3, @b_bigmac,         7
        UNION ALL SELECT @m3, @b_whopper,        7
        UNION ALL SELECT @m4, @b_thigh,        249
        UNION ALL SELECT @m4, @b_quattro,        3
        UNION ALL SELECT @m4, @b_bigmac,         3
        UNION ALL SELECT @m5, @b_riabulgogi,   129
        UNION ALL SELECT @m5, @b_fillet,        98
        UNION ALL SELECT @m5, @b_riashrimp,     29) t
 WHERE burger_id IS NOT NULL;

-- 넣은 결과
SELECT (SELECT COUNT(*) FROM member WHERE member_id IN (@admin, @m1, @m2, @m3, @m4, @m5)) AS 회원,
       (SELECT COUNT(*) FROM post WHERE member_id IN (@admin, @m1, @m2, @m3, @m4, @m5)) AS 게시글,
       (SELECT COUNT(*) FROM post_comment WHERE member_id IN (@admin, @m1, @m2, @m3, @m4, @m5)) AS 댓글,
       (SELECT COUNT(*) FROM post_like WHERE member_id IN (@admin, @m1, @m2, @m3, @m4, @m5)) AS 글추천,
       (SELECT COUNT(*) FROM post_burger WHERE post_id IN (@pA, @pB, @pC, @pD, @pE, @pF, @pG, @pH, @pI, @pJ, @pK, @pL)) AS 버거태그,
       (SELECT COUNT(*) FROM burger_like WHERE member_id IN (@admin, @m1, @m2, @m3, @m4, @m5)) AS 버거추천;
