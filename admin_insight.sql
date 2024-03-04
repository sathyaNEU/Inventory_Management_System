SELECT * FROM ALL_STOCK_INFO;
select name, a.* from products p join all_stock_info a on p.prodid = a.prodid order by p.prodid ;
select * from orders ORDER BY ORDERID;
select * from products;
select * from suppliers;
select * from productorder WHERE ORDERID = 4011;
SELECT * FROM PRODUCTSUPPLY;
select * from user_tables;


select * from user_views;
select * from INV_ORDER_REQUESTS;
SELECT * FROM V$SESSION;

SELECT * FROM V$SESSION;
