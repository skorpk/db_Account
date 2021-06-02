use AccountOMS
go
if OBJECT_ID('vw_sprMU',N'V') is not null
drop view vw_sprMU
go
create view vw_sprMU
as
select cast(MUGroupCode as varchar(2))+'.'+cast(MUUnGroupCode as varchar(2))+'.'+cast(MUCode as varchar(3)) as MU,AdultUET,ChildUET,unitCode,unitName,
		MUGroupCode,MUUnGroupCode,MUCode
from oms_NSI.dbo.vw_sprMUAll
where MUGroupCodeP is null
go
if OBJECT_ID('vw_sprSMO',N'V') is not null
drop view vw_sprSMO
go
create view vw_sprSMO
as
select smocod,sNameF,sNameS
from oms_nsi.dbo.tSMO where smocod is not null
union
select '34','√Œ—”ƒ¿–—“¬≈ÕÕŒ≈ ”◊–≈∆ƒ≈Õ»≈ "“≈––»“Œ–»¿À‹Õ€… ‘ŒÕƒ Œ¡ﬂ«¿“≈À‹ÕŒ√Œ Ã≈ƒ»÷»Õ— Œ√Œ —“–¿’Œ¬¿Õ»ﬂ ¬ŒÀ√Œ√–¿ƒ— Œ… Œ¡À¿—“»"' as sNameF,
		'“‘ŒÃ— ¬ÓÎ„Ó„‡‰ÒÍÓÈ Ó·Î‡ÒÚË' as sNameS
go
if OBJECT_ID('vw_sprT001',N'V') is not null
drop view vw_sprT001
go
create view vw_sprT001
as
select * from oms_nsi.dbo.vw_sprT001 
go
if OBJECT_ID('vw_sprMUCompletedCase',N'V') is not null
drop view vw_sprMUCompletedCase
go
create view vw_sprMUCompletedCase
as
select cast(MUGroupCode as varchar(2))+'.'+cast(MUUnGroupCode as varchar(2))+'.'+cast(MUCode as varchar(3)) as MU,AdultUET,ChildUET,unitCode,unitName,
		Profile,AgeGroupShortName,cast(MUGroupCodeP as varchar(2))+'.'+cast(MUUnGroupCodeP as varchar(2))+'.'+cast(MUCodeP as varchar(3)) as MU_P,
		MUGroupCode,MUUnGroupCode,MUCode,MUGroupCodeP,MUUnGroupCodeP,MUCodeP,MUName
from oms_NSI.dbo.vw_sprMUAll
where MUGroupCodeP is not null
go
if OBJECT_ID('vw_sprFilial',N'V') is not null
drop view vw_sprFilial
go
create view vw_sprFilial
as
select FilialId,filialName
from OMS_NSI.dbo.tFilial
go
if OBJECT_ID('vw_Diagnosis',N'V') is not null
drop view vw_Diagnosis
go
create view vw_Diagnosis
as
select rf_idCase,max(case when TypeDiagnosis=1 then DiagnosisCode else null end) DS1,
		max(case when TypeDiagnosis=2 then DiagnosisCode else null end) DS0,
		max(case when TypeDiagnosis=3 then DiagnosisCode else null end) DS2		
from t_Diagnosis
group by rf_idCase
go
if OBJECT_ID('vw_unitName',N'V') is not null
drop view vw_unitName
go
create view vw_unitName
as
select PlanUnitId,unitCode,unitName from oms_NSI.dbo.tPlanUnit
go