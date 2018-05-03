
/****** Prem:24Jan2018  Added the column Comments,LocalExchRate to the procedure select clause ******/
/****** Prem:13Mar2018  Modify the expression for localinvoiceamount ******/












CREATE   procedure [dbo].[MergeFactARInvoices]
as
--select * from harsco.FactARInvoices
--select * from harsco.DimOrganization
--truncate table Harsco.FactARInvoices

--Oracle Merge

BEGIN TRAN;


--GF Deleting duplicate invoices that are present in Union 5 query and also Union 1 query
delete 
 from
 stg.Oracle_ARInvoices 
where UNION_NO = 'Uni5'
and exists (select INVOICE_NUMBER from stg.Oracle_ARInvoices oi2 where Oracle_ARInvoices .[INVOICE_NUMBER] + '/' 
+ Oracle_ARInvoices .[CUSTOMER_NUMBER] + '/' + Oracle_ARInvoices.company + '/'  + Oracle_ARInvoices .[GL_REV_LOCATION] + '/' 
+ Oracle_ARInvoices .Customer_trx_id

 = oi2.[INVOICE_NUMBER] + '/' + oi2.[CUSTOMER_NUMBER] + '/' + oi2.company + '/'  
 + oi2.[GL_REV_LOCATION] + '/' + oi2.Customer_trx_id and UNION_NO = 'Uni1')



MERGE Harsco.FactARInvoices AS T
USING (
 select
 [XLA_LINE_ID]
,[INVOICE_NUMBER]
,[INVOICE_NUMBER] + '/' + [CUSTOMER_NUMBER] + '/' + SAR.company + '/'  + [GL_REV_LOCATION] + '/' + Customer_trx_id as InvoiceID
,[GL_XLA_DATE]
,GL_DAte,
isnull([Customer_TRX_id], 0) as Customer_TRX_id
,[INVOICE_DATE]
,[INVOICE_TYPE]
,case when [INVOICE_TYPE] = 'MET BR VEN 5551' 
then 'Asset Sales' else [RECV_TYPE] end as [RECV_TYPE]
,[Comments]
,[LOC_EXCH_RATE]
,[DUE_DATE]
,[PAYMENT_TERMS_DESCRIPTION]
,[CUSTOMER_NUMBER]
,[CURR_CODE]
,[LOC_CURRENCY_CODE]
,[LAST_UPDATE_DATE]
,do.[COMPANY]
,SAR.Invoice_Status
,SO.Sales_Order
,SAR.[PURCHASE_ORDER_NUM]
,[GL_REV_LOCATION]
,case when invoice_type = 'Payment' then 0 else original_due_amount end as original_due_amount 
,case when invoice_type = 'Payment' then 0 else
round(([ORIGINAL_DUE_AMOUNT] * cast([LOC_EXCH_RATE] as float)), 2) end as InvoiceAmountLocal
,isnull(dc.customerkey, -1) as CustomerKey
,clb.[CustomerLocationKey] as BillToKey
,cls.[CustomerLocationKey] as ShipToKey
,isnull(do.organizationkey, -1) OrganizationKey
,dd.datekey
,ddd.datekey as InvoiceDueDateKey
,isnull(ex.exchangeratekey, -1) as ExchangeRateKey
,27 as SourceSystemID
,isnull(isnull(pt.PaymentTermsKey, dc.paymenttermskey), -1) as PaymentTermsKey
,gld.datekey as GeneralLedgerDateKey
--,isnull(gl.[GeneralLedgerKey], -1) as GeneralLedgerKey
from

[stg].[Oracle_ARInvoices] SAR
left outer join Harsco.DimOrganization do
on SAR.company = do.company
and sar.gl_rev_location = do.sitecode
--and sar.sourcesystemid = do.sourcesystemid
left outer join [stg].[Oracle_AR_Sales_Order_No] so
on SAR.[XLA_LINE_ID] = so.[INTERFACE_LINE_ATTRIBUTE6]

inner join Harsco.dimdate dd on [invoice_date] = dd.fulldate
inner join Harsco.dimdate ddd on Due_DAte = ddd.fulldate
inner join Harsco.dimdate gld on [GL_DATE] = gld.fulldate
left outer join [Harsco].[LKPExchangeRate] ex
on sar.[LOC_CURRENCY_CODE] = ex.fromcurrency
and dd.datekey = ex.datekey

inner join harsco.dimcustomer dc
on sar.customer_number = dc.customeraccountnumber
and 27 = dc.sourcesystemid

left outer join [Harsco].[DimCustomerLocation] clb
on bill_to_site_use_id = clb.customerlocationnumber
left outer join [Harsco].[DimCustomerLocation] cls
on  ship_to_site_use_id = cls.customerlocationnumber
left outer join harsco.dimPaymentTerms pt
on [PAYMENT_TERMS_DESCRIPTION] = pt.paymenttermsid
and 27 = pt.sourcesystemid
--left outer join Harsco.DimGeneralLedger gl
--on SAR.[CodeCombinationID] = gl.[GeneralLedgerID]
--and 27 = gl.sourcesystemid

--where sar.[Customer_TRX_id]= '15732771'
 --where [INVOICE_NUMBER] = '10000598'
 --where [INVOICE_NUMBER] = '319'
--and do.company = 'IN001'

)
 AS S
