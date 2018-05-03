CREATE TABLE [Harsco].[FactARAdjustments] (
    [AdjustmentKey]           INT             IDENTITY (1, 1) NOT NULL,
    [CustomerKey]             INT             NULL,
    [OrganizationKey]         INT             NULL,
    [InvoiceKey]              INT             NULL,
    [GLDateKey]               INT             NOT NULL,
    [GLAccountKey]            INT             NULL,
    [ExchangeRateKey]         INT             NULL,
    [AdjustmentTransactionID] NVARCHAR (100)  NULL,
    [TransactionType]         NVARCHAR (100)  NULL,
    [Amount]                  DECIMAL (38, 4) NULL,
    [AppliedAmount]           DECIMAL (38, 4) NULL,
    [AdjustedAppliedAmount]   DECIMAL (38, 4) NULL,
    [CurrencyCode]            NVARCHAR (50)   NULL,
    [CreatedDateTime]         DATETIME        NULL,
    [LastUpdatedDateTime]     DATETIME        NULL,
    [EffectiveStartDate]      DATETIME        NOT NULL,
    [EffectiveEndDate]        DATETIME        NULL,
    [CurrentRecordIndicator]  BIT             NULL,
    [AuditKey]                INT             NULL,
    [SourceSystemID]          INT             NULL
);

