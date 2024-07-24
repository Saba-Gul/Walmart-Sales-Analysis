CREATE DATABASE IF NOT EXISTS salesgdatawalmart;
USE salesgdatawalmart;

SHOW TABLES;

CREATE TABLE IF NOT EXISTS walmartSales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT DECIMAL(6, 4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_pct DECIMAL(5, 2),  -- Adjusted from FLOAT to DECIMAL
    gross_income DECIMAL(12, 4) NOT NULL,
    rating DECIMAL(2, 1)  -- Adjusted from FLOAT to DECIMAL
);

SELECT * FROM walmartsales;
SELECT * FROM stores;

ALTER TABLE walmartsales
ADD COLUMN time_of_day VARCHAR(10);

SET SQL_SAFE_UPDATES = 0;

-- To observe purchase trend during different time of the day
UPDATE walmartsales
SET time_of_day = CASE 
    WHEN HOUR(time) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Noon'
    ELSE 'Evening'
END;

-- To observe purchase trend around the week
ALTER TABLE walmartsales
ADD COLUMN day_name VARCHAR(10);

UPDATE walmartsales
SET day_name = DAYNAME(date);

-- which week of the day is busiest.
SELECT day_name, COUNT(invoice_id) AS no_of_purchases
FROM walmartsales
GROUP BY day_name
ORDER BY no_of_purchases DESC;

-- Determine the busiest day for each branch
SELECT branch, day_name, transaction_count
FROM (
    SELECT branch, day_name, COUNT(invoice_id) as transaction_count,
           ROW_NUMBER() OVER (PARTITION BY branch ORDER BY COUNT(invoice_id) DESC) as rn
    FROM walmartsales
    GROUP BY branch, day_name
) AS subquery
WHERE rn = 1;


SELECT branch, day_name, COUNT(invoice_id) as transaction_count, ROW_NUMBER() OVER (PARTITION BY branch ORDER BY COUNT(invoice_id) DESC) as rn
FROM walmartsales
GROUP BY branch, day_name;

-- Adding month name 
ALTER TABLE walmartsales
ADD COLUMN month_name VARCHAR(10);

UPDATE walmartsales
SET month_name = MONTHNAME(date);

-- Adding YEAR
ALTER TABLE walmartsales
ADD COLUMN trans_year INT;

UPDATE walmartsales
SET trans_year = YEAR(date);


-- determine which month of the year has the most sales and profit
-- For most sales
SELECT month_name, SUM(total) AS total_sales
FROM walmartsales
GROUP BY month_name
ORDER BY total_sales DESC
LIMIT 1;

-- For most profit
SELECT month_name, SUM(gross_income) AS total_profit
FROM walmartsales
GROUP BY month_name
ORDER BY total_profit DESC
LIMIT 1;

-- Seeing Relation between sales and profit
SELECT month_name, SUM(total)  AS max_sales, SUM(gross_income) AS max_profit
FROM walmartsales
GROUP BY month_name
ORDER BY max_sales DESC, max_profit DESC;

-- Exploratory Data Analysis (EDA)

-- How many unique cities does the data have?
SELECT DISTINCT city
from walmartsales;

-- In which city is each branch?
SELECT DISTINCT city, branch
FROM walmartsales;

-- Product Analysis
-- 1. How many unique product lines does the data have?
SELECT DISTINCT COUNT(DISTINCT product_line) AS num_of_products
FROM walmartsales;

-- Listing unique product lines
SELECT DISTINCT product_line
FROM walmartsales
GROUP BY product_line;

-- What is the most common payment method?
SELECT payment_method, COUNT(payment_method) AS common_payement_method
FROM walmartsales
GROUP BY payment_method
ORDER BY common_payement_method DESC;

-- What is the most selling product line?
SELECT product_line, COUNT(product_line) AS cnt_product_line
FROM walmartsales
GROUP BY product_line
ORDER BY cnt_product_line DESC;

-- What is the total revenue by month?
SELECT month_name, SUM(gross_income) AS total_revenue_per_month
FROM walmartsales
GROUP BY month_name
ORDER BY total_revenue_per_month DESC;

-- What is the most selling product line?
SELECT product_line, COUNT(product_line) AS most_selling_product
FROM walmartsales
GROUP BY product_line
ORDER BY most_selling_product DESC
LIMIT 3;

-- What is the total revenue by month?
SELECT month_name, SUM(total) AS revenue
FROM walmartsales
GROUP BY month_name
ORDER BY revenue DESC;

-- What month had the largest COGS?
SELECT month_name, SUM(cogs) AS highest_cogs
FROM walmartsales
GROUP BY month_name
ORDER BY highest_cogs DESC
LIMIT 1;

-- What is the city with the largest revenue(sales)=SUM(sum of all sales transactions) = Price per Unit × Number of Units Sold
SELECT city, SUM(total) AS revenue
FROM walmartsales
GROUP BY city
ORDER BY revenue DESC
LIMIT 1;

-- What product line had the largest VAT?
SELECT product_line, SUM(VAT) AS highest_vat
FROM walmartsales
GROUP BY product_line
ORDER BY highest_vat DESC
LIMIT 1;

-- Which branch sold more products than average product sold?

-- Step 1: Create a Common Table Expression (CTE) to calculate the average quantity sold per branch
WITH AverageProducts AS (
    -- Select the average quantity sold across all branches
    SELECT AVG(total_quantity) AS avg_quantity
    FROM (
        -- Calculate the total quantity sold by each branch
        SELECT SUM(quantity) AS total_quantity
        FROM walmartsales
        GROUP BY branch
    ) AS BranchTotals  -- Alias for the subquery to sum quantities by branch
)

