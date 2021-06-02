USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20180101',
		@dateEndReg DATETIME='20190122',

		@dateStartReg2 DATETIME='20190101',
		@dateEndReg2 DATETIME='20200118',

		@dateEndReg3 DATETIME='20200122',
		@reportYear SMALLINT=2018,
		@reportYear2 SMALLINT=2019

		
SELECT distinct c.id AS rf_idCase, c.AmountPayment,p.ENP, a.ReportYear,a.rf_idSMO
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006=1 
	AND m.MUSurgery IN('B01.001.006','B01.001.009','B02.001.002','A16.20.005') AND f.CodeM='176001'
UNION ALL
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.ReportYear,a.rf_idSMO
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
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND c.rf_idV006=1 
AND m.MUSurgery IN('B01.001.006','B01.001.009','B02.001.002','A16.20.005') AND f.CodeM='176001'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction,2018 AS reportYear
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
			AND r.reportYear = p.ReportYear

			UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction,2019 AS reportYear
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg2 AND c.DateRegistration<@dateEndReg3
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
			AND r.reportYear = p.ReportYear

SELECT 'наши',COUNT(CASE WHEN ReportYear=2018 THEN rf_idCase ELSE NULL END) AS Case2018
		,COUNT(CASE WHEN ReportYear=2019 THEN rf_idCase ELSE NULL END) AS Case2019
		,CAST(sum(CASE WHEN ReportYear=2018 THEN AmountPayment ELSE 0.0 END) as money) AS Amount2018
		,CAST(sum(CASE WHEN ReportYear=2019 THEN AmountPayment ELSE 0.0 END) as money) AS Amount2019
FROM #tCases
WHERE AmountPayment>0 AND rf_idSMO<>'34'
UNION ALL
SELECT 'Иногородние',COUNT(CASE WHEN ReportYear=2018 THEN rf_idCase ELSE NULL END) AS Case2018
		,COUNT(CASE WHEN ReportYear=2019 THEN rf_idCase ELSE NULL END) AS Case2019
		,CAST(sum(CASE WHEN ReportYear=2018 THEN AmountPayment ELSE 0.0 END) as money) AS Amount2018
		,CAST(sum(CASE WHEN ReportYear=2019 THEN AmountPayment ELSE 0.0 END) as money) AS Amount2019
FROM #tCases
WHERE AmountPayment>0 AND rf_idSMO='34'

GO 
DROP TABLE #tCases
