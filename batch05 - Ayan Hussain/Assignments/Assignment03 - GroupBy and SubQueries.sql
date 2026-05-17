-- ============================================================
--   ASSIGNMENT 03 — GROUP BY, HAVING & SUBQUERIES
--   Database  : BikeStores
--   Topics    : GROUP BY · Aggregate Functions · HAVING
--               Subqueries · JOINs with GROUP BY
-- ============================================================


-- ============================================================
--  SECTION A — GROUP BY & AGGREGATE FUNCTIONS
-- ============================================================

-- Q1.
-- Count the total number of orders placed by each customer.
-- Show customer_id and order_count.
-- Sort by order_count descending.



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



-- ============================================================
--  END OF ASSIGNMENT 03
-- ============================================================
