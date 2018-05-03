/****** Script for SelectTopNRows command from SSMS  ******/
create view Harsco.vLKPExchangeRateToday
as
(
SELECT [ExchangeRateKey]
      ,ex.[DateKey]
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
  inner join harsco.dimdate dd
  on ex.datekey = dd.datekey
  where dd.fulldate = cast(getdate() as date)
  )