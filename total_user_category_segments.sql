/* Selects count of distinct users based on the category they viewed the most with a minimum of 5*/
--Selects categories and how many users have that category as the most viewed
SELECT
b.url,
count(b.user_id)
FROM
  --Selects distinct user and their top category
  (SELECT
  DISTINCT(a.user_id),
  first_value(a.url_part) OVER (PARTITION BY a.user_id) as url
  FROM
    --Selects users_id, category, and counts of category they consumed.  Filtering out footer pages and categories resulting in null
    (SELECT
    user_id,
    split_part(url,'/',4) as url_part,
    COUNT(*) as pvs
    FROM
    javascript.pages
    WHERE
    user_id IS NOT NULL
    and split_part(url,'/',4) <> 'footer' and split_part(url,'/',4) <> ''
    GROUP BY 1,2
    ORDER BY 1,3 DESC) a
  --Creates the threshold for acceptable amount of PVs
  WHERE a.pvs > 5) b
GROUP BY 1
ORDER BY 2 DESC
