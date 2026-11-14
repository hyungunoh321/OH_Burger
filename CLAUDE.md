# OH Burger

국내 프랜차이즈 햄버거 위키 · 티어표 · 꿀팁 커뮤니티. 대학 과제(웹 응용 서비스 개발)이며 혼자 개발한다.
서블릿 + JSP + MySQL 필수, 제출물은 이클립스 프로젝트 압축과 데모 영상(마감 12/14).

## 먼저 읽을 문서

| 문서 | 내용 |
|---|---|
| `docs/기능명세서.md` | 기능 목록(ID), 입력 · 처리 · 예외, 티어 산출 규칙. **구현의 기준** |
| `docs/DB설계.md`, `db/schema.sql` | 테이블 8개, 설계 결정, 티어 계산 SQL |
| `docs/화면설계.md`, `docs/wireframe/` | 화면 구성과 HTML 프로토타입 (CSS · 룰렛 JS 재사용) |
| `docs/개발환경.md` | 설치 경로, 프로젝트 구조, 이클립스에서 여는 법 |

명세와 다르게 구현해야 할 이유가 생기면 코드만 바꾸지 말고 명세 문서도 함께 고친다.

## 기술 규칙

- Tomcat **9** 이므로 `javax.servlet.*` 을 쓴다. `jakarta.servlet` 은 쓰지 않는다.
- Java 21, 패키지 루트는 `ohburger` (`ohburger.common`, `ohburger.web`, DAO · 모델은 필요할 때 하위 패키지 추가).
- MVC: 서블릿이 요청을 받고, DAO가 SQL을 실행하고, JSP는 화면만 그린다.
- JSP는 `src/main/webapp/WEB-INF/views/` 에 두고 서블릿이 forward 한다. JSTL · EL 을 쓰고 스크립틀릿은 피한다.
- 화면 공통부는 `header.jsp`(파라미터 `title`, `menu`) · `footer.jsp` 를 include 한다.
- SQL은 전부 `PreparedStatement`. 사용자 입력 출력은 `<c:out>` 으로 이스케이프한다.
- 로그인 · 작성자 · 관리자 검사는 화면이 아니라 서버(필터 · 서블릿)에서 한다.
- DB 연결은 `ohburger.common.DB.getConnection()` 을 try-with-resources 로 쓴다.
- 티어는 저장하지 않고 조회할 때 SQL `RANK()` 로 계산한다.
- 코드 주석과 문서, 커밋 메시지는 한국어로 쓴다.

## 실행과 확인

이클립스 없이 확인하는 방법 (Claude가 쓰는 방법):

```bash
# 1) 컴파일 (프로젝트 루트에서)
javac -encoding UTF-8 --release 21 -cp "C:\dev\apache-tomcat-9.0.124\lib\servlet-api.jar;src\main\webapp\WEB-INF\lib\*" -d build/classes $(find src/main/java -name '*.java')
cp src/main/java/db.properties build/classes/
# 2) Tomcat 실행: .claude/launch.json 의 "tomcat" (C:\dev\run-tomcat.bat)
# 3) http://localhost:8080/OH_Burger/
```

- Tomcat 의 `conf/Catalina/localhost/OH_Burger.xml` 이 `src/main/webapp` 과 `build/classes` 를 직접 가리킨다. JSP는 저장만 하면 반영되고, Java는 다시 컴파일해야 한다.
- **8080 포트는 이클립스의 Tomcat 과 겹친다.** 사용자가 이클립스에서 서버를 켜 둔 상태면 먼저 꺼 달라고 하거나 끝난 뒤 확인용 Tomcat 을 반드시 종료한다.
- 기능을 만들면 브라우저에서 실제로 눌러 보고 나서 됐다고 말한다.

## DB

- DB 이름 `oh_burger`, MySQL 8.4, 포트 3306. `mysql` 실행 파일은 `C:\Program Files\MySQL\MySQL Server 8.4\bin`.
- 웹 앱은 전용 계정 `ohburger` 로 접속한다 (조회 · 추가 · 수정 · 삭제 권한만). 접속 정보는 `src/main/java/db.properties` (Git 제외).
- 테이블을 바꾸거나 권한이 필요한 작업은 root 로 한다. root 접속 정보는 `CLAUDE.local.md` 에 있다 (Git 제외).
- 스키마를 바꾸면 `db/schema.sql` 과 `docs/DB설계.md` 를 함께 고친다. `schema.sql` 을 다시 실행하면 테이블이 전부 지워지므로 `data_burger.sql` 도 다시 넣어야 한다.
- 한글이 깨지지 않게 `--default-character-set=utf8mb4` 를 붙인다.

## 이클립스 관련 (겪은 문제)

