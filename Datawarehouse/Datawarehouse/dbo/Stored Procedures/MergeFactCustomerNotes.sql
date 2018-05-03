



create   procedure [dbo].[MergeFactCustomerNotes]
as


truncate table [Harsco].[FactCustomerNotes]


begin tran

merge [Harsco].FactCustomerNotes as T
using 
(
select 
[ROW_ID],
[NOTES],
[NOTE_STATUS],
[NOTE_STATUS_MEANING],
[NOTE_TYPE],
[NOTE_TYPE_MEANING],
dc.customerkey,
[CREATION_DATE],
[CREATED_BY_NAME]
,Last_Update_Date
,dd.datekey
from 
[stg].[Oracle_AST_Notes] cn
inner join harsco.dimcustomer dc
on cn.[OBJECT_ID_NAME] = dc.customeraccountnumber
inner join harsco.dimdate dd
on cast(cast(cn.[CREATION_DATE] as date) as datetime) = dd.fulldate

) S

on (t.CustomerNoteID  = s.[ROW_ID] 
)

WHEN NOT MATCHED BY TARGET --AND S.EmployeeName LIKE 'S%' 
    THEN INSERT(
[CustomerNoteID]
,[CustomerKey]
,[NoteDateKey]
,[NoteType]
,[NoteText]
,CreatedByUser
,[NoteLastUpdatedDateTime]
,[CreatedDateTime]
,[LastUpdatedDateTime]
,[EffectiveStartDate]
,[EffectiveEndDate]
,[CurrentRecordIndicator]
--,sourcesystemid

)
values
(row_id,
customerkey, 
datekey,
note_type_meaning, 
notes
,[CREATED_BY_NAME]
,Last_Update_Date

,getdate(), getdate()
, '2099-01-01', '2099-01-01'
, 1--,-- sourcesystemid
)

WHEN MATCHED 
    THEN UPDATE SET T.CustomerNoteID = s.row_id
	;
--WHEN NOT MATCHED BY SOURCE AND T.EmployeeName LIKE 'S%'
  --  THEN DELETE 
--OUTPUT $action, inserted.*, deleted.*;
--ROLLBACK TRAN;

commit tran




EXEC	[dbo].[CreateDimensionUnknownRowCustNote]
		@TableName = FactCustomerNotes,
		@TableSchema = harsco,
		@Action = N'1'





--select * from [Harsco].[FactARReceipts] where invoicekey <> -1


--select * from [Harsco].[FactARAging]