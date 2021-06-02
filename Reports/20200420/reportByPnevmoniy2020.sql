USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20200411',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=3



SELECT 1 AS TypeDiag,DiagnosisCode 
INTO #tDiag
FROM dbo.vw_sprMKB10 WHERE LEFT(DiagnosisCode,5) IN('J12.1','J12.2','J12.3','J12.8','J12.9','J13','J14','J15.0','J15.1','J15.2','J15.3','J15.4','J15.5','J15.6','J15.7','J15.8','J15.9',
													'J16.0','J16.8','J17.0','J17.1','J17.2','J17.3','J17.8','J18.0','J18.1','J18.2','J18.8','J18.9')
INSERT #tDiag SELECT 2,DiagnosisCode FROM dbo.vw_sprMKB10 WHERE LEFT(DiagnosisCode,5) IN('J17.0','J17.1','J17.2','J17.3','J17.8')


SELECT c.id AS rf_idCase, c.AmountPayment,c.rf_idv008,f.CodeM,c.rf_idRecordCasePatient,dd.DS1,c.rf_idV006 AS USL_OK
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase	
					INNER JOIN #tDiag d ON
            dd.DS1=d.DiagnosisCode
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006<3  AND a.ReportMonth<=@reportMonth 
		AND d.TypeDiag=1

INSERT #tCases
SELECT c.id AS rf_idCase, c.AmountPayment,c.rf_idv008,f.CodeM,c.rf_idRecordCasePatient,dd.DiagnosisCode,c.rf_idV006 AS USL_OK
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase	
					INNER JOIN #tDiag d ON
            dd.DiagnosisCode=d.DiagnosisCode
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006<3  AND a.ReportMonth<=@reportMonth 
		AND d.TypeDiag=2 AND dd.TypeDiagnosis>1

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<'20200411' 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT 2020,c.DS1,COUNT(c.rf_idCase) AS CountCase,cast(SUM(c.AmountPayment) AS money) AS AmountPayment
FROM #tCases c 
WHERE c.AmountPayment>0 AND c.USL_OK=1
GROUP BY c.DS1
ORDER BY DS1

SELECT 2020,c.DS1,COUNT(c.rf_idCase) AS CountCase,cast(SUM(c.AmountPayment) AS money) AS AmountPayment
FROM #tCases c 
WHERE c.AmountPayment>0 AND c.USL_OK=2
GROUP BY c.DS1
ORDER BY DS1
GO
DROP TABLE #tDiag
GO
DROP TABLE #tCases