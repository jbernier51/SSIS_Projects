
create view [Harsco].[vLKPExchangeRate]
as

SELECT [ExchangeRateKey]
      ,ex.[DateKey]
	  --,ddd.datekey
      ,[ExchangeRate]
      ,[FromCurrency]
      ,[ToCurrency]
      ,[CreatedDateTime]
      ,[LastUpdatedDateTime]
      ,[EffectiveStartDate]
      ,[EffectiveEndDate]
      ,[CurrentRecordIndicator]
      ,[AuditKey]
  FROM [Harsco].[LKPExchangeRate] ex
  --inner join harsco.dimdate dd
  --on ex.datekey = dd.datekey
  --inner join harsco.dimdate ddd
  --on dd.fulldate = dateadd(d, -1, ddd.fulldate)
  --where dd.fulldate = cast(getdate() as date)