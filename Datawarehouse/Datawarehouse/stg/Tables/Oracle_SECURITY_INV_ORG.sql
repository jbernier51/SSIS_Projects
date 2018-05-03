CREATE TABLE [stg].[Oracle_SECURITY_INV_ORG] (
    [USER_NAME]            NVARCHAR (100) NULL,
    [ID]                   NVARCHAR (40)  NULL,
    [ORGANIZATION_CODE]    NVARCHAR (3)   NULL,
    [NAME]                 NVARCHAR (240) NULL,
    [LineageTMST]          DATETIME       NULL,
    [UpdatedLineageString] VARCHAR (128)  NULL,
    [SourceSystemID]       INT            NULL
);

