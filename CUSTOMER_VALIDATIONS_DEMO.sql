ALTER SESSION SET CURRENT_SCHEMA = IMS_ADMIN;
SET SERVEROUTPUT ON;



declare
    v_orderid_1 integer;
begin
    insert_order('JOHN@example.com',SYSDATE, v_orderid_1);
    InsertProductOrder('Flagship Smartphone', v_orderid_1,  99);
    InsertProductOrder('Gaming Laptop', 4011,  48);
    InsertProductOrder('Convertible Laptop', v_orderid_1,  40);
end;
/

EXECUTE InsertProductOrder('Gaming Laptop', 4010,  2);
EXECUTE UPDATE_PRODUCT_QUANTITY(4010, 'Gaming Laptop', 2);
SELECT * FROM ROLE_TAB_PRIVS;


declare
    v_orderid_1 integer;
begin
    insert_order('john@example.com',SYSDATE, v_orderid_1);
    InsertProductOrder('Flagship Smartphone', v_orderid_1,  1);
end;
/

declare
    v_orderid_1 integer;
begin
    insert_order('john@example.com',SYSDATE, v_orderid_1);
    InsertProductOrder('Flagship Smartphone', v_orderid_1, 1);
end;
/

---- BAD DATA FOR CUSTOMERS----
--CUSTOMER ALREADY EXISTS--
EXEC  ADD_CUSTOMERS('Olivia Smith', 'olivia@example.com', 8889990000, '567 Oak St', '220', 'Austin', 'United States', '73301');
 
--NULL EXCEPTION--
EXEC ADD_CUSTOMERS('Olivia Smith', 'olivia@example.com', 8889990000, '567 Oak St', '220', 'Austin', 'United States', '73301');
 
--LENGTH EXCEPTION--
EXEC  ADD_CUSTOMERS('Olivia Smith', 'olivia@example.com', 888999000, '567 Oak St', '220', 'Austin', 'United States', '73301');
 
--TYPE EXCEPTION ZIPCODE--
EXEC ADD_CUSTOMERS('Olivia Smith', 'olivia@example.com', 8889990000, '567 Oak St', '220', 'Austin', 'United States', '7330d');
 
--TYPE EXCEPTION CITY--
EXEC ADD_CUSTOMERS('Olivia Smith', 'olivia@example.com', 8889990000, '567 Oak St', '220', 'Aust5!', 'United States', '73301');
 
--TYPE CONTACT NUM--
EXEC ADD_CUSTOMERS('Olivia Smith', 'olivia@example.com', 88899900, '567 Oak St', '220', 'Austin', 'United States', '73301');
 
--TYPE UNIT NUMBER--
EXEC ADD_CUSTOMERS('Olivia Smith', 'olivia@example.com', 8889990000, '567 Oak St', 'a2208', 'Austin', 'United States', '73301');
 
--TYPE EMAIL--
EXEC ADD_CUSTOMERS('Olivia Smith', 'oliviaexamplecom', 8889990000, '567 Oak St', '220', 'Austin', 'United States', '73301');
 
-- UNIQUE CONSTRAINT CONTACT NUMBER--
EXEC ADD_CUSTOMERS('Olivia Smith', 'olivia1@example.com', 8889990000, '567 Oak St', '220', 'Austin', 'United States', '73301');

