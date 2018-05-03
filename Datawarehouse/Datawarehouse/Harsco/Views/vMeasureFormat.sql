Create view harsco.vMeasureFormat
as
select 1 as FormatID, 'Decimal' as FormatName, '0.00' as FormatDefinition
union

select 2, 'Whole Number', '0'
union

select 3,  'Thousands', '0,0'

union

select 4, 'Millions',  '0,,'