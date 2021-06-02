USE AccountOMSReports
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATETIME='20171123 23:59:59',
		@dtEndRegAkt DATETIME='20171123 23:59:59'
  
				
SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment,c.AmountPayment AS AmountPaymentAccepted,c.IsChildTariff, c.rf_idV014,SUM(m.Quantity) AS Quantity
INTO #tmpCases1
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase                  
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND c.rf_idV014<3 AND a.ReportMonth>0 AND a.ReportMonth<11 AND a.ReportYear=2017 AND m.MUGroupCode=71 
		AND a.rf_idSMO<>'34'
GROUP BY f.CodeM,c.id ,c.AmountPayment,c.IsChildTariff, c.rf_idV014

UPDATE c1 SET c1.AmountPaymentAccepted=c1.AmountPaymentAccepted-isnull(p.AmountDeduction,0)
FROM #tmpCases1 c1 INNER JOIN (
								SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase
								WHERE DateRegistration >= @dtBegin and DateRegistration <= @dtEndRegAkt
								GROUP BY rf_idCase
							) p ON 
					c1.rf_idCase=p.rf_idCase
SELECT   IDRow ,SUM(Quantity) ,SUM(AmountPaymentAccepted),SUM(QuantityChild) ,sum(AmountPaymentAcceptedChild)
FROM(
	SELECT 1 AS IDRow,SUM(Quantity) as Quantity,SUM(AmountPaymentAccepted) AmountPaymentAccepted, count(CASE WHEN IsChildTariff=1 THEN rf_idCase ELSE NULL END) QuantityChild,sum(CASE WHEN IsChildTariff=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS AmountPaymentAcceptedChild  
	FROM #tmpCases1 WHERE AmountPayment>0 AND AmountPaymentAccepted>0
	UNION ALL
	SELECT 1,SUM(Quantity),SUM(AmountPaymentAccepted), count(CASE WHEN IsChildTariff=1 THEN rf_idCase ELSE NULL END),sum(CASE WHEN IsChildTariff=1 THEN AmountPaymentAccepted ELSE 0.0 END)    
	FROM #tmpCases1 WHERE AmountPayment=0 AND AmountPaymentAccepted=0
	UNION ALL
	SELECT 2,SUM(Quantity),SUM(AmountPaymentAccepted), count(CASE WHEN IsChildTariff=1 THEN rf_idCase ELSE NULL END),sum(CASE WHEN IsChildTariff=1 THEN AmountPaymentAccepted ELSE 0.0 END)   
	FROM #tmpCases1 WHERE AmountPayment>0 AND AmountPaymentAccepted>0  AND rf_idV014=1
	UNION ALL
	SELECT 2,SUM(Quantity),SUM(AmountPaymentAccepted), count(CASE WHEN IsChildTariff=1 THEN rf_idCase ELSE NULL END),sum(CASE WHEN IsChildTariff=1 THEN AmountPaymentAccepted ELSE 0.0 END)    
	FROM #tmpCases1 WHERE AmountPayment=0 AND AmountPaymentAccepted=0  AND rf_idV014=1
	UNION ALL
	SELECT 3,SUM(Quantity),SUM(AmountPaymentAccepted), count(CASE WHEN IsChildTariff=1 THEN rf_idCase ELSE NULL END),sum(CASE WHEN IsChildTariff=1 THEN AmountPaymentAccepted ELSE 0.0 END)   
	FROM #tmpCases1 WHERE AmountPayment>0 AND AmountPaymentAccepted>0  AND rf_idV014=2
	UNION ALL
	SELECT 3,SUM(Quantity),SUM(AmountPaymentAccepted), count(CASE WHEN IsChildTariff=1 THEN rf_idCase ELSE NULL END),sum(CASE WHEN IsChildTariff=1 THEN AmountPaymentAccepted ELSE 0.0 END)    
	FROM #tmpCases1 WHERE AmountPayment=0 AND AmountPaymentAccepted=0  AND rf_idV014=2
 ) t
 GROUP BY IDRow

GO
DROP TABLE #tmpCases1