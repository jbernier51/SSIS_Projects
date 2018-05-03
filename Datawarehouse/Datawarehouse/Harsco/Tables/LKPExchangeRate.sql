CREATE TABLE [Harsco].[LKPExchangeRate] (
    [ExchangeRateKey]        INT              IDENTITY (1, 1) NOT NULL,
    [DateKey]                INT              NOT NULL,
    [ExchangeRate]           DECIMAL (36, 12) NULL,
    [FromCurrency]           NVARCHAR (10)    NULL,
    [ToCurrency]             NVARCHAR (10)    NULL,
    [CreatedDateTime]        DATETIME         NULL,
    [LastUpdatedDateTime]    DATETIME         NULL,
    [EffectiveStartDate]     DATETIME         NOT NULL,
    [EffectiveEndDate]       DATETIME         NULL,
    [CurrentRecordIndicator] BIT              NULL,
    [AuditKey]               INT              NULL,
    PRIMARY KEY CLUSTERED ([ExchangeRateKey] ASC)
);

