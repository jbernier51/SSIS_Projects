
create view [Harsco].[vDimOrganization]
as
select * from harsco.dimorganization do
--where exists (select organizationkey from harsco.factarinvoices fi where do.organizationkey = fi.organizationkey)