SELECT
cohort,
months_active AS month_actual,
rank() OVER (PARTITION BY cohort ORDER BY months_active ASC) AS month_rank,
COUNT(DISTINCT(m.user_id)) AS uniques,
COUNT(DISTINCT(m.user_id)) / (first_value(COUNT(DISTINCT(m.user_id))) OVER (PARTITION BY cohort))::REAL AS fraction_retained
FROM
  (SELECT
  user_id,
  DATE_TRUNC('month', min(received_at)) AS cohort
  FROM javascript.pages
  WHERE user_id IS NOT NULL
  GROUP BY 1) c
JOIN 
  (SELECT
  user_id,
  DATE_TRUNC('month', received_at) AS months_active
  FROM javascript.pages
  WHERE user_id IS NOT NULL
  GROUP BY 1,2) m
ON c.user_id = m.user_id
GROUP BY 1,2
ORDER BY 1,2;
