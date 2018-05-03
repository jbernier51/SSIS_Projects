CREATE TABLE [Harsco].[DimOrganization] (
    [OrganizationKey]        INT            IDENTITY (1, 1) NOT NULL,
    [Division]               NVARCHAR (50)  NOT NULL,
    [Region]                 NVARCHAR (50)  NULL,
    [Country]                NVARCHAR (50)  NULL,
    [CountryCode]            NVARCHAR (50)  NULL,
    [Company]                NVARCHAR (100) NULL,
    [CompanyOriginal]        NVARCHAR (100) NULL,
    [CompanyDisplay]         NVARCHAR (100) NULL,
    [BusinessGroup]          NVARCHAR (50)  NULL,
    [Location]               NVARCHAR (100) NULL,
    [SiteType]               NVARCHAR (50)  NULL,
    [SiteCode]               NVARCHAR (50)  NULL,
    [CreatedDateTime]        DATETIME       NULL,
    [LastUpdatedDateTime]    DATETIME       NULL,
    [EffectiveStartDate]     DATETIME       NOT NULL,
    [EffectiveEndDate]       DATETIME       NULL,
    [CurrentRecordIndicator] BIT            NULL,
    [AuditKey]               INT            NULL,
    [SourceSystemID]         INT            NULL,
    PRIMARY KEY CLUSTERED ([OrganizationKey] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DimOrganization]
    ON [Harsco].[DimOrganization]([CompanyOriginal] ASC, [SiteCode] ASC);

