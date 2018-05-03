CREATE TABLE [stg].[JDELibrary] (
    [ID]          INT            IDENTITY (1, 1) NOT NULL,
    [CountryName] NVARCHAR (200) NOT NULL,
    [CountryCode] NVARCHAR (10)  NULL,
    [COM_LIB]     NVARCHAR (100) NOT NULL,
    [DTA_LIB]     NVARCHAR (100) NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

