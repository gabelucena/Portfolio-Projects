/*
The entire query creates a materialized view that efficiently summarizes monthly account creation data, 
including the total number of accounts created and the percentage changes in account creation over the last month 
and compared to the average of the last three months. This view is useful for monitoring trends in account growth, 
which can inform business strategies and decision-making processes regarding customer acquisition and retention.

*/

CREATE MATERIALIZED VIEW accounts_metrics AS
WITH accounts_by_month AS (
  SELECT
    DATE_TRUNC('month', created_at) AS month,
    COUNT(*) AS num_accounts
  FROM accounts
  GROUP BY 1
 )
SELECT
  a.month AS "Month",
  a.num_accounts AS "# Number of Accounts",
  COALESCE(100 * (a.num_accounts - LAG(a.num_accounts) OVER (ORDER BY a.month)) / LAG(a.num_accounts) OVER (ORDER BY a.month), 0) AS "% L1M Number of accounts",
  COALESCE(100 * (a.num_accounts - AVG(a.num_accounts) OVER (ORDER BY a.month ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING)) / AVG(a.num_accounts) OVER (ORDER BY a.month ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING), 0) AS "% L3M AVG Number of accounts"
FROM accounts_by_month a;

select * from accounts_metrics