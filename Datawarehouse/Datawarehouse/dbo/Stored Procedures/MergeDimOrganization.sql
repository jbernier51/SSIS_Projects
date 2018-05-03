








CREATE   procedure [dbo].[MergeDimOrganization] 
/*******************************************************************************************************************
** Procedure Name: MergeDimOrganization
** Desc:
** Auth: Gene Furibondo
** Date: 09/24/2017
********************************************************************************************************************
** Change History
--------------------------------------------------------------------------------------------------------------------
** PR   Date        Author				Description 
** --   --------   -------				------------------------------------
** 1    09/27/2017  Dhilasu Reddy       Added Inline Comments
** 2    03/23/2018  Sue Hankey          Set Business Group for JDE CA to MM Metals-NA same as US
********************************************************************************************************************/
as

--***********************************************************************************************************************
--1. Calling the 'CreateDimensionUnknownRow' stored procedure to ensure that a -1 record is present
--***********************************************************************************************************************

EXEC	[dbo].[CreateDimensionUnknownRow]
		@TableName = DimOrganization,
		@TableSchema = harsco,
		@Action = N'1'


----truncate table harsco.dimorganization

--***********************************************************************************************************************
--2. Declare and Set initial values of variables
--***********************************************************************************************************************

declare @starttime as datetime = getdate();
declare @endtime as datetime;


drop table if exists  #OrganizationTemp


--***********************************************************************************************************************
--3. Inserting data from JDE Source tables into Temporary Table
--***********************************************************************************************************************
select distinct isnull(Division, 'N/A') as Division,
			    isnull(Country, 'N/A') as Country, 
				isnull(ltrim(rtrim(Business_Group)), 'N/A') as Business_Group, 
				segment1 as Company,
				segment1 as CompanyOriginal,
				Segment2_Desc as LocationName,
				Segment2 as Sitecode, 
				cast('Finance Location' as varchar(100)) as SiteType
into #OrganizationTemp 
from [stg].[Oracle_GL_Code_Combinations] gcc
left outer join 
(SELECT  max([Division]) as Division
      ,max([Country]) as Country
      ,max([Business_Group]) as Business_Group
      ,max([Location Name]) as LocationName
      ,[Location Code]
      
  FROM [stg].[FlatFile_FinanceLocationsCSV]
  where [location name] <> ''
  group by [Location Code]) flc
  on gcc.segment2 = flc.[Location Code]
where segment2 <> 'T'
--select companyoriginal,max(country) as country, max(division) as division,
--   max(isnull(business_group, 'N/A')) as businessgroup
--   from  #OrganizationTemp 
--and  segment2 = '1Bk'
 --  and segment2 = '0000' 
 --and segment1 = 'GB001'
--   and country <> 'N/A'
--   and division <> 'N/A'
--   group by  companyoriginal




; 

insert into #organizationTemp
select distinct [Division], 
[Country],
[Business_Group],
Segment1 as [Company],
Segment1 as [CompanyOriginal],
[Location Name],
--fl.[Location Code],
t1.organization_code,
'Inventory Location' as Sitetype

from [stg].[FlatFile_FinanceLocationsCSV] fl inner join 
(
Select 
Gcck.Segment2 LOCATION_CODE, 
gcck.segment1,
Mp.Organization_Code
From 
stg.Oracle_Mtl_Parameters Mp, 
stg.Oracle_Gl_Code_Combinations_Kfv Gcck--, 
--apps.org_organization_definitions@HSCP_Dr_LINK ood
where 
gcck.code_combination_id = mp.material_account
) t1
on fl.[location code] = t1.location_code
--where t1.organization_code = '1BK'


--***********************************************************************************************************************
--3. Inserting data from JDE Source tables into Temporary Table
--***********************************************************************************************************************

insert into #organizationTemp
select distinct 'Metals and Minerals' as [Division], 
fl.Country,
case when fl.country IN ('US', 'CA') then 'MM Metals-NA' else 'N/A'  end as BusinessGroup,  -- 2) INCLUDE CA
 isnull([Oracle Entity], mcco) as OracleCompany,
 MCCO as [Company],

isnull(fls.[Location Name], location) as LOCATION,
--fls.[Location Code],
ltrim(rtrim(SiteID)) as SiteID,
'JDE Location' as Sitetype

