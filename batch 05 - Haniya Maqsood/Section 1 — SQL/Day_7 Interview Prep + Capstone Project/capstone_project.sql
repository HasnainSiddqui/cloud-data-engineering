-- ============================================================
--  RETAILMART — SQL CAPSTONE PROJECT
--  Industry : Retail (3-store chain)
--  Duration : 3 Hours
--  Covers   : DDL, DML, SELECT, JOINs, GROUP BY,  Subqueries, 
--             UNION/INTERSECT/EXCEPT, CTEs, 
--             Window Functions, PIVOT, Views, Indexes,
--             Stored Procedures
-- ============================================================
--  STORY:
--  You are a data analyst at RetailMart — a retail chain with
--  3 stores across Pakistan. Your job is to build their
--  database from scratch and answer key business questions.
-- ============================================================


-- ============================================================
--  HOUR 1 — BUILD & LOAD
-- ============================================================

-- ============================================================
--  TASK 1: DDL — Create the schema
-- ============================================================

-- ============================================================
--  RETAILMART — CREATE TABLES PRACTICE
--  Task: Fill in the blanks to complete each CREATE TABLE.
--  Table names, column names, and hints are given.
--  You must choose the correct data type and constraints.
-- ============================================================
--  DATA TYPES TO CHOOSE FROM:
--    INT, VARCHAR(n), CHAR(n), DECIMAL(10,2), DATE
--
--  CONSTRAINTS TO CHOOSE FROM:
--    PRIMARY KEY, IDENTITY(1,1), NOT NULL, UNIQUE,
--    DEFAULT, CHECK, REFERENCES
-- ============================================================

 create  schema retailmart;
 go


-- ============================================================
--  TABLE 1: categories
--  Stores product categories like Electronics, Clothing, etc.
-- ============================================================

CREATE TABLE retailmart.categories (

    category_id     INT PRIMARY KEY IDENTITY(1,1),
    --              data type    primary key  auto-increment

    category_name   VARCHAR(200) NOT NULL
    --              data type    cannot be empty
);


-- ============================================================
--  TABLE 2: products
--  Stores all products sold at RetailMart.
-- ============================================================

CREATE TABLE retailmart.products (

    product_id      INT PRIMARY KEY IDENTITY(1,1),
    --              data type    primary key  auto-increment

    product_name    VARCHAR(300) NOT NULL,
    --              data type    cannot be empty

    category_id     INT NOT NULL REFERENCES retailmart.categories(category_id),
    --              data type    cannot be    links to categories table
    --                           empty

    price           DECIMAL(10,2)  NOT NULL  CHECK(PRICE >0),
    --              decimal type  cannot be    must be greater than 0
    --                            empty

    stock_qty       INT          NOT NULL  default 0
    --              data type    cannot be    default value = 0
    --                           empty
);


-- ============================================================
--  TABLE 3: stores
--  The 3 RetailMart store locations.
-- ============================================================

CREATE TABLE retailmart.stores (

    store_id        INT PRIMARY KEY IDENTITY(1,1),
    --              data type    primary key  auto-increment

    store_name      VARCHAR(300) NOT NULL,
    --              data type    cannot be empty

    city            VARCHAR(300) NOT NULL,
    --              data type    cannot be empty
);


-- ============================================================
--  TABLE 4: customers
--  Registered customers of RetailMart.
-- ============================================================

CREATE TABLE retailmart.customers (

    customer_id     INT PRIMARY KEY IDENTITY(1,1),
    --              data type    primary key  auto-increment

    full_name       VARCHAR(300) NOT NULL,
    --              data type    cannot be empty

    email           VARCHAR(300)  NOT NULL  UNIQUE,
    --              data type    cannot be    no two customers
    --                           empty        can share email

    city            VARCHAR(300),
    --              data type (nullable - customer may not provide city)

    gender          CHAR(1)  CHECK(gender IN ('M', 'F'))
    --              single char  only 'M' or 'F' allowed
);


-- ============================================================
--  TABLE 5: orders
--  Each row = one order placed by a customer at a store.
-- ============================================================

CREATE TABLE retailmart.orders (

    order_id       INT PRIMARY KEY IDENTITY(1,1),
    --              data type    primary key  auto-increment

    store_id        INT NOT NULL REFERENCES retailmart.stores(store_id),
    --              data type    cannot be    links to stores table
    --                           empty

    customer_id     INT NOT NULL REFERENCES retailmart.customers(customer_id),
    --              data type    cannot be    links to customers table
    --                           empty

    order_date      DATE  NOT NULL DEFAULT GETDATE(),
    --              date type    cannot be    default = today's date
    --                           empty        (hint: use GETDATE())

    status          VARCHAR(200) NOT NULL DEFAULT 'Pending' CHECK(STATUS IN ('Pending' , 'Shipped' , 'Delivered' , 'Cancelled'))
    --              data type    cannot be    default =    only allow:
    --                           empty        'Pending'    'Pending'
    --                                                     'Shipped'
    --                                                     'Delivered'
    --                                                     'Cancelled'
);


-- ============================================================
--  TABLE 6: order_items
--  Each row = one product line inside an order.
--  One order can have multiple items.
-- ============================================================

