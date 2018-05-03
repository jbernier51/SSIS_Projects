





create   procedure [dbo].[MergeLkpExchangeRate]
as
--truncate table [Harsco].[LKPExchangeRate]

--select * from stg.Oracle_GL_Daily_Rates

BEGIN TRAN;
MERGE [Harsco].[LKPExchangeRate] AS T

USING (
 select
[FROM_CURRENCY]
,[TO_CURRENCY]
,[CONVERSION_DATE]
,[CONVERSION_TYPE]
--,conversion_rate
,round(cast([CONVERSION_RATE] as decimal(36,16)), 16) as Conversion_rate

,dd.datekey
from
[stg].[Oracle_GL_Daily_Rates] cc
inner join Harsco.dimdate dd on [conversion_date] = dateadd(d, -1, fulldate)
--order by 
--from_currency, conversion_date
union 

select
'USD'
,'USD'
,[CONVERSION_DATE]
,[CONVERSION_TYPE]
--,conversion_rate
,1 as Conversion_rate
,dd.datekey
from
[stg].[Oracle_GL_Daily_Rates] cc
inner join Harsco.dimdate dd on [conversion_date] = dateadd(d, -1, fulldate)
where from_currency = 'CAD'
and to_currency = 'USD'
)
 AS S
ON (T.DateKey = S.DateKey
and t.fromcurrency = s.from_currency
and t.tocurrency = s.to_currency

) 
WHEN NOT MATCHED BY TARGET 
    THEN INSERT(
	DateKey
,	[ExchangeRate]
,[FromCurrency]
,[ToCurrency]


	,[CreatedDateTime]
,[LastUpdatedDateTime]
,[EffectiveStartDate]
,[EffectiveEndDate]
,[CurrentRecordIndicator] )
values (s.datekey, conversion_rate, from_currency, to_currency
--start audit columns
,getdate(), getdate(), '2099-01-01', '2099-01-01', 1)
WHEN MATCHED 
    THEN UPDATE SET t.exchangerate = s.conversion_rate
	;
--WHEN NOT MATCHED BY SOURCE AND T.EmployeeName LIKE 'S%'
  --  THEN DELETE 
--OUTPUT $action, inserted.*, deleted.*;
--ROLLBACK TRAN;
;

--select * from [Harsco].[FactARInvoices]



commit tran 


exec [dbo].[CreateDimensionUnknownRow]
@tablename = 'LKPExchangeRate', 
@tableschema = 'Harsco'
;