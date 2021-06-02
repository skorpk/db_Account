USE AccountOMS
GO
DECLARE @reportMonth TINYINT=5,
		@reportYear SMALLINT=2019,
		@dateStart DATETIME='20190101',
		@dateEnd DATETIME=GETDATE()

SELECT rf_idSMO, LPU,rf_idRecordCasePatient, rf_idCase, AmountPayment, AmountPayment AS AmountPaymentAcc, CAST(0.0 AS DECIMAL(15,2)) AS AmountPaid INTO #tCases 
FROM dbo.t_260order_ONK 
WHERE [MONTH]=@reportMonth AND [YEAR]=@reportYear
UNION ALL
SELECT rf_idSMO,LPU,rf_idRecordCasePatient, rf_idCase, AmountPayment,AmountPayment,CAST(0.0 AS DECIMAL(15,2)) 
FROM dbo.t_260order_VMP 
WHERE [MONTH]=@reportMonth AND [YEAR]=@reportYear


UPDATE p SET p.AmountPaymentAcc=p.AmountPaymentAcc-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEnd	
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

UPDATE p SET p.AmountPaid=AmountPaymentAccept
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountPaymentAccept) AS AmountPaymentAccept
								FROM dbo.t_PaidCase c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEnd	
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT l.CodeM+' - '+ l.NAMES, rf_idSMO,COUNT(DISTINCT rf_idRecordCasePatient) AS Col1
		,COUNT( DISTINCT CASE WHEN c.AmountPaid>0 THEN rf_idRecordCasePatient ELSE NULL END) AS Col2
		,SUM(c.AmountPaymentAcc) AS Col3, SUM(c.AmountPaid) AS Col4
FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON
		c.LPU=l.CodeM
GROUP BY l.CodeM+' - '+ l.NAMES,rf_idSMO
ORDER BY l.CodeM+' - '+ l.NAMES,rf_idSMO

go

DROP TABLE #tCases
