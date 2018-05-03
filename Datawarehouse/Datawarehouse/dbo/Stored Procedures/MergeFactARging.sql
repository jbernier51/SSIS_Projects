




/*************************************************************************************************************************************************

20171130_MergeFactARAging_Failing - 20171130 by JBERNIER : Changing the #WhileDate popualtion to simplify and remove duplicate issue
20180104_Asofmonth_Issue - 20180104 by Prem : Changed the "3. Declare and Set" added subquery to display correct month
20180109_Asofmonth_Issue - 20180105 by Prem : Changed the "Dynamic Asof logic" added subquery to get the AsofMonths from view
20180319_BucketIssue - 20180314 by Prem : Changing the logic for bucketing "DateValueForAging"
*******************************************************************************************************************************************/


CREATE procedure [dbo].[MergeFactARging]
as

--truncate table [Harsco].[FactARAging]

delete Harsco.FactARAging where asofdate = 'Current'

--***********************************************************************************************************************
--2. Drop Temporary Table if already exists
--***********************************************************************************************************************
drop table if exists #WhileDate

--***********************************************************************************************************************
--3. Declare and Set initial values of variables
--***********************************************************************************************************************
DECLARE @cnt INT = 0;
DECLARE @DateKey INT = 0;
DECLARE @DateValue date;
DECLARE @DateValueForAging date;
DECLARE @Label nvarchar(50);
DECLARE @AsOfLabel nvarchar(20);

SELECT  
	d.datekey , d.fulldate as fulldate,
	CASE WHEN d.fulldate = cast(getdate() as date) THEN 'Current' 
	ELSE  (select (d1.monthnameabbreviation + ' '  + cast(d1.yearnum as nvarchar(4))) 
	      from harsco.dimdate d1
		  where d1.fulldate=dateadd(dd,-1,d.monthbegindate)) END as AsOfDateLabel,
	0 as processed
INTO #WhileDate
FROM harsco.dimdate  d
WHERE d.fulldate = cast(getdate() as date)
OR	d.datekey in (
					SELECT DISTINCT ASOFDT FROM harsco.vDimDateAsOf
			     )

 --***********************************************************************************************************************
--4. Setting Loop
--***********************************************************************************************************************
set @cnt = 1
 while @cnt > 0

BEGIN
   PRINT 'Inside simulated FOR LOOP';
  
  --***********************************************************************************************************************
