CREATE TABLE [Harsco].[DimPaymentTerms] (
    [PaymentTermsKey]         INT            IDENTITY (1, 1) NOT NULL,
    [PaymentTermsID]          NVARCHAR (100) NULL,
    [PaymentTermsName]        NVARCHAR (100) NULL,
    [PaymentTermsDays]        INT            NULL,
    [PaymentTermsDescription] NVARCHAR (100) NULL,
    [CreatedDateTime]         DATETIME       NULL,
    [LastUpdatedDateTime]     DATETIME       NULL,
    [EffectiveStartDate]      DATETIME       NOT NULL,
    [EffectiveEndDate]        DATETIME       NULL,
    [CurrentRecordIndicator]  BIT            NULL,
    [AuditKey]                INT            NULL,
    [SourceSystemID]          INT            NULL,
    PRIMARY KEY CLUSTERED ([PaymentTermsKey] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PaymentTerms]
    ON [Harsco].[DimPaymentTerms]([PaymentTermsID] ASC, [SourceSystemID] ASC);

