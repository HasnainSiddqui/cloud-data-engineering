-- ============================================================
--  HOMEWORK: Indexes & Stored Procedures
--  Topic   : SQL Indexes + Stored Procedures
--  Level   : Beginner to Intermediate
-- ============================================================


-- ============================================================
--  PART A: INDEXES
-- ============================================================

-- Q1.
-- Write a query to create a non-clustered index on the
-- last_name column of sales.customers.
-- Then write a SELECT statement that would benefit from it.
-- Hint: Think about which queries filter by last name.

-- Your answer here:



-- Q2.
-- Create a composite index on sales.orders using
-- customer_id and order_date.
-- Write a query that filters on both columns and benefits
-- from this index.
-- Hint: Composite indexes work best when you filter on both columns.

-- Your answer here:



-- Q3.
-- A teammate suggests adding a unique index on
-- sales.customers(phone_number).
-- What could go wrong with this?
-- What assumption must be true for this to be safe?
-- Hint: Think about duplicate or missing (NULL) values.

-- Your answer here (write as a comment):



-- Q4.
-- Look at the columns below from a sales.orders table.
-- Decide which columns SHOULD have an index and which should NOT.
-- Explain your reasoning for each as a comment.
--
--   order_id     (Primary Key)
--   status       (only 3 values: Pending, Shipped, Delivered)
--   customer_id  (Foreign Key)
--   notes        (free text, rarely searched)

-- Your answer here (write as a comment):



-- Q5.
-- Write the command to check existing indexes on production.products.
-- Then describe (as a comment) what the output columns tell you.
-- Hint: Use sp_helpindex.

-- Your answer here:



-- ============================================================
--  PART B: STORED PROCEDURES
-- ============================================================

-- Q6.
-- Create a stored procedure called sp_GetCustomerOrders
-- that accepts a @CustomerID parameter and returns all orders
-- for that customer showing: order_id, order_date, order_status.
-- Test it using EXEC after you create it.

-- Your answer here:



-- Q7.
-- Modify sp_GetCustomerOrders from Q6 so that if no orders
-- are found for the given customer, it returns the message:
-- 'No orders found for this customer'
-- Hint: Use IF EXISTS or check @@ROWCOUNT.

-- Your answer here:



-- Q8.
-- Create a stored procedure sp_ProductsByCategory that accepts:
--   @CategoryID  INT
--   @MaxPrice    DECIMAL(10,2)  with a default value of 9999
-- It should return all matching products ordered by price (low to high).
-- Hint: Use a default parameter value like you saw with @threshold.

-- Your answer here:



-- ============================================================
--  PART C: MIXED / THINK QUESTIONS
-- ============================================================

-- Q9.
-- You have a sales.orders table with 2 million rows.
-- A stored procedure filters by store_id and order_date.
-- It runs very slowly.
-- What TWO things would you do to fix it, and why?
-- Hint: Think about both indexes and procedure logic.

-- Your answer here (write as a comment):



-- Q10.
-- A junior developer creates indexes on EVERY column of a table
-- to "make everything faster".
-- Write a short explanation (3-5 sentences) of why this is
-- actually a bad idea.
-- Hint: Think about how INSERT, UPDATE, and DELETE are affected.

-- Your answer here (write as a comment):



-- ============================================================
--  END OF HOMEWORK
-- ============================================================