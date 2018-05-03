

CREATE procedure [dbo].[MergeDimCustomerLocation]
as
/****************************** 
** Procedure Name: MergeDimCustomerLocation
** Desc:  Customer Location details
** Auth:  Microsoft Consultants
** Date:  July-November 2017
**************************
***************************
** Change History
**************************
** PR   Date        Author				Description 
** --   --------   -------				------------------------------------
** CHG0008620 30-Jan-2018 Raj Koneru  - Added "Country" after "Province" in SELECT, NOT MATCHED and MATCHED*/


EXEC	[dbo].[CreateDimensionUnknownRow]
		@TableName = DimCustomerLocation,
		@TableSchema = harsco,
		@Action = N'1'

--truncate table Harsco.dimCustomerLocation
begin tran
MERGE Harsco.DimCustomerLocation AS T
USING (


sELECT A.ACCOUNT_NUMBER,c.location, dc.customerkey,
  C.site_use_id, l.address1, address2, address3, city, state, l.country, postal_code
FROM stg.oracle_hz_cust_accounts A
inner join 
  stg.oracle_HZ_CUST_ACCT_SITES_ALL B
  on A.CUST_ACCOUNT_ID        = B.CUST_ACCOUNT_ID
  inner join 
  stg.oracle_HZ_CUST_SITE_USES_ALL C
  on B.CUST_ACCT_SITE_ID        = C.CUST_ACCT_SITE_ID
  inner join 
  stg.oracle_HZ_PARTY_SITES P
  on B.PARTY_SITE_ID            = P.PARTY_SITE_ID
  inner join stg.oracle_HZ_LOCATIONS L
  on
  P.LOCATION_ID = L.LOCATION_ID 
  inner join harsco.dimcustomer dc

on  A.ACCOUNT_NUMBER = dc.CustomerAccountNumber
and dc.sourcesystemid = 27



)
 AS S
ON (T.CustomerLocationNumber = Convert(nvarchar(max),S.Site_use_id)) 
WHEN NOT MATCHED BY TARGET 
    THEN INSERT(
	[CustomerLocationNumber]
	,customerkey
,[CustomerLocationName]
,[Address1]
,[Address2]
,[Address3]
,[City]
,[State]
,[PostalCode]
,[Province]
,[Country]
	,[CreatedDateTime]
,[LastUpdatedDateTime]
,[EffectiveStartDate]
,[EffectiveEndDate]
,[CurrentRecordIndicator] )
values (Convert(nvarchar(max),S.Site_use_id), 
s.customerkey,
s.location,
s.address1,
s.address2,
s.address3,
s.city,
s.state,
s.postal_code,
s.country,
s.country
--start audit columns
,getdate(), getdate(), '2099-01-01', '2099-01-01', 1)
WHEN MATCHED 
    THEN UPDATE SET t.customerlocationnumber = s.site_use_id
	,t.customerkey = s.customerkey
,t.[CustomerLocationName] = s.location
,t.[Address1] = s.address1
,t.[Address2] = s.address2
,t.[Address3] = s.address3
,t.[City] = s.city
,t.[State] = s.state
,t.[PostalCode] = s.postal_code
,t.[Province] = s.country
,t.[Country] = s.country
	;



commit tran
