create view open_count as
(select campaign_id,
       sum(case when name = 'Opened' then 1 else 0 end) OpenCount
from public.email_tracker
group by campaign_id)

create view send_count as
(select campaign_id, email_subject, num_emails_sent, send_date, edition_id
from public.email_campaign)

select send_count.campaign_id, send_count.email_subject, send_count.num_emails_sent, send_count.send_date, send_count.edition_id,
        open_count.campaign_id, open_count.opencount,
        case 
          when send_count.num_emails_sent = 0 then 0 
          else 
          ((open_count.opencount) / (send_count.num_emails_sent)::float)
          end as percentopens
from send_count
left join open_count on send_count.campaign_id = open_count.campaign_id
where (send_count.send_date >= '2016-09-01')
and (send_count.email_subject <> 'We Picked These Just For You...')
and (send_count.email_subject <> 'Follow us for all the genius tricks')
and (edition_id = 1)
order by percentopens desc