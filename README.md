# Walmart Sales Data Analysis

## About

We are analyzing Walmart's sales data to identify high-performing branches and products, analyze the sales patterns of various products, and understand customer behavior. The primary objective is to enhance and optimize sales strategies. The dataset utilized in this project is sourced from the Kaggle Walmart Sales Forecasting Competition.

![Walmart Sales Data](walmart.jpeg)

## Purposes of the Project

The main goal of this project is to gain insights from Walmart's sales data, exploring various factors that influence sales across different branches. This analysis aims to:

- Identify high-performing branches and products.
- Analyze sales patterns and trends.
- Understand customer behavior and preferences.
- Optimize sales strategies based on data-driven insights.

## About Data

This project's data was obtained from the [Kaggle Walmart Sales Forecasting Competition](https://www.kaggle.com/datasets/yasserh/walmart-dataset)
 and encompasses sales transactions from three Walmart branches situated in Mandalay, Yangon, and Naypyitaw. The dataset contains 17 columns and 1000 rows with information on sales transactions, including:

- Transaction date
- Product details
- Sales amounts
- Customer information
- Branch details

## Business Questions and SQL Queries

### Generic Questions

1. **How many distinct cities are present in the dataset?**
   ```sql
   SELECT DISTINCT city
   FROM walmartsales;
   ```

2. **In which city is each branch situated?**
   ```sql
   SELECT DISTINCT city, branch
   FROM walmartsales;
   ```

### Product Analysis

1. **How many distinct product lines are there in the dataset?**
   ```sql
   SELECT DISTINCT COUNT(DISTINCT product_line) AS num_of_products
   FROM walmartsales;
   ```

2. **What is the most common payment method?**
   ```sql
   SELECT payment_method, COUNT(payment_method) AS common_payment_method
   FROM walmartsales
   GROUP BY payment_method
   ORDER BY common_payment_method DESC;
   ```

3. **What is the most selling product line?**
   ```sql
   SELECT product_line, COUNT(product_line) AS cnt_product_line
   FROM walmartsales
   GROUP BY product_line
   ORDER BY cnt_product_line DESC;
   ```

4. **What is the total revenue by month?**
   ```sql
   SELECT month_name, SUM(total) AS revenue
   FROM walmartsales
   GROUP BY month_name
   ORDER BY revenue DESC;
   ```

5. **Which month recorded the highest Cost of Goods Sold (COGS)?**
   ```sql
   SELECT month_name, SUM(cogs) AS highest_cogs
   FROM walmartsales
   GROUP BY month_name
   ORDER BY highest_cogs DESC
   LIMIT 1;
   ```

6. **Which product line generated the highest revenue?**
   ```sql
   SELECT product_line, SUM(total) AS total_revenue
   FROM walmartsales
   GROUP BY product_line
   ORDER BY total_revenue DESC
   LIMIT 1;
   ```

7. **Which city has the highest revenue?**
   ```sql
   SELECT city, SUM(total) AS revenue
   FROM walmartsales
   GROUP BY city
   ORDER BY revenue DESC
   LIMIT 1;
   ```

8. **Which product line incurred the highest VAT?**
   ```sql
   SELECT product_line, SUM(VAT) AS highest_vat
   FROM walmartsales
   GROUP BY product_line
   ORDER BY highest_vat DESC
   LIMIT 1;
   ```

9. **Retrieve each product line and add a column `product_category`, indicating 'Good' or 'Bad,' based on whether its sales are above the average.**
   ```sql
   WITH ProductSales AS (
       SELECT product_line, SUM(total) AS total_sales
       FROM walmartsales
       GROUP BY product_line
   ),
   AverageSales AS (
       SELECT AVG(total_sales) AS avg_sales
       FROM ProductSales
   )
   SELECT product_line, 
          CASE 
              WHEN total_sales > (SELECT avg_sales FROM AverageSales) THEN 'Good'
              ELSE 'Bad'
          END AS product_category
   FROM ProductSales;
   ```

10. **Which branch sold more products than the average product sold?**
    ```sql
    WITH AverageProducts AS (
        SELECT AVG(total_quantity) AS avg_quantity
        FROM (
            SELECT SUM(quantity) AS total_quantity
            FROM walmartsales
            GROUP BY branch
        ) AS BranchTotals
    )
    SELECT branch, SUM(quantity) AS total_quantity
    FROM walmartsales
    GROUP BY branch
    HAVING SUM(quantity) > (
        SELECT avg_quantity
        FROM AverageProducts
    );
    ```

11. **What is the most common product line by gender?**
    ```sql
    SELECT gender, product_line, COUNT(product_line) AS popular_product
    FROM walmartsales
    GROUP BY product_line, gender
    ORDER BY popular_product DESC;
    ```

