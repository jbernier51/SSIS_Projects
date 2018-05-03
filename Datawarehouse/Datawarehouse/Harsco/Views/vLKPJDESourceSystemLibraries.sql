CREATE VIEW [Harsco].[vLKPJDESourceSystemLibraries]

AS 

SELECT  DISTINCT  [Source_System_ID], [COM_LIB], [DTA_LIB] --, [Country_Code]

FROM [stg].[FlatFile_RecordCountsCombinedCSV]

WHERE source_system_id <> '27'
AND source_system_id BETWEEN '1' AND '99' 
AND Inactive_AR !='Yes'
