CREATE VIEW Harsco.FactARAging_Aggr1 AS (
SELECT 
--TOP (100) 
A.AsOfDate,
B.AccountCustomerKey,
B.OrganizationKey,
SUM(A.TOTALOPENAMOUNT) TOTAL_OPEN_AMOUNT
 FROM HARSCO.FactARAging A,
HARSCO.FactARInvoices B, HARSCO.DimCustomer C
WHERE A.InvoiceKey = B.InvoiceKey
AND B.AccountCustomerKey = C.CustomerKey
--AND a.AsOfDate = 'Current'
--AND B.ORGANIZATIONKEY ='12'
GROUP BY 
A.AsOfDate,
B.AccountCustomerKey,
B.OrganizationKey
)
