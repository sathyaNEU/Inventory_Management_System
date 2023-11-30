SET SERVEROUTPUT ON;

BEGIN 
FOR I IN (
WITH DESIRED_OBJECTS AS (
    SELECT 'PRODUCTSUPPLY'       OBJECT_NAME FROM DUAL
    UNION ALL 
    SELECT 'PRODUCTORDER'        FROM DUAL
    UNION ALL
    SELECT 'PRODUCTS'            FROM DUAL
    UNION ALL
    SELECT 'SUPPLIERS'           FROM DUAL
    UNION ALL 
    SELECT 'ORDERS'              FROM DUAL
    UNION ALL 
    SELECT 'DISCOUNTS'           FROM DUAL
    UNION ALL
    SELECT 'CUSTOMERS'           FROM DUAL
    UNION ALL
    SELECT 'CATEGORIES'          FROM DUAL
    UNION ALL
    SELECT 'CATEGORIES_SEQ'      FROM DUAL
    UNION ALL 
    SELECT 'CUSTOMERS_SEQ'       FROM DUAL
    UNION ALL
    SELECT 'DISCOUNTS_SEQ'       FROM DUAL
    UNION ALL
    SELECT 'ORDERS_SEQ'          FROM DUAL
    UNION ALL 
    SELECT 'SUPPLIERS_SEQ'       FROM DUAL
    UNION ALL 
    SELECT 'PRODUCTS_SEQ'        FROM DUAL
    UNION ALL
    SELECT 'PRODUCTORDER_SEQ'    FROM DUAL
    UNION ALL
    SELECT 'PRODUCTSUPPLY_SEQ'   FROM DUAL  
    )
 SELECT DT.OBJECT_NAME, UO.OBJECT_TYPE FROM DESIRED_OBJECTS DT JOIN USER_OBJECTS UO ON DT.OBJECT_NAME=UO.OBJECT_NAME 
 )
 LOOP
 DBMS_OUTPUT.PUT_LINE('DROP ' || I.OBJECT_TYPE || ' ' || I.OBJECT_NAME);
 EXECUTE IMMEDIATE 'DROP ' || I.OBJECT_TYPE || ' ' || I.OBJECT_NAME ;
 END LOOP;
EXCEPTION
 WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('SOMETHING WENT WRONG');
END;
/

CREATE TABLE categories (
    ctgryid INTEGER NOT NULL,
    name    VARCHAR2(20) NOT NULL UNIQUE,
    CONSTRAINT categories_pk PRIMARY KEY (ctgryid)
);

CREATE TABLE customers (
    custid      INTEGER,
    name        VARCHAR2(20) NOT NULL,
    email       VARCHAR2(40) NOT NULL,
    contactnum  NUMBER(10) NOT NULL,
    addr_street VARCHAR2(20) NOT NULL,
    addr_unit   VARCHAR2(4) NOT NULL,
    city        VARCHAR2(20) NOT NULL,
    country     VARCHAR2(20) DEFAULT 'USA' NOT NULL,
    zip_code    VARCHAR2(6) NOT NULL,
    CONSTRAINT customers_pk PRIMARY KEY (custid),
    CONSTRAINT customers_email_un UNIQUE (email),
    CONSTRAINT customers_contactnum_un UNIQUE (contactnum)
);

CREATE TABLE discounts (
    discid INTEGER NOT NULL,
    value  INTEGER NOT NULL,
    name   VARCHAR2(20) NOT NULL,
    CONSTRAINT discounts_pk PRIMARY KEY (discid)
);

CREATE TABLE orders (
    orderid    INTEGER NOT NULL,
    order_date  DATE DEFAULT SYSDATE NOT NULL,
    billamt    NUMBER(8, 2),
    shipstatus VARCHAR2(10),
    dlvry_date  DATE,
    custid     INTEGER NOT NULL,
    CONSTRAINT orders_pk PRIMARY KEY (orderid),
    CONSTRAINT orders_customers_fk FOREIGN KEY (custid) REFERENCES customers(custid),
    CONSTRAINT DLVRY_ORDER_DT CHECK (dlvry_date >= order_date),
    CONSTRAINT SHIP_STATUS_VAL CHECK (shipstatus IN ('PROCESSING', 'IN-TRANSIT', 'DELIVERED'))
);

