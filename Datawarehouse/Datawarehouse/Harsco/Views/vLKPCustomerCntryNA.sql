



--DROP VIEW [Harsco].[vLKPCustomerCntryNA] ;

CREATE VIEW [Harsco].[vLKPCustomerCntryNA]
AS
(
select 
distinct Dc.customerkey customerkey,
(CASE 
WHEN Dc.CustomerAccountNumber='9492' then'United States'
WHEN Dc.CustomerAccountNumber='6978'then'United States'
WHEN Dc.CustomerAccountNumber='7568'then'United States'
ELSE DCntry.Country_name END)  Country,
(CASE 
WHEN Dc.CustomerAccountNumber='9492' then'North America'
WHEN Dc.CustomerAccountNumber='6978'then'North America'
WHEN Dc.CustomerAccountNumber='7568'then'North America'
ELSE DCntry.Country_name END)  Region,
DOrg.Division Division
 from 
 Harsco.DimCustomer DC,
 Harsco.FactARInvoices FInv,
 Harsco.DimOrganization DOrg,
 Harsco.DimCustomerLocation DCustLoc,
 Harsco.vCountryCodes DCntry
where 
    DC.CustomerKey=Finv.AccountCustomerKey 
and Finv.organizationkey=DOrg.organizationkey
and Finv.BillToCustomerLocationKey=DCustLoc.CustomerLocationKey
and DCustLoc.Country=DCntry.Country
and DOrg.Division='Metals and Minerals'

)
	
/****** Raj -- Script for NA Customer Country information for Customer Notes reporting ******/

