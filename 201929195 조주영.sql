-- 프로젝트명: 온라인 서점 데이터베이스 구축
-- 작성일: 2025-12-15
-- 201929195 조주영

-- [1] 기존 테이블 삭제 순서(초기화용)
DROP TABLE ORDER_DETAIL CASCADE CONSTRAINTS;
DROP TABLE ORDERS CASCADE CONSTRAINTS;
DROP TABLE BOOK CASCADE CONSTRAINTS;
DROP TABLE PUBLISHER CASCADE CONSTRAINTS;
DROP TABLE CATEGORY CASCADE CONSTRAINTS;
DROP TABLE MEMBER CASCADE CONSTRAINTS;

-- [2] 테이블 생성 (DDL)
-- 1. 회원 테이블 (MEMBER)
-- 컬럼: 회원ID, 비밀번호, 회원이름, 연락처, 주소, 적립금
CREATE TABLE MEMBER (
    MEM_ID       VARCHAR2(20)  PRIMARY KEY,  -- 회원ID(PK)
    MEM_PW       VARCHAR2(20)  NOT NULL,     -- 비밀번호
    MEM_NAME     VARCHAR2(20)  NOT NULL,     -- 회원이름
    MEM_PHONE    VARCHAR2(13)  NOT NULL,     -- 연락처
    MEM_ADDR     VARCHAR2(100),              -- 주소
    MEM_MILEAGE  NUMBER(10)    DEFAULT 0     -- 적립금 (숫자 10자리)
);

-- 2. 카테고리 테이블 (CATEGORY)
-- 컬럼: 카테고리코드, 카테고리명
CREATE TABLE CATEGORY (
    CAT_CODE     VARCHAR2(4)   PRIMARY KEY,  -- 카테고리코드(PK)
    CAT_NAME     VARCHAR2(20)  NOT NULL      -- 카테고리명
);

-- 3. 출판사 테이블 (PUBLISHER)
-- 컬럼: 출판사코드, 출판사명, 담당자연락처
CREATE TABLE PUBLISHER (
    PUB_CODE     VARCHAR2(6)   PRIMARY KEY,  -- 출판사코드(PK)
    
    PUB_NAME     VARCHAR2(50)  NOT NULL,     -- 출판사명
    PUB_PHONE    VARCHAR2(13)                -- 담당자연락처
);

-- 4. 도서 테이블 (BOOK)
-- 컬럼: ISBN, 도서명, 저자, 가격, 재고수량, 카테고리코드, 출판사코드
CREATE TABLE BOOK (
    ISBN         VARCHAR2(13)  PRIMARY KEY,  -- ISBN(PK)
    BK_TITLE     VARCHAR2(100) NOT NULL,     -- 도서명
    BK_AUTHOR    VARCHAR2(50),               -- 저자
    BK_PRICE     NUMBER(10)    NOT NULL,     -- 가격
    BK_STOCK     NUMBER(5)     DEFAULT 0,    -- 재고수량
    CAT_CODE     VARCHAR2(4),                -- 카테고리코드(FK)
    PUB_CODE     VARCHAR2(6),                -- 출판사코드(FK)
    CONSTRAINT FK_BOOK_CAT FOREIGN KEY (CAT_CODE) REFERENCES CATEGORY(CAT_CODE),
    CONSTRAINT FK_BOOK_PUB FOREIGN KEY (PUB_CODE) REFERENCES PUBLISHER(PUB_CODE)
);

-- 5. 주문 테이블 (ORDERS)
-- 컬럼: 주문번호, 주문일자, 주문상태, 배송지, 총결제금액, 회원ID
CREATE TABLE ORDERS (
    ORD_NO       VARCHAR2(14)  PRIMARY KEY,  -- 주문번호(PK)
    ORD_DATE     DATE          DEFAULT SYSDATE, -- 주문일자
    ORD_STATUS   VARCHAR2(10),               -- 주문상태
    ORD_ADDR     VARCHAR2(200),              -- 배송지
    TOTAL_AMT    NUMBER(10)    NOT NULL,     -- 총결제금액 (숫자 10자리)
    MEM_ID       VARCHAR2(20)  NOT NULL,     -- 회원ID(FK)
    CONSTRAINT FK_ORD_MEM FOREIGN KEY (MEM_ID) REFERENCES MEMBER(MEM_ID)
);

