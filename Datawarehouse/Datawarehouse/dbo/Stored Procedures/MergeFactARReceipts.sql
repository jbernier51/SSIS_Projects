














--rollback tran



CREATE   procedure [dbo].[MergeFactARReceipts]
--select * from harsco.factarreceipts
as
/****************************** 
** Procedure Name: MergeFactARReceipts
** Desc:  Merge JDE & Oracle Receipt transactions
** Auth: MS Consultants
** Date:  May-Nov 2017
**************************
** Change History
**************************
** CHG#           Date      Author				Description 
** ----------   --------   ---------				------------------------------------
** CHG0008622  27-Nov-2017	Sue Hankey          Change oracle fx rate key lookup to not add 1 to get lookup date  
***/

--truncate table Harsco.FactARReceipts
--Oracle

BEGIN TRAN;

UPDATE [stg].[Oracle_ARReceipts] SET InvoiceIDCalculated = 
isnull(invoice_no, [Receipt_Number])+ '/' + ISNULL(CUSTOMER_NO_NEW,CUSTOMER_NO) + '/' + entity + '/' + ltrim(rtrim(segment2)) + '/' +
isnull(CustomerTRANSACTION_ID, PaymentSchedule_ID)

MERGE Harsco.FactARReceipts AS T
USING (
 select
 
 [ENTITY]
 ,customertransactionid
,[SEGMENT2]
,[TRANSACTION_ID]
,[CASH_RECEIPT_ID]
,[INVOICE_NO]
,ISNULL(CUSTOMER_NO_NEW,CUSTOMER_NO) as customer_no
,[AMOUNT]
,[AMOUNT_Applied]
,isnull([ACCTD_AMOUNT_APPLIED_TO], [AMOUNT_Applied]) as [ACCTD_AMOUNT_APPLIED_TO]
,isnull([Discount_Taken], 0) as DiscountTaken
,[CURRENCY_CODE]
,isnull(do.organizationkey, -1) as organizationkey
,dd.datekey as receiveddatekey
,gd.datekey as GLDatekey
,isnull(invoicekey, -1) as InvoiceKey
,isnull(dc.customerkey, -1) as customerkey
,-1 as unknownKey
,isnull(ex.exchangeratekey, -1) as ExchangeRateKey
,[status]
,sar.sourcesystemid
,invoiceidcalculated
-- select count(*) 
from

[stg].[Oracle_ARReceipts] SAR
inner  join Harsco.DimOrganization do
on SAR.entity = do.company
and ltrim(rtrim(sar.segment2)) = do.sitecode
inner join harsco.DimCustomer dc
on ISNULL(CUSTOMER_NO_NEW,CUSTOMER_NO) = dc.customeraccountnumber
and sar.sourcesystemid = dc.sourcesystemid

inner join Harsco.dimdate dd on rec_transaction_date = dd.fulldate

inner join harsco.dimdate gd on gl_transaction_date = gd.fulldate

--inner join Harsco.dimdate ed on rec_transaction_date = dateadd(d, 1, ed.fulldate) -- CHG0008622 --
inner join Harsco.dimdate ed on rec_transaction_date = ed.fulldate  -- CHG0008622
left outer join [Harsco].[LKPExchangeRate] ex
on sar.[CURRENCY_CODE] = ex.fromcurrency
and ed.datekey = ex.datekey
left outer join harsco.factARInvoices fi
on 
[InvoiceIDCalculated] = INvoiceID
--sar.invoice_no = fi.invoicenumber

and fi.organizationkey = do.organizationkey
--where sar.receipt_number = '32547'





)
 AS S
ON (s.[CASH_RECEIPT_ID] = t.receipttransactionid
and s.customertransactionid = t.customertransactionid) 
WHEN NOT MATCHED BY TARGET 
    THEN INSERT(
[OrganizationKey]
,[ReceiptTransactionID]
,customertransactionid
,[ReceivedAmount]
,[APPLIEDAmount]
,[ADJUSTEDAPPLIEDAmount]
,[DiscountAmount]
,CurrencyCode
,customerkey
,exchangeRateKey
,ReceivedDateKey
,GeneralLedgerDateKey
,ReceiptStatus
,[InvoiceKey]
	,[CreatedDateTime]
,[LastUpdatedDateTime]
,[EffectiveStartDate]
,[EffectiveEndDate]
,[CurrentRecordIndicator] 
,sourcesystemid)
values ( OrganizationKey, 
[CASH_RECEIPT_ID],
customertransactionid,
 amount, 
[AMOUNT_Applied],
 [ACCTD_AMOUNT_APPLIED_TO],
 DiscountTaken,
 Currency_Code,
 customerkey,
 exchangeratekey, 
receiveddatekey,
gldatekey
,[status]

,invoicekey
--start audit columns
,getdate(), getdate(), '2099-01-01', '2099-01-01', 1, sourcesystemid)
--WHEN MATCHED 
    --THEN UPDATE SET t.[ReceiptTransactionID] = s.[CASH_RECEIPT_ID]
	;
--WHEN NOT MATCHED BY SOURCE AND T.EmployeeName LIKE 'S%'
  --  THEN DELETE 
--OUTPUT $action, inserted.*, deleted.*;
--ROLLBACK TRAN;
;

--select *  from [Harsco].[FactARInvoices]


