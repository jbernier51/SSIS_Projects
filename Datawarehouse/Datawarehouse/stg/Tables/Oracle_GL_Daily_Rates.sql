CREATE TABLE [stg].[Oracle_GL_Daily_Rates] (
    [FROM_CURRENCY]        NVARCHAR (15)  NULL,
    [TO_CURRENCY]          NVARCHAR (15)  NULL,
    [CONVERSION_DATE]      DATETIME       NULL,
    [CONVERSION_TYPE]      NVARCHAR (30)  NULL,
    [CONVERSION_RATE]      NVARCHAR (50)  NULL,
    [STATUS_CODE]          NVARCHAR (1)   NULL,
    [CREATION_DATE]        DATETIME       NULL,
    [CREATED_BY]           NUMERIC (15)   NULL,
    [LAST_UPDATE_DATE]     DATETIME       NULL,
    [LAST_UPDATED_BY]      NUMERIC (15)   NULL,
    [LAST_UPDATE_LOGIN]    NUMERIC (15)   NULL,
    [CONTEXT]              NVARCHAR (150) NULL,
    [RATE_SOURCE_CODE]     NVARCHAR (15)  NULL,
    [LineageTMST]          DATETIME       NULL,
    [UpdatedLineageString] VARCHAR (128)  NULL
);

