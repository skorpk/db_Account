USE AccountOMS
go

if OBJECT_ID('usp_SecurityService',N'P') is not null
drop procedure usp_SecurityService
go
create procedure usp_SecurityService
			@dateStart datetime,
			@dateEnd datetime,
			@reportYear smallint,
			@reportMonthStart tinyint,
			@reportMonthEnd tinyint
as
select ROW_NUMBER() over(order by l.CodeM,a.DateRegister,a.Account,idRecordCase asc) as id,l.CodeM,l.NameS,a.Account,a.DateRegister
		,c.idRecordCase,p.Fam,p.Im,p.Ot,
		p.Sex,p.BirthDay,pd.SeriaDocument,pd.NumberDocument,pd.SNILS
		,r.SeriaPolis,r.NumberPolis
		,c.DateBegin, c.DateEnd, mkb.DiagnosisCode, mkb.Diagnosis
from t_File f inner join t_RegistersAccounts a on
		f.id=a.rf_idFiles
		and a.ReportYear=@reportYear
		and a.ReportMonth>=@reportMonthStart 
		and a.ReportMonth<=@reportMonthEnd
		and f.DateRegistration>=@dateStart and f.DateRegistration<=@dateEnd
			inner join vw_sprT001 l on
		f.CodeM=l.CodeM
			inner join t_RecordCasePatient r on
		a.id=r.rf_idRegistersAccounts			
			inner join t_Case c on
		r.id=c.rf_idRecordCasePatient
			inner join t_RegisterPatient p on
		r.id=p.rf_idRecordCase
		and p.rf_idFiles=f.id
			inner join vw_Diagnosis d on
		c.id=d.rf_idCase
			inner join oms_nsi.dbo.sprMKB mkb on
		d.DS1=mkb.DiagnosisCode
			left join t_RegisterPatientDocument pd on
		p.id=pd.rf_idRegisterPatient
go