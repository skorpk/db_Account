USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME='20200121',
		@dateEndReg3 DATETIME='20200123',
		@reportYear SMALLINT=2019

		
SELECT distinct c.id AS rf_idCase, c.AmountPayment,c.rf_idRecordCasePatient,c.rf_idV006,c.AmountPayment AS AmountPaymentMO
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear 


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction,2018 AS reportYear
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg3
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT v6.id,v6.name,COUNT(DISTINCT c.rf_idRecordCasePatient) AS CountCC
FROM #tCases c INNER JOIN vw_sprV006 v6 ON
		c.rf_idV006=v6.id
WHERE (CASE WHEN c.AmountPaymentMO>0 AND c.AmountPayment>0 THEN 1 WHEN c.AmountPaymentMO=0 AND c.AmountPayment=0 THEN 1 ELSE 0 END)=1
GROUP BY v6.id,v6.name
ORDER BY id

SELECT COUNT(DISTINCT c.rf_idRecordCasePatient) AS CountCC
FROM #tCases c INNER JOIN vw_sprV006 v6 ON
		c.rf_idV006=v6.id
WHERE (CASE WHEN c.AmountPaymentMO>0 AND c.AmountPayment>0 THEN 1 WHEN c.AmountPaymentMO=0 AND c.AmountPayment=0 THEN 1 ELSE 0 END)=1
GO
DROP TABLE #tCases
			