CREATE TABLE suppliers (
    supid       INTEGER NOT NULL,
    name        VARCHAR2(20) NOT NULL,
    email       VARCHAR2(40) NOT NULL,
    contactnum  NUMBER(10) NOT NULL,
    addr_street VARCHAR2(20) NOT NULL,
    website     VARCHAR2(20),
    itin        NUMBER(9) NOT NULL,
    addr_unit   VARCHAR2(4) NOT NULL,
    city        VARCHAR2(20) NOT NULL,
    country     VARCHAR2(20) DEFAULT 'USA' NOT NULL,
    zip_code    VARCHAR2(6) NOT NULL,
    CONSTRAINT suppliers_pk PRIMARY KEY (supid),
    CONSTRAINT suppliers_email_un UNIQUE (email),
    CONSTRAINT suppliers_contactnum_un UNIQUE (contactnum)
);

CREATE TABLE products (
    prodid      INTEGER NOT NULL,
    name        VARCHAR2(40) NOT NULL,
    description VARCHAR2(500) NOT NULL,
    price       NUMBER(7, 2) NOT NULL,
    qtyinstock  INTEGER NOT NULL,
    minqty      INTEGER,
    availstatus CHAR(1),
    warranty    INTEGER DEFAULT 3 NOT NULL,
    supid       INTEGER NOT NULL,
    ctgryid     INTEGER NOT NULL,
    reorderqty  INTEGER,
    discid      INTEGER,
    CONSTRAINT products_pk PRIMARY KEY (prodid),
    CONSTRAINT products_categories_fk FOREIGN KEY (ctgryid) REFERENCES categories(ctgryid),
    CONSTRAINT products_discounts_fk FOREIGN KEY (discid) REFERENCES discounts(discid),
    CONSTRAINT products_suppliers_fk FOREIGN KEY (supid) REFERENCES suppliers(supid),
    CONSTRAINT AVAIL_STATUS CHECK (AVAILSTATUS='Y' OR AVAILSTATUS='N' ),
    CONSTRAINT PRICE_GTE_1 CHECK ( PRICE >=1 )
);

CREATE TABLE productorder (
    prodid       INTEGER NOT NULL,
    orderid      INTEGER NOT NULL,
    qty          INTEGER NOT NULL,
    final_price  NUMBER(7, 2),
    prodorder_id INTEGER NOT NULL,
    CONSTRAINT productorder_pk PRIMARY KEY (prodorder_id),
    CONSTRAINT productorder_orders_fk FOREIGN KEY (orderid) REFERENCES orders(orderid),
    CONSTRAINT productorder_products_fk FOREIGN KEY (prodid) REFERENCES products(prodid),
    CONSTRAINT QTY_IN_STOCK_GT_0 CHECK ( qty > 0)
);

CREATE TABLE productsupply (
    productsupply_id INTEGER NOT NULL,
    order_date        DATE DEFAULT SYSDATE NOT NULL,
    prodid           INTEGER NOT NULL,
    status           CHAR(1) DEFAULT 'N',
    refil_date       DATE,
    price            NUMBER(7, 2) NOT NULL,
    CONSTRAINT productsupply_pk PRIMARY KEY (productsupply_id),
    CONSTRAINT productsupply_products_fk FOREIGN KEY (prodid) REFERENCES products(prodid),
    CONSTRAINT RFL_ORDER_DT CHECK (refil_date >= order_date OR refil_date IS NULL)
);

CREATE SEQUENCE categories_seq start with 1000;
CREATE SEQUENCE customers_seq start with 2000;
CREATE SEQUENCE discounts_seq start with 3000;
CREATE SEQUENCE orders_seq start with 4000;
CREATE SEQUENCE suppliers_seq start with 5000;
CREATE SEQUENCE products_seq start with 6000;
CREATE SEQUENCE productorder_seq start with 7000;
CREATE SEQUENCE productsupply_seq start with 8000;

---  Customers Product order View
 
CREATE OR REPLACE VIEW customer_order_view AS
SELECT
    o.orderid AS Orderld,
    o.order_date AS OrderDate,
    (po.qty * (p.price - (p.price * NVL(d.value, 0) / 100))) AS BillAmt,
    o.shipstatus AS ShipStatus,
    o.dlvry_date AS DlvryDate,
    po.qty AS Quantity,
    p.name AS ProductName,
    p.description AS ProductDescription,
    p.price AS ProductPrice,
    p.warranty AS ProductWarranty,
    s.name AS SupplierName,
    c.name AS CategoryName,
    NVL(d.name, 'No Discount') AS DiscountName
FROM
    orders o
