USE AccountOMS
go
if OBJECT_ID('vw_sprCSGWithParamAccount',N'V') is not null
	drop view vw_sprCSGWithParamAccount
go
create view vw_sprCSGWithParamAccount
as
select distinct m.code as MU,m.name,CASE WHEN a.accountSymbol=' ' THEN NULL ELSE a.accountSymbol END as AccountParam
from oms_NSI.dbo.tCSGroup m inner join oms_NSI.dbo.tAccountType a on
		m.rf_AccountTypeId=a.AccountTypeId
go