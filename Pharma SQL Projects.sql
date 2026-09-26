SELECT * FROM products;
SELECT * FROM employees;
SELECT * FROM customers;
SELECT * FROM inventory;
SELECT * FROM orders;
SELECT * FROM payments;
SELECT * FROM logistics;
SELECT * FROM ratings;
SELECT * FROM sales;

-- ============================================================
-- Revenue & Growth Analysis
-- ============================================================

--1 Total revenue, profit, aur order count — overall business health ek query me.
SELECT 
     COUNT(order_id) AS Total_orders,
     SUM(revenue) AS Total_revenue,
	 SUM(profit) AS Total_profit
FROM sales;

--2 What is the monthly revenue trend over time, and are there any seasonal patterns?
SELECT 
     EXTRACT(MONTH FROM o.order_date) AS month_no,
	 TO_CHAR(o.order_date,'month') AS Months,
     SUM(s.revenue) AS revenue
FROM orders o
JOIN sales s ON o.order_id = s.order_id
WHERE EXTRACT(MONTH FROM o.order_date) IS NOT NULL
GROUP BY 1,2
ORDER BY 1;

--3 Region-wise and State-wise sales 
SELECT c.region,
       c.state,
	   SUM(s.revenue) AS Total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN sales s ON s.order_id = o.order_id
GROUP BY 1,2
ORDER BY 3 DESC

--4 Order status breakdown — kitne % Delivered / Cancelled / Returned hain.
SELECT 
      Order_status,
      COUNT(*) AS Total_orders,
	  ROUND(
	        COUNT(*) * 100 / SUM(COUNT(*)) over(),2) AS Pect_order_status
FROM orders
GROUP BY 1
ORDER BY 2 DESC
		   
--5 Payment status split — Paid vs Partial vs Unpaid ka % — collections ki health.
SELECT 
      payment_status,
      COUNT(*) AS Total_transactions,
	  ROUND(
	        COUNT(*) * 100 / SUM(COUNT(*)) over(),2) AS Pect_order_status
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

--6 Top 10 salespersons by revenue.
SELECT e.salesperson_name,
       SUM(revenue) AS Total_sales
FROM employees e
JOIN orders o ON e.salesperson_id = o.salesperson_id
JOIN sales s ON s.order_id = o.order_id
WHERE e.salesperson_name NOT IN('Not Available')
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--7 Average customer rating aur complaint count — customer satisfaction snapshot.
SELECT complaint,
       COUNT(*) AS complain_counts,
       ROUND(AVG(customer_rating),2) AS Avg_rating
FROM ratings
GROUP BY 1

--8 Delivery delay analysis — Delivery_Date - Order_Date calculation and find average delivery time by courier and SLA breach % (e.g., >7 din wale orders).
SELECT l.courier,
       COUNT(*) AS Total_ordes,
       ROUND(AVG(delivery_date - order_date),2) AS AVG_deliver_time,
	   SUM
	       (CASE WHEN delivery_date - order_date > 7 THEN 1 ELSE 0 END) AS sla_breached_orders,
       SUM
	       (CASE WHEN delivery_date - order_date > 7 THEN 1 ELSE 0 END)*100 / COUNT(*) AS sla_breached_pect
FROM orders o
JOIN logistics l 
   ON o.order_id = l.order_id
WHERE (delivery_date - order_date) IS NOT NULL
GROUP BY 1
ORDER BY 5 DESC


--9 Month-over-month growth % — LAG()
WITH MonthlySale AS(
SELECT EXTRACT(MONTH FROM o.order_date) AS Month_NO,
       TO_CHAR(o.order_date , 'month') AS month_name,
	   TO_CHAR(o.order_date , 'YYYY') AS Year,
	   SUM(s.revenue) AS Total_revenue
FROM orders o
JOIN sales s ON o.order_id = s.order_id
WHERE TO_CHAR(o.order_date , 'month') IS NOT NULL
GROUP BY 1,2,3
ORDER BY 2 
)
 SELECT Year,
        Month_NO,
        month_name,
		Total_revenue,
		ROUND((Total_revenue - LAG(Total_revenue) OVER(PARTITION BY Year ORDER BY Month_NO)) * 100 /
		LAG(Total_revenue) OVER(PARTITION BY Year ORDER BY Month_NO),2) AS revenue_pect
