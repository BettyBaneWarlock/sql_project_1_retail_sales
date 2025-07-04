# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis   
**Database**: `retail_sales_db`

The purpose of this project is to demonstrate SQL skills and techniques used to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `retail_sales_db`.
- **Table Creation**: A table named `retail_sales_db` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE retail_sales_db;

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
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
  ```sql
  SELECT COUNT(*)
  FROM retail_sales_tb;
  ```
- **Customer Count**: Find out how many unique customers are in the dataset.
  ```sql
  SELECT
	COUNT(DISTINCT customer_id) AS total_customers
  FROM retail_sales_tb;
  ```
- **Category Count**: Identify all unique product categories in the dataset.
  ```sql
  SELECT 
	DISTINCT category
  FROM retail_sales_tb;
  ```
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.
```sql
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
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Retrieve all columns for sales made on '2022-11-05**:
```sql
SELECT *
FROM retail_sales_tb
WHERE sale_date = '2022-11-05';
```

2. **Retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of November-2022**:
```sql
SELECT *
FROM retail_sales_tb
WHERE
	category = 'Clothing'
	AND quantity >= 4
	AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';
```

3. **Calculate the total sales for each category**:
```sql
SELECT
	category,
	SUM(total_sale) AS net_sales,
	COUNT(*) AS total_orders
FROM retail_sales_tb
GROUP BY 1;
```

4. **Find the average age of customers who purchased items from the 'Beauty' category**:
```sql
SELECT
	ROUND(AVG(age), 2) AS average_age
FROM retail_sales_tb
WHERE category = 'Beauty';
```

5. **Find all transactions where the total sales is greater than 1000**:
```sql
SELECT *
	-- COUNT(*) AS num_of_big_sales
FROM retail_sales_tb
WHERE total_sale > 1000;
```

6. **Find the total number of transactions made by each gender in each category**:
```sql
SELECT
	category,
	gender,
	COUNT(transactions_id) AS total_transactions
FROM retail_sales_tb
GROUP BY 1, 2
ORDER BY 1, 2;
```

7. **Calculate the average sale for each month. Find out best selling month in each year**:
```sql
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
```

8. **Find the top 5 customers based on the highest total sales**:
```sql
SELECT
	customer_id,
	SUM(total_sale) AS total_sales
FROM retail_sales_tb
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

9. **Find the number of unique customers who purchased items in each category**:
```sql
SELECT
	category,
	COUNT(DISTINCT customer_id) AS num_of_unique_customers
FROM retail_sales_tb
GROUP BY 1;
```

10. **Determine each shift and number of orders during each shift. (Divide shifts as - Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
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
```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.
