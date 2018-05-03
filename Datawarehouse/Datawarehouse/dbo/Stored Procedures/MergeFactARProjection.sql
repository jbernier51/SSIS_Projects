















CREATE   procedure [dbo].[MergeFactARProjection]
as


/****************************** 
** Procedure Name: MergeFactARProjection
** Desc:  Calculation IPD and daily AR Cash Projection for month
** Auth:  Microsoft Consultants
** Date:  July-November 2017
**************************
** Change History
**************************
** PR   Date        Author			Description 
** --   --------   -------			-----------------------------------
** CHG0008627(1) 21-Nov-2017 Sue     * Removed "-isnull(tm.receivedamount, 0)" to correct Current, LastMonth, TwoMonths, Over2Months, TotalPastDue, ProjectedFuture Cash
** CHG0008627(2) 21-Nov-2017 Sue     * simplify/correct to use DATEDIFF to replace checking month/year subtraction for lastmonth/twomonths/over2months
** CHG0008627(3) 18-Jan-2018 Sue     * correct ipd calcutions should be >=1 not >1
** CHG0008627(4) 23-Jan-2018 Sue     * Use Receipt Amount not AdjustedAppliedAmount for MTD Receipts
** CHG0008627(5) 25-Jan-2018 Sue     * Only use Project New Sales if it seems COMMON (USING 5 TIMES IN PAST 6 MONTHS)
** CHG0008627(6) 05-Feb-2018 Prem    * Making this procedure to run full load daily untill we fix the Customer WID issue
** CHG0008627(7) 06-Feb-2018 Sue     * Check for null IPD3MO in timediff calculations
** CHG0008627(8) 06-Feb-2018 Sue     * Prevent NewSales from becoming negative
** CHG0008627(9) 09-Feb-2018 Sue     * Correct IPD calc to include paid invoices that are due in the future
** CHG0008627(10) 20-Feb-2018 Sue    * ignore negatives in IPD calc
** CHG0008627(11) 08-Mar-2018 Sue    * Credit Memo Amounts are stored as Negative so need to ADD not Subtract amount 
*******************************/

DECLARE @cnt INT = 0;
DECLARE @DateKey INT = 0;
DECLARE @AgingDate INT = 0;
DECLARE @DateValue date ;
DECLARE @FirstofMonth date ;
DECLARE @LastofMonth date ;
DECLARE @IPDRangeBegin date 
DECLARE @IPDRangeEnd date;
DECLARE @NewSalesRangeBegin date 
DECLARE @NewSalesRangeEnd date;
DECLARE @Label nvarchar(50);

drop table if exists #IPD

truncate table [Harsco].[FactARProjections] --Feb05 : Removed comment to run full refresh

drop table if exists #WhileDate

-- BUILD #WHILEDATE - date table for each PROJECTION date that will be calculated.  IPD Range is 3 months, NEW SALES is 6 month

select  d.datekey ,d.fulldate, [MonthBeginDate],[MonthEndDate] , dateadd(d,-1, monthbegindate) as IPDRangeEnd
,dateadd(m, -3, monthbegindate) as IPDRangeBegin, 
dateadd(d,-1, monthbegindate) as NewSalesProjectedRangeEnd
,dateadd(m, -6, monthbegindate) as NewSalesProjectedRangeBegin,
cast(format(monthbegindate, 'yyyyMMdd') as int) as AgingDate
,  0 as processed
into
#WhileDate
from harsco.dimdate  d
where  -- fulldate = '2017-11-01'
fulldate between '2017-11-01' and cast(getdate() as date)   -- use this for full refresh to rebuild history
--fulldate between   dateadd(d, -1, cast(getdate() as date)) and cast(getdate() as date) --normal rebuilds yesterday, builds today

--datepart(m,getdate()) = datepart(m, d.fulldate)
--and datepart(yyyy,getdate()) = datepart(yyyy, d.fulldate)

--select * from #IPD

set @cnt = 1
 while @cnt > 0

 begin