FROM MonthlySale

--10 Top 20% customers = 80% revenue (Pareto/ABC).
WITH CustRevenue AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(s.revenue) AS revenue
    FROM customers c
    JOIN orders o 
        ON c.customer_id = o.customer_id
    JOIN sales s 
        ON s.order_id = o.order_id
    GROUP BY c.customer_id, c.customer_name
),

CustParetoAnalysis AS (
    SELECT 
        customer_id,
        customer_name,
        revenue,
        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue,
        SUM(revenue) OVER () AS total_revenue
    FROM CustRevenue
)

SELECT 
    customer_id,
    customer_name,
    revenue,
    ROUND(
        cumulative_revenue * 100.0 / total_revenue,
        2
    ) AS cumulative_pct
FROM CustParetoAnalysis
WHERE cumulative_revenue <= total_revenue * 0.80
ORDER BY revenue DESC;

--11 Region-wise growth score for marketing investment
SELECT c.region,
       ROUND(SUM(revenue)* 100.0 / SUM(SUM(revenue)) OVER(),2) AS growth_score
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN sales s ON o.order_id = s.order_id
GROUP BY 1
ORDER BY 1 DESC


-- ============================================================
--Customer Retention Analysis
-- ============================================================

--12. How can customers be segmented into High, Medium, and Low value tiers based on their total spend, order count, and recency of last order? 
WITH RFMAnalysis AS (
  SELECT c.customer_id, c.customer_name, MAX(o.order_date) AS Last_purchase_date,
         COUNT(o.*) AS Total_orders,
		 SUM(s.revenue) AS Total_Spend
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  JOIN sales s ON o.order_id = s.order_id
  GROUP BY 1,2
  ORDER BY 4 DESC
)
  SELECT 
        customer_id, customer_name,Total_orders,Total_Spend,Last_purchase_date,
		CASE
		   WHEN Total_Spend <= 100000 THEN 'BRONZ'
		   WHEN Total_Spend BETWEEN 100000 AND 5000000 THEN 'SILVER'
		   WHEN Total_Spend BETWEEN 5000000 AND 15000000 THEN 'GOLD'
		   ELSE 'PLATINUM'
		   END customer_status
  FROM RFMAnalysis		   

--13 Which customers haven't placed an order in the last 90+ days and are at risk of churning?
SELECT c.customer_name,c.customer_name,
       MAX(o.order_date) AS last_order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY 1,2
HAVING MAX(o.order_date) < CURRENT_DATE - INTERVAL '90 DAYS'

--14  Customer Lifetime Value estimate.
SELECT c.customer_name,customer_type,c.city,
       SUM(s.revenue) AS Total_revenue
FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  JOIN sales s ON o.order_id = s.order_id
GROUP BY 1,2,3
ORDER BY 4 DESC

--15 Which customers are both high-value and at high risk of churning, and should be prioritized for retention outreach?
SELECT c.customer_id,
       customer_name,
       SUM(s.revenue) AS Total_revenue,
	   MAX(o.order_date) AS last_order_date
FROM customers c
JOIN orders o 
   ON c.customer_id = o.customer_id
JOIN sales s 
  ON o.order_id = s.order_id
GROUP BY 
  c.customer_id,
  c.customer_name
HAVING 
  SUM(s.revenue) > 5000000
  AND MAX(o.order_date) < CURRENT_DATE - INTERVAL '90 day'
ORDER BY
  4 DESC

-- ============================================================
-- Product & Inventory Analysis
-- ============================================================


--16 Top 10 products by revenue 
SELECT 
     p.medicine_name,
     SUM(s.revenue) AS Total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC

--17 Which products are approaching their expiry date within the next 90 days, putting them at risk of becoming dead stock?
SELECT product_id , medicine_name, category , expiry_date
FROM products
WHERE expiry_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '90 DAYS'
ORDER BY expiry_date

--18 Which products currently have stock levels below their reorder threshold and need immediate restocking?
SELECT *
FROM inventory
WHERE Stock_Available < Reorder_Level

