CREATE TABLE [stg].[Oracle_HZ_CUST_ACCOUNTS] (
    [CUST_ACCOUNT_ID]      INT            NOT NULL,
    [Party_ID]             NVARCHAR (50)  NULL,
    [ACCOUNT_NUMBER]       NVARCHAR (100) NULL,
    [ACCOUNT_NAME]         NVARCHAR (500) NULL,
    [CUSTOMER_TYPE]        NVARCHAR (100) NULL,
    [Payment_Term_id]      NVARCHAR (100) NULL,
    [ATTRIBUTE1]           NVARCHAR (150) NULL,
    [ATTRIBUTE2]           NVARCHAR (150) NULL,
    [LineageTMST]          DATETIME       NULL,
    [UpdatedLIneageString] VARCHAR (128)  NULL,
    [SourceSystemID]       INT            NULL
);

