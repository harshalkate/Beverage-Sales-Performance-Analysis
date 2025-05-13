SELECT 
    *
FROM
    bevg_sales;

SELECT 
    *
FROM
    cust_details;

SELECT 
    REPLACE(REPLACE('Baden-Württemberg', 'ü', 'u'),
        '-',
        ' ') AS cleaned_region

UPDATE cust_details 
SET 
    Region = REPLACE(REPLACE(Region, 'ü', 'u'),
        '-',
        ' ')
WHERE
    Region LIKE '%ü%' OR Region LIKE '%-%'
    
    
-- describing the data from every tables
desc bevg_sales;
desc cust_details;
 
SELECT 
    *
FROM
    bevg_sales
WHERE
    Order_Date IS NOT NULL;

SELECT DISTINCT
    *
FROM
    bevg_sales;
 --
 SELECT 
    REGEXP_REPLACE(Region, '[^a-zA-Z0-9- ]', '') AS Region
FROM
    cust_details;
 -- converting date column from text to column'CUS1496', 'B2B', 'Water', 'Baden-Württemberg'

UPDATE bevg_sales 
SET 
    Order_Date = STR_TO_DATE(Order_Date, '%m/%d/%Y');
-- altering the table 
alter table bevg_sales
modify column Order_Date date;

-- Joining the Two Table for the better understanding of the both tables.
SELECT 
    s.Order_ID,
    s.Order_Date,
    s.Customer_ID,
    s.Product,
    s.Unit_Price,
    s.Unit_Price,
    s.Quantity,
    s.Discount,
    s.Total_Price,
    c.Customer_ID,
    c.Customer_Type,
    c.Category,
    c.Region
FROM
    bevg_sales s
        JOIN
    cust_details c ON s.Customer_ID = c.Customer_ID;
    
-- 2. Monthly Revenue Trend    
SELECT 
    DATE_FORMAT(Order_Date, '%M  %Y') AS Month,
    ROUND(SUM(total_price), 0) AS Total_reveune
FROM
    bevg_sales
GROUP BY month
ORDER BY STR_TO_DATE(Month, '%M  %Y') desc;

/*As we can see here that Month & year of the highest revenue created monthly*/

select * from bevg_sales;


-- 4 Revenue by the prouducts and quantity 
SELECT 
    product,
    ROUND(SUM(Quantity), 2) AS sold_quantity,
    ROUND(SUM(Total_Price), 2) AS total_rev
FROM
    bevg_sales
GROUP BY Product
ORDER BY total_rev DESC
LIMIT 10;
/* As we can see  in the result that Veuve Clicquo,Moët & Chandon,Johnnie Walker,
Jack Daniels,Tanqueray they're sold in highest quantity and created the highest revenue by selling them*/

-- Renaming the products names to actual names vv
UPDATE cust_details
SET 
    Region = 'Baden-Württemberg'
WHERE
    Region = 'Baden-WÃ¼rttemberg';

-- selecting the distinct product names in the data 
SELECT DISTINCT
    (product) AS unique_names
FROM
    bevg_sales;
    
-- 4. Customer segment Performance
SELECT 
    Customer_Type,
    Category,
    ROUND(SUM(s.Total_Price), 2) AS total_sales
FROM
    bevg_sales s
        JOIN
    cust_details c ON c.Customer_ID = s.Customer_ID
GROUP BY Customer_Type , Category
ORDER BY total_sales DESC;
/* 	As we can here that Total sales according to
	the category and customer_type 
	top 3 category are Alcoholic Beverages,water,Juices were high demand */

select * from bevg_sales
where Total_Price is null;

SELECT 
    *
FROM
    cust_details
WHERE
    Region IS NULL;
-- There is no null values are in the region column

SELECT DISTINCT
    (Region) AS unique_region
FROM
    cust_details;
    
-- 5. Discount vs Revenue Impact   
SELECT 
    CASE
        WHEN Discount = 0 THEN 'No discount'
        ELSE 'Discounted'
    END AS Discount_status,
    COUNT(*) AS order_count,
    ROUND(AVG(Total_price), 2) AS avg_revenue_per_order
FROM
    bevg_sales
GROUP BY Discount_status;

--  As we can see here that Average revenue per order with discount, Non discounted
-- There is Huge difference of Rs200 Means that giving discount works and its help to increase the sales.
-- Order count has huge difference too as you can see No discount is higher than the discount  but revenue spike is with Discount orders 

-- 6. Regional Revenue Comparison
SELECT 
    Region, round(SUM(Total_Price),2) AS Total_Revenue
FROM
    bevg_sales s
        JOIN
    cust_details c ON c.Customer_ID = s.Customer_ID
GROUP BY region
ORDER BY Total_Revenue desc;

/* As we can see that here Region wise revenue Top 5 regions By 
their Total_Revenue as follow: Hamburg,Brandenburg,Hessen,Mecklenburg-Vorpommern,
Baden-Württemberg  we can selling more products here according to the counsumption and have to 
check what is the problem in low revenue regions
 */ 
-- 7. Repeat vs New Customers
with first_orders as(
select Customer_ID, min(Order_Date) as first_order
from bevg_sales
group by Customer_ID
)
SELECT 
    CASE
        WHEN s.Order_Date = f.first_order THEN 'New_customer'
        ELSE 'Repeat_Customer'
    END AS customer_status,
    COUNT(*) AS Count_order,
    ROUND(SUM(Total_Price), 2) AS Rev
FROM
    bevg_sales s
        JOIN
    first_orders f ON s.Customer_ID = f.Customer_ID
GROUP BY customer_status;

-- Repeat_Customer are more than the new_customer we can see that the 
-- quality,product_supply or pricing is better so sales are repeating by existing clients.

/*
1.bevg_details
Order_ID, Customer_ID, Order_Date, Product, Unit_Price, Quantity, Discount, Total_Price
2.customer_details
Customer_ID, Customer_Type, Category, Region

*/

SELECT 
    o.Order_Date, o.Product, c.Category, o.Total_Price
FROM
    bevg_sales o
        LEFT JOIN
    cust_details c ON o.Customer_ID = c.Customer_ID
WHERE
    o.Total_Price >= 70
ORDER BY o.Total_Price DESC;