- 이클립스 내장 JRE 는 Java 25 라서 Tomcat 9 실행이 실패했다(`Bootstrap` ClassNotFound). Installed JREs 에 JDK 21 을 등록하고 Tomcat 런타임의 JRE 로 지정해 해결했다.
- 프로젝트 설정(`.project`, `.classpath`, `.settings/`)은 런타임 이름 **`Apache Tomcat v9.0`** 을 찾는다.
- 이클립스 작업 폴더는 `C:\dev\workspace`. 그 안의 `.metadata` 나 `Servers` 설정을 이클립스가 켜져 있을 때 직접 고치지 않는다(다시 쓰여지거나 어긋난다).
- 새 서블릿 · JSP 를 추가해도 이클립스 설정 파일은 고칠 필요가 없다. jar 를 추가할 때는 `WEB-INF/lib` 에 넣으면 된다.

## 데이터 상태

- 버거 160종(7개 브랜드)이 `db/data_burger.sql` 에 있다. 공식 홈페이지에서 2026-11-14 조회.
- **가격은 롯데리아 · KFC 만 있고 121종이 NULL**이다(브랜드가 사이트에 공개하지 않음). 화면에는 "가격 정보 없음", 가격 정렬은 맨 뒤, 룰렛 가격 조건에서는 제외. 채울 목록은 `db/prices_todo.csv`.
- `image_url` 은 전부 비어 있다. 화면에서는 그림 문자 🍔 로 대신한다.
- 맘스터치 · KFC · 노브랜드버거 · 프랭크버거의 영양 정보는 이미지 표를 눈으로 읽어 옮긴 값이라 오타 가능성이 있다.
- 값을 지어내서 채우지 않는다. 모르는 값은 NULL 로 둔다.

## 남은 일 (순서대로)

진행 상태의 기준은 GitHub 이슈다. 아래 목록은 순서를 한눈에 보기 위한 요약이며 괄호 안이 이슈 번호다.

끝난 것: 버거 도감(B-01, `/burgers`), 버거 상세(B-02, `/burgers/detail`), 메인 티어표(T-01, T-02, `/home`) (#1).

1. 회원가입 · 로그인(M-01, M-02), 로그인 검사 필터 (#2), 버거 추천(B-03) (#3). 버거 상세의 추천 버튼은 지금 비활성(disabled) 상태라 여기서 연결한다
2. 게시판(P-01 ~ P-05) (#4), 댓글(C-01, C-02) (#5). 버거 상세의 "전체 보기"(`/posts?burger=`), "이 버거로 글쓰기"(`/posts/write?burger=`) 링크가 이 주소를 가리킨다. `PostDao` 는 버거 상세용 조회만 있다
3. 룰렛(R-01) (#6)
4. 404 · 403 · 500 화면 (#7)
5. 디자인 수정 (#8) (사용자가 현재 디자인이 마음에 들지 않는다고 했고, 기능 구현 뒤에 손보기로 함)
6. 가격 · 이미지 보완 (#9), 데모 영상 시나리오 정리 (#10)

선택 기능(마이페이지 M-03 (#11), 관리자 버거 관리 B-04 (#12))은 시간이 남을 때만 한다.

## 작업 방식

- 기능 하나를 DB → DAO → 서블릿 → JSP 까지 끝내고 다음으로 넘어간다.
- **실무처럼 기능마다 브랜치를 만들고 Pull Request 로 `main` 에 넣는다.** 작업 흔적을 GitHub 에 남기기 위해서다. `main` 에서 직접 작업하거나 로컬에서 `main` 에 merge 하지 않는다. 문서만 고칠 때도 같다(`docs/<내용>` 브랜치).
  1. `main` 을 최신으로 맞추고 `feature/<이슈 번호>-<기능>` 브랜치를 만든다 (예: `feature/2-member-login`).
  2. 작업하고 브라우저에서 확인한 뒤 커밋한다.
  3. 브랜치를 원격에 푸시하고 `gh pr create` 로 PR 을 연다. 본문에 무엇을 했는지, 어떻게 확인했는지, `Closes #번호` 를 적는다.
  4. 사용자가 PR 을 보고 merge 하라고 하면 `gh pr merge --merge --delete-branch` 로 merge 한다. 커밋 이력을 남기기 위해 squash 하지 않는다.
  5. `git switch main && git pull` 로 로컬 `main` 을 맞춘다.
- **할 일은 GitHub 이슈로 관리한다** (저장소 `hyungunoh321/OH_Burger`, 마일스톤 "제출"). 라벨은 `feature` · `design` · `data` · `docs` · `optional`.
  - 작업을 시작할 때 해당 이슈를 확인한다. PR 본문의 `Closes #번호` 로 merge 될 때 이슈가 닫힌다.
  - 새로 생긴 일이나 발견한 버그는 이슈로 등록한다. 이슈 생성 · 수정 · 닫기는 외부에 공개되는 일이므로 사용자가 하라고 할 때 한다.
  - `gh` 는 `C:\Program Files\GitHub CLI\gh.exe` 에 있다 (Git Bash 에서 PATH 에 없으면 전체 경로로 실행).
- 커밋 · 푸시 · PR 생성 · merge 는 사용자가 하라고 할 때만 한다. 커밋 전에 비밀번호나 개인 경로가 들어가지 않았는지 확인한다.
- 외부 사이트의 내부 API 를 직접 호출하지 않는다. 공개 페이지를 브라우저로 읽는 방식만 쓴다.
