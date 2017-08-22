/*To find a list of Email User IDs of people who have not been on the website this month but have opened an Email*/
SELECT
  (DISTINCT(b.visitor_id))
FROM
  -- selects users this month
  (SELECT DISTINCT(user_id) FROM javascript.pages
  WHERE sent_at >= date_trunc('month', current_date) a
RIGHT JOIN
  -- selects active subscribers
  (SELECT visitor_id FROM public.visitor
  WHERE unsubscribe_date IS NULL or unsubscribe_date < signup_date and date(signup_date) <> current_date) b ON a.user_id = b.visitor_id
LEFT JOIN
  -- selects the last Email open
  (SELECT user_id, date(MAX(sent_at)) AS last_open FROM javascript.email_opened
  WHERE date(sent_at) <> current_date
  GROUP BY 1) c ON b.visitor_id = c.user_id
WHERE a.user_id IS NULL and last_open IS NOT NULL and last_open >= date_trunc('month', current_date)
