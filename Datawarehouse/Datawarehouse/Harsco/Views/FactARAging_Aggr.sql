
--DROP VIEW [Harsco].[FactARAging_Aggr]
CREATE VIEW [Harsco].[FactARAging_Aggr] AS (
SELECT 
--TOP (100) 
D.Country,
D.Location,
A.AsOfDate,
A.AgingDateKey,
--A.AgingType,
B.AccountCustomerKey,
B.OrganizationKey,
--C.CustomerName,
A.ExchangeRateKey,
SUM(A.TOTALOPENAMOUNT) TotalOpenAmount,
SUM(A.CurrentAmount) CurrentAmount,
SUM(A.PastDue30) PastDue30,
SUM(A.PastDue60) PastDue60,
SUM(A.PastDue90) PastDue90,
SUM(A.PastDue120) PastDue120,
SUM(A.PastDue150) PastDue150,
SUM(A.PastDue151PLUS) PastDue151PLUS
 FROM HARSCO.FactARAging A,
HARSCO.FactARInvoices B, HARSCO.DimCustomer C,
HARSCO.DimOrganization D
WHERE A.InvoiceKey = B.InvoiceKey
AND B.AccountCustomerKey = C.CustomerKey
AND B.OrganizationKey = D.OrganizationKey
--AND a.AsOfDate = 'Current'
--AND B.ORGANIZATIONKEY ='12'
AND B.ReceivableType ='Revenue'
AND A.AgingType ='Invoice Due Date'
GROUP BY 
D.Country,
D.Location,
A.AsOfDate,
A.AgingDateKey,
--A.AgingType,
B.AccountCustomerKey,
B.OrganizationKey,
--C.CustomerName,
A.ExchangeRateKey
)
