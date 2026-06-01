-- Q1. Unified contact list of staff and customers (No duplicates)
SELECT first_name, last_name, email FROM sales.staffs
UNION
SELECT first_name, last_name, email FROM sales.customers;


-- Q2. States with BOTH a store location AND customers living there
SELECT state FROM sales.stores
INTERSECT
SELECT state FROM sales.customers;


-- Q3. Stores that received zero orders in the year 2018
SELECT store_id FROM sales.stores    
EXCEPT
SELECT store_id FROM sales.orders WHERE YEAR(order_date) = 2018;


-- ============================================================
--  SECTION B — CTEs
-- ============================================================

-- Q4. Overpriced products compared to their category average
WITH CategoryAvg AS (
    SELECT 
        category_id, 
        AVG(list_price) AS avg_price
    FROM production.products
    GROUP BY category_id
)
SELECT 
    p.category_id, 
    p.product_name, 
    p.list_price, 
    ROUND(c.avg_price, 2) AS category_average
FROM production.products p
JOIN CategoryAvg c ON p.category_id = c.category_id
WHERE p.list_price > c.avg_price;


-- Q5. Staff members with order count higher than the staff average
WITH StaffOrderCounts AS (
    SELECT 
        staff_id, 
        COUNT(order_id) AS order_count
    FROM sales.orders
    GROUP BY staff_id
),
AvgStaffOrders AS (
    SELECT AVG(CAST(order_count AS DECIMAL(10,2))) AS avg_orders 
    FROM StaffOrderCounts
)
SELECT 
    s.staff_id, 
    s.order_count
FROM StaffOrderCounts s
CROSS JOIN AvgStaffOrders a
WHERE s.order_count > a.avg_orders;


-- Q6. Yearly store performance report exceeding $1,000,000 in revenue
WITH StoreYearlyRevenue AS (
    SELECT 
        o.store_id,
        YEAR(o.order_date) AS order_year,
        SUM(i.quantity * i.list_price * (1 - i.discount)) AS total_revenue
    FROM sales.orders o
    JOIN sales.order_items i ON o.order_id = i.order_id
    GROUP BY o.store_id, YEAR(o.order_date)
)
SELECT 
    store_id,
    order_year AS [year],
    ROUND(total_revenue, 2) AS total_revenue
FROM StoreYearlyRevenue
WHERE total_revenue > 1000000;


-- ============================================================
--  SECTION C — CONSTRAINTS (DDL)
-- ============================================================

-- Q7. Create loyalty_cards table with all strict business rules
CREATE TABLE sales.loyalty_cards (
    card_number   INT PRIMARY KEY, -- Unique, not auto-generated
    customer_id   INT NOT NULL,
    points        INT NOT NULL CHECK (points >= 0), -- Cannot be negative
    tier          VARCHAR(10) NOT NULL CHECK (tier IN ('Bronze', 'Silver', 'Gold')), -- Specific tiers only
    join_date     DATE NOT NULL, -- Required field
    FOREIGN KEY (customer_id) REFERENCES sales.customers(customer_id) ON DELETE CASCADE -- Valid customer & cascading delete
);

-- Verification Inserts (Should Pass)
INSERT INTO sales.loyalty_cards VALUES (1001, 1,  500,  'Gold',   '2024-01-15');
INSERT INTO sales.loyalty_cards VALUES (1002, 2,  150,  'Silver', '2024-03-22');
INSERT INTO sales.loyalty_cards VALUES (1003, 3,  0,    'Bronze', '2024-06-01');


-- Q8. Alter test_orders to ensure shipped_date is logical
-- (Make sure you have already run the setup given in your question file before executing this)
ALTER TABLE test_orders
ADD CONSTRAINT chk_shipped_date_validation 
CHECK (shipped_date IS NULL OR shipped_date >= order_date);

-- Verification Tests
-- INSERT INTO test_orders VALUES (4, '2024-04-10', '2024-04-08'); -- Fails as expected (shipped before order date)
-- INSERT INTO test_orders VALUES (5, '2024-04-10', '2024-04-15'); -- Passes as expected


-- ============================================================
--  SECTION D — CASE EXPRESSIONS
-- ============================================================

-- Q9. Order shipping speed categorization using DATEDIFF
SELECT 
    order_id, 
    order_date, 
    shipped_date,
    CASE 
        WHEN shipped_date IS NULL THEN 'Pending'
        WHEN DATEDIFF(day, order_date, shipped_date) <= 2 THEN 'Fast'
        WHEN DATEDIFF(day, order_date, shipped_date) BETWEEN 3 AND 5 THEN 'Normal'
        ELSE 'Delayed'
    END AS shipping_speed
FROM sales.orders;


-- Q10. Warehouse product stock level labels
SELECT 
    store_id, 
    product_id, 
    quantity,
    CASE 
        WHEN quantity = 0 THEN 'Out of Stock'
        WHEN quantity BETWEEN 1 AND 10 THEN 'Low Stock'
        WHEN quantity BETWEEN 11 AND 50 THEN 'Sufficient'
        ELSE 'Well Stocked'
    END AS stock_status
FROM production.stocks
ORDER BY store_id ASC, quantity ASC;