JOIN
    productorder po ON o.orderid = po.orderid
JOIN
    products p ON po.prodid = p.prodid
JOIN
    suppliers s ON p.supid = s.supid
JOIN
    categories c ON p.ctgryid = c.ctgryid
LEFT JOIN
    discounts d ON p.discid = d.discid;

-- logistic Admin Order Status
CREATE or REPLACE VIEW logistic_admin_order_status AS
SELECT
    o.orderid,
    o.order_date,  
    o.shipstatus,
    o.dlvry_date,
    c.name AS customer_name,
    c.email AS customer_email,
    c.contactnum AS customer_contact,
    c.city AS customer_city,
    c.country AS customer_country,
     p.name AS ProductName
FROM
    orders o
    JOIN 
    customers c ON o.custid = c.custid
    JOIN
    productorder po ON o.orderid = po.orderid
    JOIN
    products p ON po.prodid = p.prodid;


-- stock report

CREATE or replace VIEW stock_report AS
SELECT
    c.name AS CategoryName,
    p.name AS ProductName,
    p.qtyinstock,
    p.reorderqty,
    CASE WHEN p.qtyinstock <= p.reorderqty THEN 'Restock Needed' ELSE 'In Stock' END AS StockStatus
FROM
    products p
JOIN
    categories c ON p.ctgryid = c.ctgryid;

--Sales Report


CREATE  OR REPLACE VIEW sales_report AS
SELECT
    o.orderid,
    o.order_date,
    c.name AS CustomerName,
    p.name AS ProductName,
    po.qty,
    (po.qty * (p.price - (p.price * NVL(d.value, 0) / 100))) AS BillAmt
FROM
    orders o
JOIN
    customers c ON o.custid = c.custid
JOIN
    productorder po ON o.orderid = po.orderid
JOIN
    products p ON po.prodid = p.prodid
LEFT JOIN
    discounts d ON p.discid = d.discid;



-- Customer Product View

CREATE OR REPLACE VIEW customer_product_view AS
SELECT
    p.prodid,
    p.name AS ProductName,
    p.description AS ProductDescription,
    p.price,
    p.warranty,
    s.name AS SupplierName,
    c.name as CategoryName,
    d.name as DiscName
FROM
    products p
JOIN
    suppliers s ON p.supid = s.supid
JOIN
    categories c ON p.ctgryid = c.ctgryid
Left JOIN
    discounts d ON p.discid = d.discid;
    

--return product id if exist, else returns -1
CREATE OR REPLACE FUNCTION GET_PRODUCT_ID(PI_PNAME VARCHAR) RETURN INTEGER AS 
V_ID INTEGER:=-1;
BEGIN
SELECT PRODID INTO V_ID FROM PRODUCTS WHERE LOWER(NAME) = LOWER(PI_PNAME);
RETURN V_ID;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    RETURN V_ID;
END;
/

-- returns supplier id if exist, else returns -1
CREATE OR REPLACE FUNCTION GET_SUPPLIER_ID_USING_EMAIL(PI_SUPL_EMAIL VARCHAR) RETURN INTEGER AS 
V_ID INTEGER:=-1;
BEGIN
SELECT SUPID INTO V_ID FROM SUPPLIERS WHERE LOWER(EMAIL) = LOWER(PI_SUPL_EMAIL);
RETURN V_ID;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    RETURN V_ID;
END;
/

CREATE OR REPLACE FUNCTION GET_SUPPLIER_ID_USING_NAME(PI_SUPL_NAME VARCHAR) RETURN INTEGER AS 
V_ID INTEGER:=-1;
BEGIN
SELECT SUPID INTO V_ID FROM SUPPLIERS WHERE LOWER(NAME) = LOWER(PI_SUPL_NAME);
RETURN V_ID;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    RETURN V_ID;
END;
/

-- returns customer id if exist, else returns -1
CREATE OR REPLACE FUNCTION GET_CUSTOMER_ID(PI_CUST_EMAIL VARCHAR) RETURN INTEGER AS 
V_ID INTEGER:=-1;
BEGIN
SELECT CUSTID INTO V_ID FROM CUSTOMERS WHERE LOWER(EMAIL) = LOWER(PI_CUST_EMAIL);
RETURN V_ID;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    RETURN V_ID;
END;
/

