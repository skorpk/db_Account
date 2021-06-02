USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200801',
		@dateEnd DATETIME='20210501',
		@dateEndPay DATETIME=GETDATE(),
		@reportPeriodStart int=202008,
		@reportPeriodEnd int=202104
/*
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, c.AmountPayment,c.rf_idRecordCasePatient,d.DiagnosisCode,p.ENP
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					JOIN dbo.tmp_FFOMS_O fo ON
            p.ENP=fo.ENP2
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient											
					JOIN dbo.t_Diagnosis d ON
            c.id=d.rf_idCase
			AND d.TypeDiagnosis=1
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYearMonth BETWEEN @reportPeriodStart AND @reportPeriodEnd 
AND c.rf_idV006<4 AND f.TypeFile='H' AND c.rf_idV008<>32 AND d.DiagnosisCode LIKE 'O%' AND fo.enp2 IS NOT NULL
*/
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, c.AmountPayment,c.rf_idRecordCasePatient,d.DiagnosisCode,ps.ENP
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					JOIN dbo.t_RegisterPatient p ON
            r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles
					JOIN dbo.tmp_FFOMS_O fo ON
            p.Fam=fo.FAM
			AND p.Im=fo.IM
			AND p.Ot=fo.OT
			AND fo.BirthDay = p.BirthDay
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient											
					JOIN dbo.t_Diagnosis d ON
            c.id=d.rf_idCase
			AND d.TypeDiagnosis=1
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYearMonth BETWEEN @reportPeriodStart AND @reportPeriodEnd 
AND c.rf_idV006<4 AND f.TypeFile='H' AND c.rf_idV008<>32 AND d.DiagnosisCode LIKE 'O%' --AND fo.enp2 IS NULL


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE AmountPayment=0.0

SELECT * FROM #tCases

SELECT COUNT(DISTINCT ENP) FROM #tCases
GO
DROP TABLE #tCases