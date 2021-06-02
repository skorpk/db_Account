USE AccountOMS
go
if OBJECT_ID('vw_sprMuWithParamAccount',N'V') is not null
	drop view vw_sprMuWithParamAccount
go
create view vw_sprMuWithParamAccount
as
select distinct MUGroupCode,m.MUUnGroupCode,m.MUCode
		,cast(m.MUGroupCode as varchar(2))+'.'+cast(m.MUUnGroupCode as varchar(2))+'.'+cast(m.MUCode as varchar(3)) as MU
		,m.MUName
		,CASE WHEN a.accountSymbol=' ' THEN NULL ELSE a.accountSymbol END as AccountParam
from oms_NSI.dbo.vw_sprMU m inner join oms_NSI.dbo.tAccountType a on
		m.rf_AccountTypeId=a.AccountTypeId
go