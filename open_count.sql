create view open_count as
(select campaign_id,
       sum(case when name = 'Opened' then 1 else 0 end) OpenCount
from public.email_tracker
group by campaign_id)