-- returns discound id if a row exists with (discount) name, else returns -1
CREATE OR REPLACE FUNCTION GET_DISCOUNT_ID_USING_NAME(PI_DISC_NAME VARCHAR) RETURN INTEGER AS 
V_ID INTEGER:=-1;
BEGIN
SELECT DISCID INTO V_ID FROM DISCOUNTS WHERE LOWER(NAME) = LOWER(PI_DISC_NAME);
RETURN V_ID;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    RETURN V_ID;
END;
/

-- returns discound id if a row exists with (discount) value, else returns -1
CREATE OR REPLACE FUNCTION GET_DISCOUNT_ID_USING_VALUE(PI_VALUE INTEGER) RETURN INTEGER AS 
V_ID INTEGER:=-1;
BEGIN
SELECT DISCID INTO V_ID FROM DISCOUNTS WHERE VALUE = PI_VALUE;
RETURN V_ID;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    RETURN V_ID;
END;
/

-- returns category id if category name is found, else returns -1
CREATE OR REPLACE FUNCTION GET_CATEGORY_ID(PI_CTGRY_NAME VARCHAR) RETURN INTEGER AS 
V_ID INTEGER:=-1;
BEGIN
SELECT CTGRYID INTO V_ID FROM CATEGORIES WHERE LOWER(NAME) = LOWER(PI_CTGRY_NAME);
RETURN V_ID;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    RETURN V_ID;
END;
/

-- returns 1 if availstatus is Y, 0 if availstatus is N, -1 if product not found
CREATE OR REPLACE FUNCTION GET_AVAIL_STATUS(PI_NAME VARCHAR) RETURN INTEGER AS
V_ERRM VARCHAR(100);
V_PID PRODUCTS.PRODID%TYPE;
V_NAME PRODUCTS.NAME%TYPE;
V_STATUS CHAR;
CUSTOM_EXCEPTION EXCEPTION;
BEGIN
V_NAME := TRIM(PI_NAME);
IF(V_NAME IS NULL OR LENGTH(V_NAME)=0) THEN
   V_ERRM := 'PRODUCT NAME CANNOT BE NULL OR LENGTH 0';
   RAISE CUSTOM_EXCEPTION;
ELSIF LENGTH(V_NAME)>40 THEN
   V_ERRM := 'PRODUCT NAME CANNOT BE MORE THAN 40 CHARACTERS';
   RAISE CUSTOM_EXCEPTION;
ELSE
   V_PID :=  GET_PRODUCT_ID(PI_NAME);
END IF;
V_PID := GET_PRODUCT_ID(V_NAME);
IF(V_PID!=-1) THEN
    SELECT AVAILSTATUS INTO V_STATUS FROM PRODUCTS WHERE PRODID = V_PID;
    IF V_STATUS = 'Y' THEN
        RETURN 1;
    ELSIF V_STATUS = 'N' THEN 
        RETURN 0;
    END IF;
ELSE 
    RETURN -1;
END IF;
EXCEPTION
WHEN CUSTOM_EXCEPTION THEN
    DBMS_OUTPUT.PUT_LINE(V_ERRM);
END;
/

-- returns -1 if the product is not found, else returns the curernt stock qty of the product 
CREATE OR REPLACE FUNCTION GET_AVAIL_QTY(PI_NAME VARCHAR) RETURN INTEGER AS
V_NAME VARCHAR(500);
V_ERRM VARCHAR(100);
OP INTEGER:=-1;
V_PID PRODUCTS.PRODID%TYPE;
CUSTOM_EXCEPTION EXCEPTION;
BEGIN
V_NAME := PI_NAME;
IF(LENGTH(V_NAME)=0 OR V_NAME IS NULL ) THEN
    V_ERRM := 'PRODUCT NAME CANNOT BE NULL OR EMPTY';
    RAISE CUSTOM_EXCEPTION;
ELSIF LENGTH(V_NAME)>40 THEN
   V_ERRM := 'PRODUCT NAME CANNOT BE MORE THAN 40 CHARACTERS';
   RAISE CUSTOM_EXCEPTION;
END IF;
V_PID := GET_PRODUCT_ID(V_NAME);
IF(V_PID!=-1) THEN 
    SELECT QTYINSTOCK INTO OP FROM PRODUCTS WHERE PRODID = V_PID;
    RETURN OP;
ELSE
    RETURN OP;
END IF;
EXCEPTION
WHEN CUSTOM_EXCEPTION THEN
    DBMS_OUTPUT.PUT_LINE(V_ERRM);
END;
/


