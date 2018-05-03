


create view [Harsco].[vLKPExchRateProjection]
as

SELECT DISTINCT
       [DateKey]
	  ,[FromCurrency]
	  ,[ToCurrency]
	  ,[ExchangeRate]

  FROM [Harsco].[LKPExchangeRate]  EX
  WHERE 
	  ToCurrency='USD' 
   AND ( DateKey like '2017%'
			OR DateKey like '2018%'
			OR DateKey like '2019%' 
			OR DateKey like '202%'  ) 

/********Prem : Object created to join projection table********/
