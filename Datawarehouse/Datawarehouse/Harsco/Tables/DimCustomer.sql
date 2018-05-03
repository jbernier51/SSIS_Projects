CREATE TABLE [Harsco].[DimCustomer] (
    [CustomerKey]            INT            IDENTITY (1, 1) NOT NULL,
    [CustomerNumber]         NVARCHAR (100) NULL,
    [CustomerName]           NVARCHAR (100) NULL,
    [CustomerAccountNumber]  NVARCHAR (100) NULL,
    [CustomerAccountName]    NVARCHAR (100) NULL,
    [CustomerType]           VARCHAR (100)  NULL,
    [GroupCustomer]          VARCHAR (100)  NULL,
    [PaymentTermsKey]        INT            NULL,
    [CustomerCreditLimit]    INT            NULL,
    [CustomerProfileClass]   VARCHAR (200)  NULL,
    [Tolerance]              VARCHAR (200)  NULL,
    [CreditChecking]         VARCHAR (200)  NULL,
    [CreditHold]             VARCHAR (200)  NULL,
    [DiscountCode]           VARCHAR (200)  NULL,
    [LTTLSurcharge]          VARCHAR (200)  NULL,
    [Country]                VARCHAR (200)  NULL,
    [CreatedDateTime]        DATETIME       NULL,
    [LastUpdatedDateTime]    DATETIME       NULL,
    [EffectiveStartDate]     DATETIME       NOT NULL,
    [EffectiveEndDate]       DATETIME       NULL,
    [CurrentRecordIndicator] BIT            NULL,
    [AuditKey]               INT            NULL,
    [SourceSystemID]         INT            NULL,
    CONSTRAINT [PK__DimCustomer] PRIMARY KEY CLUSTERED ([CustomerKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [DimCustomer_ndx_customeraccountnumber]
    ON [Harsco].[DimCustomer]([CustomerAccountNumber] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DimCustomer]
    ON [Harsco].[DimCustomer]([CustomerAccountNumber] ASC, [SourceSystemID] ASC);

