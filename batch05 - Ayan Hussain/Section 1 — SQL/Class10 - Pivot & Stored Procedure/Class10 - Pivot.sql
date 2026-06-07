SELECT 
	category_name,
	count(product_id) as product_count
FROM production.categories c
INNER JOIN production.products p
	on c.category_id = p.category_id
group by 
	category_name;

-- Subquery 

-- From 
-- Where 
-- Select 


SELECT * FROM    
(
    SELECT 
        category_name, 
        product_id
    FROM 
        production.products p
        INNER JOIN production.categories c 
            ON c.category_id = p.category_id
) t 
PIVOT(
    COUNT(product_id) 
    FOR category_name IN (
        [Children Bicycles], 
        [Comfort Bicycles], 
        [Cruisers Bicycles], 
        [Cyclocross Bicycles], 
        [Electric Bikes], 
        [Mountain Bikes], 
        [Road Bikes])
) AS pivot_table;


SELECT * FROM    
(
    SELECT 
        category_name, 
        product_id,
		model_year
    FROM 
        production.products p
        INNER JOIN production.categories c 
            ON c.category_id = p.category_id
) t 
PIVOT(
    COUNT(product_id) 
    FOR category_name IN (
        [Children Bicycles], 
        [Comfort Bicycles], 
        [Cruisers Bicycles], 
        [Cyclocross Bicycles], 
        [Electric Bikes], 
        [Mountain Bikes], 
        [Road Bikes])
) AS pivot_table;

-- H.W 

--'Pending'
--'Processing'
--'Rejected'
--'Completed'

-- count 