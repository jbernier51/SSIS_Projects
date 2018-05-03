CREATE TABLE [stg].[Oracle_HZ_PARTY_SITES] (
    [PARTY_SITE_ID]        INT            NOT NULL,
    [PARTY_ID]             INT            NULL,
    [LOCATION_ID]          NVARCHAR (100) NULL,
    [PARTY_SITE_NUMBER]    NVARCHAR (100) NULL,
    [Status]               VARCHAR (5)    NULL,
    [LineageTMST]          DATETIME       NULL,
    [UpdatedLIneageString] VARCHAR (128)  NULL
);