--select count(*) from [stg].[Oracle_ARReceipts]


commit tran 

;
--JDE

BEGIN TRAN;



UPDATE [stg].[JDE_ARReceipts] SET InvoiceID = 
[DOCUMENT_TYPE] + [DOCUMENT_NUMBER] + '/' + [Item_No] + '/' + cast([ADDRESS_NUMBER] as varchar(50))  + '/' + company



MERGE Harsco.FactARReceipts AS T
USING (
 select
 sar.company
 ,case when sar.siteid = '   ' then '0000' else   sar.siteid end as siteid
,[INVOICE_DATE]
,[INVOICE_DUE_DATE]
,[GL_POSTED_CODE]
,[BUSINESS_UNIT_ID]
,[ADDRESS_NUMBER]
,[INVOICE_NO]
,[PAYMENT_TERMS]
,case [CURRENCY_code]
when 'MXP' then 'MXN'
--chile
when 'CHP' then 'CLP'
--serbia
when 'CSD' then 'RSD'
when 'REA' then 'BRL'

else currency_code
end as currency_code
,[CUSTOMER_NO]
,[LOCATION_CODE]
--,amount
--,[DivideByAR]
, cast([AMOUNT] / [DivideByAR] as decimal(38,4)) as Amount
,[DOCUMENT_TYPE]
,[DOCUMENT_NUMBER]
,[DOCUMENT_TYPE] + [DOCUMENT_NUMBER] + '/' + [Item_No] + '/' +  cast([ADDRESS_NUMBER] as varchar(50))  + '/' + SAR.company  as InvoiceID
,[payment_DOCUMENT_TYPE] + 
[payment_DOCUMENT_NUMBER] + '-' + Document_Number as PaymentDocumentID
,[GL_DATE]
,[PAYMENT_DOCUMENT_TYPE]
,[PAYMENT_DOCUMENT_NUMBER]
--,[AMOUNT_Applied]
--,ex.exchangeratekey

,isnull(do.organizationkey, -1) as organizationkey
,dd.datekey
,invoicekey
,isnull(dc.customerkey, -1) as CustomerKey
,-1 as unknownKey
,isnull(ex.exchangeratekey, -1) as ExchangeRateKey
,SAR.sourcesystemid
from

[stg].[JDE_ARReceipts] SAR
left outer  join Harsco.DimOrganization do
on SAR.company = do.companyoriginal
and case when sar.siteid = '   ' then '0000' else   ltrim(rtrim(sar.siteid)) end = do.sitecode
left outer join harsco.DimCustomer dc
on  cast([ADDRESS_NUMBER] as varchar(50))= dc.customernumber
and sar.sourcesystemid =  dc.sourcesystemid  
left outer join Harsco.dimdate dd on [GL_DATE] = dd.JulianJDEDate
left outer join [Harsco].[LKPExchangeRate] ex
on case [CURRENCY_code]
when 'MXP' then 'MXN'
--chile
when 'CHP' then 'CLP'
--serbia
when 'CSD' then 'RSD'
when 'REA' then 'BRL'

else currency_code 
end = ex.fromcurrency
and dd.datekey = ex.datekey
left outer join harsco.factARInvoices fi
on SAR.InvoiceID = fi.invoiceID
and sar.sourcesystemid = fi.sourcesystemid
--and invoicekey is null
left outer join [Harsco].[vLKPJDELibraries] ss
--on SAR.sourcesystemid = ss.sourcesystemid
on do.countrycode = ss.countrycode
--where sar.country_id = 'MX'
--where SAR.payment_document_Type <> 'RS'
--where sar.[DOCUMENT_NUMBER] = '14004212'
--and sar.sourcesystemid = 68
--where fi.invoicekey = 2070738
--select * from harsco.factARInvoices where invoicenumber like '%52005206'

)
 AS S
ON (s.PaymentDocumentID = t.receipttransactionid) 
WHEN NOT MATCHED BY TARGET 
    THEN INSERT(
[OrganizationKey]
,[ReceiptTransactionID]
,[ReceivedAmount] 
,[ADJUSTEDAPPLIEDAmount]
--,ReceivedAmountUSD
,customerkey
,exchangeRateKey
,ReceivedDateKey
,GeneralLedgerDateKey
,[CurrencyCode]
,[InvoiceKey]
,ReceiptStatus
	,[CreatedDateTime]
,[LastUpdatedDateTime]
,[EffectiveStartDate]
,[EffectiveEndDate]
,[CurrentRecordIndicator]
,sourcesystemid )
values ( OrganizationKey, 
PaymentDocumentID,
 amount, 
 amount,
--[AMOUNT_Applied],
 customerkey,
 exchangeratekey
,datekey
,datekey
 ,[CURRENCY_Code]
,invoicekey
,'N/A'
--start audit columns
,getdate(), getdate(), '2099-01-01', '2099-01-01', 1, sourcesystemid)
--WHEN MATCHED
 --   THEN UPDATE SET t.[ReceiptTransactionID] = s.PaymentDocumentID
--	;
--WHEN NOT MATCHED BY SOURCE AND T.EmployeeName LIKE 'S%'
  --  THEN DELETE 
--OUTPUT $action, inserted.*, deleted.*;
--ROLLBACK TRAN;
;

--select *  from [Harsco].[FactARInvoices]

commit tran

;