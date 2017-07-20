/*To find the average time on a specified page using the anonymous_id and capping time at 30 minutes*/
SELECT AVG(EXTRACT('EPOCH' FROM sent_at) - EXTRACT('EPOCH' FROM last_event)) FROM    
        (SELECT *,
              LAG(sent_at,1) OVER (PARTITION BY anonymous_id ORDER BY sent_at) AS last_event,
              LAG(context_page_url,1) OVER (PARTITION BY anonymous_id ORDER BY sent_at) AS last_page
        FROM javascript.pages) as last
WHERE last_page LIKE --INSERT PAGE and last_page <> context_page_url and last_event IS NOT NULL and EXTRACT('EPOCH' FROM sent_at) - EXTRACT('EPOCH' FROM last_event) <= 1800
