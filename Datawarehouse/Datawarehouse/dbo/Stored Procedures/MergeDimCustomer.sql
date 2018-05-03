








CREATE   procedure [dbo].[MergeDimCustomer] as

/*******************************************************************************************************************
** Procedure Name: MergeDimCustomer
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


--truncate table Harsco.DimCustomer
--***********************************************************************************************************************
--1. Calling the 'CreateDimensionUnknownRow' stored procedure to ensure that a -1 record is present
--***********************************************************************************************************************

EXEC	[dbo].[CreateDimensionUnknownRow]
		@TableName = DimCustomer,
		@TableSchema = harsco,
		@Action = N'1'

--***********************************************************************************************************************
--2. Source - Oracle
--   Merge and Insert the Data where Source and Target data are not Matched ,
--   Merge and update the Data where Source and Target data are Matched
--***********************************************************************************************************************
BEGIN TRAN

MERGE Harsco.DimCustomer AS T
USING (
 select
 distinct
account_number,
isnull(account_name, cast('Customer No ' as nvarchar(100)) + account_number) as Account_Name
,[CUSTOMER_TYPE]
,hp.party_number as CustomerNumber
--,a.payment_term_id
,isnull(pt.paymenttermskey, -1) as paymenttermskey
,hp.party_name as CustomerName
,hp.party_id
,27 as SourceSystemID
,pr.[Status]
,[Credit_Checking]
,[Discount_Terms]
,[Tolerance]
,[Credit_Hold]
,[OVERALL_CREDIT_LIMIT]

					FROM stg.Oracle_hz_cust_accounts A
					left outer join
					  stg.Oracle_HZ_CUST_ACCT_SITES_ALL B
					on A.CUST_ACCOUNT_ID        = B.CUST_ACCOUNT_ID
					left outer join 
					  stg.Oracle_HZ_CUST_SITE_USES_ALL C
					on B.CUST_ACCT_SITE_ID        = C.CUST_ACCT_SITE_ID
					left outer join 
					  stg.Oracle_HZ_PARTY_SITES P
					on B.PARTY_SITE_ID            = P.PARTY_SITE_ID
					left outer join 
					(select cust_account_id, max([OVERALL_CREDIT_LIMIT]) as [OVERALL_CREDIT_LIMIT]
					from [stg].[Oracle_HZ_CUST_PROFILE_AMTS]
					group by cust_account_id ) amt
					on A.CUST_ACCOUNT_ID = amt.[CUST_ACCOUNT_ID]

					left outer join 
(select [CUST_ACCOUNT_ID],
max([Status]) as Status,
max([Credit_Checking]) as Credit_Checking,
max([Discount_Terms]) as Discount_Terms,
max([Tolerance]) as Tolerance,
max([Credit_Hold]) as Credit_Hold
from

[stg].[Oracle_HZ_CUSTOMER_PROFILES] 
group by [CUST_ACCOUNT_ID]) 

PR
on a.Cust_Account_ID = PR.Cust_Account_ID
inner join 
					 -- stg.Oracle_HZ_LOCATIONS L,
					[stg].[Oracle_HZ_PARTIES] hp
					on hp.party_id = a.party_id
					
					inner join (
					select a.CUST_ACCOUNT_ID, isnull(max(a.Payment_Term_id) , max(c.Payment_Term_ID) )as paymenttermid from
stg.Oracle_hz_cust_accounts A
					left outer join
					  stg.Oracle_HZ_CUST_ACCT_SITES_ALL B
					on A.CUST_ACCOUNT_ID        = B.CUST_ACCOUNT_ID
					left outer join 
					  stg.Oracle_HZ_CUST_SITE_USES_ALL C
					on B.CUST_ACCT_SITE_ID        = C.CUST_ACCT_SITE_ID
					
					group by a.CUST_ACCOUNT_ID
					) ptl
					on a.cust_account_id = ptl.cust_account_id

					left outer join 

					harsco.DimPaymentTerms pt
					on cast(ptl.paymenttermid as nvarchar(50)) = pt.[PaymentTermsID]
					and pt.paymenttermsid is not null
					and pt.sourcesystemid = 27
					--where account_number = '10828'

)
 AS S
ON T.[CustomerAccountNumber] = S.Account_Number
and t.sourcesystemid = s.sourcesystemid 
WHEN MATCHED 
    THEN UPDATE SET t.CustomerNumber = s.Account_Number
		,t.CustomerName  = s.customername
		,t.CustomerAccountNumber = s.account_number
	,t.CustomerAccountName = s.account_name
, t.[CustomerCreditLimit] = s.[OVERALL_CREDIT_LIMIT]
,t.[Tolerance] = s.[Tolerance]
,t.[CreditChecking] = s.[Credit_Checking]
,t.[CreditHold] = s.[Credit_Hold]
,t.[DiscountCode] = s.[Discount_Terms]
,t.PaymentTermsKey = s.PaymenTTermsKey
WHEN NOT MATCHED BY TARGET 
    THEN INSERT(CustomerNumber
	,CustomerName
	,CustomerAccountNumber
	,CustomerAccountName
, [CustomerCreditLimit]
,[Tolerance]
,[CreditChecking]
,[CreditHold]
,[DiscountCode]
--,[LTTLSurcharge]
	,PaymentTermsKey
	,SourceSystemID
	,[CreatedDateTime]
,[LastUpdatedDateTime]
,[EffectiveStartDate]
,[EffectiveEndDate]
,[CurrentRecordIndicator] )
values (customernumber, customername, s.account_number, account_name, 
[OVERALL_CREDIT_LIMIT]
,[Tolerance]
,[Credit_Checking]
,[Credit_Hold]
,[Discount_Terms]
,PaymenTTermsKey, 
SourceSystemID
--start audit columns
,getdate(), getdate(), '2099-01-01', '2099-01-01', 1)

	;

;

commit tran 


--***********************************************************************************************************************
--3. Source - JDE
--   Merge and Insert the Data where Source and Target data are not Matched ,
--   Merge and update the Data where Source and Target data are Matched
--***********************************************************************************************************************

BEGIN TRAN;
MERGE Harsco.DimCustomer AS T
USING (
 select
 distinct
account_number,
isnull(account_name, cast('Customer No ' as nvarchar(100)) + account_number) as Account_Name
,pt.PaymentTermsID
,PaymentTermsKey
,[CUSTOMER_TYPE]
,cust.SourceSystemID
from
 [stg].[JDE_F0101] cust
 left outer join stg.JDE_F0301 jpt
 on cust.[Account_number] = jpt.A5AN8
 and cust.[SourceSystemID] = jpt.d_sourcesystemid
 left outer join [Harsco].[DimPaymentTerms] pt
 on jpt.A5TRAR = pt.paymenttermsID
 and JPT.d_sourcesystemid = pt.sourcesystemID
 --where cust.account_number = '765940'

)
 AS S
ON (T.[CustomerAccountNumber] = S.Account_Number
and t.sourcesystemid = s.sourcesystemid) 
WHEN NOT MATCHED BY TARGET 
    THEN INSERT(CustomerNumber
	,CustomerName
	,CustomerAccountNumber
	,customeraccountname
	,PaymentTermsKey
	,SourceSystemID
	,[CreatedDateTime]
,[LastUpdatedDateTime]
,[EffectiveStartDate]
,[EffectiveEndDate]
,[CurrentRecordIndicator] )
values (s.account_number, account_name, account_number,account_name, paymenttermskey, SourceSystemID
--start audit columns
,getdate(), getdate(), '2099-01-01', '2099-01-01', 1)
WHEN MATCHED 
    THEN UPDATE SET t.CustomerNumber = s.Account_Number
	,t.CustomerName = s.account_name
	,t.CustomerAccountNumber = s.account_number
	,t.customeraccountname = s.account_name
	,t.PaymentTermsKey = s.paymenttermskey
	;

;

commit tran

--***********************************************************************************************************************
--    Insert Others dummy customer for TOP N / Other reports
--***********************************************************************************************************************

insert into harsco.DimCustomer(CustomerName, EffectiveStartDate)
select distinct 'Others', getdate()
from harsco.dimcustomer
where  not exists (select CustomerName from harsco.dimcustomer where customername='Others') ;