--19 Return rate by product category
SELECT 
    p.category,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN o.return_flag = 'Yes' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(
         SUM(CASE WHEN o.return_flag = 'Yes' THEN 1 ELSE 0 END)*100 
        / COUNT(*), 
        2
    ) AS return_rate_pct
FROM orders o
JOIN products p 
    ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY return_rate_pct DESC;

--20 Products to discontinue — low revenue + high return + low rating.
WITH LowProductAnalysis AS(
SELECT 
     p.product_id,
	 p.medicine_name,
	 ROUND(
         SUM(CASE WHEN o.return_flag = 'Yes' THEN 1 ELSE 0 END)*100 
        / COUNT(o.*), 
        2
    ) AS return_rate_pct,
	 ROUND(AVG(r.customer_rating),2) AS Avg_rating,
	 SUM(s.revenue) AS Total_revenue
FROM products p
JOIN orders o 
  ON p.product_id = o.product_id
JOIN sales s
  ON o.order_id = s.order_id
LEFT JOIN ratings r
  ON o.order_id = r.order_id
GROUP BY 1,2
)
  SELECT * 
  FROM LowProductAnalysis
  WHERE Avg_rating <= 4
  AND Total_revenue <= 100000
  AND return_rate_pct >= 5


-- ============================================================
-- Sales Team Performance Analysis
-- ============================================================

-- 21. Who are the top 10 salespersons by total revenue generated?
SELECT e.salesperson_name,
       SUM(revenue) AS Total_revenue
FROM sales s
JOIN orders o ON s.order_id = o.order_id
JOIN employees e ON o.salesperson_id = e.salesperson_id
WHERE e.salesperson_name NOT IN ('Not Available')
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- 22. How do salespersons rank against each other in terms of revenue, both overall and within their department?
SELECT e.salesperson_name,
       e.department,
       SUM(s.revenue) AS Total_revenue,
DENSE_RANK() OVER(PARTITION BY e.department ORDER BY SUM(s.revenue) DESC) AS Salesperson_rank	   
FROM sales s
JOIN orders o ON s.order_id = o.order_id
JOIN employees e ON o.salesperson_id = e.salesperson_id
WHERE e.salesperson_name NOT IN ('Not Available')
GROUP BY 1,2

-- 23. What is each salesperson's quarter-over-quarter revenue trend, and which salespersons
--are consistently underperforming?


-- STEP 1: Quarterly revenue per salesperson

WITH quarter_revenue AS (
SELECT e.salesperson_id,
       e.salesperson_name,
	   e.department,
	   DATE_TRUNC('quarter', o.order_date)::DATE AS quarter_start,
	   TO_CHAR(o.order_date , '"Q"Q-YYYY') AS quarter_label,
       SUM(s.revenue) AS quertar_sales
FROM sales s
JOIN orders o ON s.order_id = o.order_id
JOIN employees e ON o.salesperson_id = e.salesperson_id
GROUP BY 1,2,3,4,5
ORDER BY 6 DESC	   
),


-- STEP 2: QoQ growth using LAG (previous quarter comparison)

 Quertar_over_quertat AS (
SELECT salesperson_id,
       salesperson_name,
	   department,
	   quarter_start,
       quarter_label,
       quertar_sales,
LAG(quertar_sales) OVER(PARTITION BY salesperson_id ORDER BY quarter_start) AS Prev_Quertar_sale, 
      ROUND((quertar_sales - LAG(quertar_sales) OVER(PARTITION BY salesperson_id ORDER BY quarter_start))*100 / 
         NULLIF (LAG(quertar_sales) OVER(PARTITION BY salesperson_id ORDER BY quarter_start),0),2) AS qoq_growth_pct
FROM quarter_revenue
),

-- STEP 3: Consistency scorecard per salesperson

CONSISTENCY_CHECK AS(
SELECT salesperson_id,
       salesperson_name,
	   department,
	   COUNT(*) AS Total_quertar,
	   COUNT(*) FILTER(WHERE qoq_growth_pct < 0) AS decline_quertar,
	   ROUND(
            COUNT(*) FILTER (WHERE qoq_growth_pct < 0) * 100.0
            / NULLIF(COUNT(*) FILTER (WHERE Prev_Quertar_sale IS NOT NULL), 0)
        , 1) AS decline_ratio_pct,
       ROUND(
	   AVG(quertar_sales),2) AS avg_quarterly_revenue
FROM Quertar_over_quertat
GROUP BY 1,2,3
) 

