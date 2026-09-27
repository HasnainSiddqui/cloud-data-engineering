-- ============================================================
--   ASSIGNMENT 05 — INDEXES, VIEWS & WINDOW FUNCTIONS
--   Database  : BikeStores
-- ============================================================


-- ============================================================
--   SECTION A — INDEXES
-- ============================================================

-- Q1. Create non-clustered index on brand_id to optimize product filtering
CREATE NONCLUSTERED INDEX ix_products_brand_id
ON production.products (brand_id);
GO

-- Confirmation query
SELECT product_id, product_name, list_price
FROM production.products
WHERE brand_id = 3;
GO


-- Q2. Create non-clustered index on order_date to optimize date range filtering
CREATE NONCLUSTERED INDEX ix_orders_order_date
ON sales.orders (order_date);
GO

-- Confirmation query
SELECT order_id, customer_id, order_date
FROM sales.orders
WHERE order_date BETWEEN '2018-01-01' AND '2018-06-30';
GO


-- ============================================================
--   SECTION B — VIEWS
-- ============================================================

-- Q3. View for pending and processing orders with formatted customer names and status text
IF OBJECT_ID('sales.vw_pending_processing_orders', 'V') IS NOT NULL
    DROP VIEW sales.vw_pending_processing_orders;
GO

CREATE VIEW sales.vw_pending_processing_orders AS
SELECT 
    o.order_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    c.phone,
    c.email,
    o.order_date,
    CASE o.order_status
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Processing'
    END AS order_status_label
FROM sales.orders o
INNER JOIN sales.customers c ON o.customer_id = c.customer_id
WHERE o.order_status IN (1, 2);
GO

-- Test query for Q3
SELECT * 
FROM sales.vw_pending_processing_orders;
GO


-- Q4. Consolidated view for monitoring inventory levels across stores
IF OBJECT_ID('production.vw_store_inventory', 'V') IS NOT NULL
    DROP VIEW production.vw_store_inventory;
GO

CREATE VIEW production.vw_store_inventory AS
SELECT 
    s.store_name,
    p.product_name,
    b.brand_name,
    c.category_name,
    st.quantity
FROM production.stocks st
INNER JOIN sales.stores s ON st.store_id = s.store_id
INNER JOIN production.products p ON st.product_id = p.product_id
INNER JOIN production.brands b ON p.brand_id = b.brand_id
INNER JOIN production.categories c ON p.category_id = c.category_id;
GO

-- Query low stock inventory (< 3 units)
SELECT * 
FROM production.vw_store_inventory
WHERE quantity < 3;
GO


-- ============================================================
--   SECTION C — ROW_NUMBER, RANK & DENSE_RANK
-- ============================================================

-- Q5. Top 2 best-selling products per store by total quantity sold
WITH StoreProductSales AS (
    SELECT 
        o.store_id,
        oi.product_id,
        SUM(oi.quantity) AS total_quantity,
        DENSE_RANK() OVER (
            PARTITION BY o.store_id 
            ORDER BY SUM(oi.quantity) DESC
        ) AS sales_rank
    FROM sales.orders o
    INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.store_id, oi.product_id
)
SELECT 
    store_id,
    product_id,
    total_quantity,
    sales_rank
FROM StoreProductSales
WHERE sales_rank <= 2
ORDER BY store_id, sales_rank;
GO


-- Q6. 2nd most expensive product in each category
WITH CategoryPriceRanking AS (
    SELECT 
        category_id,
        product_name,
        list_price,
        DENSE_RANK() OVER (
            PARTITION BY category_id 
            ORDER BY list_price DESC
        ) AS price_rank
    FROM production.products
)
SELECT 
    category_id,
    product_name,
    list_price,
    price_rank
FROM CategoryPriceRanking
WHERE price_rank = 2
ORDER BY category_id;
GO


-- Q7. Duplicate customer records detection script

-- Environment setup
IF OBJECT_ID('dbo.test_customers', 'U') IS NOT NULL
    DROP TABLE dbo.test_customers;
GO

CREATE TABLE test_customers (
    customer_id INT,
    first_name  VARCHAR(50),
    last_name   VARCHAR(50),
    phone       VARCHAR(20),
    city        VARCHAR(50)
);

INSERT INTO test_customers (customer_id, first_name, last_name, phone, city) VALUES
    (1, 'Ali',   'Khan',  '0300-1111111', 'Karachi'),
    (2, 'Sara',  'Ahmed', '0321-2222222', 'Lahore'),
    (3, 'Ali',   'Khan',  '0300-1111111', 'Karachi'),
    (4, 'Usman', 'Malik', '0333-3333333', 'Islamabad'),
    (5, 'Sara',  'Ahmed', '0321-2222222', 'Lahore'),
    (6, 'Sara',  'Ahmed', '0321-2222222', 'Lahore'),
    (7, 'Hina',  'Raza',  '0312-4444444', 'Peshawar');
GO

-- Duplicate identification query
WITH CustomerOccurrences AS (
    SELECT 
        customer_id,
        first_name,
        last_name,
        phone,
        city,
        ROW_NUMBER() OVER (
            PARTITION BY first_name, last_name, phone 
            ORDER BY customer_id
        ) AS row_num
    FROM test_customers
)
SELECT 
    customer_id,
    first_name,
    last_name,
    phone,
    city
FROM CustomerOccurrences
WHERE row_num > 1
ORDER BY customer_id;
GO


-- ============================================================
--   SECTION D — LAG, LEAD & COALESCE
-- ============================================================

-- Q8. Month-by-month net sales growth comparison for 2017
WITH MonthlySales2017 AS (
    SELECT 
        MONTH(o.order_date) AS month_num,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS net_sales
    FROM sales.orders o
    INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.order_date >= '2017-01-01' AND o.order_date <= '2017-12-31'
    GROUP BY MONTH(o.order_date)
)
SELECT 
    month_num AS [month],
    CAST(net_sales AS DECIMAL(12,2)) AS net_sales,
    CAST(LAG(net_sales, 1) OVER (ORDER BY month_num) AS DECIMAL(12,2)) AS previous_month_sales,
    CAST(net_sales - LAG(net_sales, 1) OVER (ORDER BY month_num) AS DECIMAL(12,2)) AS sales_difference
FROM MonthlySales2017
ORDER BY month_num;
GO


-- Q9. Compare product list price with the next cheaper item in category
SELECT 
    category_id,
    product_name,
    list_price,
    LEAD(list_price, 1) OVER (
        PARTITION BY category_id 
        ORDER BY list_price DESC
    ) AS next_lower_price
FROM production.products
ORDER BY category_id, list_price DESC;
GO


-- Q10. Customer contact info lookup with fallback values
SELECT 
    first_name + ' ' + last_name AS full_name,
    phone,
    email,
    COALESCE(phone, email, 'No Contact Info') AS primary_contact
FROM sales.customers
ORDER BY last_name, first_name;
GO

-- ============================================================
--   END OF ASSIGNMENT 05
-- ============================================================