ON (T.InvoiceID = S.InvoiceID and
t.organizationkey = s.organizationkey
) 
WHEN NOT MATCHED BY TARGET 
    THEN INSERT(InvoiceNumber
	,InvoiceID
	,OrganizationKey
	,PaymentTermsKey
	,InvoiceType
	,[ReceivableType]
	,Comments
	,LocalExchangeRate
,[CustomerTransactionID]
	,GeneralLedgerDateKey
	--,GeneralLedgerKey
	,InvoiceDateKey
	,InvoiceDueDateKey
	,InvoiceStatus
	,SalesOrderNumber
	,PurchaseOrderNumber
	,ExchangeRateKey
	,AccountCustomerKey
	,[BillToCustomerLocationKey]
	,[ShipToCustomerLocationKey]
	,[LocalInvoiceAmount]
	,InvoiceAmount
	,[LocalCurrencyCode]
	,invoicecurrencycode
	,SourceSystemID
	,[CreatedDateTime]
,[LastUpdatedDateTime]
,[EffectiveStartDate]
,[EffectiveEndDate]
,[CurrentRecordIndicator] )
values (s.invoice_number, s.invoiceID, OrganizationKey
, paymenttermskey
, Invoice_Type
,[RECV_TYPE]
,Comments
,[LOC_EXCH_RATE]
,[Customer_TRX_id]
, GeneralLedgerDateKey
--,GeneralLedgerKey
, datekey, InvoiceDueDateKey,
Invoice_Status
,Sales_Order
,[PURCHASE_ORDER_NUM],
ExchangeRateKey, 
customerkey,
BillToKey,
ShipToKey,
  InvoiceAmountLocal,
 [ORIGINAL_DUE_AMOUNT], 
[LOC_CURRENCY_CODE],
 curr_code, SourceSystemID
--start audit columns
,getdate(), getdate(), '2099-01-01', '2099-01-01', 1)
WHEN MATCHED 
    THEN UPDATE SET t.InvoiceNumber = s.INVOICE_NUMBER
	;
--WHEN NOT MATCHED BY SOURCE AND T.EmployeeName LIKE 'S%'
  --  THEN DELETE 
--OUTPUT $action, inserted.*, deleted.*;
--ROLLBACK TRAN;
;
commit tran 

--select * from [stg].[JDE_ARInvoices]

--select * From stg.JDE_f0101 where account_number = '100085'

--select * From harsco.dimorganization where sitecode = '061'
--JDE Merge