-- Step 2: Main query to find branches that sold more products than the average
SELECT 
    branch,  -- Select the branch name
    SUM(quantity) AS total_quantity  -- Calculate the total quantity sold by this branch
FROM walmartsales
GROUP BY branch  -- Group results by branch
HAVING SUM(quantity) > (  -- Filter branches where total quantity is greater than the average
    SELECT avg_quantity  -- Select the average quantity from the CTE
    FROM AverageProducts  -- Reference the CTE
);

-- Alternate Query
SELECT branch, SUM(quantity) AS total_quantity
FROM walmartsales
GROUP BY branch
HAVING SUM(quantity) > (
    SELECT AVG(total_quantity)
    FROM (
        SELECT SUM(quantity) AS total_quantity
        FROM walmartsales
        GROUP BY branch
    ) AS BranchTotals
);

-- What is the most common product line by gender?
SELECT gender, product_line, COUNT(product_line) As popular_product
FROM walmartsales
GROUP BY product_line, gender
ORDER BY popular_product DESC;

-- Alternate Query
SELECT product_line, gender, COUNT(gender)
FROM walmartsales
GROUP BY product_line, gender
ORDER BY COUNT(gender) DESC;

-- What is the average rating of each product line?
SELECT product_line, AVG(rating)
FROM walmartsales
GROUP BY product_line
ORDER BY AVG(rating) DESC;

-- Sales Analysis
 -- Number of sales made in each time of the day per weekday
SELECT time_of_day, day_name, COUNT(invoice_id) AS num_sales
FROM walmartsales
GROUP BY time_of_day, day_name
ORDER BY day_name, time_of_day;

-- Which of the customer types brings the most revenue?
SELECT customer_type, SUM(total) AS revenue_per_customer_type
FROM walmartsales
GROUP BY customer_type
ORDER BY revenue_per_customer_type DESC;

-- Which city has the largest tax percent/ VAT (**Value Added Tax**)?
SELECT city, ROUND(AVG(VAT),2) as vat_per_city
FROM walmartsales
GROUP BY city
ORDER BY vat_per_city DESC;

-- Which customer type pays the most in VAT?
SELECT customer_type, AVG(VAT) vat_customer_type
FROM walmartsales
GROUP BY customer_type
ORDER BY vat_customer_type DESC; 

-- Customer Analysis
-- How many unique customer types does the data have?
SELECT DISTINCT (customer_type)
FROM walmartsales;

-- How many unique payment methods does the data have?
SELECT DISTINCT (payment_method)
FROM walmartsales;

-- What is the most common customer type?
SELECT customer_type, COUNT(*) as cnt_customer_type
FROM walmartsales
GROUP BY customer_type;

-- Which customer type buys the most?
SELECT customer_type, SUM(total) AS revenue_per_cust_type
FROM walmartsales
GROUP BY customer_type
ORDER BY revenue_per_cust_type DESC;

-- What is the gender of most of the customers?
SELECT gender, COUNT(*) AS gender_dist
FROM walmartsales
GROUP BY gender
ORDER BY gender_dist DESC;

-- What is the gender distribution per branch?
SELECT  branch, gender, COUNT(gender) AS gender_dis
FROM walmartsales
GROUP BY gender, branch
ORDER BY branch;

--  Which time of the day do customers give most ratings?
SELECT time_of_day, COUNT(rating) AS rat_cnt
FROM walmartsales
GROUP BY time_of_day
ORDER BY rat_cnt DESC;

-- Which time of the day do customers give most ratings per branch?

-- Step 1: Count the number of ratings given at each time for each branch
WITH RatingsCount AS (
	SELECT time_of_day, branch, COUNT(rating) as total_ratings
	FROM walmartsales
	GROUP BY time_of_day, branch
),

RankedRatings AS (
-- Step 2: Rank the times of day by the number of ratings for each branch
	SELECT time_of_day, branch, total_ratings, ROW_NUMBER() OVER(PARTITION BY branch ORDER BY total_ratings DESC) AS rn
	FROM RatingsCount
)
-- Step 3: Select the time of day with the highest number of ratings for each branch
SELECT time_of_day, branch, total_ratings
FROM RankedRatings
WHERE rn=1;-- Only get the top-ranked time for each branch

--  Which day fo the week has the best avg ratings?

SELECT day_name, AVG(rating) as avg_ratings
FROM walmartsales
GROUP BY day_name
ORDER BY avg_ratings DESC;

-- Which day of the week has the best average ratings per branch?
WITH DailyAvgRatings AS (
    -- Calculate the average rating for each day of the week per branch
SELECT branch, day_name, AVG(rating) as avg_ratings
FROM walmartsales
GROUP BY day_name, branch
),
RankedDays AS (
    -- Rank the days of the week by average rating for each branch
	SELECT branch, day_name, avg_ratings, ROW_NUMBER() OVER(PARTITION BY branch ORDER BY avg_ratings DESC) AS rn
    FROM DailyAvgRatings
    )
-- Select the best day of the week for each branch based on average rating
SELECT branch, day_name, avg_ratings
FROM RankedDays
WHERE rn=1; -- Get the top-ranked day for each branch

-- Revenue And Profit Calculations
-- Calculate total revenue
SELECT SUM(total) AS total_revenue
FROM walmartsales;

-- Calculate total gross profit
SELECT SUM(total) - SUM(cogs) AS gross_profit
FROM walmartsales;

