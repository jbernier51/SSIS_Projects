CREATE TABLE [stg].[Oracle_HZ_LOCATIONS] (
    [LOCATION_ID]          INT            NOT NULL,
    [Address1]             NVARCHAR (500) NULL,
    [Address2]             NVARCHAR (500) NULL,
    [Address3]             NVARCHAR (500) NULL,
    [City]                 NVARCHAR (500) NULL,
    [State]                VARCHAR (200)  NULL,
    [Country]              VARCHAR (200)  NULL,
    [Province]             VARCHAR (200)  NULL,
    [Postal_code]          VARCHAR (200)  NULL,
    [LineageTMST]          DATETIME       NULL,
    [UpdatedLineageSTring] VARCHAR (128)  NULL
);

