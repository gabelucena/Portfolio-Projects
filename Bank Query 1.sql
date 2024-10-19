WITH all_transactions AS (
  SELECT 
    t.account_id,
    'in' AS transaction_type,
    t.amount AS amount,
    to_timestamp(t.transaction_completed_at / 1000) AT TIME ZONE 'UTC' AS completed_at,
    dt.month_id,
    dt.year_id
  FROM transfer_ins t
  JOIN d_time dt ON to_timestamp(t.transaction_completed_at / 1000) AT TIME ZONE 'UTC' = dt.action_timestamp::timestamptz
  
  UNION ALL
  
  SELECT 
    t.account_id,
    'out' AS transaction_type,
    -t.amount AS amount,
    to_timestamp(t.transaction_completed_at / 1000) AT TIME ZONE 'UTC' AS completed_at,
    dt.month_id,
    dt.year_id
  FROM transfer_outs t
  JOIN d_time dt ON to_timestamp(t.transaction_completed_at / 1000) AT TIME ZONE 'UTC' = dt.action_timestamp::timestamptz
  
  UNION ALL
  
  SELECT 
    p.account_id,
    CASE 
      WHEN p.in_or_out = 'in' THEN 'in'
      ELSE 'out'
    END AS transaction_type,
    CASE 
      WHEN p.in_or_out = 'in' THEN p.pix_amount
      ELSE -p.pix_amount
    END AS amount,
    to_timestamp(p.pix_completed_at / 1000) AT TIME ZONE 'UTC' AS completed_at,
    dt.month_id,
    dt.year_id
  FROM pix_movements p
  JOIN d_time dt ON to_timestamp(p.pix_completed_at / 1000) AT TIME ZONE 'UTC' = dt.action_timestamp::timestamptz
)

SELECT 
  a.account_id as "Account ID",
  d.action_month as "Month",
  dy.action_year as "Year",
  SUM(CASE WHEN at.transaction_type = 'in' THEN at.amount ELSE 0 END) AS "Total Money In",
  SUM(CASE WHEN at.transaction_type = 'out' THEN -at.amount ELSE 0 END) AS "Total Money Out",
  SUM(at.amount) AS "Account Monthly Balance"
FROM all_transactions at
JOIN accounts a ON a.account_id = at.account_id
JOIN d_month d ON d.month_id = at.month_id
JOIN d_year dy ON dy.year_id = at.year_id
GROUP BY a.account_id, d.action_month, dy.action_year
ORDER BY dy.action_year ASC, d.action_month ASC;