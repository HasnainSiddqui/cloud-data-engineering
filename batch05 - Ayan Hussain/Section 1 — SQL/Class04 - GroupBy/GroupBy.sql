-- Group By
-- Grouping on same values 


-- Syntax

-- GROUP BY 
--		COLUMN LIST

select * from sales.orders;

-- Date functions 
-- year(date), day, month 

select customer_id,
	year(order_date) as order_year
	from sales.orders
where 
	customer_id in (1,2)
group by 
	customer_id,
	year(order_date)

-- Aggregate functions ---Count, Max Min, Sum, avg 

select customer_id
	from sales.orders
where 
	customer_id in (1,2)
group by 
	customer_id

select 
	customer_id,
	year(order_date) as order_year,
	count(order_id) as order_count
from 
	sales.orders
where 
	customer_id in (1,2,115)
group by 
	customer_id,
	year(order_date)

-- customers count by city 
select 
	city,
	count(customer_id) as customer_count
from 
	sales.customers
group by 
	city
order by 
	city

-- Max & min value in every category
select 
	category_id,
	max(list_price) as max_price,
	min(list_price) as min_price
from production.products
group by 
	category_id



-- har order_id ki net_value

-- Sum(
-- honda bike 2 (2*list_price)
-- suz bike 1 (1*list_price)
-- toyotta 1  (1*list_price)
-- ) - discount 

select 
	order_id,
	sum(
		quantity * list_price * (1 - discount)
	) as net_value
from sales.order_items
group by 
	order_id;

select * from sales.order_items

-- 100 0.30
-- 30% -- 30rs
-- 70% 70rs
-- 100 *(1 - 0.70) == 70

--  (100% - 30%) == 70% pay wali percentage


-- Having 

select 
	customer_id,
	year(order_date) as order_year,
	count(order_id) as order_count
from 
	sales.orders
where 
	customer_id in (1,2,115)
group by 
	customer_id,
	year(order_date)
having 
	count(order_id) > 1;



-- Max & min value in every category
select 
	category_id,
	max(list_price) as max_price,
	min(list_price) as min_price
from production.products
group by 
	category_id
having 
	avg(list_price) > 1000


-- AVG PRICE FOR EVERY CATEGORY (500 - 1000)
SELECT 
	category_id,
	avg(list_price) as avg_price
from production.products
group by 
	category_id
having 
	avg(list_price) between 500 AND 1000