CREATE TABLE [Harsco].[FactCustomerNotes] (
    [CustomerNoteKey]         INT            IDENTITY (1, 1) NOT NULL,
    [CustomerNoteID]          NVARCHAR (100) NULL,
    [CustomerKey]             INT            NOT NULL,
    [NoteLastUpdatedDateTime] DATETIME       NOT NULL,
    [NoteDateKey]             INT            NOT NULL,
    [NoteType]                NVARCHAR (100) NULL,
    [NoteText]                NVARCHAR (MAX) NULL,
    [CreatedByUser]           NVARCHAR (100) NULL,
    [CreatedDateTime]         DATETIME       NULL,
    [LastUpdatedDateTime]     DATETIME       NULL,
    [EffectiveStartDate]      DATETIME       NOT NULL,
    [EffectiveEndDate]        DATETIME       NULL,
    [CurrentRecordIndicator]  BIT            NULL,
    [AuditKey]                INT            NULL,
    PRIMARY KEY CLUSTERED ([CustomerNoteKey] ASC)
);

