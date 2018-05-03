









CREATE view [Harsco].[vCustomerNoteInvoiceM2M]
as

select isnull(cn2.CustomerNoteKey, -1) as CustomerNoteKey, t1.InvoiceKey

from
(
select fin.invoicekey, accountcustomerkey, max(cn.NoteLastUpdatedDateTime) as MaxNote

from 
 harsco.factarinvoices fin
left outer join (SELECT s.CustomerKey,s.MinNoteDateKey,S.MaxNoteDateKey,s.NoteLastUpdatedDateTime,cn.NoteText,
cn.NoteType,cn.CreatedByUser
FROM
 (SELECT CustomerKey,MIN(NoteDatekey) AS MinNoteDateKey,MAX(NoteDatekey) AS MaxNoteDateKey,
 MAX(NoteLastUpdatedDateTime) AS  NoteLastUpdatedDateTime
 FROM harsco.FactCustomerNotes
 GROUP BY CustomerKey)s,
 harsco.FactCustomerNotes cn
 WHERE 
 s.CustomerKey = cn.CustomerKey
 AND S.MaxNoteDateKey = cn.NoteDatekey) cn

on cn.customerkey = fin.AccountCustomerKey
and     cn.MinNoteDateKey >= fin.InvoiceDateKey

group by fin.invoicekey, AccountCustomerKey
) t1
left outer join 
harsco.FactCustomerNotes cn2
on t1.AccountCustomerKey = cn2.customerkey
and maxnote = cn2.NoteLastUpdatedDateTime



--select count(*) from harsco.FactCustomerNotes