




--DROP VIEW [Harsco].[vDimActiveCustomer];

CREATE VIEW [Harsco].[vDimActiveCustomer]
AS
(
SELECT 
DISTINCT CUST.CustomerKey,
CUST.CustomerAccountNumber,
CUST.CustomerName,
CUST.PaymentTermsKey,
CUST.SourceSystemID 
FROM HARSCO.DIMCUSTOMER CUST, HARSCO.FACTARRECEIPTS REC
WHERE CUST.CUSTOMERKEY =REC.CUSTOMERKEY
UNION 
SELECT 
DISTINCT CUST.CustomerKey,
CUST.CustomerAccountNumber,
CUST.CustomerName,
CUST.PaymentTermsKey,
CUST.SourceSystemID 
FROM HARSCO.DIMCUSTOMER CUST, HARSCO.FACTARINVOICES INV
WHERE CUST.CUSTOMERKEY =INV.ACCOUNTCUSTOMERKEY
UNION 
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [CustomerKey]
      ,[CustomerAccountNumber]
      ,N'Ω Sum of Other Customers' CustomerName
      ,[PaymentTermsKey]
      ,[SourceSystemID]
  FROM [Harsco].[DimCustomer]
where CustomerName ='Others'
)
	
/****** Rama -- Script for TopN selction ******/

