SELECT
    product_name, 
    brand_name, 
    list_price
FROM
    production.products p
INNER JOIN production.brands b 
        ON b.brand_id = p.brand_id;


-- View Syntax 


--CREATE VIEW view_name
--AS
-- Query



CREATE VIEW production.vw_product_info
AS
SELECT
    product_name, 
    brand_name, 
    list_price
FROM
    production.products p
INNER JOIN production.brands b 
        ON b.brand_id = p.brand_id;

select * from production.vw_product_info;

-- Materialized View (indexed views)
-- Refresh -- cron 


CREATE VIEW sales.daily_sales
AS
SELECT
    year(order_date) AS y,
    month(order_date) AS m,
    day(order_date) AS d,
    p.product_id,
    product_name,
    quantity * i.list_price AS sales
FROM
    sales.orders AS o
INNER JOIN sales.order_items AS i
    ON o.order_id = i.order_id
INNER JOIN production.products AS p
    ON p.product_id = i.product_id;


select * from sales.daily_sales
where y = 2016


CREATE VIEW sales.vw_staff_sales (
        first_name, 
        last_name,
        year, 
        amount
)
AS 
    SELECT 
        first_name,
        last_name,
        YEAR(order_date),
        SUM(list_price * quantity) amount
    FROM
        sales.order_items i
    INNER JOIN sales.orders o
        ON i.order_id = o.order_id
    INNER JOIN sales.staffs s
        ON s.staff_id = o.staff_id
    GROUP BY 
        first_name, 
        last_name, 
        YEAR(order_date);


select * from sales.vw_staff_sales


-- COALESCE
SELECT 
    COALESCE(NULL, 'Hi', 'Hello', NULL) result;

	-- COALESCE
SELECT 
    COALESCE(NULL, NULL, 'Hello', NULL) result;

--At least one of the arguments to COALESCE must be an expression that is not the NULL constant.
SELECT 
    COALESCE(NULL, NULL, NULL, NULL) result;

--
SELECT 
    first_name, 
    last_name, 
    phone, 
    email
FROM 
    sales.customers
ORDER BY 
    first_name, 
    last_name;

SELECT 
    first_name, 
    last_name, 
    COALESCE(phone,'unknown') phone, 
    email
FROM 
    sales.customers
ORDER BY 
    first_name, 
    last_name;

