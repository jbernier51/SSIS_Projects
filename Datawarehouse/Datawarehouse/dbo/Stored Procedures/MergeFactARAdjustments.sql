






CREATE   procedure [dbo].[MergeFactARAdjustments]
/*******************************************************************************************************************
** Procedure Name: MergeFactARAdjustments
** Desc:
** Auth: Gene Furibondo
** Date: 09/27/2017
********************************************************************************************************************
** Change History
--------------------------------------------------------------------------------------------------------------------
** PR   Date        Author				Description 
** --   --------   -------				------------------------------------
** 1    01/10/2017  Dhilasu Reddy       Added Inline Comments
********************************************************************************************************************/
as

truncate table Harsco.FactARAdjustments

--***********************************************************************************************************************
--1. Source - Oracle
--   Merge and Insert the Data where Source and Target data are not Matched ,
--   Merge and update the Data where Source and Target data are Matched
--***********************************************************************************************************************

BEGIN TRAN;
MERGE Harsco.FactARAdjustments AS T
USING (
 select
 
 [ENTITY]
,[SEGMENT2]
,[TRANSACTION_ID]
,[INVOICE_NO]
--,[CUSTOMER_NO]
,[AMOUNT]
,[AMOUNT_Applied]
,[ACCTD_AMOUNT_APPLIED_TO]
,[CURRENCY_CODE]
,[TRXTYPE]
,do.organizationkey
,dd.datekey
,isnull(invoicekey, -1) as InvoiceKey
--,dc.customerkey
,-1 as unknownKey
,isnull(ex.exchangeratekey, -1) as ExchangeRateKey
,sar.sourcesystemid

from

[stg].[Oracle_ARAdjustments] SAR
left outer join Harsco.DimOrganization do
on SAR.entity = do.company
and sar.segment2 = do.sitecode
--inner join harsco.DimCustomer dc
--on [Customer_no] = dc.customeraccountnumber

inner join Harsco.dimdate dd on transaction_date = fulldate
left outer join [Harsco].[LKPExchangeRate] ex
on sar.[CURRENCY_CODE] = ex.fromcurrency
and dd.datekey = ex.datekey
left outer join harsco.factARInvoices fi
on SAR.customertransactionid = fi.customertransactionid
and fi.invoicetype <> 'Payment'
and sar.sourcesystemid = fi.sourcesystemid
--and do.organizationkey = fi.organizationkey

--and invoicekey is not null
--where invoice_no = '10000179'
--order by transaction_id

union

select
 
 [ENTITY]
,[SEGMENT2]
,[TRANSACTION_ID]
,[INVOICE_NO]
--,[CUSTOMER_NO]
,[AMOUNT]
,[AMOUNT_Applied]
,[ACCTD_AMOUNT_APPLIED_TO] * -1
,[CURRENCY_CODE]
,[TRXTYPE]
,do.organizationkey
,dd.datekey
,isnull(invoicekey, -1) as InvoiceKey
--,dc.customerkey
,-1 as unknownKey
,isnull(ex.exchangeratekey, -1) as ExchangeRateKey
,sar.sourcesystemid

from

[stg].[Oracle_ARAdjustments] SAR
left outer join Harsco.DimOrganization do
on SAR.entity = do.company
and sar.segment2 = do.sitecode
--inner join harsco.DimCustomer dc
--on [Customer_no] = dc.customeraccountnumber

inner join Harsco.dimdate dd on transaction_date = fulldate
left outer join [Harsco].[LKPExchangeRate] ex
on sar.[CURRENCY_CODE] = ex.fromcurrency
and dd.datekey = ex.datekey
left outer join harsco.factARInvoices fi
on SAR.appliedcustomertransactionid = fi.customertransactionid
and fi.invoicetype <> 'Payment'
and sar.sourcesystemid = fi.sourcesystemid
--and do.organizationkey = fi.organizationkey

--and invoicekey is not null
--where invoice_no = '10000179'
--order by transaction_id


)
 AS S
