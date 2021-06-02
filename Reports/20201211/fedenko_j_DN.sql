USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200101',
		@dateEnd DATETIME='20201210',
		@dateEndPay DATETIME='20201210'

SELECT DiagnosisCode INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J12' and 'J16'
UNION ALL
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS ='J18'


SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, cc.id AS rf_idCompletedCase,cc.AmountPayment AS AmmPay,ENP,a.rf_idSMO AS CodeSMO
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient												
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase	
					INNER JOIN #tDiag dd ON
			d.DiagnosisCode=dd.DiagnosisCode				
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth<12 AND c.rf_idV006<4 AND d.TypeDiagnosis IN(1,3)
	AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=2 AND m.MUUnGroupCode=88 AND m.MUCode BETWEEN 52 AND 77 
				UNION ALL
				SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=2 AND m.MUUnGroupCode=88 AND m.MUCode =110 )

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
DELETE FROM #tCases WHERE AmountPayment=0.0

SELECT c.CodeM+' - '+l.NAMES AS LPU,COUNT(DISTINCT c.ENP) AS CountENP
FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
GROUP BY c.CodeM+' - '+l.NAMES
ORDER BY LPU
GO
DROP TABLE #tCases
GO
DROP TABLE #tDiag