-- FINAL: Underperformers = majority quarters declining + enough Data
 
SELECT
    salesperson_id,
    salesperson_name,
    department,
    Total_quertar,
    decline_quertar,
    decline_ratio_pct,
    avg_quarterly_revenue
FROM CONSISTENCY_CHECK
WHERE Total_quertar >= 3            -- minimum quarters to call it a "trend"
  AND decline_ratio_pct >= 50        -- declined in half or more comparisons
ORDER BY decline_ratio_pct DESC, avg_quarterly_revenue ASC;

-- ============================================================
-- Operations — Logistics & Quality
-- ============================================================

--24 What is the average delivery time by courier, and what percentage of orders are breaching the 
--delivery SLA (e.g., more than 7 days)?

-- STEP 1: Delivery time per order (only genuinely delivered orders)

WITH Delivery_orders AS(
 SELECT o.order_id,
        l.courier,
		o.delivery_date,
		o.order_date,
		(o.delivery_date - o.order_date) AS Delivery_days
 FROM orders o
 INNER JOIN logistics l
    ON o.order_id = l.order_id
 WHERE o.order_status = 'Delivered'
 AND o.delivery_date IS NOT NULL
 AND o.order_date IS NOT NULL
 AND o.delivery_date >= o.order_date
),	   


-- STEP 2: Courier-wise average delivery time + SLA breach flag
CourierSLA AS (
 SELECT courier,
        order_id,
		Delivery_days,
		CASE WHEN Delivery_days >= 7 THEN 1 ELSE 0 END AS SLA_Bench_Orders
 FROM Delivery_orders		
)
-- FINAL: Aggregate by courier
SELECT 
      courier,
	  COUNT(*) AS Total_orders_delivered,
	  ROUND(AVG(Delivery_days),2) AS AVG_Delivery_days,
      MIN(Delivery_days) AS min_delivery_time,
      MAX(Delivery_days)AS max_delivery_time,
	  SUM(SLA_Bench_Orders) AS Total_SLA_Orders,
	  ROUND(
	     SUM(SLA_Bench_Orders) * 100.0 / COUNT(*),2) AS SAL_Order_Pect
FROM CourierSLA
GROUP BY 1


--25 How do different courier partners compare in terms of delivered, failed, and returned order percentages?
WITH  courier_status_counts AS(
SELECT 
      courier,
	  delivery_status,
	  COUNT(*) AS orders_status
FROM logistics
GROUP BY 1,2
),
	couriertotals AS(
	SELECT
	     courier,
		 COUNT(*) AS Total_orders,
		 ROUND(AVG(transport_cost),2) AS avg_transport_cost
	FROM logistics
	GROUP BY 1
)  
SELECT t.courier,
	   t.Total_orders,
	   t.avg_transport_cost,
	   ROUND(SUM(CASE WHEN c.delivery_status = 'Delivered' THEN c.orders_status ELSE 0 END) *100/t.Total_orders,2) AS Delivery_pect,
       ROUND(SUM(CASE WHEN c.delivery_status = 'Returned' THEN c.orders_status ELSE 0 END) *100/t.Total_orders,2) AS Returned_pect,
	   ROUND(SUM(CASE WHEN c.delivery_status = 'Failed' THEN c.orders_status ELSE 0 END) *100/t.Total_orders,2) AS Failed_pect,
	   ROUND(SUM(CASE WHEN c.delivery_status = 'Pending' THEN c.orders_status ELSE 0 END) *100/t.Total_orders,2) AS Pending_pect,
 	   ROUND(SUM(CASE WHEN c.delivery_status = 'In Transit' THEN c.orders_status ELSE 0 END) *100/t.Total_orders,2) AS In_Transit_pect,
       ROUND(SUM(CASE WHEN c.delivery_status NOT IN('Delivered','Returned','Failed','Pending','In Transit') THEN c.orders_status ELSE 0 END) *100/t.Total_orders,2) AS Other_status_pect
FROM couriertotals t
JOIN courier_status_counts c
  ON t.courier = c.courier
GROUP BY 1,2,3
