CREATE TABLE [Harsco].[LKPUserSecurity] (
    [UserName]             VARCHAR (MAX)  NULL,
    [Country]              NVARCHAR (50)  NULL,
    [CountryCode]          NVARCHAR (50)  NULL,
    [OrganizationKey]      INT            NULL,
    [SiteCode]             NVARCHAR (MAX) NULL,
    [Location]             NVARCHAR (100) NULL,
    [LineageTMST]          DATETIME       NULL,
    [UpdatedLineageString] VARCHAR (128)  NULL
);