set @IPDRangeBegin = (select top 1 IPDRangeBegin from #WhileDate where processed = 0)
set @IPDRangeEnd = (select top 1 IPDRangeEnd from #WhileDate where processed = 0)
set @NewSalesRangeBegin = (select top 1 NewSalesProjectedRangeBegin from #WhileDate where processed = 0)
set @NewSalesRangeEnd = (select top 1 NewSalesProjectedRangeEnd from #WhileDate where processed = 0)

set @LastofMonth = (select top 1 MonthEndDate from #WhileDate where processed = 0)
set @DateValue = (select top 1 fulldate from #WhileDate where processed = 0)
set @DateKey = (select top 1 DateKey from #WhileDate where processed = 0)

drop table if exists #IPD
drop table if exists #rec
drop table if exists  #ReceiptsThisMonthInvoice
drop table if exists  #ReceiptsThisMonthNoInvoice


 delete harsco.FactARProjections where ProjectionDateKey = @datekey



 --Get Received date for each invoice
select invoicekey, min(receiveddatekey) as receiveddatekey
into #rec
from
(
select invoicekey, min(receiveddatekey) as receiveddatekey from harsco.FactARReceipts 
where receiveddatekey < @DateKey
group by invoicekey

union

select invoicekey, min(GLDateKey) as receiveddatekey from harsco.FactARAdjustments 
where [GLDateKey] < @Datekey
group by invoicekey
) t1
group by InvoiceKey

--Calculate IPD

select dcm.customerkey,sum(DaysToPay) / count(*) as test1,  case when count(*) >=1 then sum(DaysToPay) / count(*) else 0 end  as IPD3Mo --CHG0008627(3)
into #IPD
from 
harsco.dimcustomer dcm 
left outer join 
(
select fi.invoicekey, fi.invoicenumber
,fi.InvoiceType
,fi.InvoiceAmount
, dc.customernumber
,fi.accountcustomerkey as customerkey
, dc.customeraccountnumber
, id.fulldate as InvoiceDate
, rd.fulldate as ReceivedDate
,fi.invoiceduedatekey
, case when datediff(day,id.fulldate,  isnull(rd.fulldate, @DateValue)) < 0 then 0 else datediff(day,id.fulldate,  
isnull(rd.fulldate, @DateValue)) end as DaysToPay

from 

harsco.FactARInvoices fi
left outer join 

#rec  fr

on fi.invoicekey = fr.invoicekey


left outer join Harsco.DimDate id on
fi.invoicedatekey = id.datekey
left outer join Harsco.DimDAte rd
on fr.receiveddatekey = rd.datekey


inner join harsco.dimCustomer dc
on fi.AccountCustomerKey = dc.customerkey

inner join harsco.dimdate idd
on fi.invoiceduedatekey = idd.datekey

--inner join harsco.dimdate med
--on '2017-10-18' = med.fulldate


--where fi.invoicekey = 1591503

----where fi.invoicenumber = '16008883'


where --dc.customeraccountnumber = '7443' and

 id.fulldate between @IPDRangeBegin and @IPDRangeEnd
--and fi.invoiceduedatekey < @DateKey --CHG0008627(9)
and ((fr.receiveddatekey is not null and fr.receiveddatekey <= @datekey) or (fi.invoiceduedatekey < @DateKey and fr.receiveddatekey is  null))  --CHG0008627(9)
and fi.InvoiceType <> 'Payment'
and fi.InvoiceAmount > 0  --CHG0008627(10)
--and dc.customerkey = 10146
--and dc.CustomerAccountNumber = '117821'
--and ([ReceivedAmount] is null or [ReceivedAmount] > 0)
---and rd.FullDate is not null
--order by invoicenumber


) t1
on dcm.CustomerKey = t1.customerkey
--where dcm.CustomerAccountNumber = '117821'
group by dcm.customerkey


--select * from #IPD


 drop table if exists #ReceiptsThisMonthNoInvoice
drop table if exists #ReceiptsThisMonthInvoice

 -- set  @DateKey = (select top 1 datekey from #WhileDate where processed = 0)
--  set @DateValue = (select top 1 fulldate from #WhileDate where processed = 0)
  set @AgingDate = (select top 1 AgingDate from #WhileDate where datekey = @DateKey )



  set @FirstOfMonth = (select top 1 MonthBeginDate from #WhileDate where datekey = @DateKey )
 -- set @Label = (select AsOfDateLabel from #WhileDate where datekey = @DateKey)
 set  @cnt = (select count(*) from #WhileDate where processed = 0)

--select invoicekey,sum(adjustedappliedamount) as receivedamount --CHG0008627(4)
select invoicekey,sum(Receivedamount) as receivedamount --CHG0008627(4)
into #ReceiptsThisMonthInvoice
from [Harsco].[FactARReceipts] ar
inner join harsco.dimdate dd
 on receiveddatekey = dd.datekey
where  dd.fulldate between @FirstofMonth and @DateValue
group by invoicekey
--

--select customerkey, organizationkey, sum(adjustedappliedamount) as receivedamount -- CHG0008627(4)
select customerkey, organizationkey, sum(ReceivedAmount) as receivedamount --CHG0008627(4)
into #ReceiptsThisMOnthNoInvoice
from [Harsco].[FactARReceipts] ar
inner join harsco.dimdate dd
 on receiveddatekey = dd.datekey
where  dd.fulldate between @FirstofMonth and @DateValue
and invoicekey is null
group by customerkey, organizationkey

--NewSalesProjected

drop table if exists #NewSalesProjected
drop table if exists  #NewSalesCurrent

drop table if exists #RecIPD




-- sum(ReceivedAmount)/count(distinct id.MonthBeginDate) as NewSalesAmount --CHG0008627(4) COMMENTED OUT FOR CHG0008627(5)
select  fi.AccountCustomerKey, 
fi.OrganizationKey, 
--sum(adjustedappliedamount)/count(distinct id.MonthBeginDate) as NewSalesAmount --CHG0008627(4)
-- sum(ReceivedAmount)/count(distinct id.MonthBeginDate) as NewSalesAmount --CHG0008627(4) COMMENTED OUT FOR CHG0008627(5)
case when count(distinct id.monthbegindate) >= 5 then  sum(ReceivedAmount)/count(distinct id.MonthBeginDate) else 0 end  as NewSalesAmount --CHG0008627(5)
into #NewSalesProjected
from [Harsco].[FactARReceipts] ar
inner join harsco.dimdate dd
 on receiveddatekey = dd.datekey
 inner join harsco.FactARInvoices fi
 on ar.InvoiceKey = fi.InvoiceKey
 inner join harsco.dimdate id
 on fi.InvoiceDateKey = id.datekey
 INNER JOIN HARSCO.DIMDATE IDD   --CHG0008627 (7)
 ON FI.InvoiceDueDateKey = IDD.DATEKEY --CHG0008627 (7)

 inner join #IPD
 on ar.CustomerKey = #ipd.CustomerKey

where  dd.fulldate between @NewSalesRangeBegin and @NewSalesRangeEnd
and dd.MonthFormatYYYYMM = id.MonthFormatYYYYMM
and DATEDIFF(d, @datevalue, @lastofmonth) > IPD3Mo
and fi.InvoiceAmount > 0
group by fi.AccountCustomerKey, fi.OrganizationKey


--NewSalesCurrent

select  ar.AccountCustomerKey, ar.OrganizationKey, sum(InvoiceAmount) as NewSalesAmount
into #NewSalesCurrent
from [Harsco].[FactARInvoices] ar
inner join harsco.dimdate dd
 on InvoiceDateKey = dd.datekey
 inner join harsco.dimdate id --CHG0008627 (7)
--on InvoiceDateKey = idd.DateKey --CHG0008627 (7)
 on InvoiceDateKey = id.DateKey --CHG0008627 (7)
 inner join #IPD
 on ar.AccountCustomerKey = #ipd.customerkey

where  dd.fulldate > @IPDRangeEnd
and dd.fulldate < @DateValue
--and dateadd(d, IPD3Mo, idd.FullDate) < dd.MonthEndDate  --CHG0008627 (7)
and dateadd(d, IPD3Mo, id.FullDate) < dd.MonthEndDate  --CHG0008627 (7)
and ar.InvoiceAmount > 0

group by  ar.AccountCustomerKey, ar.OrganizationKey


 drop table if exists #adjustments
drop table if exists #Creditmemos

select invoicekey, sum( [ADJUSTEDAPPLIEDAmount]) as AdjustmentAmount 
into #adjustments
from harsco.factARAdjustments
where  [GLDateKey] < @DateKey and transactiontype= 'Adjustment'
group by invoicekey


select invoicekey, sum( [ADJUSTEDAPPLIEDAmount]) as CreditMemoAmount 
into #CreditMemos 
from  harsco.factARAdjustments
where  [GLDateKey] < @DateKey  and transactiontype= 'Credit Memo'
--and adjustmenttransactionid not in (select isnull(customertransactionid, 0) from harsco.factarreceipts)
group by invoicekey 

--- received amount to date  
 select fr.invoicekey,sum(
case when fi.invoicetype = 'Payment' and ReceiptStatus  IN ('ACC', 'UNAPP', 'UNID', 'OTHER ACC') 
then
ReceivedAmount 
when fi.	invoicetype <> 'Payment' 
--then adjustedappliedamount  --CHG0008627(4)
then ReceivedAmount  --CHG0008627(4)
else 0
end
) as receivedamount


,sum(DiscountAmount)  as DiscountTaken, currencycode 
into #RecIPD
from [Harsco].[FactARReceipts] fr
inner join harsco.factarinvoices fi
on fr.invoicekey = fi.invoicekey
where 
fr.GeneralLedgerDateKey <   @DateKey

--and ( fr.SourceSystemID = 27 
--or (
--(ReceiptTransactionID  not like 'RS%')
--or
--(ReceiptTransactionID  like 'RS%' and fi.InvoiceType <> 'RU')
--))

group by fr.invoicekey, currencycode



  print @cnt
  print @datekey
  
  drop table if exists #AgingTemp

select

i.invoicekey, i.invoicenumber, i.Invoicecurrencycode, r.currencycode as receiptcurrencycode, i.localcurrencycode,
dd.fulldate as invoiceduedate ,
id.fulldate as invoicedate, 
@Datekey as AgingDateKey,
--(max([localInvoiceAmount]) ) as InvoiceAmount,
(max(
case when i.[InvoiceType] = 'RU' then 
[localInvoiceAmount] * -1 
else [localInvoiceAmount] end )) as InvoiceAmount,

(isnull(sum(r.[ReceivedAmount]), 0) ) as ReceivedAmount,
(isnull(sum(a.adjustmentamount), 0)  ) as adjustedAmount,

isnull(sum(DiscountTaken), 0) as DiscountTaken,


(max(
case when i.[InvoiceType] = 'RU' then 
[localInvoiceAmount] * 0 
else [localInvoiceAmount] end )) -
isnull(sum(r.[ReceivedAmount]), 0) +

isnull(sum(adjustmentamount) , 0)
+     --CHG0008627 (11)  sign changed from '-' to '+' 
isnull(sum(creditmemoamount), 0) - 


isnull(sum(DiscountTaken), 0)


  as totalopenamount, 

 i.sourcesystemid,
 er.exchangeratekey
into #AgingTemp
from 

 [Harsco].[FactARInvoices] i
left outer join #RecIPD r

on i.invoicekey = r.invoicekey

left outer join 
 #Adjustments a

on i.invoicekey = a.invoicekey
left outer join 
#CreditMemos b
on i.invoicekey = b.invoicekey


left outer join harsco.dimdate dd
on i.invoiceduedatekey = dd.datekey
left outer join harsco.dimdate id
on i.invoicedatekey = id.datekey
inner join harsco.dimdate gld
on i.GeneralLedgerDateKey = gld.datekey
left outer join harsco.lkpExchangeRate er
on dateadd(d, -1, @DateValue) = CONVERT (datetime,convert(char(8), er.datekey))
and  (case [LocalCurrencyCode]
when 'MXP' then 'MXN'
--chile
when 'CHP' then 'CLP'
--serbia
when 'CSD' then 'RSD'
when 'REA' then 'BRL'

else LocalCurrencyCode end)  = er.fromcurrency

where gld.datekey < @Datekey
--and i.sourcesystemid = 27
--and i.accountcustomerkey = 184
--and i.invoicekey = 430786

group by er.exchangeratekey, i.invoicekey, i.invoicenumber,  dd.fulldate, id.fulldate, i.invoicestatus, i.sourcesystemid, i.Invoicecurrencycode, i.localcurrencycode, r.currencycode
--having ((max(
--case when i.[InvoiceType] = 'RU' then 
--[localInvoiceAmount] * 0 
--else [localInvoiceAmount] end ))  -
--isnull(sum(r.[ReceivedAmount]), 0) +

--isnull(sum(adjustmentamount) , 0)
---
--isnull(sum(creditmemoamount), 0)
---
--isnull(sum(DiscountTaken), 0)

--) <> 0



insert into Harsco.FactARProjections (
ProjectionDateKey,
	InvoiceNumber,
	AccountCustomerKey,
	OrganizationKey,
	TotalOpenAmount ,
	[OpenAmountEndofLastMonth],
	InvoiceDate ,
	IPDDate ,
	IPD3Mo ,
	ReceivedThisMonth ,
	CurrentMonthIPDDue ,
	[OpenAmountNotYetDue],
	LastMonthIPDDue ,
	TwoMonthsIPDDue ,
	Over2MonthsIPDDue ,
	OpenARTotalPastDue ,
	ProjectedFutureCashToBeReived --,
	--TotalSalesProjectByMonth 
	)

select @DateKey as ProjectionDate
,
-- fi.InvoiceKey , 
fi.invoicenumber
,fi.AccountCustomerKey
,fi.OrganizationKey
, fa.[TotalOpenAmount]
,ag.TotalOpenAmount  as PriorMonthEndOpenAmount
, id.fulldate
, case when IPD3MO is null then idd.fulldate else dateadd(d, IPD3Mo , id.fulldate ) END as IPDDate --CHG0008627(7)
, ipd3mo
,tm.receivedamount as ReceivedThisMonth

,
--Due in Current Month based on IPD
-- case when  month(dateadd(d, IPD3Mo , id.fulldate )) = month(@DateValue) --CHG0008627(7)
-- then fa.totalopenamount - isnull(tm.receivedamount, 0)  else 0 end as CurrentMonthIPDDue --CHG0008627(7)
case when datediff(m, case when IPD3MO is null then idd.fulldate else dateadd(d,IPD3MO, ID.FullDate) END , @DateValue) = 0 --CHG0008627(7)
then fa.totalopenamount else 0 end as CurrentMonthIPDDue

,
--Not Due yet based on IPD 
-- case when  dateadd(d, IPD3Mo , id.fulldate ) > (@DateValue) -- CHG0008627
-- then fa.totalopenamount - isnull(tm.receivedamount, 0) else 0 end as OpenAmountNotYetDue -- CHG0008627
case when datediff(m, case when IPD3MO is null then idd.fulldate else dateadd(d,IPD3MO, ID.FullDate) END, @DateValue) < 0  --CHG0008627(7)
then fa.totalopenamount else 0 end as OpenAmountNotYetDue

,
--Due Last Month based on IPD
-- case when  DATEPART(m, dateadd(d, IPD3Mo , id.fulldate )) = DATEPART(m, DATEADD(m, -1, @DateValue)) -- CHG0008627
--then fa.totalopenamount - isnull(tm.receivedamount, 0) else 0 end as LastMonthIPDDue -- CHG0008627
case when datediff(m, case when IPD3MO is null then idd.fulldate else  dateadd(d,IPD3MO, ID.FullDate) END, @DateValue) = 1   --CHG0008627(7)
then fa.totalopenamount else 0 end as LastMonthIPDDue

,
--Due 2 Months Ago based on IPD
-- case when  DATEPART(m, dateadd(d, IPD3Mo , id.fulldate )) = DATEPART(m, DATEADD(m, -2, @DateValue)) -- CHG0008627
-- AND DATEPART(yyyy, dateadd(d, IPD3Mo , id.fulldate )) = DATEPART(yyyy, DATEADD(m, -2, @DateValue)) -- CHG0008627
-- then fa.totalopenamount - isnull(tm.receivedamount, 0) else 0 end as TwoMonthsIPDDue -- CHG0008627
case when datediff(m, case when IPD3MO is null then idd.fulldate else  dateadd(d,IPD3MO, ID.FullDate) END, @DateValue) = 2  --CHG0008627(7)
then fa.totalopenamount else 0 end as TwoMonthsIPDDue

,
--Due Over 2 Months Ago based on IPD
-- case when  DATEPART(m, dateadd(d, IPD3Mo , id.fulldate )) < DATEPART(m, DATEADD(m, -2, @DateValue)) -- CHG0008627
-- AND DATEPART(yyyy, dateadd(d, IPD3Mo , id.fulldate )) <= DATEPART(yyyy, DATEADD(m, -2, @DateValue)) -- CHG0008627
-- then fa.totalopenamount - isnull(tm.receivedamount, 0) else 0 end as Over2MonthsIPDDue -- CHG0008627
case when datediff(m, case when IPD3MO is null then idd.fulldate else   dateadd(d,IPD3MO, ID.FullDate) END, @DateValue) > 2 --CHG0008627(7)
then fa.totalopenamount  else 0 end as Over2MonthsIPDDue

----

,

--Total AR Past Due based on IPD
------ complex case commented out and replaced with dateiff >=1   -- CHG0008627
-- case when InvoiceDueDateKey >= @datekey then 0 
-- else
--(
--case when  DATEPART(m, dateadd(d, IPD3Mo , id.fulldate )) = DATEPART(m, DATEADD(m, -1, @DateValue))
--AND DATEPART(yyyy, dateadd(d, IPD3Mo , id.fulldate )) = DATEPART(yyyy, DATEADD(m, -1, @DateValue))
---- then fa.totalopenamount - isnull(tm.receivedamount, 0) else 0 end +
--then fa.totalopenamount else 0 end +
--isnull(case when  DATEPART(m, dateadd(d, IPD3Mo , id.fulldate )) = DATEPART(m, DATEADD(m, -2, @DateValue))
--AND DATEPART(yyyy, dateadd(d, IPD3Mo , id.fulldate )) = DATEPART(yyyy, DATEADD(m, -2, @DateValue))
----year(dateadd(d, IPD3Mo , id.fulldate )) = year(@DateValue) and month(dateadd(d, IPD3Mo , id.fulldate )) = month(@DateValue) 
---- then fa.totalopenamount - isnull(tm.receivedamount, 0) else 0 end, 0) +
--then fa.totalopenamount else 0 end, 0) +
--isnull(case when  DATEPART(m, dateadd(d, IPD3Mo , id.fulldate )) < DATEPART(m, DATEADD(m, -2, @DateValue))
--AND DATEPART(yyyy, dateadd(d, IPD3Mo , id.fulldate )) = DATEPART(yyyy, DATEADD(m, -2, @DateValue))
----year(dateadd(d, IPD3Mo , id.fulldate )) = year(@DateValue) and month(dateadd(d, IPD3Mo , id.fulldate )) = month(@DateValue) 
----then fa.totalopenamount - isnull(tm.receivedamount, 0) else 0 end, 0)) end as OpenARTotalPastDue,

case when datediff(m, case when IPD3MO is null then idd.fulldate else   dateadd(d,IPD3MO, ID.FullDate) END , @DateValue) >= 1 --CHG0008627(7)
then fa.totalopenamount else 0 end  as OpenARTotalPastDue -- CHG0008627

, 
--=--
-- Projected Future Cash to be Received this Month based on IPD
------ complex case commented out and replaced with dateDiff between 0 and 2  -- CHG0008627
--case when year(dateadd(d, IPD3Mo , id.fulldate )) = year(@DateValue) and month(dateadd(d, IPD3Mo , id.fulldate )) = month(@DateValue) 
----then fa.totalopenamount - isnull(tm.receivedamount, 0) else 0 end + 
-- then fa.totalopenamount else 0 end + 
--case when  DATEPART(m, dateadd(d, IPD3Mo , id.fulldate )) = DATEPART(m, DATEADD(m, -1, @DateValue))
--AND DATEPART(yyyy, dateadd(d, IPD3Mo , id.fulldate )) = DATEPART(yyyy, DATEADD(m, -1, @DateValue))
----then fa.totalopenamount - isnull(tm.receivedamount, 0) else 0 end +
--then fa.totalopenamount  else 0 end +
--case when  DATEPART(m, dateadd(d, IPD3Mo , id.fulldate )) = DATEPART(m, DATEADD(m, -2, @DateValue))
--AND DATEPART(yyyy, dateadd(d, IPD3Mo , id.fulldate )) = DATEPART(yyyy, DATEADD(m, -2, @DateValue))
----year(dateadd(d, IPD3Mo , id.fulldate )) = year(@DateValue) and month(dateadd(d, IPD3Mo , id.fulldate )) = month(@DateValue) 
----then fa.totalopenamount - isnull(tm.receivedamount, 0) else 0 end  as ProjectedFutureCashToBeReived
--then fa.totalopenamount else 0 end  as ProjectedFutureCashToBeReived
case when datediff(m, case when IPD3MO is null then idd.fulldate else  dateadd(d,IPD3MO, ID.FullDate) END, @DateValue) >= 0 
AND datediff(m, case when IPD3MO is null then idd.fulldate else  dateadd(d,IPD3MO, ID.FullDate) end, @DateValue) <=2--CHG0008627(7)
then fa.totalopenamount else 0 end  as ProjectedFutureCashToBeReived -- CHG0008627


---






from #AgingTemp fa
inner join harsco.factARInvoices fi
on fa.invoicekey = fi.invoicekey
inner join harsco.dimdate id
on id.datekey = fi.invoicedatekey 
inner join harsco.dimdate idd --CHG0006XXX (7)
on idd.datekey = fi.invoiceduedatekey --CHG0006XXX (7)
inner join #ipd IPD  
on fi.accountcustomerkey = ipd.customerkey

left outer join #ReceiptsThisMonthInvoice tm
on fi.invoicekey = tm.invoicekey

left join harsco.FactARAging ag
on fi.InvoiceKey = ag.InvoiceKey
and ag.AgingType = 'Invoice Due Date'
and ag.AgingDateKey = @AgingDate

inner join harsco.DimCustomer dc
on fi.AccountCustomerKey = dc.CustomerKey

where 
--dc.CustomerAccountNumber = '117821'
--and 
(fa.totalopenamount <> 0 
or ag.TotalOpenAmount <> 0
or tm.ReceivedAmount <> 0)



--where 
--fa.totalopenamount <> 0
--and
-- datediff(day, id.fulldate, @DateValue) < 360
----and fa.[AsOfDate] = 'Current'


  insert into Harsco.FactARProjections (
ProjectionDateKey,
	InvoiceNumber,
	Organizationkey, 
	AccountCustomerKey,
	IPD3Mo,
	
	ReceivedThisMonth 
	
	)


select @DateKey as ProjectionDate,'No Invoice',
tm.customerkey, OrganizationKey,
 IPD3Mo
,tm.receivedamount as ReceivedThisMonth

from #ReceiptsThisMOnthNoInvoice tm

inner join harsco.DimCustomer dc
on tm.CustomerKey = dc.CustomerKey
left outer join #IPD
on dc.CustomerKey = #ipd.customerkey




  insert into Harsco.FactARProjections (
ProjectionDateKey,
	Organizationkey, 
	InvoiceNumber,
	AccountCustomerKey,
	IPD3Mo,
	
	
	NewSalesPaymentProjection
	
	)


select @DateKey as ProjectionDate
,  p.OrganizationKey, 'Projected Cash',  p.AccountCustomerKey,
ipd.IPD3Mo
,p.NewSalesAmount - isnull(c.NewSalesAmount , 0) NewSalesAmount

from #NewSalesProjected p
inner join #IPD ipd
on p.AccountCustomerKey = ipd.customerkey
left outer join #NewSalesCurrent c
on p.AccountCustomerKey = c.AccountCustomerKey
and p.OrganizationKey = c.OrganizationKey
where p.NewSalesAmount > 0 and c.NewSalesAmount > 0 and p.NewSalesAmount >= c.NewSalesAmount--CHG0008627(8)




 update #WhileDate set Processed = 1 where datekey = @DateKey

  set @cnt = (select count(*) from #WhileDate where processed = 0)





END;

PRINT 'Done simulated FOR LOOP ';

--select datepart(m, dateadd(m, -9, getdate()))


--select * from harsco.factarprojections
