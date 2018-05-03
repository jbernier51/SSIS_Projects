


create  view [Harsco].[vFactARReceipts]

as

select r.*, isnull(i.invoicenumber, 'No Invoice') as [Invoice Number] from 
harsco.FactARReceipts r
left outer join harsco.factarinvoices i
on r.InvoiceKey = i.InvoiceKey

where r.ReceiptTransactionID not like 'RS%'
--and i.AccountCustomerKey = 13212