-- insert product procedure
CREATE OR REPLACE PROCEDURE ADD_PRODUCT(PI_PNAME VARCHAR, PI_DESC VARCHAR, 
                                        PI_PRICE NUMBER, PI_QTY_IN_STOCK INTEGER, PI_WARRANTY INTEGER, 
                                        PI_SUPL_NAME VARCHAR, PI_CTGRY_NAME VARCHAR, PI_DISC_NAME VARCHAR DEFAULT NULL)
AS 
V_PID INTEGER;
V_SID INTEGER;
V_DISCID INTEGER;
V_CTGRYID INTEGER;
V_CALC_QTY INTEGER;
V_NAME VARCHAR(500);
V_DESC VARCHAR(500);
V_SUPL_NAME VARCHAR(500);
V_CTGRY_NAME VARCHAR(500);
V_SUPLNAME VARCHAR(20);
V_ERRM VARCHAR(100);
CUSTOM_EXCEPTION EXCEPTION;
BEGIN
V_NAME := TRIM(PI_PNAME);
V_DESC := TRIM(PI_DESC);
V_SUPL_NAME := TRIM(PI_SUPL_NAME);
V_CTGRY_NAME := TRIM(PI_CTGRY_NAME);
V_PID := GET_PRODUCT_ID(V_NAME);
V_SID := GET_SUPPLIER_ID_USING_NAME(V_SUPL_NAME);
IF(V_DESC IS NULL) THEN
    V_DISCID := NULL;
ELSE
    V_DISCID := GET_DISCOUNT_ID_USING_NAME(PI_DISC_NAME);
END IF;
V_CTGRYID := GET_CATEGORY_ID(V_CTGRY_NAME);
IF(LENGTH(V_DESC)>500) THEN
   V_ERRM := 'DESCRIPTION CANNOT BE MORE THAN  500 CHARACTERS';
   RAISE CUSTOM_EXCEPTION;
ELSIF(LENGTH(V_DESC)=0 OR V_DESC IS NULL ) THEN
    V_ERRM := 'DESCRIPTION CANNOT BE NULL OR EMPTY';
    RAISE CUSTOM_EXCEPTION;
ELSIF(LENGTH(V_NAME)=0 OR V_NAME IS NULL ) THEN
    V_ERRM := 'PRODUCT NAME CANNOT BE NULL OR EMPTY';
    RAISE CUSTOM_EXCEPTION;
ELSIF LENGTH(V_NAME)>40 THEN
   V_ERRM := 'PRODUCT NAME CANNOT BE MORE THAN 40 CHARACTERS';
   RAISE CUSTOM_EXCEPTION;
ELSIF(PI_PRICE IS NULL) THEN
    V_ERRM := 'PRICE CANNOT BE  NULL';
    RAISE CUSTOM_EXCEPTION;
ELSIF(PI_PRICE<=1) THEN
    V_ERRM := 'PRICE CANNOT BE LESS THAN A DOLLOAR';
    RAISE CUSTOM_EXCEPTION;
ELSIF(PI_QTY_IN_STOCK IS NULL) THEN
    V_ERRM := 'QTY IN STOCK CANNOT BE NULL OR EMPTY';
    RAISE CUSTOM_EXCEPTION;
ELSIF(PI_QTY_IN_STOCK<50) THEN
    V_ERRM := 'QUANTITY IN STOCK SHOULD ATLEAST BE 50';
    RAISE CUSTOM_EXCEPTION;
ELSIF(PI_WARRANTY IS NULL) THEN
    V_ERRM := 'WARRANTY CANNOT BE NULL';
    RAISE CUSTOM_EXCEPTION;
ELSIF(PI_WARRANTY<1) THEN
    V_ERRM := 'WARRANTY SHOULD BE 1 MONTH OR MORE';
    RAISE CUSTOM_EXCEPTION;
ELSIF V_PID!=-1 THEN
    V_ERRM :='PRODUCT NAME ALREADY EXISTS';
    RAISE CUSTOM_EXCEPTION;
ELSIF V_SID=-1 THEN
    V_ERRM :=  'SUPPLIER NAME IS INVALID';
    RAISE CUSTOM_EXCEPTION;
ELSIF V_CTGRYID=-1 THEN
    V_ERRM := 'CATEGORY NAME IS INVALID';
    RAISE CUSTOM_EXCEPTION;
ELSIF V_DISCID=-1 THEN
    V_ERRM := 'DISCOUNT NAME IS INVALID';
    RAISE CUSTOM_EXCEPTION;
