CREATE TABLE [stg].[Oracle_GL_SETS_OF_BOOKS] (
    [SET_OF_BOOKS_ID]      INT           NOT NULL,
    [NAME]                 VARCHAR (250) NULL,
    [SHORT_NAME]           VARCHAR (150) NULL,
    [CURRENCY_CODE]        VARCHAR (20)  NULL,
    [PERIOD_SET_NAME]      VARCHAR (100) NULL,
    [LineageTMST]          DATETIME      NULL,
    [UpdatedLIneageString] VARCHAR (128) NULL
);

