USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME=GETDATE(),
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=8


CREATE TABLE #tDiag(DiagnosisCode varchar(10))

INSERT #tDiag(DiagnosisCode) VALUES('U07.1'),('U07.2')


SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,c.rf_idRecordCasePatient,c.rf_idV006 AS USL_OK,f.CodeM,ps.ENP,c.rf_idV009,c.KD,a.ReportMonth
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
             ps.rf_idRecordCasePatient = r.id
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase	
					INNER JOIN #tDiag d ON
            dd.DiagnosisCode=d.DiagnosisCode					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006=1  AND a.ReportMonth<=@reportMonth 
		AND dd.TypeDiagnosis IN(1,3)

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT COUNT(DISTINCT rf_idRecordCasePatient) FROM #tCases 

SELECT ReportMonth,COUNT(DISTINCT ENP) AS Col1
	,count(DISTINCT CASE WHEN rf_idV009 IN(105,106) THEN rf_idCase ELSE NULL END) AS Col2
	,0 AS Col3
	,sum(DISTINCT CASE WHEN rf_idV009 IN(105,106) THEN KD ELSE 0 END) AS Col4
FROM #tCases WHERE AmountPayment>0 GROUP BY ReportMonth
ORDER BY ReportMonth

SELECT rf_idCase, kd
FROM #tCases
WHERE AmountPayment>0 AND rf_idV009 IN(105,106) 

GO
DROP TABLE #tCases
GO
DROP TABLE #tDiag