END IF;
V_CALC_QTY := CEIL(PI_QTY_IN_STOCK/2);
INSERT INTO PRODUCTS VALUES(products_seq.NEXTVAL, INITCAP(V_NAME), V_DESC, PI_PRICE, PI_QTY_IN_STOCK, V_CALC_QTY, 'Y', PI_WARRANTY, V_SID, V_CTGRYID, V_CALC_QTY , V_DISCID);
COMMIT;
DBMS_OUTPUT.PUT_LINE('PRODUCT ADDED SUCCESSFULLY !');
EXCEPTION
WHEN CUSTOM_EXCEPTION THEN
    DBMS_OUTPUT.PUT_LINE(V_ERRM);
WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE('SOMETHIGN WENT WRONG ' || SQLERRM);
END;
/


CREATE OR REPLACE PROCEDURE UPDATE_PRODUCT_INFO(PI_NAME VARCHAR, PI_DESC VARCHAR, PI_PRICE NUMBER) AS
V_PID INTEGER;
V_NAME VARCHAR(100);
V_DESC VARCHAR(100);
V_ERRM VARCHAR(100);
CUSTOM_EXCEPTION EXCEPTION;
BEGIN
V_NAME := TRIM(PI_NAME);
V_DESC := TRIM(PI_DESC);
IF(LENGTH(V_DESC)>500) THEN
   V_ERRM := 'DESCRIPTION CANNOT BE MORE THAN  500 CHARACTERS';
   RAISE CUSTOM_EXCEPTION;
ELSIF(LENGTH(V_NAME)=0 OR V_NAME IS NULL ) THEN
    V_ERRM := 'PRODUCT NAME CANNOT BE NULL OR EMPTY';
    RAISE CUSTOM_EXCEPTION;
ELSIF LENGTH(V_NAME)>40 THEN
   V_ERRM := 'PRODUCT NAME CANNOT BE MORE THAN 40 CHARACTERS';
   RAISE CUSTOM_EXCEPTION;
ELSIF(PI_PRICE<=1) THEN
    V_ERRM := 'PRICE CANNOT BE LESS THAN A DOLLOAR';
    RAISE CUSTOM_EXCEPTION;
ELSIF V_PID=-1 THEN
    V_ERRM :='PRODUCT NAME NOT FOUND';
END IF;
UPDATE PRODUCTS SET DESCRIPTION = NVL(V_DESC, DESCRIPTION), PRICE = NVL(PI_PRICE, PRICE);
COMMIT;
DBMS_OUTPUT.PUT_LINE('PRODUCT UPDATED SUCCESSFULLY');
EXCEPTION
WHEN CUSTOM_EXCEPTION THEN
    DBMS_OUTPUT.PUT_LINE(V_ERRM);
END;
/

-- insert discount procedure
CREATE OR REPLACE PROCEDURE ADD_DISCOUNT(PI_NAME VARCHAR, PI_VALUE INTEGER) AS
V_DISCID_1 INTEGER;
V_DISCID_2 INTEGER;
V_ERRM VARCHAR(100);
CUSTOM_EXCEPTION EXCEPTION;
V_NAME VARCHAR(20);
BEGIN
V_NAME := TRIM(PI_NAME);
IF(LENGTH(V_NAME)=0 OR V_NAME IS NULL ) THEN
    V_ERRM := 'DISCOUNT NAME CANNOT BE NULL OR EMPTY';
    RAISE CUSTOM_EXCEPTION;
ELSIF(LENGTH(PI_VALUE)=0 OR PI_VALUE IS NULL ) THEN
    V_ERRM := 'DISCOUNT VALUE CANNOT BE NULL OR EMPTY';
    RAISE CUSTOM_EXCEPTION;
ELSIF (PI_VALUE<5) THEN
    V_ERRM := 'DISCOUNT VALUE SHOULD ATLEAST BE 5 PERCENT';
    RAISE CUSTOM_EXCEPTION;
END IF;
V_DISCID_1 := GET_DISCOUNT_ID_USING_NAME(V_NAME);
V_DISCID_2 := GET_DISCOUNT_ID_USING_VALUE(PI_VALUE);
IF(V_DISCID_1!=-1 OR V_DISCID_2!=-1 ) THEN
    V_ERRM := 'DISCOUNT ALEADY EXIST ';
    RAISE CUSTOM_EXCEPTION;
