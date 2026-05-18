Gemini
Database Structure Aur SQL Queries
Conversation with Gemini
sql ka data base structure ye hai tables ke folder ke ander sare tables hen me question donga us ko solve kar ke dena

Bilkul, main samajh gaya! Aapki BikeStores database ka structure mere samne hai, jismein different schemas (dbo, hr, production, sales) ke andar ye saari tables hain:

dbo.candidates

hr.employees

production.brands

production.categories

production.products

production.stocks

sales.customers

sales.order_items

sales.orders

sales.staffs

sales.stores

Aap apna SQL ka question send kijiye, main aapko uska perfect query aur solution nikal kar de dunga!

Q1.

-- Count the total number of orders placed by each customer.

-- Show customer_id and order_count.

-- Sort by order_count descending.

Is query ko solve karne ke liye hume sales.orders table ka use karna hoga, jahan hum customer_id ke hisab se orders ko GROUP BY karenge aur COUNT() function se total orders nikalenge.

Aapki query ye rahi:

SQL
SELECT 
    customer_id, 
    COUNT(order_id) AS order_count
FROM 
    sales.orders
GROUP BY 
    customer_id
ORDER BY 
    order_count DESC;
Yeh query kaise kaam kar rahi hai?
COUNT(order_id): Har customer ke total orders ko ginta hai.

GROUP BY customer_id: Data ko customer ke mutabiq alag-alag groups mein baant deta hai taake har ek ka count alag se dikhe.

ORDER BY order_count DESC: Jis customer ne sab se zyada orders diye hain, usko sab se upar (descending order mein) show karta hai.

Aap agla question send kar sakte hain!

ye sare question hen is sab ka question ke niche answer likh kar do



-- Q2.

-- For each store, find the total number of orders placed.

-- Show store_id and total_orders.







-- Q3.

-- Calculate the net revenue per order.

-- Net revenue formula: SUM( quantity * list_price * (1 - discount) )

-- Show order_id and net_revenue, sorted by net_revenue descending.

-- (Hint: use sales.order_items)







-- Q4.

-- Find the average list price of products in each category.

-- Show category_id and avg_price (rounded to 2 decimal places).

-- (Hint: use ROUND())







-- Q5.

-- Find the total number of orders placed in each year.

-- Show order_year and total_orders, sorted by order_year.

-- (Hint: use YEAR(order_date))







-- ============================================================

--  SECTION B — HAVING CLAUSE

-- ============================================================



-- Q6.

-- Find customers who have placed MORE than 5 orders in total.

-- Show customer_id and order_count.







-- Q7.

-- Find categories where the AVERAGE list price is greater than $1,500.

-- Show category_id and avg_price.







-- Q8.

-- Find customers who placed at least 2 orders in the year 2017.

-- Show customer_id, order_year, and order_count.







-- ============================================================

--  SECTION C — SUBQUERIES

-- ============================================================



-- Q9.

-- Find all orders placed by customers who live in 'Houston'.

-- Use a subquery to get the customer_ids first.

-- Show all columns from sales.orders.







-- Q10.

-- Find all products whose list_price is greater than the

-- AVERAGE list_price of ALL products.

-- Show product_name and list_price.







-- Q11.

-- Find all products that belong to the category 'Mountain Bikes'

-- or 'Road Bikes'. Use a subquery on production.categories.

-- Show product_name and list_price.







-- Q12.

-- Find all customers who have NEVER placed an order.

-- Show customer_id, first_name, and last_name.

-- (Hint: use NOT IN with a subquery on sales.orders)







-- ============================================================

--  SECTION D — JOINs WITH GROUP BY

-- ============================================================



-- Q13.

