-- SUBQUERY 

-- Nested Query 
-- Where/Select/From 

select customer_id 
from sales.customers
where city = 'New York'

select * 
	from sales.orders
where customer_id in (
	16,178,327,411,854,927,1016)


select  -- Outer Query
	*
From 
	sales.orders
where customer_id IN (
	select -- Inner Query
		customer_id
	from 
		sales.customers
	where 
		city = 'New York'
	)

-- wo products chayai hain jinki price avg price se zayada using subquery
select product_name,
	list_price
from 
	production.products 
where list_price >
	(select avg (list_price) from production.products where brand_id in 
	(select brand_id from production.brands where brand_name in ('electra','trek')))

select * from production.brands
--Electra
--Trek
select * from production.categories

-- find product name of these two categories 
-- Comfort Bicycles
-- Electric Bikes


select *
from production.products
where category_id in (select category_id from production.categories 
where category_name in ('Comfort Bicycles', 'Electric Bikes'
)) 


-- Find product details where prouct stocks quantity greater than 30  

select *
from production.products
where product_id in (select product_id from production.stocks where quantity > 25)
