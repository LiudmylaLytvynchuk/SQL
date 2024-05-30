SELECT
   distinct event_name
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
LIMIT 100
;

SELECT
   distinct event_name
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
LIMIT 100
;

/*
Є спосіб кверіти лише частину таблиць (технічна складова, це не оператор і не частина таблиці це біг квері дає спосіб як використовувати те що винесено за зірочку, він стрінг рядок і його можна легко порівнювати)
*/

SELECT distinct event_date
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
where _table_suffix >= '20210101'
;
SELECT distinct event_date
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
where _table_suffix = '20210101'
;
SELECT distinct event_date
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
where _table_suffix in ( '20202130', '20202131' )
;

-- Доречі можна через битвин 
SELECT distinct event_date
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
where _table_suffix between '20201201' and '20201231'
;

SELECT
   cast(event_timestamp as string),
   timestamp_micros(event_timestamp),
   event_timestamp / event_bundle_sequence_id,
   date(timestamp_micros(event_timestamp)),
   date_diff(current_date(), date(timestamp_micros(event_timestamp)), week),
   event_name,
   regexp_extract(event_name, r'([^_]+)$')
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
LIMIT 100
;

select
  (SELECT value.int_value FROM e.event_params WHERE key = 'ga_session_id') as ga_session_id -- не є унікальним, відрізнається також за юзером
from  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e
;

select
regexp_extract(
      (select value.string_value from unnest(event_params) where key = 'page_location'),
      r'(?:\w+\:\/\/)?[^\/]+\/([^\?#]*)') as page_path
from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e
;


select 1 / 2
;

select
   round(event_timestamp / event_bundle_sequence_id,2)
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
;

select
   event_timestamp,
   date(timestamp_micros(event_timestamp))
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
;


select
  current_date() as rep_date,
  date(timestamp_micros(event_timestamp)) as event_date,
  date_diff( current_date(), date(timestamp_micros(event_timestamp)), week) as diff_between_dates
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
;


 select
   event_name,
   regexp_extract(event_name, r'([^_]+)$')
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
;

select event_params
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
limit 100
;

select
  date(timestamp_micros(event_timestamp)) as event_date,
  event_name,
  (SELECT value.int_value FROM e.event_params WHERE key = 'ga_session_id') as ga_session_id, -- не є унікальним, відрізнається також за юзером
  regexp_extract((SELECT value.string_value FROM e.event_params WHERE key = 'page_location'),r'(?:\w+\:\/\/)?[^\/]+\/([^\?#]*)') as page_path,
  (SELECT value.string_value FROM e.event_params WHERE key = 'session_engaged') as is_session_engaged
from  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131` as e
limit 1000
;

select geo.city
from  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131` as e
limit 1000
;

-- весь інший синтаксис робимо як звикли ранше, наприклад пошук які івенти є найпопулярніші
SELECT  
       event_name, count(*)
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
where _table_suffix between '20201201' and '20201231'
group by event_name
order by 2 desc
;