CREATE TABLE retailmart.order_items (

    item_id         INT PRIMARY KEY IDENTITY(1,1),
    --              data type    primary key  auto-increment

    order_id        INT NOT NULL REFERENCES retailmart.orders(order_id),
    --              data type    cannot be    links to orders table
    --                           empty

    product_id      INT NOT NULL REFERENCES retailmart.products(product_id),
    --              data type    cannot be    links to products table
    --                           empty

    quantity        INT NOT NULL CHECK(quantity >0),
    --              data type    cannot be    must be greater than 0
    --                           empty

    unit_price      DECIMAL(10,2)  NOT NULL
    --              decimal type cannot be empty
);



--  END OF EXERCISE
-- ============================================================

-- ============================================================
--  TASK 2: DML — INSERT, UPDATE, DELETE, MERGE
-- ============================================================

-- INSERT categories

INSERT INTO retailmart.categories (category_name) VALUES
('Electronics'), ('Clothing'), ('Groceries'), ('Accessories'), ('Home Appliances');

-- INSERT products
INSERT INTO retailmart.products (product_name, category_id, price, stock_qty) VALUES
('Samsung 4K TV',        1,  85000, 15),
('iPhone 15',            1, 295000, 10),
('Wireless Earbuds',     4,   4500, 80),
('Leather Jacket',       2,   8500, 40),
('Linen Shirt',          2,   2200, 60),
('Rice 5kg',             3,    950, 200),
('Cooking Oil 3L',       3,    750, 150),
('Sunglasses',           4,   1800, 55),
('Microwave Oven',       5,  18000, 20),
('Electric Kettle',      5,   3200, 35);

-- INSERT stores
INSERT INTO retailmart.stores (store_name, city) VALUES
('RetailMart Karachi',   'Karachi'),
('RetailMart Lahore',    'Lahore'),
('RetailMart Islamabad', 'Islamabad');

-- INSERT customers
INSERT INTO retailmart.customers (full_name, email, city, gender) VALUES
('Ahmed Khan',      'ahmed@gmail.com',   'Karachi',   'M'),
('Sara Malik',      'sara@gmail.com',    'Lahore',    'F'),
('Bilal Hussain',   'bilal@gmail.com',   'Islamabad', 'M'),
('Fatima Nawaz',    'fatima@gmail.com',  'Karachi',   'F'),
('Omar Sheikh',     'omar@gmail.com',    'Lahore',    'M'),
('Nadia Ali',       'nadia@gmail.com',   'Islamabad', 'F'),
('Hamza Raza',      'hamza@gmail.com',   'Karachi',   'M'),
('Zara Qureshi',    'zara@gmail.com',    'Lahore',    'F');

-- INSERT orders
INSERT INTO retailmart.orders (store_id, customer_id, order_date, status) VALUES
(1, 1, '2024-01-10', 'Delivered'),
(1, 4, '2024-01-15', 'Delivered'),
(2, 2, '2024-02-03', 'Delivered'),
(2, 5, '2024-02-20', 'Shipped'),
(3, 3, '2024-03-05', 'Delivered'),
(3, 6, '2024-03-18', 'Pending'),
(1, 7, '2024-04-01', 'Delivered'),
(2, 8, '2024-04-22', 'Cancelled'),
(1, 1, '2024-05-10', 'Delivered'),
(3, 3, '2024-06-01', 'Shipped');

-- INSERT order items
INSERT INTO retailmart.order_items (order_id, product_id, quantity, unit_price) VALUES
(1,  2,  1, 295000),
(1,  3,  2,   4500),
(2,  4,  1,   8500),
(3,  5,  3,   2200),
(3,  8,  1,   1800),
(4,  1,  1,  85000),
(5,  9,  1,  18000),
(5, 10,  2,   3200),
(6,  6,  4,    950),
(7,  3,  1,   4500),
(8,  2,  1, 295000),
(9,  4,  2,   8500),
(10, 9,  1,  18000);
-- UPDATE: Reduce price of Electric Kettle by 10%
select * from retailmart.products where product_id = 10;
UPDATE retailmart.products
SET price = price * 0.90
WHERE product_id = 10;

-- DELETE: Remove the cancelled order's items and the order itself
DELETE FROM retailmart.order_items WHERE order_id = 8;
DELETE FROM retailmart.orders       WHERE order_id = 8;


-- ============================================================
--  HOUR 2 — QUERY & ANALYZE
-- ============================================================

-- ============================================================
--  TASK 3: SELECT, filtering, sorting
-- ============================================================

-- All products under Rs. 5,000
select * from retailmart.products
where price < 5000;

-- Customers from Karachi
select * from [retailmart].[customers]
where city = 'Karachi';

-- Orders placed in 2024 sorted by date descending
select * from [retailmart].[orders]
where year(order_date) = '2024';

-- ============================================================
--  TASK 4: JOINs — INNER, LEFT, RIGHT
-- ============================================================

-- INNER JOIN: Orders with customer name and product details

