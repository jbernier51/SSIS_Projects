CREATE TABLE [stg].[Oracle_HZ_CUST_ACCT_SITES_ALL] (
    [CUST_ACCT_SITE_ID]    INT           NOT NULL,
    [CUST_ACCOUNT_ID]      INT           NULL,
    [PARTY_SITE_ID]        INT           NULL,
    [Payment_Term_id]      INT           NULL,
    [ORG_ID]               INT           NULL,
    [Status]               VARCHAR (1)   NULL,
    [LineageTMST]          DATETIME      NULL,
    [UpdatedLIneageString] VARCHAR (128) NULL
);