from [stg].[JDE_Organization] fl
left outer  join (
select [JDE Country], [JDE Site], max([Oracle Finance Loc]) as [Oracle Finance Loc], max([Oracle Entity]) as [Oracle Entity]
from 
[stg].[FlatFile_JDE_ORACLE_ORG_MAPPINGCSV]
group by [JDE Country], [JDE Site])
 map
on fl.country = map.[JDE Country]
and fl.siteid = map.[JDE SITE]
--and fl.mcco = [Oracle Entity]
left outer join [stg].[FlatFile_FinanceLocationsCSV] fls
on fls.[location code] = map.[Oracle Finance Loc]
where 1=1 --and siteid = '763'
and fl.country <> ''

--***********************************************************************************************************************
--5. Merge and Insert the Data where Source and Target data are not Matched ,
--   Merge and update the Data where Source and Target data are Matched
--***********************************************************************************************************************


UPDATE #OrganizationTemp

SET
  Country     = ot.Country,
  Division     = ot.Division,
  Business_Group         = ot.BusinessGroup
 
FROM
   (select companyoriginal,min(country) as country, min(division) as division,
   max(isnull(business_group, 'N/A')) as businessgroup
   from  #OrganizationTemp 
   where sitecode <> '0000' 
   and country <> 'N/A'
   and division <> 'N/A'
   and division <> 'Corporate'
   and country <> 'Default'
   group by companyoriginal)  ot

  

WHERE 
  
    #OrganizationTemp.companyoriginal = ot.companyoriginal
   and #OrganizationTemp.sitecode = '0000'



BEGIN TRAN;

MERGE Harsco.DimOrganization AS T

USING (
select distinct isnull(division, 'N/A') as division
, isnull(rc.country_name, 'N/A') as Country_Name
, rc.[Country] as country_code, company
, companyoriginal
,case when sitetype  = 'JDE Location' then 'JDE' + '-' + rc.country + '-' + companyoriginal else company  end as CompanyDisplay
, region_name, case when len(business_group) = 0 then  'N/A' else Business_group end as BusinessGroup , 
 [LocationName] as Location, 
SiteCode, sitetype from #OrganizationTemp  ot
--left outer join [stg].[FlatFile_RecordCountsCombinedCSV] rc
left outer join [Harsco].[vCountryCodes] rc
on (ot.country = rc.country_name
or ot.country = rc.country)

)
 AS S
ON (T.Companyoriginal = S.Companyoriginal and T.SiteCode = S.SiteCode and T.location = S.Location
--and t.sitetype = s.sitetype
--and t.sourceysstemid = s.sourcesystemid
) 
WHEN NOT MATCHED BY TARGET --AND S.EmployeeName LIKE 'S%' 
    THEN INSERT(Division
	, Country
	,CountryCode
	, BusinessGroup
	,Region
	,Company
	,CompanyOriginal
	,CompanyDisplay
	, [Location]
	, SiteType
	, SiteCode
	,[CreatedDateTime]
,[LastUpdatedDateTime]
,[EffectiveStartDate]
,[EffectiveEndDate]
,[CurrentRecordIndicator]


	) VALUES(s.division, s.country_name, Country_Code, s.businessgroup, 
	Region_name,
	 s.company, companyoriginal, 
	companydisplay, s.location, s.sitetype, s.sitecode, getdate(), getdate(), '2099-01-01', '2099-01-01', 1)

WHEN MATCHED 
 --  and
	--(t.[Division] <> s.division or
	--t.[Region] <> s.Region_name or 
	--t.[Country] <> s.country_name or
	--t.[CompanyOriginal] <> s.companyoriginal or 
	--t.[BusinessGroup] <> s.businessGroup or 
	--t. [Location] = s.location
	--)
		THEN UPDATE SET t.division = s.division
	, t.region = s.Region_name
	, t.country = s.country_name
	, t.businessgroup = s.businessgroup
	,t.countrycode = s.country_code
	, t.location = s.location
	,t.sitetype = s.sitetype

--WHEN NOT MATCHED BY SOURCE AND T.EmployeeName LIKE 'S%'
--    THEN DELETE 
--OUTPUT $action, inserted.*, deleted.*;
--ROLLBACK TRAN;

;
commit tran
;