-- 6. 주문 상세 테이블 (ORDER_DETAIL)
-- 컬럼: 순번, 구매수량, 판매가, 주문번호, ISBN
CREATE TABLE ORDER_DETAIL (
    OD_NO        NUMBER        PRIMARY KEY,  -- 순번(PK)
    OD_QTY       NUMBER(3)     NOT NULL,     -- 구매수량
    OD_PRICE     NUMBER(10)    NOT NULL,     -- 판매가
    ORD_NO       VARCHAR2(14)  NOT NULL,     -- 주문번호(FK)
    ISBN         VARCHAR2(13)  NOT NULL,     -- ISBN(FK)
    CONSTRAINT FK_OD_ORD FOREIGN KEY (ORD_NO) REFERENCES ORDERS(ORD_NO),
    CONSTRAINT FK_OD_BK  FOREIGN KEY (ISBN)   REFERENCES BOOK(ISBN)
);

-- [3] 인덱스 설정 (물리적 설계 반영)
-- 이유: 도서 검색 및 기간별 주문 조회의 성능 최적화
CREATE INDEX IDX_BOOK_NAME ON BOOK(BK_TITLE);
CREATE INDEX IDX_ORDER_DATE ON ORDERS(ORD_DATE);

-- [4] 샘플 데이터 입력 (DML)

-- 1. 기초 데이터 (회원, 카테고리, 출판사)
-- 적립금 3000원, 1000원
INSERT INTO MEMBER VALUES ('user01', '1234', '홍길동', '010-1111-2222', '서울시 강남구', 3000);
INSERT INTO MEMBER VALUES ('user02', '5678', '김철수', '010-3333-4444', '부산시 해운대구', 1000);

INSERT INTO CATEGORY VALUES ('NV01', '소설');
INSERT INTO CATEGORY VALUES ('IT01', '컴퓨터/IT');

INSERT INTO PUBLISHER VALUES ('PUB001', '민음사', '02-123-4567');
INSERT INTO PUBLISHER VALUES ('PUB002', '한빛미디어', '02-987-6543');

-- 2. 도서 데이터
INSERT INTO BOOK VALUES ('9788937460', '노르웨이의 숲', '무라카미 하루키', 15000, 100, 'NV01', 'PUB001');
INSERT INTO BOOK VALUES ('9791162240', '이것이 자바다', '신용권', 30000, 50, 'IT01', 'PUB002');

-- 3. 주문 데이터 
-- 홍길동이 30,000원짜리 책을 주문함
INSERT INTO ORDERS VALUES ('20231215001', SYSDATE, '배송중', '서울시 강남구', 30000, 'user01');
INSERT INTO ORDER_DETAIL VALUES (1, 1, 30000, '20231215001', '9791162240');

-- 김철수가 15,000원짜리 책 2권을 주문함
INSERT INTO ORDERS VALUES ('20231215002', SYSDATE, '결제완료', '부산시 해운대구', 30000, 'user02');
INSERT INTO ORDER_DETAIL VALUES (2, 2, 15000, '20231215002', '9788937460');

COMMIT;

-- [5] sql 문제 30가지 이상

-- [시나리오 1: 데이터 확장 (INSERT)]
-- 초기 데이터 외에 다양한 상황 분석을 위해 데이터를 추가한다.

-- Q1. 도서 분류(카테고리) 3개를 추가 등록하시오.
INSERT INTO CATEGORY VALUES ('HM01', '인문');
INSERT INTO CATEGORY VALUES ('EC01', '경제/경영');
INSERT INTO CATEGORY VALUES ('SF01', '과학/SF');

