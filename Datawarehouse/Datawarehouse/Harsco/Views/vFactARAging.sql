
create view [Harsco].[vFactARAging]
as

select ag.*, dd.fulldate as AgingDate, DATEADD(month, DATEDIFF(month, 0, dateadd(d, -1, fulldate)), 0) as PriorMonthAgingDate from 

harsco.FactARAging ag
inner join harsco.dimdate dd
on ag.AgingDateKey = dd.DateKey