CREATE TABLE [stg].[Oracle_HZ_CUST_PROFILE_AMTS] (
    [CUST_ACCT_PROFILE_AMT_ID] INT           NOT NULL,
    [CUST_ACCOUNT_PROFILE_ID]  INT           NULL,
    [CUST_ACCOUNT_ID]          INT           NULL,
    [TRX_CREDIT_LIMIT]         NUMERIC (15)  NULL,
    [Currency_Code]            VARCHAR (100) NULL,
    [OVERALL_CREDIT_LIMIT]     NUMERIC (15)  NULL
);

