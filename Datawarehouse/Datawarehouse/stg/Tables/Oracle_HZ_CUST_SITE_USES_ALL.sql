CREATE TABLE [stg].[Oracle_HZ_CUST_SITE_USES_ALL] (
    [SITE_USE_ID]          INT           NOT NULL,
    [CUST_ACCT_SITE_ID]    INT           NULL,
    [Payment_Term_ID]      INT           NULL,
    [STATUS]               VARCHAR (5)   NULL,
    [LOCATION]             VARCHAR (200) NULL,
    [Attribute1]           VARCHAR (200) NULL,
    [Attribute2]           VARCHAR (200) NULL,
    [LineageTMST]          DATETIME      NULL,
    [UpdatedLineageSTring] VARCHAR (128) NULL
);