ELSE 
    INSERT INTO DISCOUNTS VALUES(DISCOUNTS_SEQ.NEXTVAL, PI_VALUE, UPPER(V_NAME));
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('DISCOUNT ADDED SUCCESSFULY');
END IF;
EXCEPTION 
WHEN CUSTOM_EXCEPTION THEN
    DBMS_OUTPUT.PUT_LINE(V_ERRM);
END;
/

-- insert category procedure
CREATE OR REPLACE PROCEDURE ADD_CATEGORY(PI_NAME VARCHAR) AS
V_CTGRYID INTEGER;
V_ERRM VARCHAR(100);
V_NAME VARCHAR(20);
CUSTOM_EXCEPTION EXCEPTION;
BEGIN
V_NAME := TRIM(PI_NAME);
IF(LENGTH(V_NAME)=0 OR V_NAME IS NULL ) THEN
    V_ERRM := 'CATEGORY NAME CANNOT BE NULL OR EMPTY';
    RAISE CUSTOM_EXCEPTION;
ELSIF(LENGTH(V_NAME)>20) THEN
    V_ERRM := 'CATEGORY NAME CANNOT BE MORE THAN 20 CHARACTERS';
    RAISE CUSTOM_EXCEPTION;
ELSE
    V_CTGRYID := GET_CATEGORY_ID(V_NAME);
    IF(V_CTGRYID!=-1) THEN 
        V_ERRM := 'CATEGORY NAME ALREADY EXIST';
        RAISE CUSTOM_EXCEPTION;
    ELSE 
        INSERT INTO CATEGORIES VALUES (DISCOUNTS_SEQ.NEXTVAL, INITCAP(V_NAME));
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('CATEGORY ADDED SUCCESSFULY');
    END IF;
END IF;
EXCEPTION
WHEN CUSTOM_EXCEPTION THEN
    DBMS_OUTPUT.PUT_LINE(V_ERRM);
END;
/

-- update availability status of a product ( toggle between Y and N )
CREATE OR REPLACE PROCEDURE UPDATE_AVAIL_STATUS(PI_NAME VARCHAR, PI_STATUS CHAR) AS
V_ERRM VARCHAR(100);
V_PID PRODUCTS.PRODID%TYPE;
V_NAME PRODUCTS.NAME%TYPE;
CUSTOM_EXCEPTION EXCEPTION;
BEGIN
V_NAME := TRIM(PI_NAME);
IF(V_NAME IS NULL OR LENGTH(V_NAME)=0) THEN
    V_ERRM := 'PRODUCT NAME CANNOT BE NULL OR LENGTH 0';
    RAISE CUSTOM_EXCEPTION;
ELSIF LENGTH(V_NAME)>40 THEN
   V_ERRM := 'PRODUCT NAME CANNOT BE MORE THAN 40 CHARACTERS';
   RAISE CUSTOM_EXCEPTION;
ELSE
   V_PID :=  GET_PRODUCT_ID(PI_NAME);
END IF;
IF V_PID!=-1 THEN
    IF(UPPER(PI_STATUS)='Y' OR UPPER(PI_STATUS)='N') THEN
         IF(UPPER(PI_STATUS)='Y') THEN
             UPDATE PRODUCTS SET AVAILSTATUS='Y';
             COMMIT;
             DBMS_OUTPUT.PUT_LINE('PRODUCT IS NOW LIVE');         
         ELSE 
             UPDATE PRODUCTS SET AVAILSTATUS='N';
             COMMIT;
             DBMS_OUTPUT.PUT_LINE('PRODUCT IS NOT AVAILABLE AT THE MOMENT');
         END IF;
    ELSE 
         V_ERRM := 'INVALID FLAG FOR AVAIL STATUS' ;
         RAISE CUSTOM_EXCEPTION;
    END IF;
ELSE 
    V_ERRM := 'PRODUCT NOT FOUND' ;
    RAISE CUSTOM_EXCEPTION;
END IF;
EXCEPTION
WHEN CUSTOM_EXCEPTION THEN
    DBMS_OUTPUT.PUT_LINE(V_ERRM);
END;
/

-- update a product's discount from one value to another or null
CREATE OR REPLACE PROCEDURE UPDATE_PROD_DISC(PI_NAME VARCHAR, PI_DISC_NAME VARCHAR) AS
V_PID PRODUCTS.PRODID%TYPE;
V_NAME PRODUCTS.NAME%TYPE;
V_DISC_NAME VARCHAR(100);
V_ERRM VARCHAR(100);
V_DISCID DISCOUNTS.DISCID%TYPE;
CUSTOM_EXCEPTION EXCEPTION;
BEGIN
V_NAME := TRIM(PI_NAME);
V_DISC_NAME := TRIM(PI_DISC_NAME);
IF(V_NAME IS NULL OR LENGTH(V_NAME)=0) THEN
    V_ERRM := 'PRODUCT NAME CANNOT BE NULL OR LENGTH 0';
    RAISE CUSTOM_EXCEPTION;