12. **What is the average rating of each product line?**
    ```sql
    SELECT product_line, AVG(rating) AS avg_rating
    FROM walmartsales
    GROUP BY product_line
    ORDER BY avg_rating DESC;
    ```

### Sales Analysis

1. **Number of sales made in each time of the day per weekday.**
   ```sql
   SELECT time_of_day, day_name, COUNT(invoice_id) AS num_sales
   FROM walmartsales
   GROUP BY time_of_day, day_name
   ORDER BY day_name, time_of_day;
   ```

2. **Identify the customer type that generates the highest revenue.**
   ```sql
   SELECT customer_type, SUM(total) AS revenue_per_customer_type
   FROM walmartsales
   GROUP BY customer_type
   ORDER BY revenue_per_customer_type DESC;
   ```

3. **Which city has the largest tax percent/ VAT (Value Added Tax)?**
   ```sql
   SELECT city, ROUND(AVG(VAT), 2) AS vat_per_city
   FROM walmartsales
   GROUP BY city
   ORDER BY vat_per_city DESC;
   ```

4. **Which customer type pays the most VAT?**
   ```sql
   SELECT customer_type, AVG(VAT) AS vat_customer_type
   FROM walmartsales
   GROUP BY customer_type
   ORDER BY vat_customer_type DESC;
   ```

### Customer Analysis

1. **How many unique customer types does the data have?**
   ```sql
   SELECT DISTINCT customer_type
   FROM walmartsales;
   ```

2. **How many unique payment methods does the data have?**
   ```sql
   SELECT DISTINCT payment_method
   FROM walmartsales;
   ```

3. **Which is the most common customer type?**
   ```sql
   SELECT customer_type, COUNT(*) AS cnt_customer_type
   FROM walmartsales
   GROUP BY customer_type;
   ```

4. **Which customer type buys the most?**
   ```sql
   SELECT customer_type, SUM(total) AS revenue_per_cust_type
   FROM walmartsales
   GROUP BY customer_type
   ORDER BY revenue_per_cust_type DESC;
   ```

5. **What is the gender of most of the customers?**
   ```sql
   SELECT gender, COUNT(*) AS gender_dist
   FROM walmartsales
   GROUP BY gender
   ORDER BY gender_dist DESC;
   ```

6. **What is the gender distribution per branch?**
   ```sql
   SELECT branch, gender, COUNT(gender) AS gender_dis
   FROM walmartsales
   GROUP BY gender, branch
   ORDER BY branch;
   ```

7. **Which time of the day do customers give the most ratings?**
   ```sql
   SELECT time_of_day, COUNT(rating) AS rat_cnt
   FROM walmartsales
   GROUP BY time_of_day
   ORDER BY rat_cnt DESC;
   ```

8. **Which time of the day do customers give the most ratings per branch?**
   ```sql
   WITH RatingsCount AS (
       SELECT time_of_day, branch, COUNT(rating) AS total_ratings
       FROM walmartsales
       GROUP BY time_of_day, branch
   ),
   RankedRatings AS (
       SELECT time_of_day, branch, total_ratings, ROW_NUMBER() OVER(PARTITION BY branch ORDER BY total_ratings DESC) AS rn
       FROM RatingsCount
   )
   SELECT time_of_day, branch, total_ratings
   FROM RankedRatings
   WHERE rn = 1;
   ```

9. **Which day of the week has the best average ratings?**
   ```sql
   SELECT day_name, AVG(rating) AS avg_ratings
   FROM walmartsales
   GROUP BY day_name
   ORDER BY avg_ratings DESC;
   ```

10. **Which day of the week has the best average ratings per branch?**
    ```sql
    WITH DailyAvgRatings AS (
        SELECT branch, day_name, AVG(rating) AS avg_ratings
        FROM walmartsales
        GROUP BY day_name, branch
    ),
    RankedDays AS (
        SELECT branch, day_name, avg_ratings, ROW_NUMBER() OVER(PARTITION BY branch ORDER BY avg_ratings DESC) AS rn
        FROM DailyAvgRatings
    )
    SELECT branch, day_name, avg_ratings
    FROM RankedDays
    WHERE rn = 1;
    ```

## Revenue and Profit Calculations

1. **Calculate total revenue:**
   ```sql
   SELECT SUM(total) AS total_revenue
   FROM walmartsales;
   ```

2. **Calculate total profit:**
   ```sql
   SELECT SUM(profit) AS total_profit
   FROM walmartsales;
   ```

## Data Visualization

**Note:** For data visualization, we have used PowerBI to visualize sales patterns, revenue trends, and other insights.
