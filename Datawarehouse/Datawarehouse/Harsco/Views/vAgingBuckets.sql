
create View [Harsco].[vAgingBuckets]
as

SELECT asofdate, AgingDateKey, agingtype, invoicekey,[ExchangeRateKey] , Bucket, openamount, case 
when Bucket = 'Current' then 1
when Bucket = '1-30' then 2
when Bucket = '31-60' then 3
when Bucket = '61-90' then 4
when Bucket = '91-120' then 5
when Bucket = '121-150' then 6
when Bucket = '151+' then 7
else 8
end as BucketSort
,cast(InvoiceKey as varchar) + '-' + cast(AgingDateKey as varchar)  + '-' + cast( case 
when Bucket = 'Current' then 1
when Bucket = '1-30' then 2
when Bucket = '31-60' then 3
when Bucket = '61-90' then 4
when Bucket = '91-120' then 5
when Bucket = '121-150' then 6
when Bucket = '151+' then 7
else 8
end as varchar)  + '-' + 
case when agingtype = 'Invoice Due Date' then '1' else '2' end as SummaryKey

FROM 
   (SELECT asofdate,[AgingType], invoicekey, [ExchangeRateKey], AgingDateKey
   ,[CurrentAmount] as 'Current'
   , [PastDue30] as '1-30'
   ,[PastDue60] as '31-60'
   ,[PastDue90] as '61-90'
   ,[PastDue120] as '91-120'
,[PastDue150] as '121-150'
,[PastDue151PLUS] as '151+'

   FROM [Harsco].[FactARAging]) p
UNPIVOT
   (OpenAmount FOR Bucket IN 
      ([Current], [1-30], [31-60], [61-90], [91-120],[121-150],[151+])
)AS unpvt;