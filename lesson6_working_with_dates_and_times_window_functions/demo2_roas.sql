-- приклад ROAS 
-- Задача: агрегувати ROAS по днях та реалізувати порівняння ROAS Week-over-Week, тобто з таким самим днем попереднього тижня.
with ad_roas as (
	select 
	 ad_date,
	 case  when sum(spend) != 0 then sum(value)::numeric / sum(spend) end as roas	
	from facebook_ads_basic_daily fabd 
	group by 1
	order by 1 desc
)
select 
  roas.ad_date,
  roas.roas,
  roas7d.roas as roas7d
from ad_roas as roas 
left join ad_roas as roas7d on roas.ad_date  =  roas7d.ad_date +  interval '7 day' 
;

-- для року
with ad_roas as (
	select  
	 date(date_trunc('month' , ad_date)) as ad_month,
	 case  when sum(spend) != 0 then sum(value)::numeric / sum(spend) end as roas	
	from facebook_ads_basic_daily fabd 
	group by 1
	order by 1 desc
)
select 
  roas.ad_month, 
  roas.roas,
  roas1y.roas as roas1y
from ad_roas as roas 
left join ad_roas as roas1y on roas.ad_month  =  roas1y.ad_month +  interval '1 year' 
;

-- для місяця
with ad_roas as (
	select  
	 date(date_trunc('month' , ad_date)) as ad_month,
	 case  when sum(spend) != 0 then sum(value)::numeric / sum(spend) end as roas	
	from facebook_ads_basic_daily fabd 
	group by 1
	order by 1 desc
)
select 
  roas.ad_month, 
  roas.roas,
  roas1m.roas as roas1m
from ad_roas as roas 
left join ad_roas as roas1m on roas.ad_month  =  roas1m.ad_month +  interval '1 month'
;
-------------------------------------------------------------------------------------
-- !!!! трохи більш надійний селф джойн, але можна ще вирішити за допомогою лаг-а
with ad_roas as (
		select 
			date(date_trunc('month' , ad_date)) as ad_month,
			case 
				when sum(spend) != 0 then sum(value)::numeric / sum(spend)
			end as roas	
		from facebook_ads_basic_daily fabd 
		group by 1
		order by 1 desc
)
select
  roas.ad_month, 
  roas.roas,
  lag(roas) over (order by ad_month asc)  as roas_1m_ago
from ad_roas as roas 
;
