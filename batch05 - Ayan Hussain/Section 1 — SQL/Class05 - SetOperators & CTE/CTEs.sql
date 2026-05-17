-- CTE -- Common table expressions 

-- it allows to store the temporary result 

-- query readable, understandable, Reusability

-- Syntax 

--With cte_name(columns names) 
--as 
--	(cte_query)

-- sql_statment;

select 
	order_id,
	sum(
		quantity * list_price * (1 - discount)
	) as net_value
from sales.order_items
group by 
	order_id;

-- ayan 10000 
-- mohsin 15000



SELECT 
	first_name + ' ' + last_name as full_name,
	sum(
		quantity * list_price * (1 - discount)
	) as net_sales,
	year(o.order_date) as year_order
from sales.staffs st
	join sales.orders o
		on o.staff_id = st.staff_id
	join sales.order_items ot
		on ot.order_id =  o.order_id
group by 
		first_name + ' ' + last_name,
		year(o.order_date);

With cte_sales_by_staff(full_name,net_sales,year_order)
AS
	(
	SELECT 
		first_name + ' ' + last_name as full_name,
		sum(
			quantity * list_price * (1 - discount)
		) as net_sales,
		year(o.order_date) as year_order
	from sales.staffs st
		join sales.orders o
			on o.staff_id = st.staff_id
		join sales.order_items ot
			on ot.order_id =  o.order_id
		group by 
			first_name + ' ' + last_name,
			year(o.order_date)
	)
select * from cte_sales_by_staff
where year_order =  '2016';




With cte_sales_by_staff(full_name,net_sales,year_order)
AS
	(
	SELECT 
		first_name + ' ' + last_name as full_name,
		sum(
			quantity * list_price * (1 - discount)
		) as net_sales,
		year(o.order_date) as year_order
	from sales.staffs st
		join sales.orders o
			on o.staff_id = st.staff_id
		join sales.order_items ot
			on ot.order_id =  o.order_id
		group by 
			first_name + ' ' + last_name,
			year(o.order_date)
	)

select * from cte_sales_by_staff
union 
select * from cte_sales_by_staff;

-- select * from cte_sales_by_staff; does not exist

SELECT 
	first_name + ' ' + last_name as full_name,
	sum(
		quantity * list_price * (1 - discount)
	) as net_sales,
	year(o.order_date) as year_order
from sales.staffs st
	join sales.orders o
		on o.staff_id = st.staff_id
	join sales.order_items ot
		on ot.order_id =  o.order_id
	group by 
		first_name + ' ' + last_name,
		year(o.order_date)

union 


SELECT 
	first_name + ' ' + last_name as full_name,
	sum(
		quantity * list_price * (1 - discount)
	) as net_sales,
	year(o.order_date) as year_order
from sales.staffs st
	join sales.orders o
		on o.staff_id = st.staff_id
	join sales.order_items ot
		on ot.order_id =  o.order_id
	group by 
		first_name + ' ' + last_name,
		year(o.order_date)


-- Find order count by staff_id

SELECT
	staff_id,
	count(*) as order_count
FROM sales.orders
Group by 
	staff_id;

with sales(staff_id, orders)
as 
	(
	SELECT
		staff_id,
		count(*) as order_count
	FROM sales.orders
	Group by 
		staff_id
	)

select avg(orders) as avg_order_count from sales; 

with sales(staff_id, ordersss) -- column name hai 
as 
	(
	SELECT
		staff_id,
		count(*)
	FROM sales.orders
	Group by 
		staff_id
	)
select * from sales;


-- Query 1 -- category_counts (Category_id, category_name , product_count)
-- Query 2 -- category_sales  (category_id, sales) 
-- Output  -- (Category_id, category_name, product_count, sales ) -- inner join 

select
	c.category_id,
	c.category_name,
	count(p.product_id) as product_count

from production.products p
	join production.categories c 
		on p.category_id = c.category_id
group by 
	c.category_id,
	c.category_name


-- Query 2 -- option 1

select 
	c.category_id,
	sum(
		quantity * oi.list_price * (1 - discount)
	) as net_sales

from production.categories c
join production.products p 
	on p.category_id = c.category_id
join sales.order_items oi
	on oi.product_id = p.product_id
group by 
		c.category_id

-- Query 2 -- option 2

select 
	p.category_id,
	sum(
		quantity * oi.list_price * (1 - discount)
	) as net_sales
from production.products p
join sales.order_items oi
	on oi.product_id = p.product_id
group by 
		p.category_id;


	-- Main Query 

WITH cte_category_counts(Category_id, category_name , product_count)
as
	(
select
	c.category_id,
	c.category_name,
	count(p.product_id) as product_count

from production.products p
	join production.categories c 
		on p.category_id = c.category_id
group by 
	c.category_id,
	c.category_name
)
,

cte_category_sales (category_id, sales) 
AS 
	(
	select 
		p.category_id,
		sum(
			quantity * oi.list_price * (1 - discount)
		) as net_sales
	from production.products p
	join sales.order_items oi
		on oi.product_id = p.product_id
	group by 
			p.category_id
	)

SELECT
	cs.Category_id, category_name, product_count, sales
FROM 
	cte_category_counts cc
inner join cte_category_sales cs
	on cc.Category_id = cs.category_id


-- HW  where order_status is completed 4