--2. Re-initialize values of variables
--***********************************************************************************************************************
  set  @DateKey = (select top 1 datekey from #WhileDate where processed = 0)
  set @DateValue = (select top 1 fulldate from #WhileDate where processed = 0)
  set @Label = (select AsOfDateLabel from #WhileDate where datekey = @DateKey)
  set @AsOfLabel = (select top 1 Asofdatelabel from #WhileDate where processed = 0)
  set  @cnt = (select count(*) from #WhileDate where processed = 0)
  --set @DateValueForAging = dateadd(d, 0, @datevalue) Old Expression by MS_team
  set @DateValueForAging =  (CASE WHEN @AsOfLabel='Current' THEN CAST(dateadd(d, 0, @DateValue) AS DATE) ELSE CAST(dateadd(d, -1, @DateValue) AS DATE) END )
 
drop table if exists #adjustments
drop table if exists #Creditmemos
drop table if exists #Rec

select invoicekey, sum( [ADJUSTEDAPPLIEDAmount]) as AdjustmentAmount 
into #adjustments
from harsco.factARAdjustments
where  [GLDateKey] < @Datekey and transactiontype= 'Adjustment'
group by invoicekey


select invoicekey, sum([ADJUSTEDAPPLIEDAmount]) as CreditMemoAmount 
into #CreditMemos 
from  harsco.factARAdjustments
where  [GLDateKey] < @Datekey  and transactiontype= 'Credit Memo'
--GF Removed antiquated filter for credit memos and receipts
--and adjustmenttransactionid not in (select isnull(customertransactionid, 0) from harsco.factarreceipts)

group by invoicekey 

drop table if exists #REC

 select fr.invoicekey,sum(
case when fi.invoicetype = 'Payment' and ReceiptStatus  IN ('ACC', 'UNAPP', 'UNID', 'OTHER ACC') 
then
ReceivedAmount 
when fi.invoicetype <> 'Payment' 
then adjustedappliedamount
else 0
end

) as receivedamount
,sum(DiscountAmount)  as DiscountTaken, CurrencyCode
into #Rec
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
@DAtekey as AgingDateKey,
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
+
isnull(sum(creditmemoamount), 0) - 


isnull(sum(DiscountTaken), 0)


  as openamount, 

 i.sourcesystemid,
 er.exchangeratekey
into #AgingTemp
from 

 [Harsco].[FactARInvoices] i
left outer join #Rec r

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
on dateadd(d, 0, @DateValue) = CONVERT (datetime,convert(char(8), er.datekey))
and  (case [LocalCurrencyCode]
when 'MXP' then 'MXN'
--chile
when 'CHP' then 'CLP'
--serbia
when 'CSD' then 'RSD'
when 'REA' then 'BRL'

else LocalCurrencyCode end)  = er.fromcurrency

where gld.datekey < @DateKey
--and i.sourcesystemid = 27
--and i.accountcustomerkey = 184
--and i.invoicekey = 430786

group by er.exchangeratekey, i.invoicekey, i.invoicenumber,  dd.fulldate, id.fulldate, i.invoicestatus, i.sourcesystemid, i.Invoicecurrencycode, i.localcurrencycode, r.currencycode
having ((max(
case when i.[InvoiceType] = 'RU' then 
[localInvoiceAmount] * 0 
else [localInvoiceAmount] end ))  -
isnull(sum(r.[ReceivedAmount]), 0) +

isnull(sum(adjustmentamount) , 0)
+
isnull(sum(creditmemoamount), 0)
-
isnull(sum(DiscountTaken), 0)

) <> 0


PRINT 'Done populating temp table';

--***********************************************************************************************************************
--5. Merge and Insert the Data where Source and Target data are not Matched ,
--   Merge and update the Data where Source and Target data are Matched
--***********************************************************************************************************************
begin tran

merge [Harsco].[FactARAging] as T
using 
(
select 

invoicekey, invoiceduedate, @Label as AsOfDate, 'Invoice Due Date' as AgingType,
invoiceamount, 
receivedamount,
AgingDatekey,
localcurrencycode,
invoicecurrencycode,
receiptcurrencycode,
exchangeratekey,

datediff(d, invoiceduedate, @DateValueForAging)  as opendays,
case when datediff(d, invoiceduedate, @DateValueForAging)  <= 0 then openamount end as 'CurrentAmount',
case when datediff(d, invoiceduedate, @DateValueForAging)  between  1 and 30 then openamount end as 'PastDue30',
case when datediff(d, invoiceduedate, @DateValueForAging)  between  31 and 60 then openamount end as 'PastDue60',
case when datediff(d, invoiceduedate, @DateValueForAging)  between  61 and 90 then openamount end as 'PastDue90',
case when datediff(d, invoiceduedate, @DateValueForAging)  between  91 and 120 then openamount end as 'PastDue120',
case when datediff(d, invoiceduedate, @DateValueForAging)  between  121 and 150 then openamount end as 'PastDue150',
case when datediff(d, invoiceduedate, @DateValueForAging) > 150 then openamount end as 'PastDue151PLUS'

,openamount
,sourcesystemid

from #AgingTemp
where abs(openamount) > .02
) S

on (t.[InvoiceKey]  = s.invoicekey and
t.[AsOfDate] = s.asofdate and
t.[AgingType] = s.agingtype)

WHEN NOT MATCHED BY TARGET --AND S.EmployeeName LIKE 'S%' 
	THEN INSERT(
[InvoiceKey]
,[AgingType]
,[AsOfDate]
,AgingDateKey
,exchangeratekey
,LocalCurrencyCode
,invoicecurrencycode,
receiptcurrencycode
,[CurrentAmount]
,[PastDue30]
,[PastDue60]
,[PastDue90]
,[PastDue120]
,[PastDue150]
,[PastDue151PLUS]
,TotalOpenAmount
,[CreatedDateTime]
,[LastUpdatedDateTime]
,[EffectiveStartDate]
,[EffectiveEndDate]
,[CurrentRecordIndicator]
,sourcesystemid

)
values
([InvoiceKey]
,[AgingType]
,[AsOfDate]
,agingDatekey
,exchangeratekey
,localcurrencyCode
,invoicecurrencycode,
receiptcurrencycode
,[CurrentAmount]
,[PastDue30]
,[PastDue60]
,[PastDue90]
,[PastDue120]
,[PastDue150]
,[PastDue151PLUS]
,openamount

,getdate(), getdate()
, '2099-01-01', '2099-01-01'
, 1, sourcesystemid)

WHEN MATCHED 
	THEN UPDATE SET T.[InvoiceKey] = s.InvoiceKey
	;



merge [Harsco].[FactARAging] as T
using 
(
select 

invoicekey, invoiceduedate, @Label as AsOfDate, 'Invoice Date' as AgingType,
invoiceamount, 
receivedamount,
AgingDatekey,
localcurrencycode,
invoicecurrencycode,
receiptcurrencycode,
exchangeratekey,

datediff(d, invoicedate, @datevalueforaging)  as opendays,
case when datediff(d, invoicedate, @Datevalueforaging)  <= 0 then openamount end as 'CurrentAmount',
case when datediff(d, invoicedate, @Datevalueforaging)  between  1 and 30 then openamount end as 'PastDue30',
case when datediff(d, invoicedate, @Datevalueforaging)  between  31 and 60 then openamount end as 'PastDue60',
case when datediff(d, invoicedate, @Datevalueforaging)  between  61 and 90 then openamount end as 'PastDue90',
case when datediff(d, invoicedate, @Datevalueforaging)  between  91 and 120 then openamount end as 'PastDue120',
case when datediff(d, invoicedate, @Datevalueforaging)  between  121 and 150 then openamount end as 'PastDue150',
case when datediff(d, invoicedate, @Datevalueforaging) > 150 then openamount end as 'PastDue151PLUS'

,openamount
,sourcesystemid

from #AgingTemp
where abs(openamount) > .02
) S

on (t.[InvoiceKey]  = s.invoicekey and
t.[AsOfDate] = s.asofdate and
t.[AgingType] = s.agingtype)

WHEN NOT MATCHED BY TARGET --AND S.EmployeeName LIKE 'S%' 
	THEN INSERT(
[InvoiceKey]
,[AgingType]
,[AsOfDate]
,AgingDateKey
,exchangeratekey
,LocalCurrencyCode
,invoicecurrencycode,
receiptcurrencycode
,[CurrentAmount]
,[PastDue30]
,[PastDue60]
,[PastDue90]
,[PastDue120]
,[PastDue150]
,[PastDue151PLUS]
,TotalOpenAmount
,[CreatedDateTime]
,[LastUpdatedDateTime]
,[EffectiveStartDate]
,[EffectiveEndDate]
,[CurrentRecordIndicator]
,sourcesystemid

)
values
([InvoiceKey]
,[AgingType]
,[AsOfDate]
,agingDatekey
,exchangeratekey
,localcurrencyCode
,invoicecurrencycode,
receiptcurrencycode
,[CurrentAmount]
,[PastDue30]
,[PastDue60]
,[PastDue90]
,[PastDue120]
,[PastDue150]
,[PastDue151PLUS]
,openamount

,getdate(), getdate()
, '2099-01-01', '2099-01-01'
, 1, sourcesystemid)

WHEN MATCHED 
	THEN UPDATE SET T.[InvoiceKey] = s.InvoiceKey
	;
--WHEN NOT MATCHED BY SOURCE AND T.EmployeeName LIKE 'S%'
  --  THEN DELETE 
--OUTPUT $action, inserted.*, deleted.*;
--ROLLBACK TRAN;

commit tran

print @DateKey
 update #WhileDate set Processed = 1 where datekey = @DateKey


 set @cnt = (select count(*) from #WhileDate where processed = 0)
END;

PRINT 'Done simulated FOR LOOP ';





--select * from [Harsco].[FactARReceipts] where invoicekey <> -1


--select asofdate, count(*) from [Harsco].[FactARAging] group by asofdate

--select sum(totalopenamount) from harsco.factaraging where asofdate = 20170701

--select * from harsco.factaraging where asofdate = 20170701


--select sum(totalopenamount) from harsco.factaraging ag
--inner join harsco.factarinvoices i
--on ag.invoicekey = i.invoicekey
--inner join harsco.dimcustomer  c
--on i.accountcustomerkey = c.customerkey
--and c.[CustomerAccountNumber] = '4859'
--where asofdate = 'Jun 2017'

--select * from harsco.factarinvoices i where invoicenumber = '7817'

--select * from harsco.factaraging ag

--update harsco.factaraging set asofdate = 'Current'
