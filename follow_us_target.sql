/*Selects user_ids from people who have indicated they have a social account but have not come from our social pages*/
SELECT
  DISTINCT(a.user_id)
FROM
--Selects users that have a social action and come from earned traffic of the same platform
  (SELECT user_id FROM javascript.article_shared
    WHERE action_type = 'Pinterest' --Change Social Action to match Social Network
      and user_id IS NOT NULL
  UNION
  SELECT user_id FROM javascript.pages
    WHERE context_campaign_source <> 'pinterest' --Change source to match Social Network
      and context_page_referrer LIKE '%pinterest.%' --Change referrer to match Social Network
      and user_id IS NOT NULL) a
LEFT JOIN
--Select users that have come from owned traffic of the platform
(SELECT user_id FROM javascript.pages
  WHERE context_campaign_source = 'pinterest') --Change source to match Social Network
    b ON a.user_id = b.user_id
WHERE b.user_id IS NULL and a.user_id IS NOT NULL
