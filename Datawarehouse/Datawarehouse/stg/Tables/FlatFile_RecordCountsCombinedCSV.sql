CREATE TABLE [stg].[FlatFile_RecordCountsCombinedCSV] (
    [Country]              VARCHAR (50)  NULL,
    [Country_Name]         VARCHAR (50)  NULL,
    [Country_Code]         VARCHAR (50)  NULL,
    [Region]               VARCHAR (50)  NULL,
    [Country_Currency]     VARCHAR (50)  NULL,
    [VAT]                  VARCHAR (50)  NULL,
    [INV_Div_By]           VARCHAR (50)  NULL,
    [Region_Name]          VARCHAR (50)  NULL,
    [COM_LIB]              VARCHAR (50)  NULL,
    [DTA_LIB]              VARCHAR (50)  NULL,
    [CUST1_LIB]            VARCHAR (50)  NULL,
    [CUST2_LIB]            VARCHAR (50)  NULL,
    [Sub_Region]           VARCHAR (50)  NULL,
    [Sub_Region_Name]      VARCHAR (50)  NULL,
    [Source_System_ID]     VARCHAR (50)  NULL,
    [QOH_Div_By]           VARCHAR (50)  NULL,
    [Inactive_AR]          VARCHAR (10)  NULL,
    [Inactive_Others]      VARCHAR (10)  NULL,
    [LineageTMST]          DATETIME      NULL,
    [UpdatedLineageString] VARCHAR (128) NULL
);

