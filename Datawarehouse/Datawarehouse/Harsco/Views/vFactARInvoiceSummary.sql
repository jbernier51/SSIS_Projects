



create  view [Harsco].[vFactARInvoiceSummary]

as

select  ag.AsOfDate, d.fulldate as ReceiptDate, r.*, isnull(i.invoicenumber, 'No Invoice') as [Invoice Number], cast(i.InvoiceKey as varchar) + '-' + cast(ag.AgingDateKey as varchar) + '-2'  + '-' + case when agingtype = 'Invoice Due Date' then '1' else '2' end as SummaryKey
from 
harsco.FactARReceipts r
inner join harsco.factarinvoices i
on r.InvoiceKey = i.InvoiceKey
inner join harsco.FactARAging ag
on i.invoicekey = ag.InvoiceKey
and r.ReceivedDateKey >= ag.AgingDateKey

inner join harsco.DimDate d
on r.ReceivedDateKey = d.DateKey

where r.ReceiptTransactionID not like 'RS%'
and d.FullDate  < (select MonthEndDate from harsco.DimDate where DateKey = AgingDateKey)
--and i.AccountCustomerKey = 13212