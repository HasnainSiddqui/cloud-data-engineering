-- Section 11 

-- insert 

--INSERT INTO table_name (column_list)
--VALUES (value_list);

INSERT INTO production.products(product_id, product_name, brand_id, category_id, model_year, list_price) VALUES(1,'Trek 820 - 2016',9,6,2016,379.99)

SET IDENTITY_INSERT production.brands ON;  

INSERT INTO production.brands(brand_name)
Output inserted.brand_id
VALUES('Electra-5')


-- inserted
-- deleted 

SET IDENTITY_INSERT production.brands OFF;  


select * from production.brands;


CREATE TABLE production.brands (
	brand_id INT IDENTITY (1, 1) PRIMARY KEY,
	brand_name VARCHAR (255) NOT NULL
);



INSERT INTO production.categories(category_id,category_name)
	VALUES(1,'Children Bicycles'),
			(2,'Comfort Bicycles'),
			(3,'Cruisers Bicycles')

-- Insert into Select 

select * from sales.customers;


-- NY customers --new table 
select * from sales.customers
where state = 'NY'


create table new_york_customers(
		customer_id int, 
		customer_name varchar(max)
	)

insert into 
	new_york_customers(customer_id, customer_name)
select 
	customer_id,
	first_name + ' ' + last_name
	from sales.customers
where state = 'NY';


SELECT * FROM new_york_customers;



-- Update 

--UPDATE 
--    table_name
--SET 
--    c1 = v1, 
--    c2 = v2, 
--    ...,
--    cn = vn
--[WHERE condition]


select * from production.brands;

update 
	production.brands
set brand_name = 'Electra-6'
where brand_id = 103 or brand_id = 102;

-- created_timestamp 
-- updated_timestamp

-- GETDATE()


-- Delete


--DELETE [ TOP ( expression ) [ PERCENT ] ]  
--FROM table_name
--[WHERE search_condition];

DELETE FROM production.brands
WHERE brand_id = 103;



CREATE TABLE sales.category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    amount DECIMAL(10 , 2 )
);

INSERT INTO sales.category(category_id, category_name, amount)
VALUES(1,'Children Bicycles',15000),
    (2,'Comfort Bicycles',25000),
    (3,'Cruisers Bicycles',13000),
    (4,'Cyclocross Bicycles',10000);


CREATE TABLE sales.category_staging (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    amount DECIMAL(10 , 2 )
);


INSERT INTO sales.category_staging(category_id, category_name, amount)
VALUES(1,'Children Bicycles',15000),
    (3,'Cruisers Bicycles',13000),
    (4,'Cyclocross Bicycles',20000),
    (5,'Electric Bikes',10000),
    (6,'Mountain Bikes',10000);


MERGE sales.category t 
    USING sales.category_staging s
ON (s.category_id = t.category_id)
WHEN MATCHED
    THEN UPDATE SET 
        t.category_name = s.category_name,
        t.amount = s.amount
WHEN NOT MATCHED BY TARGET 
    THEN INSERT (category_id, category_name, amount)
         VALUES (s.category_id, s.category_name, s.amount)
WHEN NOT MATCHED BY SOURCE 
    THEN DELETE;


select * from sales.category;


-- Transactions 


CREATE TABLE invoices (
  id int IDENTITY PRIMARY KEY,
  customer_id int NOT NULL,
  total decimal(10, 2) NOT NULL DEFAULT 0 CHECK (total >= 0)
);

CREATE TABLE invoice_items (
  id int,
  invoice_id int NOT NULL,
  item_name varchar(100) NOT NULL,
  amount decimal(10, 2) NOT NULL CHECK (amount >= 0),
  tax decimal(4, 2) NOT NULL CHECK (tax >= 0),
  PRIMARY KEY (id, invoice_id),
  FOREIGN KEY (invoice_id) REFERENCES invoices (id)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);


BEGIN TRANSACTION;

INSERT INTO invoices (customer_id, total)
VALUES (100, 0);

INSERT INTO invoice_items (id, invoice_id, item_name, amount, tax)
VALUES (10, 1, 'Keyboard', 70, 0.08),
       (20, 1, 'Mouse', 50, 0.08);

UPDATE invoices
SET total = (SELECT
  SUM(amount * (1 + tax))
FROM invoice_items
WHERE invoice_id = 1);

COMMIT;


select * from invoices;