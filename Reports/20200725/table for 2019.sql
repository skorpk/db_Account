USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME='20200125',
		@reportYear SMALLINT=2019


SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,c.rf_idV006 AS USL_OK,c.rf_idRecordCasePatient,pp.rf_idV005 AS Sex, d.flag,f.TypeFile, 1 AS TypeDs
	,@reportYear AS ReportYear,cc.id AS rf_idCompletedCase
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN oms_nsi.dbo.tmp_DS2report202007 d ON
             dd.DiagnosisCode=d.йнд					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear  AND  a.rf_idSMO<>'34'  AND dd.TypeDiagnosis=1 AND age>16 AND c.rf_idV006<4


INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,c.rf_idV006 AS USL_OK,c.rf_idRecordCasePatient,pp.rf_idV005 AS Sex, d.flag,f.TypeFile,2
		,@reportYear AS ReportYear,cc.id AS rf_idCompletedCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase																
					INNER JOIN oms_nsi.dbo.tmp_DS2report202007 d ON
			dd.DiagnosisCode=d.йнд
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear  AND  a.rf_idSMO<>'34' AND f.TypeFile='F' AND dd.TypeDiagnosis<>1 AND age>16


INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,c.rf_idV006 AS USL_OK,c.rf_idRecordCasePatient,pp.rf_idV005 AS Sex, d.flag,f.TypeFile,2, @reportYear AS ReportYear,cc.id AS rf_idCompletedCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase					
					INNER JOIN oms_nsi.dbo.tmp_DS2report202007 d ON
             dd.DiagnosisCode=d.йнд											
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND  a.rf_idSMO<>'34' AND f.TypeFile='F'  AND age>16

DELETE FROM #t WHERE Age<18

SELECT	rf_idCase,
        AmountPayment,
        CodeM,
        ENP,
        Age,
        USL_OK,
        rf_idRecordCasePatient,
        Sex,
        flag,
        TypeFile,
        TypeDs,
        ReportYear,
        rf_idCompletedCase
INTO t_CaseDN_2019
FROM #t 
GO
DROP TABLE #t