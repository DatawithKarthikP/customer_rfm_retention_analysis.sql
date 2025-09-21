# # 📊 Customer RFM & Retention Analysis

This project showcases how to perform **RFM (Recency, Frequency, Monetary)** and **Customer Retention Analysis** using **SQL Server**. The goal is to help businesses better understand customer behavior, identify high-value customers, and improve retention strategies.

---

## 📌 Objectives

- Calculate **RFM metrics** to segment customers
- Identify **high-value and churned customers**
- Analyze **monthly retention trends**
- Perform **cohort analysis** for long-term customer behavior
- Use **SQL Server CTEs**, **window functions**, and **joins** to solve real business problems

---

## 🗂️ Dataset Structure

Assumes two core tables:

### `Customers`
| Column       | Type        |
|--------------|-------------|
| CustomerID   | INT (PK)    |
| CustomerName | NVARCHAR    |
| SignupDate   | DATE        |

### `Orders`
| Column       | Type        |
|--------------|-------------|
| OrderID      | INT (PK)    |
| CustomerID   | INT (FK)    |
| OrderDate    | DATE        |
| TotalAmount  | DECIMAL     |

---

## ✅ Business Questions Answered

1. **Calculate RFM metrics** (Recency, Frequency, Monetary) for each customer  
2. **Segment customers** into RFM tiers using NTILE() and generate RFM scores  
3. **Identify top 10 high-value customers** based on RFM score  
4. **Measure monthly customer retention rates**  
5. **Detect churned customers** (no purchases in last 90 days)  
6. **Perform cohort analysis** by customer signup month

---

## 🛠️ SQL Features Used

- `CTE (Common Table Expressions)`
- `NTILE()` and other **window functions**
- `GROUP BY`, `HAVING`, `JOIN`
- `DATEDIFF()`, `FORMAT()` for date-based analytics

---

