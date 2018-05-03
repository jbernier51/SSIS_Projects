



CREATE procedure [dbo].[RunDWTruncate]
as
begin

truncate table [Harsco].[LKPExchangeRate]
truncate table harsco.dimorganization
truncate table harsco.dimcustomer
truncate table harsco.dimcustomerlocation
truncate table harsco.dimpaymentterms
truncate table harsco.factaradjustments
truncate table [Harsco].[FactARInvoices]
-- Remove Comment by JBE - Prem has put a logic to handle the list of period to calculate
truncate table [Harsco].[FactARAging]
truncate table [Harsco].[FactARReceipts]
-- Commented by Prem to avoid purging previous periods projection data
--truncate table [Harsco].[FactARProjections]
truncate table [Harsco].[FactARAdjustments]

end
