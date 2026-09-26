# 🏥 Pharma End TO End Analysis Project | Power BI

**Pages:** Revenue Overview • Customer Analysis • Product & Inventory • Logistics & Sales Team

![Revenue Overview](https://github.com/shivrajsinghsisodiya9351-alt/Pharma-end-to-end-analysis-project/blob/main/Revenue%20Overview.png)
![Customer Analysis](https://github.com/shivrajsinghsisodiya9351-alt/Pharma-end-to-end-analysis-project/blob/main/Customer%20Analysis.png)
![Product & Inventory](https://github.com/shivrajsinghsisodiya9351-alt/Pharma-end-to-end-analysis-project/blob/main/Product%20%26%20Inventory%20Analysis.png)
![Logistics & Sales Team](https://github.com/shivrajsinghsisodiya9351-alt/Pharma-end-to-end-analysis-project/blob/main/Logistics%20%26%20Sales%20Team%20Analysis.png)

---

## 📌 Project Description

An end-to-end Power BI dashboard built for a pharmaceutical distribution business, covering **19 cities**, **300 products**, and **4.95K customers**. The dashboard tracks revenue, customer behavior (RFM segmentation), inventory/expiry risk, and logistics/sales team performance across four interactive pages, enabling data-driven decisions on sales growth, stock management, and delivery efficiency.

---

## 📊 Key KPIs

| Metric | Value | YoY Change |
|---|---|---|
| Net Revenue | 54.65bn | ▲ 16.5% |
| Net Profit | 9.70bn | ▲ 16.3% |
| Total Orders | 96.1K | ▲ 12.5% |
| Avg Order Value | 568.86K | ▲ 3.5% |

---

## ⚙️ Process

- **Data Collection** – Sourced 9 relational tables: customers, employees, inventory, logistics, orders, payments, products, ratings, sales.
- **Data Preparation** – Structured raw tables for relationships (customer ↔ orders ↔ products ↔ logistics).
- **Data Cleaning** – Handled nulls, duplicates, and inconsistent formats in Power Query.
- **Data Modeling** – Built a star schema with fact (Orders/Sales) and dimension tables (Customer, Product, Employee, Logistics, Date).
- **Dashboard Development** – Designed 4 pages with KPI cards, DAX measures (YoY, RFM, profit bridge), and drill-down visuals.
- **Testing & Deployment** – Validated KPI accuracy against source data, tested slicers/filters, and published the final `.pbix` report.

---

## ❓ Business Questions Answered

- Which product categories and medicines drive the most revenue?
- Who are the top customers, and how are they segmented by RFM (Champions, Loyal, At Risk, Lost)?
- Which products carry the highest expiry/return risk, and where is stock concentrated?
- Which couriers and salespeople deliver the fastest and most reliably?
- What share of orders are delivered, pending, returned, or cancelled?
- How does gross sale bridge down to net profit (discounts + COGS impact)?

---

## 🔍 Observations & Data Highlights

- Net Revenue of **54.65bn** converts to a **17.74% profit margin**, up from last year.
- **83% repeat customer rate**, but a **22% complaint rate** signals a service gap worth addressing.
- **Pharmacy customers (40.4%)** are the largest customer type, followed by Hospitals (20.2%).
- **Champions + Loyal segments** (≈2,519 customers) generate **39.5bn** of revenue — the core customer base.
- **Stock Turnover Ratio is only 18.14%**, indicating slow-moving inventory relative to target.
- Several batches (e.g., Gabapentin, Ceftriaxone) show **"Expired"** risk flags in the Expiry Risk table.
- **On-Time Delivery is just 49.8%**, with average delivery taking **6.3 days** — a clear operational bottleneck.
- **Delhivery and Bluedart** are the fastest/cheapest couriers by avg delivery time and cost.
- **Meera Kumar** is the top salesperson at **1.52bn** in sales.

---

## 📈 Visuals & Analytics Used

- KPI cards with YoY comparisons (Revenue, Profit, Orders, AOV)
- Gauge charts (Profit Margin, Stock Turnover Ratio)
- Combo bar + line chart (Sale & Profit Trend by month)
- Donut charts (Order Status – by page)
- Waterfall/bridge chart (Gross Sale → Discount → COGS → Net Profit)
- Drill-down hierarchy chart (Revenue Distribution: Category → Medicine)
- Ranked table with conditional formatting (Top 10 Customers by Revenue)
- RFM segmentation summary table
- Pie & bar charts (Customer type, Region, Payment status distribution)
- Horizontal bar charts (Stock by Pack Size/Category, Return Rate by Dosage Form)
- Expiry risk table with Day-to-Expiry flagging
- Top/Bottom toggle bar chart (Product by Revenue)
- Scatter plot (Avg Distance vs Avg Cost by Courier)
- Employee performance table (Sales team KPIs by department)

---

## 💡 Actionable Insights

- Investigate the **22% complaint rate** — likely linked to the 49.8% on-time delivery rate.
- Prioritize clearing **expired-flagged batches** to reduce write-offs and free up warehouse space.
- Shift more volume to **Delhivery/Bluedart** given their better cost-to-speed ratio vs Self Pickup/FedEx.
- Run targeted retention offers on the **"At Risk"** RFM segment (1,269 customers, 10.66bn revenue) before they churn to "Lost".
- Re-balance inventory — Small/Large pack sizes hold the most stock (49M/48M) but turnover is low; align procurement with actual sell-through.
- Recognize and replicate practices of top performers like **Meera Kumar** and **Anjali Joshi** (highest on-time %) across the sales team.

---

## 🎯 Expected Outcomes

- Improved on-time delivery rate through courier reallocation.
- Reduced inventory holding cost via better expiry-risk monitoring.
- Higher customer retention through targeted RFM-based campaigns.
- Clearer sales team accountability via performance benchmarking.

---

## ✅ Conclusion

This dashboard consolidates revenue, customer, inventory, and logistics data into a single Power BI report, surfacing where the pharma distribution business is performing well (revenue growth, customer loyalty) and where it needs attention (delivery delays, expiry risk, complaint rate). It gives stakeholders a page-by-page view to act on specific operational and commercial levers.

---

## 📥 Project File

Want to explore the full interactive report — all filters, drill-downs, and DAX measures?
**Download the `.pbix` file** from this repo and open it in Power BI Desktop to explore it yourself.

---

## 📬 Contact Me

**Shivraj Singh Sisodiya**
Data Analyst | Power BI Developer
- Portfolio: [datascienceportfol.io/shivraj](https://datascienceportfol.io/shivraj)
- GitHub: [github.com/shivrajsinghsisodiya9351-alt](https://github.com/shivrajsinghsisodiya9351-alt)
