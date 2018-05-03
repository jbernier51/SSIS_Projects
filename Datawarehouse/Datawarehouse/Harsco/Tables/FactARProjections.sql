CREATE TABLE [Harsco].[FactARProjections] (
    [ARProjectionKey]               INT             IDENTITY (1, 1) NOT NULL,
    [ProjectionDateKey]             INT             NULL,
    [InvoiceNumber]                 NVARCHAR (50)   NULL,
    [AccountCustomerKey]            INT             NULL,
    [OrganizationKey]               INT             NULL,
    [CurrencyCode]                  NVARCHAR (50)   NULL,
    [TotalOpenAmount]               DECIMAL (20, 2) NULL,
    [InvoiceDate]                   DATE            NULL,
    [IPDDate]                       DATE            NULL,
    [IPD3Mo]                        NVARCHAR (50)   NULL,
    [ReceivedThisMonth]             DECIMAL (20, 2) NULL,
    [OpenAmountEndofLastMonth]      DECIMAL (20, 2) NULL,
    [CurrentMonthIPDDue]            DECIMAL (20, 2) NULL,
    [OpenAmountNotYetDue]           DECIMAL (20, 2) NULL,
    [LastMonthIPDDue]               DECIMAL (20, 2) NULL,
    [TwoMonthsIPDDue]               DECIMAL (20, 2) NULL,
    [Over2MonthsIPDDue]             DECIMAL (20, 2) NULL,
    [OpenARTotalPastDue]            DECIMAL (20, 2) NULL,
    [ProjectedFutureCashToBeReived] DECIMAL (20, 2) NULL,
    [NewSalesPaymentProjection]     DECIMAL (20, 2) NULL,
    PRIMARY KEY CLUSTERED ([ARProjectionKey] ASC)
);

