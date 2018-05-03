CREATE TABLE [stg].[Oracle_HZ_CUSTOMER_PROFILES] (
    [CUST_ACCOUNT_PROFILE_ID] INT           NOT NULL,
    [CUST_ACCOUNT_ID]         INT           NULL,
    [Status]                  VARCHAR (5)   NULL,
    [Credit_Checking]         VARCHAR (5)   NULL,
    [Discount_Terms]          VARCHAR (5)   NULL,
    [Tolerance]               INT           NULL,
    [Credit_Hold]             VARCHAR (5)   NULL,
    [LineageTMST]             DATETIME      NULL,
    [UpdatedLineageSTring]    VARCHAR (128) NULL
);

