SELECT
COUNT(DISTINCT(a.user_id)) as uniques,
count(a.received_at) as PVs,
--counts pages that were not the beginning of a new session and have a previous pageview
SUM(CASE WHEN a.new_session <> 1 and a.previous IS NOT NULL THEN 1 ELSE 0 END) as next_PVs,
--
(SUM(CASE WHEN a.new_session <> 1 and a.previous IS NOT NULL THEN 1 ELSE 0 END) * 1.00)/count(a.received_at) as likelihood
FROM
  (SELECT 
    user_id,
    received_at,
    lag(received_at) over (PARTITION BY user_id order by received_at) as previous,
    extract(epoch from received_at) - lag(extract(epoch from received_at)) over (PARTITION BY user_id order by received_at) as time_interval,
    --defines the sessionization as a 30 minute time interval
    CASE WHEN extract(epoch from received_at) - lag(extract(epoch from received_at)) over (PARTITION BY user_id order by received_at) >= 30 * 60
    THEN 1
    ELSE 0
    END as new_session
  FROM javascript.pages
  WHERE
  --change date where relevant
  DATE_TRUNC('month', received_at) = '12/1/2017' and user_id IS NOT NULL) a
