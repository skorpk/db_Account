USE RegisterCases
GO
SELECT f.CodeM,a.Account,rp.Fam+' '+rp.Im+' '+ISNULL(rp.Ot,'') AS FIO,rp.BirthDay,rp.Sex,c.DateEnd
FROM dbo.t_Case_PID_ENP ce INNER JOIN dbo.t_Case c ON
				ce.rf_idCase=c.id
							INNER JOIN dbo.t_RecordCasePatient r ON
				c.rf_idRecordCasePatient=r.id
							INNER JOIN dbo.t_RegistersAccounts a ON
				r.rf_idRegistersAccounts=a.id
							INNER JOIN dbo.t_File f ON
				a.rf_idFiles=f.id
							INNER JOIN dbo.t_RegisterPatient rp ON
				f.id=rp.rf_idFiles
				AND r.id=rp.rf_idRecordCase
WHERE f.DateRegistration>'20140101'	AND f.DateRegistration<'20141028' AND a.ReportMonth>0 AND a.ReportMonth<10 AND a.ReportYear=2014
		AND ce.PID IS null		
GROUP BY f.CodeM,a.Account,rp.Fam+' '+rp.Im+' '+ISNULL(rp.Ot,'') ,rp.BirthDay,rp.Sex,c.DateEnd
 
 /*
declare @t as TVP_Insurance

INSERT @t
SELECT distinct c.id,case when r.rf_idF008=3 then r.SeriaPolis else null end,rp.Fam,rp.Im,rp.Ot,rp.BirthDay,rp.BirthPlace,pd.SNILS,null,pd.NumberDocument,null,
		c.DateEnd
FROM AccountOMS.dbo.t_Case_PID_ENP ce INNER JOIN AccountOMS.dbo.t_Case c ON
				ce.rf_idCase=c.id
							INNER JOIN AccountOMS.dbo.t_RecordCasePatient r ON
				c.rf_idRecordCasePatient=r.id
							INNER JOIN AccountOMS.dbo.t_RegistersAccounts a ON
				r.rf_idRegistersAccounts=a.id
							INNER JOIN AccountOMS.dbo.t_File f ON
				a.rf_idFiles=f.id
							INNER JOIN AccountOMS.dbo.t_RegisterPatient rp ON
				f.id=rp.rf_idFiles
				AND r.id=rp.rf_idRecordCase
							left join AccountOMS.dbo.t_RegisterPatientDocument pd on
				rp.id=pd.rf_idRegisterPatient
WHERE f.DateRegistration>'20140101'	AND f.DateRegistration<'20141028' AND a.ReportMonth>0 AND a.ReportMonth<10 AND a.ReportYear=2014
		AND ce.PID IS null		


create table #tPeople
(
	rf_idRefCaseIteration bigint,
	PID int,
    DateEnd DATE,
    IsDelete TINYINT,
    DateBegin DATE
)
exec dbo.usp_GetPID @t
--фильтрация умершил людей.
SELECT rf_idRefCaseIteration,PID INTO AccountOMS.dbo.tmp_PeopleIteration2 FROM #tPeople

go
DROP TABLE #tPeople

*/


