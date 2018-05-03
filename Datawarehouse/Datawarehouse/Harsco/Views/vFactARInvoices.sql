
/****** 20180420_MergeFactARAging_Failing - Prem : Changing the ReceivableType to a expression as per tammy request ******/


create view [Harsco].[vFactARInvoices]
as


SELECT i.InvoiceKey
      ,i.CustomerTransactionID
      ,i.OrganizationKey
      ,i.GeneralLedgerDateKey
      ,i.InvoiceDateKey
      ,i.InvoiceDueDateKey
      ,i.ExchangeRateKey
      ,i.AccountCustomerKey
      ,i.BillToCustomerLocationKey
      ,i.ShipToCustomerLocationKey
      ,i.PaymentTermsKey
      ,i.LocalCurrencyCode
      ,i.InvoiceCurrencyCode
      ,i.LocalExchangeRate
      ,i.InvoiceNumber
      ,i.InvoiceID
      ,i.SalesOrderNumber
      ,i.PurchaseOrderNumber
      ,i.InvoiceType
       --,i.ReceivableType Changed by Prem to replace expression
	  ,(CASE i.InvoiceType
		WHEN 'MET BR VEN 5551' THEN 'Asset Sales' 
		WHEN 'MET CA Conv Misc Inv' THEN 'OTHER'
		WHEN 'MET US Conv Misc Inv' THEN 'OTHER'
		WHEN 'MET CA Misc Inv' THEN 'OTHER'
		WHEN 'MET US Misc Inv' THEN 'OTHER'
		WHEN 'MIN CA Misc Inv' THEN 'Revenue'
		ELSE i.ReceivableType
		END) AS ReceivableType
      ,i.InvoiceStatus
      ,i.ReasonCode
      ,i.Comments
      ,i.LocalInvoiceAmount
      ,i.InvoiceAmount
      ,i.InvoiceAmountUSD
      ,n.NoteText
	  ,n.NoteType 
	  ,n.CreatedByUser
	  ,n.NoteLastUpdatedDateTime

  FROM
   harsco.FactARInvoices i
left outer join (SELECT 
S.InvoiceKey,S.AccountCustomerKey,N.NoteDatekey,N.NoteLastUpdatedDateTime,
N.Notetext,N.NoteType,N.CreatedByUser
FROM 
(SELECT F.*, min_date = MIN(INVOICEDATEKEY) OVER (PARTITION BY AccountCustomerKey)
  FROM harsco.FactARInvoices F
  WHERE 
 InvoiceStatus = 'OP'
 
 ) s

 LEFT OUTER JOIN 

  (  SELECT m.NoteDatekey,m.NoteLastUpdatedDateTime,m.CustomerKey,m.notetext,
  m.NoteType,m.CreatedByUser
from
(
  SELECT * ,
    max_date = MAX(NoteLastUpdatedDateTime) OVER (PARTITION BY CUSTOMERKEY)
  FROM harsco.FactCustomerNotes
 
  ) m
  where m.NoteLastUpdatedDateTime = max_date) n
  ON S.AccountCustomerKey = N.CustomerKey
  AND N. NoteDatekey >= S.min_date)  n
on i.InvoiceKey = n.InvoiceKey