select 
c.customer_id,
c.full_name,
o.order_id,
o.order_date,
p.product_name
from [retailmart].[customers] c
inner join [retailmart].[orders]o
on c.customer_id=o.customer_id
inner join [retailmart].[order_items]oi
on oi.order_id=o.order_id
inner join [retailmart].[products]p
on p.product_id=oi.product_id;

-- LEFT JOIN: All customers including those with no orders

-- RIGHT JOIN: All products including those never ordered



-- ===========================================================
--  TASK 5: GROUP BY + CASE
-- ============================================================

-- Total revenue by store and category 
SELECT
	s.store_name,
	c.category_name,
	SUM(oi.quantity* oi.unit_price) AS total_revenue
FROM [retailmart].[orders] o
JOIN [retailmart].[stores] s
ON s.store_id = o.store_id
JOIN [retailmart].[order_items] oi
ON o.order_id = oi.order_id
JOIN [retailmart].[products] p
ON p.product_id = oi.product_id
JOIN [retailmart].[categories] c
ON p.category_id = c.category_id
GROUP BY 	s.store_name,c.category_name;

-- Label each product as Budget / Mid-range / Premium using CASE



-- ============================================================
--  TASK 7: Subqueries 
-- ============================================================



-- Orders where the total exceeds the average order value (subquery in WHERE)
select o.order_id, sum([quantity]*[unit_price]) as total
from [retailmart].[order_items] o 
group by o.order_id
having sum([quantity]*[unit_price]) >
(select avg([quantity]*[unit_price]) from [retailmart].[order_items]) --59,123


-- ============================================================
--  TASK 8: Set operators — UNION, INTERSECT, EXCEPT
-- ============================================================

-- UNION: All unique cities where we have customers OR stores


-- INTERSECT: Customers who ordered from BOTH store 1 AND store 2

-- EXCEPT: Customers who have NEVER placed an order
-- A - B A = {1,2,3,4} , B= {2,4,6,7}===== A-B = {1,3}
select customer_id from [retailmart].[customers] --A
except
select customer_id from [retailmart].[orders] -- B

SELECT PRODUCT_ID FROM [retailmart].[products]
EXCEPT
SELECT PRODUCT_ID FROM [retailmart].[order_items]

-- ============================================================
--  HOUR 3 — ADVANCED & AUTOMATE
-- ============================================================

-- ============================================================
--  TASK 9: CTEs + Recursive CTE
-- ============================================================

-- Regular CTE: Top 5 customers by total spend

JOIN CUSTOMERS --- JOIN -- ORDERS --  JOIN - ORDER ITEMS --- QUANTITY * UNIT_PRICE
GROUP CUSTOMER_ID -- TOTAL SPENDING 
TOP 5
-- ============================================================
--  TASK 10: Window functions
-- ============================================================

-- ROW_NUMBER and RANK: Products ranked by revenue

CTE( PRODUCT -- JOIN -- ORDER ITEMS -- 
GROUP BY PRODUCT -- SUM(UNIT_PRICE* QUANTITY) -- REVENUE)

WITH CTE AS (
SELECT P.PRODUCT_ID, SUM(OI.UNIT_PRICE*OI.UNIT_PRICE) AS REVENUE
FROM [retailmart].[products] P INNER JOIN [retailmart].[order_items] OI
ON OI.product_id = P.product_id
GROUP BY P.PRODUCT_ID)


SELECT product_id, ROW_NUMBER() OVER(ORDER BY REVENUE DESC) AS RN FROM CTE


-- Running total of revenue by store




-- ============================================================
--  TASK 12: Views
-- ============================================================

-- Standard view: Order summary


-- Use the view


-- Indexed (materialized) view: Store revenue totals
-- Note: Requires SCHEMABINDING + unique clustered index



-- ============================================================
--  TASK 13: Indexes
-- ============================================================

-- Composite index: Speed up queries filtering by customer + date


-- Filtered index: Only index Pending orders (partial index)

-- Non-clustered index on customer email for fast lookups

-- Verify indexes
EXEC sp_helpindex 'retailmart.orders';
EXEC sp_helpindex 'retailmart.customers';


-- ============================================================
--  TASK 14: Stored Procedures + Error Handling
-- ============================================================



-- Procedure 1: Monthly sales report for a store

-- Test the report for Store 1 (Karachi)
EXEC retailmart.sp_MonthlySalesReport @StoreID = 1, @Year = 2024;

-- Test with default year
EXEC retailmart.sp_MonthlySalesReport @StoreID = 2;


-- ============================================================
--  END OF CAPSTONE PROJECT
-- ============================================================
--  You have covered:
--  DDL         CREATE TABLE, constraints, data types
--  DML         INSERT, UPDATE, DELETE, MERGE
--  Querying    SELECT, WHERE, ORDER BY
--  Joins       INNER, LEFT, RIGHT
--  CASE        Price tier labelling
--  Subqueries  Inline
--  Set ops     UNION, INTERSECT, EXCEPT
--  CTEs        Regular 
--  Windows     ROW_NUMBER, RANK
--  Views       Standard + Indexed
--  Indexes     Clustered, Non-clustered
--  Procedures  Parameters, defaults
-- ============================================================