-- Q2. 새로운 출판사 3곳의 정보를 등록하시오.
INSERT INTO PUBLISHER VALUES ('PUB003', '길벗', '02-333-3333');
INSERT INTO PUBLISHER VALUES ('PUB004', '위즈덤하우스', '031-444-4444');
INSERT INTO PUBLISHER VALUES ('PUB005', '김영사', '031-555-5555');

-- Q3. 판매할 신규 도서 5종을 시스템에 등록하시오.
INSERT INTO BOOK VALUES ('9791162242', 'SQL 전문가 가이드', '한국데이터진흥원', 50000, 10, 'IT01', 'PUB003');
INSERT INTO BOOK VALUES ('9788901234', '사피엔스', '유발 하라리', 22000, 20, 'HM01', 'PUB005');
INSERT INTO BOOK VALUES ('9788901236', '돈의 심리학', '모건 하우절', 16000, 50, 'EC01', 'PUB004');
INSERT INTO BOOK VALUES ('9788901237', '트렌드 코리아 2026', '김난도', 18000, 100, 'EC01', 'PUB004');
INSERT INTO BOOK VALUES ('9788901238', '클린 코드', '로버트 C. 마틴', 28000, 25, 'IT01', 'PUB003');

-- Q4. 신규 회원 3명을 추가 등록하시오.
INSERT INTO MEMBER VALUES ('lee', '1234', '이영희', '010-3333-3333', '대구시 수성구', 2000);
INSERT INTO MEMBER VALUES ('park', '1234', '박민수', '010-4444-4444', '광주시 북구', 1000);
INSERT INTO MEMBER VALUES ('choi', '1234', '최지우', '010-5555-5555', '서울시 마포구', 0);

-- Q5. 회원들의 과거 주문 내역(주문서 헤더) 3건을 생성하시오.
INSERT INTO ORDERS VALUES ('20231215003', TO_DATE('2023-12-12','YYYY-MM-DD'), '결제됨', '대구시 수성구', 50000, 'lee');
INSERT INTO ORDERS VALUES ('20231215004', TO_DATE('2023-12-13','YYYY-MM-DD'), '접수됨', '서울시 강남구', 28000, 'user01');
INSERT INTO ORDERS VALUES ('20231215005', TO_DATE('2023-12-14','YYYY-MM-DD'), '결제됨', '서울시 마포구', 16000, 'choi');

-- Q6. 위 주문에 대한 상세 내역(어떤 책을 몇 권 샀는지)을 등록하시오. (PK인 OD_NO는 기존 2번 이후인 3번부터 시작)
INSERT INTO ORDER_DETAIL VALUES (3, 1, 50000, '20231215003', '9791162242'); -- 이영희: SQL가이드
INSERT INTO ORDER_DETAIL VALUES (4, 1, 28000, '20231215004', '9788901238'); -- 홍길동: 클린코드
INSERT INTO ORDER_DETAIL VALUES (5, 1, 16000, '20231215005', '9788901236'); -- 최지우: 돈의심리학

COMMIT;


-- [시나리오 2: 조회 (SELECT)]
-- 사용자와 관리자가 데이터를 검색하는 상황

-- Q7. 등록된 모든 도서의 목록을 도서명 순(오름차순)으로 정렬하여 조회하시오.
SELECT * FROM BOOK ORDER BY BK_TITLE ASC;

-- Q8. 판매 가격이 20,000원 이상인 도서의 제목과 가격을 조회하시오.
SELECT BK_TITLE, BK_PRICE FROM BOOK WHERE BK_PRICE >= 20000;

-- Q9. 재고가 20권 이하로 떨어져 추가 발주가 필요한 도서를 조회하시오.
SELECT BK_TITLE, BK_STOCK FROM BOOK WHERE BK_STOCK <= 20;

