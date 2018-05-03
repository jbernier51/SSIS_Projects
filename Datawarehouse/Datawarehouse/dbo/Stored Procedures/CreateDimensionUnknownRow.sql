CREATE proc [dbo].[CreateDimensionUnknownRow]  
  
/*******************************************************************************************************************
** Procedure Name: CreateDimensionUnknownRow
** Desc:
** Auth: Gene Furibondo
** Date: 08/24/2017
********************************************************************************************************************
** Change History
--------------------------------------------------------------------------------------------------------------------
** PR   Date        Author				Description 
** --   --------   -------				------------------------------------
** 1    09/10/2017  Dhilasu Reddy       Added Inline Comments
********************************************************************************************************************/
 
--***********************************************************************************************************************
--1. Parameter declarations for Stored Procedure 
--***********************************************************************************************************************
      @TableName sysname, 
      @TableSchema sysname = 'Harsco', 
      @Action varchar(10) = 'Script' 
as 


--***********************************************************************************************************************
--2. Declare and Set initial values of variables
--***********************************************************************************************************************
declare 
      @ColumnListing varchar(max) = '', 
      @ValuesList varchar(max) = '', 
      @query varchar(max)=' '

set @query = @query+ 'IF NOT EXISTS (SELECT * FROM ['+@TableSchema+'].['+@TableName+'] WHERE '+substring(@tablename,4,len(@tablename))+'key= -1)' 
set @query = @query+ ' begin' 
set @query = @query+ ' set identity_insert ['+@TableSchema+'].['+@TableName+'] ON' 
declare @insert varchar(max) = ' INSERT INTO ['+@TableSchema+'].['+@TableName+']'

SELECT @ColumnListing = @ColumnListing+'['+Column_Name+']'+',' 
      FROM  INFORMATION_SCHEMA.COLUMNS c 
      INNER JOIN SYSOBJECTS o 
      ON c.TABLE_NAME = o.name 
      INNER JOIN sys.schemas s 
      ON o.uid = s.schema_id 
      LEFT JOIN sys.all_columns c2 
      ON o.id = c2.object_id 
      AND c.COLUMN_NAME = c2.name

WHERE 
      c.TABLE_NAME = @TableName 
      AND c.TABLE_SCHEMA = @TableSchema 
      AND c2.is_computed = 0 
      AND c.TABLE_SCHEMA = s.name 
ORDER BY c.ORDINAL_POSITION 

set @ColumnListing = SUBSTRING(@ColumnListing,0, len(@columnlisting))

set @insert = @insert+'('+ @columnlisting+')' 
set @query = @query+@insert 
SELECT 
      @ValuesList = @ValuesList+ 
      CASE 
            WHEN DATA_TYPE IN ('INT', 'NUMERIC') AND c.COLUMN_NAME NOT LIKE '%DateSK' THEN  '-1' 
            WHEN DATA_TYPE IN ('DECIMAL') THEN  '-1' 
            WHEN DATA_TYPE IN ('VARCHAR', 'CHAR') AND CHARACTER_MAXIMUM_LENGTH = 1 THEN '''U''' 
            WHEN DATA_TYPE IN ('VARCHAR', 'CHAR') AND CHARACTER_MAXIMUM_LENGTH = 2 THEN '''Un''' 
            WHEN DATA_TYPE IN ('VARCHAR', 'CHAR') AND CHARACTER_MAXIMUM_LENGTH BETWEEN 3 AND 7 THEN '''Unk''' 
            WHEN DATA_TYPE IN ('VARCHAR', 'CHAR') AND CHARACTER_MAXIMUM_LENGTH > 7 THEN '''Unknown''' 
            WHEN DATA_TYPE IN ('NVARCHAR', 'CHAR') AND CHARACTER_MAXIMUM_LENGTH = 1 THEN '''U''' 
            WHEN DATA_TYPE IN ('NVARCHAR', 'CHAR') AND CHARACTER_MAXIMUM_LENGTH = 2 THEN '''Un''' 
            WHEN DATA_TYPE IN ('NVARCHAR', 'CHAR') AND CHARACTER_MAXIMUM_LENGTH BETWEEN 3 AND 7 THEN '''Unk''' 
            WHEN DATA_TYPE IN ('NVARCHAR', 'CHAR') AND CHARACTER_MAXIMUM_LENGTH > 7 THEN '''Unknown''' 
            WHEN DATA_TYPE IN ('INT') AND c.COLUMN_NAME like '%DateKey' THEN '19000101' 
            WHEN DATA_TYPE IN ('DateTime') THEN '''1900-01-01''' 
            WHEN DATA_TYPE IN ('Date') THEN '''1900-01-01''' 
            WHEN DATA_TYPE IN ('TINYINT') THEN  '0' 
            WHEN DATA_TYPE IN ('FLOAT') THEN  '0' 
            WHEN DATA_TYPE IN ('BIT') THEN  '0' 
            ELSE ''''+DATA_TYPE+'''' 
      END+',' 
      FROM  INFORMATION_SCHEMA.COLUMNS c 
      INNER JOIN SYSOBJECTS o 
      ON c.TABLE_NAME = o.name 
      INNER JOIN sys.schemas s 
      ON o.uid = s.schema_id 
      LEFT JOIN sys.all_columns c2 
      ON o.id = c2.object_id 
      AND c.COLUMN_NAME = c2.name

WHERE 
      c.TABLE_NAME = @TableName 
      AND c.TABLE_SCHEMA = @TableSchema 
      AND c2.is_computed = 0 
      AND c.TABLE_SCHEMA = s.name 
ORDER BY c.ORDINAL_POSITION

set @query = @query+ ' VALUES('+substring(@ValuesList,0,LEN(@valueslist))+')' 
set @query = @query+ ' set identity_insert ['+@TableSchema+'].['+@TableName+'] OFF' 
set @query = @query+ ' end'

if(@Action = 'Script') 
begin 
      print @query 
end 
else 
begin 
      exec (@query) 
end

-- End of Stored Procedure ---