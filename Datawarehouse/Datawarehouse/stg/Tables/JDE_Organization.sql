CREATE TABLE [stg].[JDE_Organization] (
    [MCCO]                 VARCHAR (5)   NULL,
    [COUNTRY]              VARCHAR (3)   NULL,
    [SITEID]               VARCHAR (4)   NULL,
    [LOCATION]             VARCHAR (30)  NULL,
    [SITETYPE]             VARCHAR (12)  NULL,
    [LineageTMST]          DATETIME      NULL,
    [UpdatedLineageString] VARCHAR (128) NULL,
    [D_DTA_Lib]            NVARCHAR (11) NULL,
    [D_Country]            NVARCHAR (6)  NULL,
    [D_COM_Lib]            NVARCHAR (11) NULL,
    [D_SourceSystemID]     INT           NULL
);

