# OH Burger

국내 프랜차이즈 햄버거 위키 · 티어표 · 꿀팁 커뮤니티.

맥도날드, 버거킹, 롯데리아, 맘스터치, KFC, 노브랜드버거, 프랭크버거 7개 브랜드의 버거 160종을 한곳에서 찾아보고,
기준별 티어표로 비교하고, 꿀조합과 꿀팁을 나누는 웹 서비스다. 대학 "웹 응용 서비스 개발" 과목의 개인 과제로 만들었다.

## 주요 기능

| 분류 | 기능 | 주소 |
|---|---|---|
| 티어표 | 인기 · 단백질 · 열량 · 포화지방 · 가성비 5종 티어표(S ~ D), 브랜드 필터, 정렬 방향 전환 | `/home` |
| 사이드 티어표 | 사이드 · 치킨 · 디저트의 단백질 · 열량 · 포화지방 · 가성비 티어표, 종류 · 브랜드 필터 | `/sides/tier` |
| 버거 도감 | 이름 검색, 브랜드 · 패티 필터, 정렬 | `/burgers` |
| 버거 상세 | 가격 · 영양 정보, 티어, 추천, 이 버거가 태그된 글 | `/burgers/detail?id=` |
| 게시판 | 꿀조합 · 꿀팁 · 자유 글 목록 · 작성 · 수정 · 삭제 · 추천, 버거 태그, 댓글 | `/posts` |
| 룰렛 | 브랜드 · 패티 · 가격 · 열량 조건에 맞는 버거 중 하나를 무작위로 뽑는다 | `/roulette` |
| 회원 | 회원가입, 로그인 · 로그아웃, 마이페이지(내 글, 내가 추천한 버거) | `/join`, `/login`, `/mypage` |
| 관리자 | 버거 등록 · 수정 · 삭제 | `/admin/burgers` |

티어는 DB 에 저장하지 않고 조회할 때 SQL `RANK()` 로 계산한다. 산출 규칙은 [기능명세서](docs/기능명세서.md)에 있다.

## 기술 스택

| 항목 | 내용 |
|---|---|
| 언어 | Java 21 |
| 서버 | Apache Tomcat 9 (서블릿 4.0, `javax.servlet`) |
| 화면 | JSP, JSTL 1.2, EL, HTML · CSS · JavaScript (프레임워크 없음) |
| DB | MySQL 8.4, MySQL Connector/J 9.7.0, Tomcat JDBC 연결 풀 |
| 개발 도구 | Eclipse (Dynamic Web Project) |

구조는 MVC 다. 서블릿이 요청을 받고, DAO 가 SQL 을 실행하고, JSP 는 화면만 그린다.

## 폴더 구조

```
OH_Burger/
├─ src/main/java/
│  ├─ ohburger/common/        DB 연결, 필터(인코딩 · CSRF · 로그인 · 관리자), 공통 기능
│  ├─ ohburger/dao/           DAO (SQL)
│  ├─ ohburger/model/         모델
│  ├─ ohburger/web/           서블릿, 입력 검사
│  └─ db.properties.example   DB 접속 정보 양식
├─ src/main/webapp/
│  ├─ css/, js/               정적 파일
│  └─ WEB-INF/
│     ├─ web.xml              필터 순서, 오류 화면
│     ├─ lib/                 라이브러리 jar
│     ├─ tags/                JSP 태그 파일
│     └─ views/               JSP (서블릿이 forward)
├─ db/                        스키마와 초기 데이터 SQL
└─ docs/                      설계 문서, HTML 프로토타입, 제안서
```

## 실행 방법

준비물: JDK 21, Tomcat 9, MySQL 8, Eclipse (Enterprise Java and Web Developers).

### 1. DB 만들기

저장소 루트에서 실행한다. `schema.sql` 은 `oh_burger` DB 의 테이블을 지우고 다시 만든다.

```bash
mysql -u root -p --default-character-set=utf8mb4 -e "source db/schema.sql"
```

버거와 사이드 메뉴 데이터를 넣는다. 둘 다 `schema.sql` 이 넣은 브랜드를 쓰므로 그 다음에 실행한다.

```bash
mysql -u root -p --default-character-set=utf8mb4 -e "source db/data_burger.sql"
```

```bash
mysql -u root -p --default-character-set=utf8mb4 -e "source db/data_side.sql"
```

웹 앱이 쓸 전용 계정을 만든다.

```sql
CREATE USER 'ohburger'@'localhost' IDENTIFIED BY '비밀번호';
GRANT SELECT, INSERT, UPDATE, DELETE ON oh_burger.* TO 'ohburger'@'localhost';
```

### 2. 접속 정보 넣기

`src/main/java/db.properties.example` 을 같은 폴더에 `db.properties` 로 복사하고 위에서 정한 비밀번호를 적는다.
`db.properties` 는 Git 에 올라가지 않는다.

### 3. 이클립스에서 실행

1. `Window > Preferences > Server > Runtime Environments` 에서 Tomcat 9 를 **`Apache Tomcat v9.0`** 이라는 이름으로 등록한다.
2. `File > Import > General > Existing Projects into Workspace` 로 이 폴더를 불러온다.
3. 프로젝트를 우클릭해 `Run As > Run on Server` 를 누른다.
4. 브라우저에서 `http://localhost:8080/OH_Burger/` 를 연다.

자세한 설치 경로와 겪은 문제는 [개발환경](docs/개발환경.md)에 있다.

### 관리자 계정

관리자는 화면에서 만들 수 없다. 회원가입을 한 뒤 root 로 권한을 바꾼다.

```sql
UPDATE member SET role = 'ADMIN' WHERE login_id = '아이디';
```

## 문서

| 문서 | 내용 |
|---|---|
| [기능명세서](docs/기능명세서.md) | 기능 목록, 입력 · 처리 · 예외, 티어 산출 규칙 |
| [DB설계](docs/DB설계.md) | 테이블 8개, 설계 결정, 티어 계산 SQL |
| [화면설계](docs/화면설계.md) | 화면 구성, 화면 흐름, 디자인 기준 |
| [개발환경](docs/개발환경.md) | 설치 경로, 이클립스에서 여는 법 |
| [프로토타입](docs/wireframe/) | 구현 전에 만든 HTML 화면 |

## 데이터 출처와 한계

- 버거 160종의 이름 · 영양 정보 · 사진 주소는 각 브랜드 공식 홈페이지에서 2026-11-14 에 조회했다.
- 가격은 107종에만 있다. 롯데리아 · KFC 는 공식 사이트 값이고, 맥도날드 · 버거킹 · 맘스터치 · 노브랜드버거(2종)는 나무위키와 기사에서 옮긴 매장 가격이라 최신 값과 다를 수 있다. 나머지 53종은 확인하지 못해 "가격 정보 없음"으로 나온다. 출처는 `db/data_burger.sql` 의 주석에 있다.
- 버거 사진은 파일로 저장하지 않고 공식 사이트의 주소를 그대로 불러온다. 인터넷이 없거나 주소가 바뀌면 CSS 로 그린 버거 표시가 대신 나온다.
- 상표와 제품 사진의 권리는 각 브랜드에 있다. 이 프로젝트는 학습용이며 상업적으로 쓰지 않는다.
