
create view [Harsco].[vCountries] 
as
 select distinct country, country_name, region_name 
 from [stg].[FlatFile_RecordCountsCombinedCSV]