/*The entire query creates a materialized view that efficiently summarizes monthly Pix transaction data, 
including the total number of transfers, total amount transferred, and percentage changes in the number of 
transfers over the last month and compared to the average of the last three months. This view can be helpful 
for financial analysis and reporting related to Pix transactions, allowing stakeholders to quickly understand trends 
and performance in outgoing Pix transactions over time.
*/


CREATE MATERIALIZED VIEW pix_metrics AS
WITH pix_outs_by_month AS (
  SELECT
    DATE_TRUNC('month', TO_TIMESTAMP(pix_completed_at / 1000)) AS month,
    COUNT(*) AS num_pix_outs,
    SUM(pix_amount) AS total_pix_outs
  FROM pix_movements
  WHERE in_or_out = 'pix_out'
  GROUP BY 1
)
SELECT
  p.month AS "Month",
  p.num_pix_outs AS "# Number of transfers",
  p.total_pix_outs AS "R$ Amount of Transfers",
  COALESCE(100 * (p.num_pix_outs - LAG(p.num_pix_outs) OVER (ORDER BY p.month)) / LAG(p.num_pix_outs) OVER (ORDER BY p.month), 0) AS "% L1M Number of transfers",
  COALESCE(100 * (p.num_pix_outs - AVG(p.num_pix_outs) OVER (ORDER BY p.month ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING)) / AVG(p.num_pix_outs) OVER (ORDER BY p.month ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING), 0) AS "% L3M AVG Number of transfers"
FROM pix_outs_by_month p;

select * from pix_metrics