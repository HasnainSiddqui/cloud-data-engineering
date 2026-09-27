/*=========================================================
                    SQL DAY 4
      DDL, DML, DATA TYPES & CONSTRAINTS
=========================================================*/


/*---------------------------------------------------------
    CHECK TABLE STRUCTURE
---------------------------------------------------------*/

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'products';


/*---------------------------------------------------------
    DATA TYPES
---------------------------------------------------------*/

-- Numeric Data Types

-- customer_id INT
-- Used for whole numbers

-- age SMALLINT
-- Suitable for smaller numeric values

-- DECIMAL(p,s)
-- Example: DECIMAL(10,2)
-- Maximum value: 99,999,999.99

-- FLOAT / REAL
-- Approximate values


/*---------------------------------------------------------
    CHARACTER DATA TYPES
---------------------------------------------------------*/

-- CHAR(n)
-- Fixed length

-- VARCHAR(n)
-- Variable length

-- Example:
-- CHAR(500) vs VARCHAR(500)


/*---------------------------------------------------------
    DATE & TIME DATA TYPES
---------------------------------------------------------*/

-- DATE
-- TIME
-- DATETIME
-- SMALLDATETIME


/*---------------------------------------------------------
    OTHER DATA TYPES
---------------------------------------------------------*/

-- BIT
-- UNIQUEIDENTIFIER


/*---------------------------------------------------------
    CONSTRAINTS
---------------------------------------------------------*/

-- PRIMARY KEY
-- FOREIGN KEY
-- UNIQUE
-- NOT NULL


/*=========================================================
                    ALTER TABLE
=========================================================*/

-- Add a new column

ALTER TABLE sales.customers
ADD date_of_birth DATE;


-- Drop a column

ALTER TABLE sales.customers
DROP COLUMN date_of_birth;


-- Add constraint

ALTER TABLE sales.customers
ADD CONSTRAINT UQ_Customer_Email
UNIQUE(email);


-- Change datatype

ALTER TABLE sales.customers
ALTER COLUMN phone VARCHAR(20);


/*=========================================================
                    TRUNCATE
=========================================================*/

TRUNCATE TABLE sales.customers;


/*=========================================================
                    DELETE
=========================================================*/

DELETE
FROM sales.customers
WHERE TRANSACTION_DATE = '2026-01-01';


/*=========================================================
                    BACKUP TABLE
=========================================================*/

SELECT *
INTO production.products_bkp
FROM production.categories;


SELECT *
FROM production.products_bkp;


/*=========================================================
                    INSERT
=========================================================*/

INSERT INTO production.categories
(
    category_name
)
VALUES
(
    'Motor Bikes'
);


INSERT INTO production.categories
(
    category_name
)
VALUES
(
    'Motor Bikes'
),
(
    'Sports Bikes'
);


SELECT *
FROM production.categories;


/*=========================================================
                    UPDATE
=========================================================*/

UPDATE production.categories
SET category_name = 'Pink Bikes'
WHERE category_id = 9;


/*=========================================================
                    INSERT EXAMPLES
=========================================================*/

INSERT INTO production.brands
(
    brand_name
)
VALUES
(
    'Giant'
),
(
    'Specialized'
),
(
    'Cannondale'
);


-- Identity column example
INSERT INTO production.categories
(
    category_name
)
VALUES
(
    'E-Bikes'
);


-- Insert from another table

INSERT INTO production.products_archive
SELECT *
FROM production.products
WHERE model_year < 2020;


/*=========================================================
                    UPDATE & DELETE
=========================================================*/

UPDATE table_name
SET column1 = value1,
    column2 = value2
WHERE condition;


DELETE
FROM table_name
WHERE condition;


/*=========================================================
                    PRACTICE COMMANDS
=========================================================*/

-- CREATE TABLE

-- ALTER TABLE

-- DROP TABLE

-- INSERT

-- UPDATE

-- DELETE

-- Check constraints using SELECT queries
