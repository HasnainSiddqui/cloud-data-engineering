-- Windows Functions 

-- Syntax 

--ROW_NUMBER() OVER (
--    [PARTITION BY partition_expression, ... ]
--    ORDER BY sort_expression [ASC | DESC], ...
--)

RANK() OVER (
    [PARTITION BY partition_expression, ... ]
    ORDER BY sort_expression [ASC | DESC], ...
)

-- without partition by 

SELECT 
   ROW_NUMBER() OVER (
	ORDER BY first_name
   ) row_num,
   first_name, 
   last_name, 
   city
FROM 
   sales.customers;


with cte_row_num 
AS (
SELECT 
	customer
   ROW_NUMBER() OVER (
	partition by first_name, last_name
	ORDER BY first_name
   ) row_num,
   first_name, 
   last_name, 
   city
FROM 
   sales.customers_2
   )
   
delete from cte_row_num
where row_num > 1;


delete from sales.customers;


SELECT *
INTO sales.customers_3
FROM sales.customers;



with cte_row_num 
AS (
SELECT 
	customer_id,
   ROW_NUMBER() OVER (
	partition by first_name, last_name
	ORDER BY first_name
   ) row_num,
   first_name, 
   last_name, 
   city
FROM 
   sales.customers_3
   )
   
delete from sales.customers_3
where customer_id = (select customer_id from cte_row_num where row_num > 1);


RANK() OVER (
    [PARTITION BY partition_expression, ... ]
    ORDER BY sort_expression [ASC | DESC], ...
)



SELECT 
   RANK() OVER (
	partition by first_name, last_name
	ORDER BY first_name
   ) row_num,
   first_name, 
   last_name, 
   city
FROM 
   sales.customers


SELECT
	product_id,
	product_name,
	list_price,
	RANK () OVER ( 
		ORDER BY list_price DESC
	) price_rank ,
	dense_RANK () OVER ( 
		ORDER BY list_price DESC
	) price_rank 

FROM
	production.products;


--  LAG 
--LAG(return_value ,offset [,default]) 
--OVER (
--    [PARTITION BY partition_expression, ... ]
--    ORDER BY sort_expression [ASC | DESC], ...
--)


CREATE VIEW sales.vw_netsales_brands
AS
	SELECT 
		c.brand_name, 
		MONTH(o.order_date) month, 
		YEAR(o.order_date) year, 
		CONVERT(DEC(10, 0), SUM((i.list_price * i.quantity) * (1 - i.discount))) AS net_sales
	FROM sales.orders AS o
		INNER JOIN sales.order_items AS i ON i.order_id = o.order_id
		INNER JOIN production.products AS p ON p.product_id = i.product_id
		INNER JOIN production.brands AS c ON c.brand_id = p.brand_id
	GROUP BY c.brand_name, 
			MONTH(o.order_date), 
			YEAR(o.order_date);


SELECT 
	*
FROM 
	sales.vw_netsales_brands
ORDER BY 
	year, 
	month, 
	brand_name, 
	net_sales;




WITH cte_netsales_2018 AS(
	SELECT 
		month, 
		SUM(net_sales) net_sales
	FROM 
		sales.vw_netsales_brands
	WHERE 
		year = 2018
	GROUP BY 
		month
)
SELECT 
	month,
	net_sales,
	LAG(net_sales,1) OVER (
		ORDER BY month
	) previous_month_sales
FROM 
	cte_netsales_2018;


-- Lead 


WITH cte_netsales_2018 AS(
	SELECT 
		month, 
		SUM(net_sales) net_sales
	FROM 
		sales.vw_netsales_brands
	WHERE 
		year = 2018
	GROUP BY 
		month
)
SELECT 
	month,
	net_sales,
	lead(net_sales,1) OVER (
		ORDER BY month
	) previous_month_sales
FROM 
	cte_netsales_2018;
