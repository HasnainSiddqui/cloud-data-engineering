CREATE TABLE production.parts(
    part_id identity INT NOT NULL, 
    part_name VARCHAR(100)
);
ALTER TABLE production.parts
ADD PRIMARY KEY (part_id);

DROP TABLE production.parts;

INSERT INTO 
    production.parts(part_id, part_name)
VALUES
    (1,'Frame'),
    (2,'Head Tube'),
    (3,'Handlebar Grip'),
    (4,'Shock Absorber'),
    (5,'Fork');




SELECT 
    part_id, 
    part_name
FROM 
    production.parts
WHERE 
    part_id = 5;

CREATE CLUSTERED INDEX ix_parts_id
ON production.parts (part_id);  

SELECT  * FROM sales.ORDERS
WHERE order_id = 6;

SELECT  * FROM sales.ORDERS
where customer_id = 259;


CREATE TABLE production.parts (
    part_id INT IDENTITY(1,1),
    part_name VARCHAR(100) NOT NULL
);

WITH parts AS (
    SELECT *
    FROM (VALUES
        ('Frame'),
        ('Head Tube'),
        ('Handlebar Grip'),
        ('Shock Absorber'),
        ('Fork')
    ) AS p(part_name)
),
nums AS (
    SELECT TOP (2000000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects a
    CROSS JOIN sys.objects b
)

INSERT INTO production.parts(part_name)
SELECT
    CONCAT(p.part_name, '_', n.n)
FROM nums n
CROSS JOIN parts p;

select * from production.parts;  -- 3.2M



select * from production.parts
where part_id = 3129380;


SELECT  * FROM sales.ORDERS
where customer_id = 259;


CREATE INDEX ix_customers_id
ON sales.ORDERS(customer_id);


SELECT 
    customer_id, 
    first_name, 
    last_name
FROM 
    sales.customers
WHERE 
   first_name = 'Monika' and last_name = 'Berg';

CREATE INDEX ix_customers_name 
ON sales.customers(last_name, first_name);


SELECT 
    customer_id, 
    first_name, 
    last_name
FROM 
    sales.customers
WHERE 
   (last_name = 'Berg' and first_name = 'Monika')
   or city = 'Atwater';



select * from sales.customers;

CREATE VIEW sales.product_info
AS
select customer_id , first_name
from sales.customers;

