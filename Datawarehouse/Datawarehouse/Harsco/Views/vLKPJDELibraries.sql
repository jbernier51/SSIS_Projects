

CREATE VIEW [Harsco].[vLKPJDELibraries]

as

select distinct
sourcesystemid, datlib, comlib,[CountryCode] ,[DivideByAR], [DivideByReceipts]
from 
[stg].[FlatFile_JDELibrary]