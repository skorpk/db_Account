USE AccountOMSReports
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20200512',
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME='20200512',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=5


SELECT DiagnosisCode ,MainDS INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'I%'

CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tDiag(DiagnosisCode)

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,dd.DS1,c.rf_idRecordCasePatient,f.DateRegistration,a.ReportMonth,pv.DN
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DS1=d.DiagnosisCode
					inner JOIN t_PurposeOfVisit pv ON
             c.id=pv.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND f.TypeFile='H'
	 AND c.rf_idV006 =3 AND pv.rf_idV025='1.3' AND pv.DN IN (1,2) AND c.Age>17

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,dd.DiagnosisCode,c.rf_idRecordCasePatient,f.DateRegistration,a.ReportMonth,c.IsNeedDisp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND f.TypeFile='F'
	 AND c.rf_idV006 =3 AND c.IsNeedDisp IN(1,2) AND c.Age>17

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,dd.DiagnosisCode,c.rf_idRecordCasePatient,f.DateRegistration,a.ReportMonth,dd.IsNeedDisp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND f.TypeFile='F'
	 AND c.rf_idV006 =3 AND dd.IsNeedDisp IN(1,2) AND c.Age>17

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT ENP,DS1,DN,rf_idCase,DateRegistration,CAST(NULL AS INT) AS rf_D02Person,ReportMonth
INTO dbo.tmp_DN_I
FROM #tCases 
WHERE AmountPayment>0
GO
DROP TABLE #tCases
GO
DROP TABLE #tDiag
GO
--DROP TABLE dbo.tmp_DN_I