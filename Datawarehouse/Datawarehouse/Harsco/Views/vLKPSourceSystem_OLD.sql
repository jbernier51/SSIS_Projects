
-- =================================================================================
-- Create View template for Azure SQL Database and Azure SQL Data Warehouse Database
-- =================================================================================
create view [Harsco].[vLKPSourceSystem_OLD]

as
select
[Source_System_ID] as SourceSystemID,
max(cast([INV_Div_By]  as integer))    as JDEInvoiceDivideBy
from

[stg].[FlatFile_RecordCountsCombinedCSV]


where [Source_System_ID] between '1' and '99'


group by [Source_System_ID]