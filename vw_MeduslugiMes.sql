use AccountOMS
go
if OBJECT_ID('vw_MeduslugiMes',N'V') is not null
	drop view vw_MeduslugiMes
go
create view vw_MeduslugiMes
as
select m.rf_idCase,cast(m.MUCode as varchar(2))+'.'+cast(m.MUUnGroupCode as varchar(2))+'.'+cast(m.MUCode as varchar(3)) as MUCode
		,m.IsChildTariff,m.Quantity,m.Price,m.rf_idV002
from t_Meduslugi m
union all
select mes.rf_idCase,mes.MES as MUCode,c.IsChildTariff,mes.Quantity,mes.Tariff,c.rf_idV002
from t_MES mes inner join t_Case c on
		mes.rf_idCase=c.id
go
create nonclustered index IX_Mes_Case_Quantity on dbo.t_Mes(rf_idCase)
INCLUDE(MES,Quantity,Tariff) with drop_existing