from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, Float, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session

# 가상환경 설정 명령어 venv\Scripts\activate
# 서버 실행 명령어 uvicorn main:app --reload
# 1. 데이터베이스 연결 설정
# 주의: 'root:1234' 부분에 본인 MySQL 비밀번호를 넣으세요!
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://root:0000@localhost:3306/OH_Burger"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# 2. 햄버거 테이블 모델 정의 (DB 테이블이랑 똑같이 생겨야 함)
class Burger(Base):
    __tablename__ = "burgers"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100))
    brand = Column(String(50))
    price = Column(Integer)
    image_url = Column(String(500))
    tier = Column(String(10))
    calories = Column(Integer)
    carbs = Column(Float)
    protein = Column(Float)
    fat = Column(Float)
    description = Column(Text)

# 3. FastAPI 앱 생성
app = FastAPI()

# 4. CORS 설정 (프론트엔드 React가 데이터를 가져갈 수 있게 허용)
origins = [
    "http://localhost:5173", # Vite(React) 기본 포트
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 5. DB 세션 도구 (요청 올 때마다 DB 문 열고, 끝나면 닫음)
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# === 여기서부터 API 주소(URL) 만들기 ===

# 기본 접속 테스트
@app.get("/")
def read_root():
    return {"message": "OH! Burger 서버가 정상적으로 실행 중입니다! 🍔"}

# 햄버거 목록 전체 조회 API
@app.get("/burgers")
def read_burgers(db: Session = Depends(get_db)):
    # DB에서 Burger 데이터를 모두(.all()) 가져와라
    return db.query(Burger).all()