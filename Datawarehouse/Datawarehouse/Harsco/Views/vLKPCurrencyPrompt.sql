-- =================================================================================
-- Create View template for Azure SQL Database and Azure SQL Data Warehouse Database
-- =================================================================================

create view harsco.vLKPCurrencyPrompt

as

select 'Local Currency' as CurrencyType

union

select 'USD'