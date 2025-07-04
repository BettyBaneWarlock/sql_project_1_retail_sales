-- SQL Analysis Project: Retail Sales
CREATE DATABASE retail_sales_db;

-- Creating the Table 
DROP TABLE IF EXISTS retail_sales_tb;

-- Deleting table of same name if exists
CREATE TABLE retail_sales_tb (
	transactions_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(15),
	age INT,
	category VARCHAR(100),
	quantity INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
);

-- Checking if data was correctly imported
SELECT *
FROM retail_sales_tb;

SELECT *
FROM retail_sales_tb
LIMIT 10;

-- Checking amount of rows
SELECT COUNT(*)
FROM retail_sales_tb;

-- DATA CLEANING
-- Checking for null values, one column at a time
SELECT *
FROM retail_sales_tb
WHERE transactions_id IS NULL;

SELECT *
FROM retail_sales_tb
WHERE sale_date IS NULL;

-- Checking for null values, all at once
SELECT *
FROM retail_sales_tb
WHERE
	transactions_id IS NULL
	OR sale_date IS NULL
	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR age IS NULL
	OR category IS NULL
	OR quantity IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL;

-- Deleting rows with null values (with the exception of null ages)
DELETE FROM retail_sales_tb
WHERE
	transactions_id IS NULL
	OR sale_date IS NULL
	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR category IS NULL
	OR quantity IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL;

-- DATA EXPLORATION
-- How many individual sales are there?
SELECT
	COUNT(*) AS total_sales
FROM retail_sales_tb;

-- How many unique customers are there?
SELECT
	COUNT(DISTINCT customer_id) AS total_customers
FROM retail_sales_tb;

-- What are the unique categories?
SELECT 
	DISTINCT category
FROM retail_sales_tb;

--  DATA ANALYSIS AND BUSINESS KEY PROBLEMS AND ANSWERS
-- Query 1 - Retrieve all columns for sales made on '2022-11-05'.
SELECT *
FROM retail_sales_tb
WHERE sale_date = '2022-11-05';

-- Query 2 - Retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of November-2022.
SELECT *
FROM retail_sales_tb
WHERE
	category = 'Clothing'
	AND quantity >= 4
	AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';

-- Query 3 - Calculate the total sales for each category.
SELECT
	category,
	SUM(total_sale) AS net_sales,
	COUNT(*) AS total_orders
FROM retail_sales_tb
GROUP BY 1;

-- Query 4 - Find the average age of customers who purchased items from the 'Beauty' category.
SELECT
	ROUND(AVG(age), 2) AS average_age
FROM retail_sales_tb
WHERE category = 'Beauty';

-- Query 5 - Find all transactions where the total sales is greater than 1000.
SELECT *
	-- COUNT(*) AS num_of_big_sales
FROM retail_sales_tb
WHERE total_sale > 1000;

-- Query 6 - Find the total number of transactions made by each gender in each category.
SELECT
	category,
	gender,
	COUNT(transactions_id) AS total_transactions
FROM retail_sales_tb
GROUP BY 1, 2
ORDER BY 1, 2;

-- Query 7 - Calculate the average sale for each month. Find out best selling month in each year.
SELECT *
FROM
	(
		SELECT
			EXTRACT(YEAR FROM sale_date) AS YEAR,
			EXTRACT(MONTH FROM sale_date) AS MONTH,
			AVG(total_sale) AS avg_sale,
			RANK() OVER (
				PARTITION BY EXTRACT(YEAR FROM sale_date)
				ORDER BY AVG(total_sale) DESC) AS rank_of_sales
		FROM retail_sales_tb
		GROUP BY 1, 2
			-- ORDER BY 1,	3 DESC
	) AS t1
WHERE rank_of_sales = 1;

-- Query 8 - Find the top 5 customers based on the highest total sales.
SELECT
	customer_id,
	SUM(total_sale) AS total_sales
FROM retail_sales_tb
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Query 9 - Find the number of unique customers who purchased items in each category.
SELECT
	category,
	COUNT(DISTINCT customer_id) AS num_of_unique_customers
FROM retail_sales_tb
GROUP BY 1;

-- Query 10 - Determine each shift and number of orders during each shift.
--!Alternate Answer!
-- SELECT 
-- 	COUNT(transactions_id), 
-- 	CASE 
-- 		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'morning_shift'
-- 		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'afternoon_shift'
-- 		ELSE 'evening_shift'
-- 	END AS shift
-- FROM retail_sales_tb
-- GROUP BY shift;

WITH hourly_sales AS (
	SELECT *,
		CASE
			WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'morning_shift'
			WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17  THEN 'afternoon_shift'
			ELSE 'evening_shift'
		END AS shift
	FROM retail_sales_tb
					)
SELECT
	shift,
	COUNT(transactions_id) AS total_orders
FROM hourly_sales
GROUP BY shift;

-- END OF PROJECT