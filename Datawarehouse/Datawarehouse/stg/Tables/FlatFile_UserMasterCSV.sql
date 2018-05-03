CREATE TABLE [stg].[FlatFile_UserMasterCSV] (
    [Location Code]            VARCHAR (500) NULL,
    [USER ID]                  VARCHAR (50)  NULL,
    [Division Name]            VARCHAR (50)  NULL,
    [Region Name]              VARCHAR (50)  NULL,
    [Country Name]             VARCHAR (50)  NULL,
    [Employee Full Name (LFM)] VARCHAR (50)  NULL,
    [Report User Type]         VARCHAR (50)  NULL,
    [Job Family]               VARCHAR (50)  NULL,
    [Department]               VARCHAR (50)  NULL,
    [Job Title]                VARCHAR (50)  NULL,
    [Assignment Title]         VARCHAR (50)  NULL,
    [Assignment Category]      VARCHAR (50)  NULL,
    [Assignment Status]        VARCHAR (50)  NULL,
    [Direct Indirect]          VARCHAR (50)  NULL,
    [LineageTMST]              DATETIME      NULL,
    [UpdatedLineageString]     VARCHAR (128) NULL
);

