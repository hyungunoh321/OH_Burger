-- OH Burger 스키마 (MySQL 8.0 이상)
-- 실행: mysql -u root -p < db/schema.sql

CREATE DATABASE IF NOT EXISTS oh_burger
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE oh_burger;

-- 자식 테이블부터 삭제 (다시 실행할 수 있게)
DROP TABLE IF EXISTS post_comment;
DROP TABLE IF EXISTS post_like;
DROP TABLE IF EXISTS post_burger;
DROP TABLE IF EXISTS post;
DROP TABLE IF EXISTS burger_like;
DROP TABLE IF EXISTS burger;
DROP TABLE IF EXISTS side_menu;
DROP TABLE IF EXISTS brand;
DROP TABLE IF EXISTS member;

-- 회원
CREATE TABLE member (
  member_id     INT          NOT NULL AUTO_INCREMENT,
  login_id      VARCHAR(20)  NOT NULL,
  password_hash CHAR(64)     NOT NULL COMMENT 'SHA-256(salt + 비밀번호) 16진수',
  salt          CHAR(32)     NOT NULL COMMENT '회원별 무작위 값 16진수',
  nickname      VARCHAR(10)  NOT NULL,
  role          ENUM('USER', 'ADMIN') NOT NULL DEFAULT 'USER',
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (member_id),
  UNIQUE KEY uk_member_login_id (login_id),
  UNIQUE KEY uk_member_nickname (nickname)
) ENGINE = InnoDB;

-- 브랜드
CREATE TABLE brand (
  brand_id INT          NOT NULL AUTO_INCREMENT,
  name     VARCHAR(30)  NOT NULL,
  logo_url VARCHAR(255) NULL,
  PRIMARY KEY (brand_id),
  UNIQUE KEY uk_brand_name (name)
) ENGINE = InnoDB;

-- 버거 (단품 기준). 브랜드가 공개하지 않은 영양 정보는 NULL
CREATE TABLE burger (
  burger_id    INT           NOT NULL AUTO_INCREMENT,
  brand_id     INT           NOT NULL,
  name         VARCHAR(60)   NOT NULL,
  description  VARCHAR(500)  NULL,
  image_url    VARCHAR(255)  NULL,
  patty_type   ENUM('BEEF', 'CHICKEN', 'SEAFOOD', 'ETC') NOT NULL DEFAULT 'ETC',
  price        INT           NULL COMMENT '단품 가격(원)',
  weight_g     INT           NULL,
  calories_kcal INT          NULL,
  protein_g    DECIMAL(5, 1) NULL,
  sat_fat_g    DECIMAL(5, 1) NULL,
  sugar_g      DECIMAL(5, 1) NULL,
  sodium_mg    INT           NULL,
  view_count   INT           NOT NULL DEFAULT 0,
  created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (burger_id),
  UNIQUE KEY uk_burger_brand_name (brand_id, name),
  CONSTRAINT fk_burger_brand FOREIGN KEY (brand_id) REFERENCES brand (brand_id)
) ENGINE = InnoDB;

-- 버거 추천 (회원 1명이 버거 1개에 1회)
CREATE TABLE burger_like (
  member_id  INT      NOT NULL,
  burger_id  INT      NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (member_id, burger_id),
  KEY idx_burger_like_burger (burger_id),
  CONSTRAINT fk_burger_like_member FOREIGN KEY (member_id) REFERENCES member (member_id) ON DELETE CASCADE,
  CONSTRAINT fk_burger_like_burger FOREIGN KEY (burger_id) REFERENCES burger (burger_id) ON DELETE CASCADE
) ENGINE = InnoDB;

