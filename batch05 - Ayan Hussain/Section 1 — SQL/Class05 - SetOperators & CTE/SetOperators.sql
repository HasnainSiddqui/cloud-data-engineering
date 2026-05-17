-- Set Operators 

-- Union Combine the results of two tables or select statements 


-- JOINS Combine the columns from two tables while unions joins rows from two tables 

-- query 1 
-- union 
-- query 2 

SELECT first_name, last_name
	from sales.staffs -- 10 
UNION -- (EXPECTED	1455) ACTUAL 1454 
SELECT first_name, last_name
	from sales.customers -- 1445


-- UNION vs UNION ALL ( It includes duplicates as well )


SELECT first_name, last_name
	from sales.staffs -- 10 
UNION ALL-- (EXPECTED 1455) ACTUAL 1455 
SELECT first_name, last_name
	from sales.customers -- 1445

-- Same name does not matter 
SELECT email as first_name, last_name
	from sales.staffs -- 10 
UNION ALL 
SELECT first_name, last_name
	from sales.customers -- 1445

-- data type should be same


-- two tables 
-- first_name 
-- fristname

-- All queries combined using a UNION, INTERSECT or EXCEPT operator must have an equal number of expressions in their target lists.
SELECT first_name, last_name, email
	from sales.staffs -- 10 
UNION ALL 
SELECT first_name, last_name
	from sales.customers -- 1445

-- No of columns should be same
SELECT first_name, last_name, email -- no of columns 3
	from sales.staffs -- 10 
UNION ALL 
SELECT first_name, last_name, 'null' as email -- no of columns 3
	from sales.customers -- 1445


-- Intersect -- common rows 

select city from sales.customers
intersect
select city from sales.stores;


SELECT first_name, last_name
	from sales.staffs  
intersect  
SELECT first_name, last_name
	from sales.customers;

SELECT first_name, last_name,
	count(*) as name_count
	from sales.customers
	group by 
		first_name, last_name
	order by count(*) desc
	;

SELECT first_name, last_name,
	count(*) as name_count
	from sales.customers
	group by 
		first_name, last_name
	having count(*) > 1;

-- Except  -- Home Work

