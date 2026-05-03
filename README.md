# Global Electronics Sales — SQL Analytics Portfolio
# Overview
This project is an end-to-end SQL Server (T-SQL) data analysis portfolio built on a 
fictional Global Electronics Retailer dataset. It covers the full analytics workflow — 
from database design and data ingestion to business KPI reporting and advanced analytics.

Built to demonstrate real-world SQL skills relevant to Data Analyst roles.

---

## 🗃️ Database Schema
4 relational tables connected via foreign keys:

| Table       | Description                              |
|-------------|------------------------------------------|
| Customers   | Customer demographics and join date      |
| Products    | Product catalog with cost and price      |
| Regions     | Sales regions and country managers       |
| Sales       | Transactional data (100 records, 2022–2023) |

---

## 🔍 Project Steps

| Step | Description |
|------|-------------|
| 1 | Database & table creation (DDL)          |
| 2 | Sample data insertion (DML)              |
| 3 | Data exploration & quality checks        |
| 4 | Sales analysis queries                   |
| 5 | Advanced analytics (CTEs, Window Functions) |
| 6 | KPI reporting views                      |

---

## Key Business Questions Answered
- What is the total revenue, profit, and profit margin?
- Which regions and product categories drive the most revenue?
- How does revenue trend month-over-month and year-over-year?
- Who are the top customers by lifetime value?
- What is the impact of discounts on order value?
- Which products rank highest within their category?

---

## SQL Concepts Demonstrated
- DDL: `CREATE TABLE`, Primary Keys, Foreign Keys
- DML: `INSERT INTO`
- Joins: multi-table `INNER JOIN`
- Aggregations: `SUM`, `COUNT`, `AVG`, `ROUND`
- Filtering: `WHERE`, `HAVING`, `CASE WHEN`
- CTEs: `WITH` clause for readable multi-step logic
- Window Functions: `LAG`, `RANK`, `SUM OVER`, `AVG OVER`
- Views: `CREATE VIEW` for reusable reporting layers
- Data Quality: NULL checks, duplicate detection, date range validation

---

## Tools Used
- **Database:** Microsoft SQL Server (SQL Server Express 16)
- **IDE:** SQL Server Management Studio (SSMS)

---

## File Structure# Global-Electronics-Sales-Analysis
End-to-end SQL Server sales analysis project covering database design, data exploration, revenue reporting, and advanced analytics using CTEs and window functions.

---

## 🚀 How to Run
1. Open SQL Server Management Studio (SSMS)
2. Run scripts in order from `01` to `06`
3. Each file is self-contained with `USE ElectronicsSalesDB;` at the top

---

## Author
**[Khin Mar Lar Aye]**  
Aspiring Data Analyst | SQL • Excel • Power BI  