-- Find the total number of orders per city (customer's city).

-- Join sales.orders with sales.customers.

-- Show city and total_orders, sorted by total_orders descending.







-- Q14.

-- For each staff member, count how many orders they handled.

-- Join sales.orders with sales.staffs.

-- Show staff full name (first_name + ' ' + last_name) as staff_name

-- and order_count, sorted by order_count descending.







-- Q15. (BONUS — Multi-concept)

-- Find customers who have spent more than $10,000 in total.

-- Join sales.customers → sales.orders → sales.order_items.

-- Show customer full name as customer_name and total_spent.

-- Sort by total_spent descending.

-- (Hint: JOIN + GROUP BY + HAVING)

Aapke saare questions ke SQL queries niche diye gaye hain. Har question ke neechay uska complete aur accurate answer likha hua hai.

============================================================
SECTION A — GROUP BY & AGGREGATE FUNCTIONS
============================================================
Q2.
For each store, find the total number of orders placed. Show store_id and total_orders.

SQL
SELECT 
    store_id, 
    COUNT(order_id) AS total_orders
FROM 
    sales.orders
GROUP BY 
    store_id;
Q3. Calculate the net revenue per order. Net revenue formula: SUM( quantity * list_price * (1 - discount) ) Show order_id and net_revenue, sorted by net_revenue descending. (Hint: use sales.order_items)

SQL
SELECT 
    order_id, 
    SUM(quantity * list_price * (1 - discount)) AS net_revenue
FROM 
    sales.order_items
GROUP BY 
    order_id
ORDER BY 
    net_revenue DESC;
Q4. Find the average list price of products in each category. Show category_id and avg_price (rounded to 2 decimal places). (Hint: use ROUND())

SQL
SELECT 
    category_id, 
    ROUND(AVG(list_price), 2) AS avg_price
FROM 
    production.products
GROUP BY 
    category_id;
Q5. Find the total number of orders placed in each year. Show order_year and total_orders, sorted by order_year. (Hint: use YEAR(order_date))

SQL
SELECT 
    YEAR(order_date) AS order_year, 
    COUNT(order_id) AS total_orders
FROM 
    sales.orders
GROUP BY 
    YEAR(order_date)
ORDER BY 
    order_year;
============================================================
SECTION B — HAVING CLAUSE
============================================================
Q6. Find customers who have placed MORE than 5 orders in total. Show customer_id and order_count.

SQL
SELECT 
    customer_id, 
    COUNT(order_id) AS order_count
FROM 
    sales.orders
GROUP BY 
    customer_id
HAVING 
    COUNT(order_id) > 5;
Q7. Find categories where the AVERAGE list price is greater than $1,500. Show category_id and avg_price.

SQL
SELECT 
    category_id, 
    AVG(list_price) AS avg_price
FROM 
    production.products
GROUP BY 
    category_id
HAVING 
    AVG(list_price) > 1500;
Q8. Find customers who placed at least 2 orders in the year 2017. Show customer_id, order_year, and order_count.

SQL
SELECT 
    customer_id, 
    YEAR(order_date) AS order_year,
    COUNT(order_id) AS order_count
FROM 
    sales.orders
WHERE 
    YEAR(order_date) = 2017
GROUP BY 
    customer_id, 
    YEAR(order_date)
HAVING 
    COUNT(order_id) >= 2;
============================================================
SECTION C — SUBQUERIES
============================================================
Q9. Find all orders placed by customers who live in 'Houston'. Use a subquery to get the customer_ids first. Show all columns from sales.orders.

SQL
SELECT 
    * FROM 
    sales.orders
WHERE 
    customer_id IN (
        SELECT customer_id 
        FROM sales.customers 
        WHERE city = 'Houston'
    );
Q10. Find all products whose list_price is greater than the AVERAGE list_price of ALL products. Show product_name and list_price.

SQL
SELECT 
    product_name, 
    list_price
FROM 
    production.products
WHERE 
    list_price > (
        SELECT AVG(list_price) 
        FROM production.products
    );
Q11. Find all products that belong to the category 'Mountain Bikes' or 'Road Bikes'. Use a subquery on production.categories. Show product_name and list_price.

SQL
SELECT 
    product_name, 
    list_price
FROM 
    production.products
WHERE 
    category_id IN (
        SELECT category_id 
        FROM production.categories 
        WHERE category_name IN ('Mountain Bikes', 'Road Bikes')
    );
Q12. Find all customers who have NEVER placed an order. Show customer_id, first_name, and last_name. (Hint: use NOT IN with a subquery on sales.orders)

SQL
SELECT 
    customer_id, 
    first_name, 
    last_name
FROM 
    sales.customers
WHERE 
    customer_id NOT IN (
        SELECT DISTINCT customer_id 
        FROM sales.orders 
        WHERE customer_id IS NOT NULL
    );
============================================================
SECTION D — JOINs WITH GROUP BY
============================================================
Q13. Find the total number of orders per city (customer's city). Join sales.orders with sales.customers. Show city and total_orders, sorted by total_orders descending.

SQL
SELECT 
    c.city, 
    COUNT(o.order_id) AS total_orders
FROM 
    sales.orders o
JOIN 
    sales.customers c ON o.customer_id = c.customer_id
GROUP BY 
    c.city
ORDER BY 
    total_orders DESC;
Q14. For each staff member, count how many orders they handled. Join sales.orders with sales.staffs. Show staff full name (first_name + ' ' + last_name) as staff_name and order_count, sorted by order_count descending.

SQL
SELECT 
    s.first_name + ' ' + s.last_name AS staff_name, 
    COUNT(o.order_id) AS order_count
FROM 
    sales.orders o
JOIN 
    sales.staffs s ON o.staff_id = s.staff_id
GROUP BY 
    s.first_name, 
    s.last_name
ORDER BY 
    order_count DESC;
Q15. (BONUS — Multi-concept) Find customers who have spent more than $10,000 in total. Join sales.customers → sales.orders → sales.order_items. Show customer full name as customer_name and total_spent. Sort by total_spent descending. (Hint: JOIN + GROUP BY + HAVING)

SQL
SELECT 
    c.first_name + ' ' + c.last_name AS customer_name,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
FROM 
    sales.customers c
JOIN 
    sales.orders o ON c.customer_id = o.customer_id
JOIN 
    sales.order_items oi ON o.order_id = oi.order_id
GROUP BY 
    c.first_name, 
    c.last_name, 
    c.customer_id -- Group by id bhi include kiya taake same naam wale customers mix na hon
HAVING 
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) > 10000
ORDER BY 
    total_spent DESC;
mujhe questin ke sath answer likh kar do notepad me

Your TXT file is ready
TXT icon
 BikeStores...QL_Queries 
TXT

Aapki request ke mutabiq maine saare questions aur unke SQL answers ko ek notepad (.txt) file mein arrange kar diya hai. Aap is file ko download karke direct SQL Server mein chalane ke liye use kar sakte hain.







Gemini is AI and can make mistakes.

-- ============================================================
--  SECTION A — GROUP BY & AGGREGATE FUNCTIONS
-- ============================================================

-- Q2.
-- For each store, find the total number of orders placed.
-- Show store_id and total_orders.
SELECT 
    store_id, 
    COUNT(order_id) AS total_orders
FROM 
    sales.orders
GROUP BY 
    store_id;


-- Q3.
-- Calculate the net revenue per order.
-- Net revenue formula: SUM( quantity * list_price * (1 - discount) )
-- Show order_id and net_revenue, sorted by net_revenue descending.
-- (Hint: use sales.order_items)
SELECT 
    order_id, 
    SUM(quantity * list_price * (1 - discount)) AS net_revenue
FROM 
    sales.order_items
GROUP BY 
    order_id
ORDER BY 
    net_revenue DESC;


-- Q4.
-- Find the average list price of products in each category.
-- Show category_id and avg_price (rounded to 2 decimal places).
-- (Hint: use ROUND())
SELECT 
    category_id, 
    ROUND(AVG(list_price), 2) AS avg_price
FROM 
    production.products
GROUP BY 
    category_id;


-- Q5.
-- Find the total number of orders placed in each year.
-- Show order_year and total_orders, sorted by order_year.
-- (Hint: use YEAR(order_date))
SELECT 
    YEAR(order_date) AS order_year, 
    COUNT(order_id) AS total_orders
FROM 
    sales.orders
GROUP BY 
    YEAR(order_date)
ORDER BY 
    order_year;


-- ============================================================
--  SECTION B — HAVING CLAUSE
-- ============================================================

-- Q6.
-- Find customers who have placed MORE than 5 orders in total.
-- Show customer_id and order_count.
SELECT 
    customer_id, 
    COUNT(order_id) AS order_count
FROM 
    sales.orders
GROUP BY 
    customer_id
HAVING 
    COUNT(order_id) > 5;


-- Q7.
-- Find categories where the AVERAGE list price is greater than $1,500.
-- Show category_id and avg_price.
SELECT 
    category_id, 
    AVG(list_price) AS avg_price
FROM 
    production.products
GROUP BY 
    category_id
HAVING 
    AVG(list_price) > 1500;


-- Q8.
-- Find customers who placed at least 2 orders in the year 2017.
-- Show customer_id, order_year, and order_count.
SELECT 
    customer_id, 
    YEAR(order_date) AS order_year,
    COUNT(order_id) AS order_count
FROM 
    sales.orders
WHERE 
    YEAR(order_date) = 2017
GROUP BY 
    customer_id, 
    YEAR(order_date)
HAVING 
    COUNT(order_id) >= 2;


-- ============================================================
--  SECTION C — SUBQUERIES
-- ============================================================

-- Q9.
-- Find all orders placed by customers who live in 'Houston'.
-- Use a subquery to get the customer_ids first.
-- Show all columns from sales.orders.
SELECT 
    * FROM 
    sales.orders
WHERE 
    customer_id IN (
        SELECT customer_id 
        FROM sales.customers 
        WHERE city = 'Houston'
    );


-- Q10.
-- Find all products whose list_price is greater than the
-- AVERAGE list_price of ALL products.
-- Show product_name and list_price.
SELECT 
    product_name, 
    list_price
FROM 
    production.products
WHERE 
    list_price > (
        SELECT AVG(list_price) 
        FROM production.products
    );


-- Q11.
-- Find all products that belong to the category 'Mountain Bikes'
-- or 'Road Bikes'. Use a subquery on production.categories.
-- Show product_name and list_price.
SELECT 
    product_name, 
    list_price
FROM 
    production.products
WHERE 
    category_id IN (
        SELECT category_id 
        FROM production.categories 
        WHERE category_name IN ('Mountain Bikes', 'Road Bikes')
    );


-- Q12.
-- Find all customers who have NEVER placed an order.
-- Show customer_id, first_name, and last_name.
-- (Hint: use NOT IN with a subquery on sales.orders)
SELECT 
    customer_id, 
    first_name, 
    last_name
FROM 
    sales.customers
WHERE 
    customer_id NOT IN (
        SELECT DISTINCT customer_id 
        FROM sales.orders 
        WHERE customer_id IS NOT NULL
    );


-- ============================================================
--  SECTION D — JOINs WITH GROUP BY
-- ============================================================

-- Q13.
-- Find the total number of orders per city (customer's city).
-- Join sales.orders with sales.customers.
-- Show city and total_orders, sorted by total_orders descending.
SELECT 
    c.city, 
    COUNT(o.order_id) AS total_orders
FROM 
    sales.orders o
JOIN 
    sales.customers c ON o.customer_id = c.customer_id
GROUP BY 
    c.city
ORDER BY 
    total_orders DESC;


-- Q14.
-- For each staff member, count how many orders they handled.
-- Join sales.orders with sales.staffs.
-- Show staff full name (first_name + ' ' + last_name) as staff_name
-- and order_count, sorted by order_count descending.
SELECT 
    s.first_name + ' ' + s.last_name AS staff_name, 
    COUNT(o.order_id) AS order_count
FROM 
    sales.orders o
JOIN 
    sales.staffs s ON o.staff_id = s.staff_id
GROUP BY 
    s.first_name, 
    s.last_name
ORDER BY 
    order_count DESC;


-- Q15. (BONUS — Multi-concept)
-- Find customers who have spent more than $10,000 in total.
-- Join sales.customers → sales.orders → sales.order_items.
-- Show customer full name as customer_name and total_spent.
-- Sort by total_spent descending.
-- (Hint: JOIN + GROUP BY + HAVING)
SELECT 
    c.first_name + ' ' + c.last_name AS customer_name,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
FROM 
    sales.customers c
JOIN 
    sales.orders o ON c.customer_id = o.customer_id
JOIN 
    sales.order_items oi ON o.order_id = oi.order_id
GROUP BY 
    c.first_name, 
    c.last_name, 
    c.customer_id
HAVING 
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) > 10000
ORDER BY 
    total_spent DESC;
BikeStores_SQL_Queries.txt
Displaying BikeStores_SQL_Queries.txt.
