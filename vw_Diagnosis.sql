USE AccountOMS
if OBJECT_ID('vw_Diagnosis',N'V') is not null
drop view vw_Diagnosis
go
create view vw_Diagnosis
as
select rf_idCase,max(case when TypeDiagnosis=1 then DiagnosisCode else null end) DS1,
		max(case when TypeDiagnosis=2 then DiagnosisCode else null end) DS0,
		max(case when TypeDiagnosis=3 then DiagnosisCode else null end) DS2,		
		max(case when TypeDiagnosis=4 then DiagnosisCode else null end) DS3
from t_Diagnosis
group by rf_idCase
go