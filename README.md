# Customer Churn & Retention Analysis

Telecom dataset with 7,000 customers. The goal was to figure out *who* is leaving, *why*, and how much revenue that actually costs the business.

**Tools:** MySQL · Power BI · CSV (Telco dataset)

---

## What I found

- Overall churn rate is **26.6%** — 1,869 customers out of 7K
- **Month-to-month contracts** churn at 42%+. Two-year contracts barely churn at all
- **Fiber optic** users churn the most (~42%), which is surprising given it's the premium tier — likely a pricing/support issue
- Churn drops sharply after the first year. Customers who stick around 4+ years almost never leave
- Senior citizens churn at **41.68%** vs ~25% for non-seniors
- **$139K monthly revenue at risk** from high-risk customers alone
- Los Angeles accounts for the highest revenue lost by city

---

## Dashboard

Three pages — Overview, Deep Dive, and Revenue.

**Page 1 — Overview**
High-level numbers: churn rate, total churned, retained. Broken down by internet service, contract type, gender, and tenure band.
<img width="1341" height="792" alt="image" src="https://github.com/user-attachments/assets/58aee2f1-a864-4c58-b351-a0276c8295e5" />

---

**Page 2 — Deep Dive**
3K high-risk customers flagged. Churn reasons ranked — "Attitude of support person" and "Competitor offered higher speed" are the top two. Risk segmentation by Medium/High/Low.
<img width="1340" height="791" alt="image" src="https://github.com/user-attachments/assets/be106569-12d6-4247-b8fa-1ff2a4328502" />

---

**Page 3 — Revenue**
Where the money is going. $139K monthly revenue at risk, avg CLTV of churned customers at $4.15K. Scatter plot of high-value customers, broken down by contract + internet service.
<img width="1338" height="789" alt="image" src="https://github.com/user-attachments/assets/4d95f855-ecd4-4545-95b0-a6438f3c1cc0" />


---

## SQL work

Queried the dataset using CTEs, `RANK()` partitioned by contract type, and `CASE`-based tenure bands. Main queries:
- Flagged 3K high-risk customers
- Calculated churn rate by contract, city, gender, senior status
- Built a reusable view for the Power BI data model

---

## Files

| File | What it is |
|------|------------|
| `customer_churn.sql` | All SQL queries used for analysis |
| `Customer_Churn.pbix` | Power BI report file (3 pages) |
| `Telco_customer_churn.csv` | Raw dataset |

---

## How to use

1. Run `customer_churn.sql` in MySQL to create the tables and views
2. Open `Customer_Churn.pbix` in Power BI Desktop
3. Update the data source connection to your local MySQL if needed
