
create view [Harsco].[vCountryCodes] 
as

/**************************
** Change History
**************************
** PR   Date        Author		Description 
** --   --------   -------		------------------------------------
** CHG0008627 31-Jan-2018 Prem  - Included LocalCurrency column in the Select clause

***************************/
 select sq.country , sq.country_name, sq.region_name, 
  (case sq.Country_Currency
		when 'MXP' then 'MXN'		--chile
		when 'CHP' then 'CLP'		--serbia
		when 'CSD' then 'RSD'
		when 'REA' then 'BRL'
		else sq.Country_Currency end) as LocalCurrency 
 from
 (
 select distinct country, max(country_name) as country_name, max(region_name ) as region_name
 , max(Country_Currency) as Country_Currency
 from [stg].[FlatFile_RecordCountsCombinedCSV]
 group by country
 ) sq



