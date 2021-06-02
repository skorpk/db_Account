USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME='20200118',
		@dateEndReg3 DATETIME='20200122',
		@reportYear SMALLINT=2019


SELECT * FROM oms_nsi.dbo.V001 WHERE IDRB='A16.23.034.013'

SELECT distinct c.id AS rf_idCase, c.AmountPayment,p.ENP, a.ReportYear,a.rf_idSMO,f.CodeM,c.AmountPayment AS AmountPayment2
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND m.MUSurgery='A16.23.034.013'		


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg3
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT 'Волгоградская область'
		,COUNT(DISTINCT rf_idCase) AS Case2019
		,CAST(sum( AmountPayment) as money) AS Amount2019
		,COUNT(DISTINCT ENP) AS ENP
FROM #tCases
WHERE AmountPayment>0 AND rf_idSMO<>'34'
UNION ALL
SELECT 'Другой регион'
		,COUNT(DISTINCT rf_idCase) AS Case2019
		,CAST(ISNULL(SUM(ISNULL(AmountPayment,0.0) ),0.0) as money) AS Amount2019
		,COUNT(DISTINCT ENP) AS ENP
FROM #tCases
WHERE AmountPayment>0 AND rf_idSMO='34'

GO 
DROP TABLE #tCases
