CREATE   procedure [dbo].[MergeDimPaymentTerms] as
/*******************************************************************************************************************
** Procedure Name: MergeDimPaymentTerms
** Desc:
** Auth: Gene Furibondo
** Date: 09/24/2017
********************************************************************************************************************
** Change History
--------------------------------------------------------------------------------------------------------------------
** PR   Date        Author				Description 
** --   --------   -------				------------------------------------
** 1    09/27/2017  Dhilasu Reddy       Added Inline Comments
********************************************************************************************************************/


--***********************************************************************************************************************
--1. Calling the 'CreateDimensionUnknownRow' stored procedure to ensure that a -1 record is present
--***********************************************************************************************************************

EXEC	[dbo].[CreateDimensionUnknownRow]
		@TableName = DimPaymentTerms,
		@TableSchema = harsco,
		@Action = N'1'


--***********************************************************************************************************************
--2. Source - Oracle
--   Merge and Insert the Data where Source and Target data are not Matched ,
--   Merge and update the Data where Source and Target data are Matched
--***********************************************************************************************************************
BEGIN TRAN;
MERGE Harsco.DimPaymentTerms AS T
USING (
 select [TERM_ID], [NAME], [DESCRIPTION], cast(cast(cast(Due_Days as nvarchar(100)) as numeric(18,0)) as int) as Due_Days, sourcesystemid
 from 
[stg].[Oracle_RA_Terms]
)
 AS S
ON (T.PaymentTermsID	 = Convert(nvarchar(max),S.Term_ID )and t.sourcesystemid = s.sourcesystemid) 
WHEN NOT MATCHED BY TARGET 
    THEN INSERT(
[PaymentTermsID]
,[PaymentTermsDays]
,[PaymentTermsDescription]
,[PaymentTermsName]
,SourceSystemID
	,[CreatedDateTime]
,[LastUpdatedDateTime]
,[EffectiveStartDate]
,[EffectiveEndDate]
,[CurrentRecordIndicator] )
values (Convert(nvarchar(max),S.Term_ID ), [Due_Days], [DESCRIPTION], [NAME], SourceSystemID
--start audit columns
,getdate(), getdate(), '2099-01-01', '2099-01-01', 1)
WHEN MATCHED AND t.sourcesystemID =S.sourcesystemID
    THEN UPDATE SET t.PaymentTermsID = Convert(nvarchar(max),S.Term_ID ) -- no sourcesystemID
				,t.[PaymentTermsDays] = [Due_Days]
				,t.[PaymentTermsDescription] = [DESCRIPTION]
				,t.[PaymentTermsName] = [NAME]	;
	;

;

commit tran 

--***********************************************************************************************************************
--2. Source - JDEdwards
--   Merge and Insert the Data where Source and Target data are not Matched ,
--   Merge and update the Data where Source and Target data are Matched
--***********************************************************************************************************************

BEGIN TRAN;
MERGE Harsco.DimPaymentTerms AS T
USING (
 select PNPTC, PNPTD,  cast(PNNDTP as int) as PNNDTP, d_sourcesystemid
 from 
[stg].[JDE_F0014]
where rtrim(ltrim(pnptc)) is not null
)
 AS S
ON (T.PaymentTermsID	 = S.PNPTC AND t.sourcesystemID = S.d_sourcesystemID) 
WHEN NOT MATCHED BY TARGET 
    THEN INSERT(
[PaymentTermsID]
,[PaymentTermsDays]
,[PaymentTermsDescription]
,[PaymentTermsName]
,SourceSystemID
	,[CreatedDateTime]
,[LastUpdatedDateTime]
,[EffectiveStartDate]
,[EffectiveEndDate]
,[CurrentRecordIndicator] )
values (Convert(nvarchar(max),PNPTC),PNNDTP, PNPTD, PNPTD, d_sourcesystemid
--start audit columns
,getdate(), getdate(), '2099-01-01', '2099-01-01', 1)
WHEN MATCHED AND t.sourcesystemID = S.d_sourcesystemID
    THEN UPDATE SET t.PaymentTermsID = Convert(nvarchar(max),S.PNPTC)
					,t.[PaymentTermsDays] = PNNDTP
					,t.[PaymentTermsDescription] = PNPTD
					,t.[PaymentTermsName] = PNPTD	;

;

commit tran