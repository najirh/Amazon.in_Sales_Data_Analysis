-- Amazon Sales Analysis Projects 

-- Create the table so we can import the data

CREATE TABLE sales(
					id int PRIMARY KEY,
					order_date date,
					customer_name VARCHAR(25),
					state VARCHAR(25),
					category VARCHAR(25),
					sub_category VARCHAR(25),
					product_name VARCHAR(255),
					sales FLOAT,
					quantity INT,
					profit FLOAT
					);

-- Importing the data into the table 

-- -------------------------------------------------------------------------------------
-- Exploratory Data Analysis and Pre Processing
-- -------------------------------------------------------------------------------------


--  Checking total rows count

SELECT * FROM sales;

SELECT COUNT(*)
FROM sales;

-- Checking if there any missing values

SELECT COUNT(*)
FROM sales
WHERE id IS NULL 
   OR order_date IS NULL 
   OR customer_name IS NULL 
   OR state IS NULL 
   OR category IS NULL 
   OR sub_category IS NULL 
   OR product_name IS NULL 
   OR sales IS NULL 
   OR quantity IS NULL 
   OR profit IS NULL;

--  Checking for duplicate entry


SELECT * FROM 
	(SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) as rn
FROM sales ) x
WHERE rn > 1;


-- -------------------------------------------------------------------------------------
-- Feature Engineering 
-- -------------------------------------------------------------------------------------


--  creating a year column
ALTER TABLE sales
ADD COLUMN YEAR VARCHAR(4);
-- adding year value into the year column
UPDATE sales
SET year = EXTRACT(YEAR FROM order_date);

-- creating a new column for the month 
ALTER TABLE sales
ADD COLUMN MONTH VARCHAR(15);

-- adding abbreviated month name  
UPDATE sales
SET month = TO_CHAR(order_date, 'mon');

-- adding new column as day_name
ALTER TABLE sales
ADD COLUMN day_name VARCHAR(15);

-- updating day name into the day column
UPDATE sales 
SET day_name = TO_CHAR(order_date, 'day');

SELECT TO_CHAR(order_date, 'day')
FROM sales;



-- -------------------------------------------------------------------------------------
-- Solving Business Problems 
-- -------------------------------------------------------------------------------------

-- Q.1 Find total sales for each category ?

SELECT 
	category,
	SUM(sales) as total_sales
FROM sales
GROUP BY 1
ORDER BY 2 DESC;


-- Q.2 Find out top 5 customers who made the highest profits?
SELECT 
	customer_name,
	SUM(profit) as total_profit
FROM sales
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 5;

-- Q.3 Find out average qty ordered per category 
SELECT
	category,
	AVG(quantity) as avg_qty_ordered
FROM sales
GROUP BY 1
ORDER BY 2 DESC;


-- Q.4 Top 5 products that has generated highest revenue 

SELECT 
    product_name,
    ROUND(SUM(sales)::numeric, 2) as revenue
FROM 
    sales
GROUP BY 
    1
ORDER BY 
    2 DESC
LIMIT 5;


-- Q.5 Top 5 products whose revenue has decreased in comparison to previous year?

WITH py1 
AS (
	SELECT
		product_name,
		SUM(sales) as revenue
	FROM sales
	WHERE year = '2023'
	GROUP BY 1
),
py2 
AS	(
	SELECT
		product_name,
		SUM(sales) as revenue
	FROM sales
	WHERE year = '2022'
	GROUP BY 1
)
SELECT
	py1.product_name,
	py1.revenue as current_revenue,
	py2.revenue as prev_revenue,
	(py1.revenue / py2.revenue) as revenue_decreased_ratio
FROM py1
JOIN py2
ON py1.product_name = py2.product_name
WHERE py1.revenue < py2.revenue
ORDER BY 2 DESC
LIMIT 5;
	

-- Q.6 Highest profitable sub category ?

SELECT 
	sub_category,
	sum(profit)
FROM sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- Q.7 Find out states with highest total orders?
SELECT 
	state,
	COUNT(id) as total_order
FROM sales
GROUP BY 1
ORDER BY 2 DESC; 
	
-- Q.8 Determine the month with the highest number of orders.

SELECT 
	(month ||'-' || year) month_name, -- for mysql CONCAT()
	COUNT(id)
FROM sales
GROUP BY 1
ORDER BY 2 DESC;
	
-- Q.9 Calculate the profit margin percentage for each sale (Profit divided by Sales).

SELECT 
	profit/sales as profit_mergin
FROM sales

-- 10 Calculate the percentage contribution of each sub-category to 
-- the total sales amount for the year 2023.

WITH CTE
	AS (SELECT
			sub_category,
			SUM(sales) as revenue_per_category
		FROM sales
		WHERE year = '2023'
		GROUP BY 1

)

SELECT	
	sub_category,
	(revenue_per_category / total_sales * 100)
FROM cte
CROSS JOIN
(SELECT SUM(sales) AS total_sales FROM sales WHERE year = '2023') AS cte1;


-- End of Projects 
