USE AccountOMS
go
DECLARE @dateStart DATETIME='20190101',	--всегда с начало года
		@dateEnd DATETIME='20200125',
		@reportYear SMALLINT=2019

SELECT DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'	
--AND MainDS NOT IN('C80','C81','C82','C83','C84','C85','C86','C88','C90', 'C91','C92','C93','C94','C95','C96')

--DROP TABLE t_CasesOnkologia2018
----берем с диагнозом из списка
INSERT dbo.t_CasesOnkologia2018(rf_idCase,ENP,ReportYear)
SELECT DISTINCT c.id AS rf_idCase,ps.ENP,@reportYear
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN #tD dd ON
			d.DS1=dd.DiagnosisCode     										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient																		   					  					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006<4 AND f.TypeFile='H'

INSERT dbo.t_CasesOnkologia2018(rf_idCase,ENP,ReportYear)
SELECT DISTINCT c.id AS rf_idCase,ps.ENP,@reportYear
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN #tD dd ON
			d.DiagnosisCode=dd.DiagnosisCode     										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006<4 AND f.TypeFile='F'
GO
DROP TABLE #tD