ON (s.transaction_id = adjustmenttransactionid
and
[TRXTYPE] = [TransactionType]
and s.invoicekey = t.invoicekey

) 
WHEN NOT MATCHED BY TARGET 
    THEN INSERT(
[OrganizationKey]
,[AdjustmentTransactionID]
,[Amount]
,[AppliedAmount]
,[ADJUSTEDAPPLIEDAmount]
,CurrencyCode
--,customerkey
,exchangeRateKey
,[GLDateKey]

,[InvoiceKey]
,[TransactionType]
	,[CreatedDateTime]
,[LastUpdatedDateTime]
,[EffectiveStartDate]
,[EffectiveEndDate]
,[CurrentRecordIndicator] 
,sourcesystemid)
values ( OrganizationKey 
,[TRANSACTION_ID]
 ,amount, 
[AMOUNT_Applied],
[ACCTD_AMOUNT_APPLIED_TO],
 Currency_Code,
-- customerkey,
 exchangeratekey, 
datekey

,isnull(invoicekey, -1)
,[TRXTYPE]
--start audit columns
,getdate(), getdate(), '2099-01-01', '2099-01-01', 1, sourcesystemid)
WHEN MATCHED 
    THEN UPDATE SET t.[AdjustmentTransactionID] = s.[TRANSACTION_ID]
	;
;


commit tran 



----JDE

--BEGIN TRAN;
--MERGE Harsco.FactARReceipts AS T
--USING (
-- select
--[INVOICE_DATE]
--,[INVOICE_DUE_DATE]
--,[GL_POSTED_CODE]
--,[BUSINESS_UNIT_ID]
--,[ADDRESS_NUMBER]
--,[INVOICE_NO]
--,[PAYMENT_TERMS]
--,[CURRENCY]
--,[CUSTOMER_NO]
--,[LOCATION_CODE]
--, cast([AMOUNT] / [JDEInvoiceDivideBy] as decimal(10,2)) as Amount
--,[DOCUMENT_TYPE]
--,[DOCUMENT_NUMBER]
--,[payment_DOCUMENT_TYPE] + 
--[payment_DOCUMENT_NUMBER] as PaymentDocumentID
--,[GL_DATE]
--,[PAYMENT_DOCUMENT_TYPE]
--,[PAYMENT_DOCUMENT_NUMBER]
----,[AMOUNT_Applied]


--,do.organizationkey
--,dd.datekey
--,invoicekey
--,isnull(dc.customerkey, -1) as CustomerKey
--,-1 as unknownKey
--,case when [CURRENCY_CODE] = 'USD' then -1 else isnull(ex.exchangeratekey, -1) end as ExchangeRateKey,
--SAR.sourcesystemid
--from

--[stg].[JDE_ARReceipts] SAR
--inner join Harsco.DimOrganization do
--on SAR.company = do.companyoriginal
--and sar.siteid = do.sitecode
--left outer join harsco.DimCustomer dc
--on  [ADDRESS_NUMBER]= dc.customernumber

--inner join Harsco.dimdate dd on [GL_DATE] = dd.JulianJDEDate
--left outer join [Harsco].[LKPExchangeRate] ex
--on sar.[CURRENCY_CODE] = ex.fromcurrency
--and dd.datekey = ex.datekey
--left outer join harsco.factARInvoices fi
--on SAR.document_number = fi.invoicenumber
--and sar.sourcesystemid = fi.sourcesystemid
----and invoicekey is null
--inner join [Harsco].[vLKPSourceSystem] ss
--on SAR.sourcesystemid = ss.sourcesystemid

--)
-- AS S
--ON (s.PaymentDocumentID = t.receipttransactionid) 
--WHEN NOT MATCHED BY TARGET 
--    THEN INSERT(
--[OrganizationKey]
--,[ReceiptTransactionID]
--,[ReceivedAmount] 
----,ReceivedAmountUSD
--,customerkey
--,exchangeRateKey
--,ReceivedDateKey
--,[GLAccountKey]
--,[InvoiceKey]
--	,[CreatedDateTime]
--,[LastUpdatedDateTime]
--,[EffectiveStartDate]
--,[EffectiveEndDate]
--,[CurrentRecordIndicator]
--,sourcesystemid )
--values ( OrganizationKey, 
--PaymentDocumentID,
-- amount, 
----[AMOUNT_Applied],
-- customerkey,
-- exchangeratekey, 
--datekey
--,unknownKey
--,invoicekey
----start audit columns
--,getdate(), getdate(), '2099-01-01', '2099-01-01', 1, sourcesystemid)
--WHEN MATCHED
--    THEN UPDATE SET t.[ReceiptTransactionID] = s.PaymentDocumentID
--	;
----WHEN NOT MATCHED BY SOURCE AND T.EmployeeName LIKE 'S%'
--  --  THEN DELETE 
----OUTPUT $action, inserted.*, deleted.*;
----ROLLBACK TRAN;
--;

----select *  from [Harsco].[FactARInvoices]

--commit tran