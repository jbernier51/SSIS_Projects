CREATE TABLE [Harsco].[FactARReceipts] (
    [ReceiptKey]             INT             IDENTITY (1, 1) NOT NULL,
    [CustomerKey]            INT             NULL,
    [OrganizationKey]        INT             NOT NULL,
    [InvoiceKey]             INT             NULL,
    [ReceivedDateKey]        INT             NOT NULL,
    [GeneralLedgerDateKey]   INT             NOT NULL,
    [ExchangeRateKey]        INT             NULL,
    [CustomerTransactionID]  NVARCHAR (100)  NULL,
    [ReceiptTransactionID]   NVARCHAR (100)  NULL,
    [ReceiptStatus]          NVARCHAR (50)   NULL,
    [ReceivedAmount]         DECIMAL (38, 4) NULL,
    [AppliedAmount]          DECIMAL (38, 4) NULL,
    [AdjustedAppliedAmount]  DECIMAL (38, 4) NULL,
    [DiscountAmount]         DECIMAL (38, 4) NULL,
    [CurrencyCode]           NVARCHAR (50)   NULL,
    [CreatedDateTime]        DATETIME        NULL,
    [LastUpdatedDateTime]    DATETIME        NULL,
    [EffectiveStartDate]     DATETIME        NOT NULL,
    [EffectiveEndDate]       DATETIME        NULL,
    [CurrentRecordIndicator] BIT             NULL,
    [AuditKey]               INT             NULL,
    [SourceSystemID]         INT             NULL,
    CONSTRAINT [PK_FactARReceipts] PRIMARY KEY CLUSTERED ([ReceiptKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [nci_wi_FactARReceipts_51A589170E21EBC7059F4F3651A4A25B]
    ON [Harsco].[FactARReceipts]([ReceivedDateKey] ASC, [InvoiceKey] ASC)
    INCLUDE([AdjustedAppliedAmount], [CustomerKey], [OrganizationKey]);


GO
CREATE NONCLUSTERED INDEX [nci_wi_FactARReceipts_7E7D17F3E4BD5CE7EF7738EF1A124F48]
    ON [Harsco].[FactARReceipts]([InvoiceKey] ASC);