-- Q10. 주소가 '서울'인 회원들의 아이디, 이름, 주소를 조회하시오.
SELECT MEM_ID, MEM_NAME, MEM_ADDR FROM MEMBER WHERE MEM_ADDR LIKE '%서울%';

-- Q11. 카테고리 코드가 'IT01'이면서 가격이 30,000원 이상인 도서를 조회하시오.
SELECT BK_TITLE, BK_PRICE FROM BOOK WHERE CAT_CODE = 'IT01' AND BK_PRICE >= 30000;

-- Q12. 현재 배송 상태가 '결제완료'인 주문 건들의 목록을 조회하시오.
SELECT * FROM ORDERS WHERE ORD_STATUS = '결제됨';


-- [시나리오 3: 조인 (JOIN)]
-- 테이블 간의 관계를 활용하여 의미 있는 정보를 추출하는 상황

-- Q13. 모든 도서의 제목과 해당 도서의 카테고리 이름(CAT_NAME)을 함께 조회하시오.
SELECT B.BK_TITLE, C.CAT_NAME
FROM BOOK B
JOIN CATEGORY C ON B.CAT_CODE = C.CAT_CODE;

-- Q14. '민음사'에서 출판한 도서의 제목, 저자, 가격을 조회하시오.
SELECT B.BK_TITLE, B.BK_AUTHOR, B.BK_PRICE
FROM BOOK B
JOIN PUBLISHER P ON B.PUB_CODE = P.PUB_CODE
WHERE P.PUB_NAME = '민음사';

-- Q15. 주문번호 '20231215001'에 포함된 도서의 제목과 구매 수량을 조회하시오.
SELECT B.BK_TITLE, OD.OD_QTY
FROM ORDER_DETAIL OD
JOIN BOOK B ON OD.ISBN = B.ISBN
WHERE OD.ORD_NO = '20231215001';

-- Q16. 회원 '홍길동'이 주문한 모든 주문 날짜와 주문 상태를 조회하시오.
SELECT O.ORD_DATE, O.ORD_STATUS
FROM ORDERS O
JOIN MEMBER M ON O.MEM_ID = M.MEM_ID
WHERE M.MEM_NAME = '홍길동';

-- Q17. 각 주문별로 주문한 회원의 이름과 배송지를 함께 조회하시오.
SELECT O.ORD_NO, M.MEM_NAME, O.ORD_ADDR
FROM ORDERS O
JOIN MEMBER M ON O.MEM_ID = M.MEM_ID;

-- Q18. '컴퓨터/IT' 분야의 책을 주문한 적이 있는 회원의 이름을 중복 없이 조회하시오.
SELECT DISTINCT M.MEM_NAME
FROM MEMBER M
JOIN ORDERS O ON M.MEM_ID = O.MEM_ID
JOIN ORDER_DETAIL OD ON O.ORD_NO = OD.ORD_NO
JOIN BOOK B ON OD.ISBN = B.ISBN
JOIN CATEGORY C ON B.CAT_CODE = C.CAT_CODE
WHERE C.CAT_NAME = '컴퓨터/IT';


-- [시나리오 4: 집계 및 그룹핑 (GROUP BY)]
-- 통계 데이터를 추출하는 상황

-- Q19. 전체 도서의 평균 가격과 총 재고 수량을 조회하시오.
SELECT ROUND(AVG(BK_PRICE), 3) AS AVG_PRICE, SUM(BK_STOCK) AS TOTAL_STOCK FROM BOOK;

-- Q20. 각 출판사별로 등록된 도서가 몇 권인지 조회하시오.
SELECT P.PUB_NAME, COUNT(*) AS BOOK_COUNT
FROM BOOK B
JOIN PUBLISHER P ON B.PUB_CODE = P.PUB_CODE
GROUP BY P.PUB_NAME;

