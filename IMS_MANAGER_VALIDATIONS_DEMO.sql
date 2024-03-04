set serveroutput on;
ALTER SESSION SET CURRENT_SCHEMA = IMS_ADMIN;


EXECUTE ADD_DISCOUNT('10% OFF', 10);
EXECUTE ADD_DISCOUNT('10% OFF', 20);
EXECUTE ADD_DISCOUNT('20% OFF', 10);

EXECUTE ADD_CATEGORY('LaPToP');
EXECUTE ADD_CATEGORY('laptop');
EXECUTE ADD_CATEGORY('LAPTOP');

EXECUTE ADD_PRODUCT('Ultra-Slim Laptop', 'Sleek and lightweight laptop for on-the-go productivity', 1500.00, 60, 24, 'Apple Inc', 'Laptop', '10% Off');
EXECUTE ADD_PRODUCT('', 'Sleek and lightweight laptop for on-the-go productivity', 1500.00, 60, 24, 'Apple Inc', 'Laptop', '10% Off');
EXECUTE ADD_PRODUCT('Ultra-Slim Laptop123', 'Sleek and lightweight laptop for on-the-go productivity', 1500.00, 60, 24, '', 'Laptop', '10% Off');
EXECUTE ADD_PRODUCT('Ultra-Slim Laptop', 'Sleek and lightweight laptop for on-the-go productivity', -2000, 60, 24, 'Apple Inc', 'Laptop', '10% Off');
EXECUTE ADD_PRODUCT('Ultra-Slim Laptop123', 'Sleek and lightweight laptop for on-the-go productivity', 2000, 60, 24, 'Apple Inc', 'Laptop', '100% Off');
EXECUTE ADD_PRODUCT('Ultra-Slim Laptop123', 'Sleek and lightweight laptop for on-the-go productivity', 1500.00, 60, 24, 'Apple Inc', 'DANGER', '10% Off');
EXECUTE ADD_PRODUCT('Ultra-Slim Laptop9', 'Sleek and lightweight laptop for on-the-go productivity', 1500.00, 60, 24, 'Apple Inc', 'LAPTOP', '');


select * from role_tab_privs;
SELECT * FROM INV_ORDER_REQUESTS;

EXECUTE REFIL_QTY(6001);
EXECUTE REFIL_QTY(6002);

