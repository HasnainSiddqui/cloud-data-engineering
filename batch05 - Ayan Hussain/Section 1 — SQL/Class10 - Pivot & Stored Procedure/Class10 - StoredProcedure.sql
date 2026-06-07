-- Stored Procedure 

SELECT 
	product_name, 
	list_price
FROM 
	production.products
ORDER BY 
	product_name;

-- Syntax 
--

--CREATE PROCEDURE procedure_name 
--AS
--Begin 
--	query 
--End

CREATE PROCEDURE product_list
As 
BEGIN
	SELECT 
		product_name, 
		list_price
	FROM 
		production.products
	ORDER BY 
		product_name;
END;

-- Execute

EXECUTE product_list;


ALTER PROCEDURE [dbo].[product_list]
As 
BEGIN
	SELECT 
		product_name, 
		list_price,
		product_id
	FROM 
		production.products
	ORDER BY 
		product_name;
END;


-- DROP PROCEDURE procedure_name


--EXEC sp_rename 'sales.contr', 'contracts';

--EXEC sp_rename 'contr', 'contracts', 'COLUMN'	;


CREATE PROCEDURE product_list_2(@min_list_price as decimal)
As 
BEGIN
	SELECT 
		product_name, 
		list_price
	FROM 
		production.products
	where 
		list_price >= @min_list_price
	ORDER BY 
		product_name;
END;

EXEC product_list_2 10000;
-- MULTIPLE PARAMETERS


CREATE PROCEDURE product_list_3(@min_list_price as decimal, @max_list_price as decimal)
As 
BEGIN
	SELECT 
		product_name, 
		list_price
	FROM 
		production.products
	where 
		list_price >= @min_list_price
		and list_price <= @max_list_price
	ORDER BY 
		product_name;
END;

EXEC product_list_3 100,2500;

-- Default paramter

CREATE PROCEDURE product_list_4(
	@min_list_price as decimal = 0, -- default
	@max_list_price as decimal = 10000000)
As 
BEGIN
	SELECT 
		product_name, 
		list_price
	FROM 
		production.products
	where 
		list_price >= @min_list_price
		and list_price <= @max_list_price
	ORDER BY 
		product_name;
END;


EXEC product_list_4 1000;

select * from production.products
where product_name like 'Trek%';


CREATE PROCEDURE product_list_5(
	@min_list_price as decimal = 0, -- default
	@max_list_price as decimal = 10000000,
	@name AS VARCHAR(max))
As 
BEGIN
	SELECT 
		product_name, 
		list_price
	FROM 
		production.products
	where 
		list_price >= @min_list_price
		and list_price <= @max_list_price
		and product_name like  @name + '%'
	ORDER BY 
		product_name;
END;

EXECUTE product_list_5 
    @name = 'Trek';


-- Declare Variable 

DECLARE @model_year int;

SET @model_year = 2018; -- harcoded 

SELECT
    product_name,
    model_year,
    list_price 
FROM 
    production.products
WHERE 
    model_year = @model_year
ORDER BY
    product_name;


declare @product_count int;

set @product_count = 
	(select count(*)  from production.products
	)
print @product_count;
select @product_count as product_count;



CREATE  PROC uspGetProductList1(
    @model_year SMALLINT
) AS 
BEGIN
    DECLARE @product_list VARCHAR(MAX);

    SET @product_list = ''; -- empty

    SELECT
        @product_list = @product_list + product_name 
                        + CHAR(10)

    FROM 
        production.products
    WHERE
        model_year = @model_year
    ORDER BY 
        product_name;

    PRINT @product_list;
END;

EXEC uspGetProductList1 2018

select char(97);



BEGIN
    DECLARE @sales INT;

    SELECT 
        @sales = SUM(list_price * quantity)
    FROM
        sales.order_items i
        INNER JOIN sales.orders o ON o.order_id = i.order_id
    WHERE
        YEAR(order_date) = 2018;

    SELECT @sales;
	print @sales;

    IF @sales > 10000000
        PRINT 'Great! The sales amount in 2018 is greater than 1,0000,000';
	Else
        PRINT 'Alas! The sales amount in 2018 is less than 1,00000000';
END


-- While Loop 

--WHILE Boolean_expression  -- condition
--     { sql_statement | statement_block}  


DECLARE @counter INT = 1;

WHILE @counter <= 5
BEGIN
    PRINT @counter;
    SET @counter = @counter + 1;
END



DECLARE @counter INT = 1;

WHILE @counter <= 10
BEGIN
    PRINT @counter;
    SET @counter = @counter + 1;

	if @counter = 5
		Break
END


DECLARE @counter INT = 1;

WHILE @counter <= 10
BEGIN

	SET @counter = @counter + 1;
	
	if @counter = 5
		continue
	PRINT @counter;
END