-- Q21. 카테고리별로 가장 비싼 책의 가격은 얼마인지 조회하시오.
SELECT CAT_CODE, MAX(BK_PRICE) AS MAX_PRICE
FROM BOOK
GROUP BY CAT_CODE;

-- Q22. 각 회원별로 총 얼마를 주문했는지(총 주문금액 합계) 조회하시오.
SELECT M.MEM_NAME, SUM(O.TOTAL_AMT) AS TOTAL_SPENT
FROM MEMBER M
JOIN ORDERS O ON M.MEM_ID = O.MEM_ID
GROUP BY M.MEM_NAME;

-- Q23. 일자별 매출액(총결제금액의 합)을 조회하여 매출 추이를 확인하시오.
SELECT ORD_DATE, SUM(TOTAL_AMT) AS DAILY_SALES
FROM ORDERS
GROUP BY ORD_DATE
ORDER BY ORD_DATE;


-- [시나리오 5: 서브쿼리 및 고급 기능]

-- Q24. 전체 도서의 평균 가격보다 비싼 도서의 목록을 조회하시오.
SELECT BK_TITLE, BK_PRICE
FROM BOOK
WHERE BK_PRICE > (SELECT AVG(BK_PRICE) FROM BOOK);

-- Q25. 한 번도 주문을 하지 않은 회원의 ID와 이름을 조회하시오.
SELECT MEM_ID, MEM_NAME
FROM MEMBER
WHERE MEM_ID NOT IN (SELECT MEM_ID FROM ORDERS);

-- Q26. 가장 많은 재고를 보유하고 있는 도서의 정보를 조회하시오.
SELECT * FROM BOOK
WHERE BK_STOCK = (SELECT MAX(BK_STOCK) FROM BOOK);


-- [시나리오 6: 데이터 수정 (UPDATE)]

-- Q27. 회원 'user02'(김철수)가 이사를 갔다. 주소를 '서울시 서초구'로 변경하시오.
UPDATE MEMBER SET MEM_ADDR = '서울시 서초구' WHERE MEM_ID = 'user02';
SELECT * FROM MEMBER WHERE MEM_ID = 'user02';

-- Q28. 물가 상승으로 인해 'IT01' 카테고리 도서들의 가격을 10% 인상하시오.
UPDATE BOOK SET BK_PRICE = BK_PRICE * 1.1 WHERE CAT_CODE = 'IT01';
SELECT * FROM BOOK WHERE CAT_CODE = 'IT01';

-- Q29. 주문번호 '20231215004'의 배송이 시작되었다. 상태를 '배송중'으로 변경하시오.
UPDATE ORDERS SET ORD_STATUS = '배송중' WHERE ORD_NO = '20231215004';
SELECT * FROM ORDERS WHERE ORD_NO = '20231215004';

-- Q30. 회원 'user01'에게 이벤트 당첨 기념으로 적립금 5000원을 추가 지급하시오.
UPDATE MEMBER SET MEM_MILEAGE = MEM_MILEAGE + 5000 WHERE MEM_ID = 'user01';
SELECT * FROM MEMBER WHERE MEM_ID = 'user01';


-- [시나리오 7: 데이터 삭제 (DELETE)]

-- Q31. 주문 상태가 '주문접수'인 상태에서 취소된 주문 상세내역(OD_NO=4)을 삭제하시오.
DELETE FROM ORDER_DETAIL WHERE OD_NO = 4;
SELECT * FROM ORDER_DETAIL;

-- Q32. 상세내역이 삭제된 해당 주문 건(ORD_NO='20231215004') 자체를 삭제하시오.
DELETE FROM ORDERS WHERE ORD_NO = '20231215004';
SELECT * FROM ORDERS;

-- Q33. 재고가 0인 도서 중 판매 계획이 없는 도서 데이터를 삭제하시오. (테스트를 위해 조건만 작성)
DELETE FROM BOOK WHERE BK_STOCK = 0;
SELECT * FROM BOOK;

-- 최종 변경사항 저장
COMMIT;
