create database Customer_Churn;

select * from telco_customer_churn;

-- Overall churn rate & Revenue at risk
SELECT
  COUNT(*) AS total_customers,
  SUM(Churn_Value) AS churned_customers,
  ROUND(SUM(Churn_Value) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
  ROUND(SUM(CASE WHEN Churn_Label = 'Yes' THEN Monthly_Charges ELSE 0 END), 2) AS monthly_revenue_lost
FROM telco_customer_churn;

-- Churn rate by contract type
SELECT Contract,
COUNT(*) AS total_customers, SUM(Churn_Value) AS churned,
ROUND(SUM(Churn_Value) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
ROUND(AVG(Monthly_Charges), 2) AS avg_monthly_charge
FROM telco_customer_churn
GROUP BY Contract
ORDER BY churn_rate_pct DESC;


-- Top churn reasons by revenue lost
SELECT Churn_Reason,
COUNT(*) AS customers_lost, ROUND(SUM(Monthly_Charges), 2) AS monthly_revenue_lost,
ROUND(AVG(CLTV), 0) AS avg_lifetime_value
FROM telco_customer_churn
WHERE Churn_Label = 'Yes'
GROUP BY Churn_Reason
ORDER BY monthly_revenue_lost DESC
LIMIT 10;


-- Churn by Tenure band
SELECT
CASE
WHEN Tenure_Months <= 12 THEN '0–1 Year'
WHEN Tenure_Months <= 24 THEN '1–2 Years'
WHEN Tenure_Months <= 48 THEN '2–4 Years'
ELSE '4+ Years'
END AS tenure_band,
COUNT(*) AS total_customers, SUM(Churn_Value) AS churned,
ROUND(SUM(Churn_Value) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
ROUND(AVG(Monthly_Charges), 2) AS avg_monthly_charge
FROM telco_customer_churn
GROUP BY tenure_band
ORDER BY churn_rate_pct DESC;


-- High valued churned customers
WITH high_value AS (
SELECT *
FROM customer_churn.telco_customer_churn
WHERE CLTV > (SELECT AVG(CLTV) FROM customer_churn.telco_customer_churn) )
SELECT
Contract, Internet_Service,
COUNT(*) AS high_value_churned,
ROUND(AVG(Monthly_Charges), 2) AS avg_monthly_charge,
ROUND(AVG(CLTV), 0) AS avg_cltv
FROM high_value
WHERE Churn_Label = 'Yes'
GROUP BY Contract, Internet_Service
ORDER BY avg_cltv DESC;


-- Rank customers by CLTV within contract type
SELECT 
Customer_ID, Contract, Monthly_Charges, CLTV, Churn_Label,
RANK() OVER (PARTITION BY Contract ORDER BY CLTV DESC) AS cltv_rank
FROM customer_churn.telco_customer_churn
ORDER BY Contract, cltv_rank
LIMIT 30;


-- Churn scores segments with AVG charges
WITH scored AS (
SELECT *,
CASE
WHEN Churn_Score >= 70 THEN 'High Risk'
WHEN Churn_Score >= 40 THEN 'Medium Risk'
ELSE 'Low Risk'
END AS risk_segment
FROM telco_customer_churn )
SELECT risk_segment,
COUNT(*) AS total_customers, SUM(Churn_Value) AS actually_churned,
ROUND(AVG(Monthly_Charges), 2) AS avg_monthly_charge,
ROUND(AVG(CLTV), 0) AS avg_cltv
FROM scored
GROUP BY risk_segment
ORDER BY avg_monthly_charge DESC;


-- Service adoption vs Churn rate
SELECT
(CASE WHEN Online_Security = 'Yes' THEN 1 ELSE 0 END +
CASE WHEN Online_Backup = 'Yes' THEN 1 ELSE 0 END +
CASE WHEN Device_Protection = 'Yes' THEN 1 ELSE 0 END +
CASE WHEN Tech_Support = 'Yes' THEN 1 ELSE 0 END +
CASE WHEN Streaming_TV = 'Yes' THEN 1 ELSE 0 END +
CASE WHEN Streaming_Movies = 'Yes' THEN 1 ELSE 0 END) AS services_count,
COUNT(*) AS total_customers,
SUM(Churn_Value) AS churned,
ROUND(SUM(Churn_Value) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customer_churn.telco_customer_churn
GROUP BY services_count
ORDER BY services_count;


-- Running total of revenue lost by city 
SELECT City, churned_customers, monthly_revenue_lost,
ROUND(SUM(monthly_revenue_lost) OVER (ORDER BY monthly_revenue_lost DESC), 2) AS running_total_lost
FROM (
SELECT City,
SUM(Churn_Value) AS churned_customers,
ROUND(SUM(CASE WHEN Churn_Label = 'Yes' THEN Monthly_Charges ELSE 0 END), 2) AS monthly_revenue_lost
FROM customer_churn.telco_customer_churn
GROUP BY City ) city_summary
ORDER BY monthly_revenue_lost DESC
LIMIT 20;


-- Senior citizen churn vs non-senior
WITH segments AS (
SELECT
CASE WHEN Senior_Citizen = 1 THEN 'Senior' ELSE 'Non-Senior' END AS segment, Churn_Value, Monthly_Charges, CLTV, Contract
FROM customer_churn.telco_customer_churn )
SELECT segment, COUNT(*) AS total, SUM(Churn_Value) AS churned,
ROUND(SUM(Churn_Value) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
ROUND(AVG(Monthly_Charges), 2) AS avg_monthly_charge,
ROUND(AVG(CLTV), 0) AS avg_cltv
FROM segments
GROUP BY segment;


-- Payment method churn with % contribution
SELECT Payment_Method,
COUNT(*) AS total_customers, SUM(Churn_Value) AS churned,
ROUND(SUM(Churn_Value) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
ROUND(SUM(Churn_Value) * 100.0 /
SUM(SUM(Churn_Value)) OVER (), 2) AS pct_of_total_churn
FROM customer_churn.telco_customer_churn
GROUP BY Payment_Method
ORDER BY churned DESC;
