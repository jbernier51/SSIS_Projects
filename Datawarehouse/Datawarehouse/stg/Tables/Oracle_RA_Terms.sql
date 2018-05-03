﻿CREATE TABLE [stg].[Oracle_RA_Terms] (
    [ROW_ID]                      NVARCHAR (3950) NULL,
    [TERM_ID]                     NUMERIC (15)    NULL,
    [LAST_UPDATE_DATE]            DATETIME        NULL,
    [LAST_UPDATED_BY]             NUMERIC (15)    NULL,
    [CREATION_DATE]               DATETIME        NULL,
    [CREATED_BY]                  NUMERIC (15)    NULL,
    [LAST_UPDATE_LOGIN]           NUMERIC (15)    NULL,
    [CREDIT_CHECK_FLAG]           NVARCHAR (1)    NULL,
    [DUE_CUTOFF_DAY]              NUMERIC (38, 4) NULL,
    [PRINTING_LEAD_DAYS]          NUMERIC (38, 4) NULL,
    [START_DATE_ACTIVE]           DATETIME        NULL,
    [END_DATE_ACTIVE]             DATETIME        NULL,
    [ATTRIBUTE_CATEGORY]          NVARCHAR (30)   NULL,
    [ATTRIBUTE1]                  NVARCHAR (150)  NULL,
    [ATTRIBUTE2]                  NVARCHAR (150)  NULL,
    [ATTRIBUTE3]                  NVARCHAR (150)  NULL,
    [ATTRIBUTE4]                  NVARCHAR (150)  NULL,
    [ATTRIBUTE5]                  NVARCHAR (150)  NULL,
    [ATTRIBUTE6]                  NVARCHAR (150)  NULL,
    [ATTRIBUTE7]                  NVARCHAR (150)  NULL,
    [ATTRIBUTE8]                  NVARCHAR (150)  NULL,
    [ATTRIBUTE9]                  NVARCHAR (150)  NULL,
    [ATTRIBUTE10]                 NVARCHAR (150)  NULL,
    [BASE_AMOUNT]                 NUMERIC (38, 4) NULL,
    [CALC_DISCOUNT_ON_LINES_FLAG] NVARCHAR (1)    NULL,
    [FIRST_INSTALLMENT_CODE]      NVARCHAR (12)   NULL,
    [IN_USE]                      NVARCHAR (1)    NULL,
    [PARTIAL_DISCOUNT_FLAG]       NVARCHAR (1)    NULL,
    [ATTRIBUTE11]                 NVARCHAR (150)  NULL,
    [ATTRIBUTE12]                 NVARCHAR (150)  NULL,
    [ATTRIBUTE13]                 NVARCHAR (150)  NULL,
    [ATTRIBUTE14]                 NVARCHAR (150)  NULL,
    [ATTRIBUTE15]                 NVARCHAR (150)  NULL,
    [NAME]                        NVARCHAR (15)   NULL,
    [DESCRIPTION]                 NVARCHAR (240)  NULL,
    [PREPAYMENT_FLAG]             NVARCHAR (1)    NULL,
    [BILLING_CYCLE_ID]            NUMERIC (15)    NULL,
    [CYCLE_NAME]                  NVARCHAR (255)  NULL,
    [Due_Days]                    NVARCHAR (150)  NULL,
    [LineageTMST]                 DATETIME        NULL,
    [UpdatedLineageString]        VARCHAR (128)   NULL,
    [SourceSystemID]              INT             NULL
);

