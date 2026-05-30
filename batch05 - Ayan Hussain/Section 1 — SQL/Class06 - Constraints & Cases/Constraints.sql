-- Constraints

-- Primary key 
-- foriegn key
-- Not null constraint 
-- Unqiue constraint
-- Check constraint


-- Primary key 
-- Unique id that identifies each row uniquely 
-- Not null

--Create table table_name (
--	id data_type primary key,
--	....
--)

-- Composite key -- more than 1 column combined


create table order_items (
	order_id int ,
	item_id  int,
	quantity int,
	primary key (order_id, item_id)
	)

-- Alter 
create table order_items_2 (
	order_id int ,
	item_id  int,
	quantity int
	)
alter table order_items_2
add primary key (order_id, item_id)

-- Foreign keys 

create table vendor_group(
	group_id int primary key,
	group_name varchar(100)
)
create table vendors(
	vendor_id int primary key,  -- identity 
	vendor_name varchar(100),
	group_id int, 
	constraint fk_group Foreign key (group_id)
	references vendor_group (group_id)
	on update cascade
	on delete set null 
	)

insert into vendor_group(group_id, group_name)
values (1,	'Mandi'),
	    (2,	'Lucky'),
		(3,  'Kababjees')

insert into vendors(vendor_id ,vendor_name,group_id)
values (14,	'lucky one',2),
	    (15,'kfc',2),
		(16,  'bakers',3)

select * from vendors

-- referential integrities 
-- On delete
-- on update


-- on update no action 
-- on update cascade
-- on update set null
-- on update set default 100


-- On delete no action
-- On delete cascade
-- On delete set null
-- On delete set default



-- 3rd Constraint 
-- Not null 
drop table vendor_group;

--create table vendor_group_2(
--	group_id int primary key,
--	group_name varchar(100) Not null
--)
--insert into vendor_group_2(group_id, group_name)
--values (1,)

------------------------------------ Unique Constraint ---------------

-- Cnic, phone number, email 

-- ayanhussain@gmail.com 
-- ayanhussain@gmail.com -- 2nd time -- it shows an error 

-- primary vs unique 

-- create table vendor_group(
--	group_id int primary key,
--	group_name varchar(100),
--  email varchar(100),
--  constraint unique_email unique(email)
--)


----------------------------------- Check Constraint ---------------------

create table dummy_products(
	product_id int primary key, 
	product_name varchar(255) not null Unique,
	unit_price int check(unit_price > 0)
	)

insert into dummy_products(product_id,product_name,unit_price)
values (123, 'bike' , 1000)

insert into dummy_products(product_id,product_name,unit_price)
values (12, 'bike_2' , 0)

insert into dummy_products(product_id,product_name,unit_price)
values (12, 'bike' ,20)


select * from sales.orders -- 1615 
-- 4 completed -- 9
-- 3 rejected  -- 8 
-- 2 processing -- 10
-- 1 pending     -- 7


select 
	order_status,
	count(order_id) as order_count 
from sales.orders 
group by 
	order_status
order by order_status;

-- compeleted -- 1145
-- pending -- 62

-- Case Expressions

-- Case syntax 
-- case input 
--		when value1 then result1
--      when value2 then result2
--      else



select 
	case order_status
		when 1 then 'Pending'
		when 2 then 'Processing'
		when 3 then 'Rejected'
		when 4 then 'Completed'
		else 
			'unknown'
	End as Order_status,
	count(order_id) as order_count 
from sales.orders 
group by 
	order_status
order by order_status;


-- order_id, order_value (sum (quantity * list_price)) , order_priority
-- order_priority less than 1000 "Low"
-- order_priority greater than 1000 and less than 5000 "Medium"
-- order_priority greater than 5000 "High"
--when sum (quantity * list_price) < 10000
--	rhen low 


select 
	order_id,
	sum(quantity * list_price) as order_value,
	case 
		when sum(quantity * list_price) <= 1000
			then 'low'
		when sum(quantity * list_price) > 1000 AND sum(quantity * list_price) <= 5000
			then 'medium'
		when sum(quantity * list_price) > 5000
			then 'high'
	End as order_priority
from sales.order_items
group by 
	order_id


-- Coalesce