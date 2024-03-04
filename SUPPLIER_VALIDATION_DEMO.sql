ALTER SESSION SET CURRENT_SCHEMA = IMS_ADMIN;
SET SERVEROUTPUT ON;

select * from role_tab_privs;
select * from role_sys_privs;

select * from SUPPLIER_PRODUCT_PERFORMANCE_VIEW;

EXECUTE GET_SUPPLIER_ORDER_REQ_USING_PRODNAME('Oneplus Technology','Flagship Smartphone');

EXECUTE GET_SUPPLIER_PRODUCT_PERFORMANCE_VIEW('xiaomi@example.com');

SELECT * FROM SUPPLIER_PRODUCT_PERFORMANCE_VIEW ORDER BY TOTAL_ORDERED_AMOUNT DESC;


-- EXCEPTIONS FOR SUPPLIERS --
-- Check if supplier already exists --
EXEC ADD_SUPPLIERS('Samsung Electronics', 'samsung@example.com', 9876543210, 'Samsung-ro 129', 'www.samsung.com', 987654321, '4102', 'Suwon', 'South Korea', '16678');
-- Check null values --
EXEC ADD_SUPPLIERS('Samsung Electronics', '', 9876543210, 'Samsung-ro 129', 'www.samsung.com', 987654321, '4102', 'Suwon', 'South Korea', '16678');
-- Check if length exceeds --
EXEC ADD_SUPPLIERS('Samsung Electronics', 'samsung@example.com', 9876543210, 'apartment no 129dfjskhfsidfsdiufsf', 'www.samsung.com', 987654321, '4102', 'Suwon', 'South Korea', '16678');
-- Check format of emailid --
EXEC ADD_SUPPLIERS('Samsung Electronics', 'abcd', 9876543210, 'Samsung-ro 129', 'www.samsung.com', 987654321, '4102', 'Suwon', 'South Korea', '16678');
-- Check format of contact number --
EXEC ADD_SUPPLIERS('Samsung Electronics', 'samsung@example.com', 9876543, 'Samsung-ro 129', 'www.samsung.com', 987654321, '4102', 'Suwon', 'South Korea', '16678');
-- Check format of itin --
EXEC ADD_SUPPLIERS('Samsung Electronics', 'samsung@example.com', 9876543210, 'Samsung-ro 129', 'www.samsung.com', 9876321, '4102', 'Suwon', 'South Korea', '16678');
-- Check format of unit number --
EXEC ADD_SUPPLIERS('Samsung Electronics', 'samsung@example.com', 9876543210, 'Samsung-ro 129', 'www.samsung.com', 987654321, 'A4109', 'Suwon', 'South Korea', '16678');
-- Check for special characters in city, name, country --
EXEC ADD_SUPPLIERS('Samsung Electronics', 'samsung@example.com', 9876543210, 'Samsung-ro 129', 'www.samsung.com', 987654321, 'A419', 'Suwon*$', 'South Korea', '16678');
-- Check for valid zipcode --
EXEC ADD_SUPPLIERS('Samsung Electronics', 'samsung@example.com', 9876543210, 'Samsung-ro 129', 'www.samsung.com', 987654321, 'A419', 'Suwon', 'South Korea', '16678L');
-- Check for unique constraint on email, contact number, itin, name --
EXEC ADD_SUPPLIERS('Samsung', 'samsung@example.com', 9876543211, 'Samsung-ro 129', 'www.samsung.com', 987654321, 'A419', 'Suwon', 'South Korea', '16678');