ELSIF LENGTH(V_NAME)>40 THEN
   V_ERRM := 'PRODUCT NAME CANNOT BE MORE THAN 40 CHARACTERS';
   RAISE CUSTOM_EXCEPTION;
ELSE
   V_PID :=  GET_PRODUCT_ID(PI_NAME);
   IF V_PID=-1 THEN
         V_ERRM := 'PRODUCT NOT FOUND' ;
        RAISE CUSTOM_EXCEPTION;  
   END IF;
END IF;
IF(V_DISC_NAME IS NULL OR LENGTH(V_DISC_NAME)=0) THEN
    V_ERRM := 'DISCOUNT DISSOCIATED SUCCESSFULLY';
    UPDATE PRODUCTS SET DISCID = NULL WHERE PRODID = V_PID;
    COMMIT;
    RAISE CUSTOM_EXCEPTION;
ELSIF LENGTH(V_DISC_NAME)>40 THEN
   V_ERRM := 'DISCOUNT NAME CANNOT BE MORE THAN 20 CHARACTERS';
   RAISE CUSTOM_EXCEPTION;
ELSE
   V_DISCID := GET_DISCOUNT_ID_USING_NAME(PI_DISC_NAME);
   IF V_DISCID=-1 THEN
        V_ERRM := 'DISCOUNT ID NOT FOUND';
        RAISE CUSTOM_EXCEPTION;
   END IF;
END IF;
UPDATE PRODUCTS SET DISCID = V_DISCID WHERE PRODID = V_PID;
COMMIT;
DBMS_OUTPUT.PUT_LINE('DISCOUNT REFERENCED SUCCESSFULLY');
EXCEPTION
WHEN CUSTOM_EXCEPTION THEN
    DBMS_OUTPUT.PUT_LINE(V_ERRM);
END;
/


CREATE OR REPLACE PROCEDURE TOGGLE_SHIP_STATUS_UP(PI_OID INTEGER) AS
V_OID ORDERS.ORDERID%TYPE;
BEGIN
IF(PI_OID IS NULL OR PI_OID = '') THEN
    DBMS_OUTPUT.PUT_LINE('ORDER ID CANNOT BE NULL OR EMPTY');
END IF;
SELECT ORDERID INTO V_OID FROM ORDERS WHERE ORDERID = PI_OID;
UPDATE ORDERS SET SHIPSTATUS = (CASE WHEN SHIPSTATUS = 'PROCESSING' THEN 'IN-TRANSIT' 
                                     WHEN SHIPSTATUS = 'IN-TRANSIT' THEN 'DELIVERED' 
                                     WHEN SHIPSTATUS = 'DELIVERED' THEN 'DELIVERED' END) 
                                WHERE ORDERID = V_OID;
COMMIT;
DBMS_OUTPUT.PUT_LINE('ORDER UPDATED');
EXCEPTION
WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('ORDER ID NOT FOUND');
END;
/


CREATE OR REPLACE PROCEDURE TOGGLE_SHIP_STATUS_DOWN(PI_OID INTEGER) AS
V_OID ORDERS.ORDERID%TYPE;
BEGIN
IF(PI_OID IS NULL OR PI_OID = '') THEN
    DBMS_OUTPUT.PUT_LINE('ORDER ID CANNOT BE NULL OR EMPTY');
END IF;
SELECT ORDERID INTO V_OID FROM ORDERS WHERE ORDERID = PI_OID;
UPDATE ORDERS SET SHIPSTATUS = (CASE WHEN SHIPSTATUS = 'DELIVERED' THEN 'IN-TRANSIT' 
                                     WHEN SHIPSTATUS = 'IN-TRANSIT' THEN 'PROCESSING' 
                                     WHEN SHIPSTATUS = 'PROCESSING' THEN 'PROCESSING' END) 
                                WHERE ORDERID = V_OID;
COMMIT;
DBMS_OUTPUT.PUT_LINE('ORDER UPDATED');
EXCEPTION
WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('ORDER ID NOT FOUND');
END;
/







