CREATE TABLE [stg].[Oracle_GL_Code_Combinations_dgl] (
    [CODE_COMBINATION_ID]  NUMERIC (15)  NULL,
    [SEGMENT1]             NVARCHAR (25) NULL,
    [SEGMENT2]             NVARCHAR (25) NULL,
    [SEGMENT3]             NVARCHAR (25) NULL,
    [SEGMENT4]             NVARCHAR (25) NULL,
    [LineageTMST]          DATETIME      NULL,
    [UpdatedLineageString] VARCHAR (128) NULL
);

