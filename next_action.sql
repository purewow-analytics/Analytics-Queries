with page_info as  --selects page information and the next page information
    (
        SELECT
          anonymous_id, 
          user_id,
          id as page_id, 
          received_at,
          context_page_path,
          category,
          split_part(context_page_path, '/', 2) as category_regex, 
          LAG(received_at) over (PARTITION BY anonymous_id order by received_at DESC) as next_time_stamp,
          LAG(EXTRACT(EPOCH FROM received_at)) over (PARTITION BY anonymous_id order by received_at DESC) - EXTRACT(EPOCH FROM received_at) as time_to_next_page,
          LAG(context_page_path) OVER (PARTITION BY anonymous_id ORDER BY received_at DESC) as next_page,
          LAG(category) OVER (PARTITION BY anonymous_id ORDER BY received_at DESC) as next_category,
          LAG(split_part(context_page_path, '/', 2)) OVER (PARTITION BY anonymous_id ORDER BY received_at DESC) as next_category_regex,
          CASE WHEN
            LAG(EXTRACT(EPOCH FROM received_at)) over (PARTITION BY anonymous_id order by received_at DESC) - EXTRACT(EPOCH FROM received_at) <= 30 * 60
            THEN 1
            ELSE 0
            END as within_session
        FROM javascript.pages
        WHERE DATE(received_at) >= '2/1/2018' and DATE(received_at) <= '2/12/2018')
, track_info as  --Joins page information to event information.  Creates more records as pages can have more than one event.
(select
    pi.*,
    --b.anonymous_id,
    b.id as event_id,
    --b.context_page_path,
    b.received_at as event_tstamp,
    b.event
FROM
    page_info pi
    left join javascript.tracks b on pi.anonymous_id = b.anonymous_id and pi.context_page_path = b.context_page_path and (DATE(b.received_at) >= '2/1/2018' OR b.received_at IS NULL) AND (event <> 'article_completed' OR event IS NULL)  AND (pi.received_at > b.received_at OR event IS NULL)  
WHERE pi.category_regex = 'news'  --defines the category we are looking at
ORDER BY pi.anonymous_id, b.received_at

)

SELECT
COUNT(*)
FROM
(
SELECT DISTINCT  --creates distinct records for first events and relevant information of the first event that happens on the page.
  track_info.*,
  FIRST_VALUE(event_id) OVER (PARTITION BY anonymous_id, context_page_path, received_at ORDER BY event_tstamp ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as first_event_id,
  FIRST_VALUE(event) OVER (PARTITION BY anonymous_id, context_page_path, received_at ORDER BY event_tstamp ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as first_event,
  FIRST_VALUE(event_tstamp) OVER (PARTITION BY anonymous_id, context_page_path, received_at ORDER BY event_tstamp ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as first_event_tstamp
  
  
FROM track_info
--limit 1000
) WHERE (first_event_id = event_id OR first_event_id IS NULL) and within_session = 1
