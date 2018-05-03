
CREATE procedure [dbo].[RunDWLoad]
as
begin


exec dbo.MergeDimPaymentTerms;
Exec [dbo].[MergeLkpExchangeRate];
Exec [dbo].[MergeDimCustomer];
Exec [dbo].[MergeDimCustomerLocation];
Exec [dbo].[MergeDimOrganization];
Exec [dbo].[MergeFactARInvoices];
exec dbo.MergeFactARReceipts;
Exec [dbo].[MergeFactARAdjustments];
Exec [dbo].[MergeFactARging];
Exec [dbo].[MergeFactARProjection];
Exec [dbo].[MergeFactCustomerNotes];
EXEC dbo.SSISSysLogMaintenance;

end