-- 사이드 메뉴 (사이드 · 치킨 · 디저트, 음료 제외). 열은 burger 와 같고 패티 종류 대신 종류(kind)를 둔다.
-- 사이즈 · 조각 수가 여러 개인 메뉴는 기본 사이즈 한 줄만 넣는다 (DB설계.md 5번)
CREATE TABLE side_menu (
  side_id       INT           NOT NULL AUTO_INCREMENT,
  brand_id      INT           NOT NULL,
  name          VARCHAR(60)   NOT NULL,
  description   VARCHAR(500)  NULL,
  image_url     VARCHAR(255)  NULL,
  kind          ENUM('SIDE', 'CHICKEN', 'DESSERT') NOT NULL DEFAULT 'SIDE' COMMENT '사이드 / 치킨 / 디저트',
  price         INT           NULL COMMENT '단품 가격(원)',
  weight_g      INT           NULL,
  calories_kcal INT           NULL,
  protein_g     DECIMAL(5, 1) NULL,
  sat_fat_g     DECIMAL(5, 1) NULL,
  sugar_g       DECIMAL(5, 1) NULL,
  sodium_mg     INT           NULL,
  view_count    INT           NOT NULL DEFAULT 0,
  created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (side_id),
  UNIQUE KEY uk_side_menu_brand_name (brand_id, name),
  KEY idx_side_menu_kind (kind),
  CONSTRAINT fk_side_menu_brand FOREIGN KEY (brand_id) REFERENCES brand (brand_id)
) ENGINE = InnoDB;

-- 게시글
CREATE TABLE post (
  post_id    INT          NOT NULL AUTO_INCREMENT,
  member_id  INT          NOT NULL,
  category   ENUM('COMBO', 'TIP', 'FREE') NOT NULL COMMENT '꿀조합 / 꿀팁 / 자유',
  title      VARCHAR(100) NOT NULL,
  content    TEXT         NOT NULL,
  view_count INT          NOT NULL DEFAULT 0,
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME     NULL,
  PRIMARY KEY (post_id),
  KEY idx_post_category_created (category, created_at),
  KEY idx_post_member (member_id),
  CONSTRAINT fk_post_member FOREIGN KEY (member_id) REFERENCES member (member_id)
) ENGINE = InnoDB;

-- 게시글에 태그된 버거 (글 하나에 최대 3개, 개수 제한은 서버 코드에서 검사)
CREATE TABLE post_burger (
  post_id   INT NOT NULL,
  burger_id INT NOT NULL,
  PRIMARY KEY (post_id, burger_id),
  KEY idx_post_burger_burger (burger_id),
  CONSTRAINT fk_post_burger_post   FOREIGN KEY (post_id)   REFERENCES post (post_id)     ON DELETE CASCADE,
  CONSTRAINT fk_post_burger_burger FOREIGN KEY (burger_id) REFERENCES burger (burger_id) ON DELETE CASCADE
) ENGINE = InnoDB;

-- 게시글 추천 (회원 1명이 글 1개에 1회)
CREATE TABLE post_like (
  member_id  INT      NOT NULL,
  post_id    INT      NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (member_id, post_id),
  KEY idx_post_like_post (post_id),
  CONSTRAINT fk_post_like_member FOREIGN KEY (member_id) REFERENCES member (member_id) ON DELETE CASCADE,
  CONSTRAINT fk_post_like_post   FOREIGN KEY (post_id)   REFERENCES post (post_id)     ON DELETE CASCADE
) ENGINE = InnoDB;

-- 댓글
CREATE TABLE post_comment (
  comment_id INT          NOT NULL AUTO_INCREMENT,
  post_id    INT          NOT NULL,
  member_id  INT          NOT NULL,
  content    VARCHAR(500) NOT NULL,
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (comment_id),
  KEY idx_post_comment_post (post_id, created_at),
  CONSTRAINT fk_post_comment_post   FOREIGN KEY (post_id)   REFERENCES post (post_id) ON DELETE CASCADE,
  CONSTRAINT fk_post_comment_member FOREIGN KEY (member_id) REFERENCES member (member_id)
) ENGINE = InnoDB;

-- 기본 데이터: 브랜드 7곳
INSERT INTO brand (name) VALUES
  ('맥도날드'),
  ('버거킹'),
  ('롯데리아'),
  ('맘스터치'),
  ('KFC'),
  ('노브랜드버거'),
  ('프랭크버거');