BEGIN TRAN;
MERGE Harsco.FactARInvoices AS T
USING (
 select
[UpdatedLineageString]

,PaymentStatus
,[INVOICE_DATE]
,[INVOICE_NO]
,[INVOICE_TYPE] + [INVOICE_NO] + '/' + [Item_No] + '/' +  [CUSTOMER_No]  + '/' + SAR.company as InvoiceID
,[INVOICE_TYPE]
,[INVOICE_DUE_DATE]
,[PAYMENT_TERMS_DESCRIPTION]
,[CUSTOMER_No]
,case [CURRENCY]
when 'MXP' then 'MXN'
--chile
when 'CHP' then 'CLP'
--serbia
when 'CSD' then 'RSD'
when 'REA' then 'BRL'

else currency 
end as currency
,SAR.[COMPANY]
,'Revenue' as ReceivableType
--,mcco
, siteid
,cast(amount as decimal(20,0)) / [DivideByAR]  as AMOUNT
,isnull(dc.customerkey, -1) as CustomerKey
,isnull(do.organizationkey, -1) as OrganizationKey
--,isnull(gl.GeneralLedgerKey, -1) as GeneralLedgerKey
,dd.datekey
,ddd.datekey as InvoiceDueDateKey
,gld.datekey as GeneralLedgerDateKey
,sar.SourceSystemID
,isnull(isnull(pt.paymenttermskey, dc.paymenttermskey), -1) as paymenttermskey
,isnull(ex.ExchangeRatekey, -1) as exchangeratekey
from
[stg].[JDE_ARInvoices] SAR
left outer join Harsco.DimOrganization do
on SAR.company = do.companyoriginal
and case when sar.siteid = '   ' then '0000' else   sar.siteid end = do.sitecode
inner join Harsco.dimdate dd on [invoice_date] = dd.fulldate
inner join Harsco.dimdate ddd on invoice_due_date = ddd.fulldate
inner join harsco.dimdate gld on SAR.gldate = gld.julianjdedate
left outer join [Harsco].[LKPExchangeRate] ex
on case [CURRENCY]
when 'MXP' then 'MXN'
--chile
when 'CHP' then 'CLP'
--serbia
when 'CSD' then 'RSD'
--brazil
when 'REA' then 'BRL'

else currency 
end = ex.fromcurrency
and dd.datekey = ex.datekey
left outer join harsco.dimcustomer dc
on sar.customer_no = dc.customernumber
and sar.sourcesystemid = dc.sourcesystemid
left outer join harsco.dimpaymentterms pt
on sar.[PAYMENT_TERMS] = pt.paymenttermsid
and sar.sourcesystemid = pt.sourcesystemid
inner join [Harsco].[vLKPJDELibraries] ss
--on SAR.sourcesystemid = ss.sourcesystemid
on do.countrycode = ss.countrycode

where (gld.datekey  >= 20140101
or
(sar.company = '00100' and sar.customer_no = '121683' and gld.datekey >= 20100101)
or
(sar.company = '00497' and sar.customer_no = '982239' and gld.datekey >= 20100101)
or
(sar.company = '00214' and sar.customer_no = '510723' and gld.datekey >= 20100101)
or 
(sar.company = '00105' and sar.customer_no = '122333' and gld.datekey >= 20130101)
)


--left outer join harsco.DimGeneralLedger gl
--on sar.[RPAID2] = gl.[AccountNumber]
--and sar.sourcesystemid = gl.sourcesystemid
--where sar.[INVOICE_NO] = '7516'
--AND SAR.SOURCESYSTEMID = 68
--order by sar.invoice_no


)
 AS S
ON (T.InvoiceID = S.InvoiceID
and t.sourcesystemid = s.sourcesystemid) 
WHEN NOT MATCHED BY TARGET 
    THEN INSERT(InvoiceNumber
	,InvoiceID
	,OrganizationKey
	,paymenttermskey
	,InvoiceType
	,ReceivableType
	,GeneralLedgerDateKey
	--,GeneralLedgerKey
	,InvoiceDateKey
	,InvoiceDueDateKey
	,InvoiceStatus
	,ExchangeRateKey
	,AccountCustomerKey
	,[BillToCustomerLocationKey]
	,[ShipToCustomerLocationKey]
	,InvoiceAmount
	,localinvoiceamount
	,invoicecurrencycode
	,localcurrencycode
	,SourceSystemID
	,[CreatedDateTime]
,[LastUpdatedDateTime]
,[EffectiveStartDate]
,[EffectiveEndDate]
,[CurrentRecordIndicator] )
values (s.[INVOICE_NO], s.invoiceid, OrganizationKey
, paymenttermskey, Invoice_Type, ReceivableType
, GeneralLedgerDateKey
--,GeneralLedgerKey
, datekey, InvoiceDueDateKey, paymentstatus, exchangeratekey, 
customerkey,
-1,
-1
,[AMOUNT],amount,currency, currency,SourceSystemID
--start audit columns
,getdate(), getdate(), '2099-01-01', '2099-01-01', 1)
--WHEN MATCHED 
  --  THEN UPDATE SET t.InvoiceNumber = s.INVOICE_NUMBER
	;
--WHEN NOT MATCHED BY SOURCE AND T.EmployeeName LIKE 'S%'
  --  THEN DELETE 
--OUTPUT $action, inserted.*, deleted.*;
--ROLLBACK TRAN;
;


--select sitetype, dc.customername, dc.customernumber, (invoiceamountoriginal), fi.* from [Harsco].[FactARInvoices] fi
--inner join harsco.dimorganization o
--on fi.organizationkey = o.organizationkey
--inner join harsco.dimcustomer dc
--on fi.accountcustomerkey = dc.customerkey
--where fi.invoicenumber = '405191'


--customer no 112546
--customeraccount no 9749





commit tran
