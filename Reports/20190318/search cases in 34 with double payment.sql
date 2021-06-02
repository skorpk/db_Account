USE AccountOMSReports
GO
SELECT f.CodeM,a.Account, cc.id,cc.AmountPayment,CAST(0.0 AS DECIMAL(15,2)) AS AmountPaymentAcc
INTO #tCase34
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case cc ON
			r.id=cc.rf_idRecordCasePatient                  
WHERE f.DateRegistration>'20180101' AND a.ReportYear=2018 AND a.rf_idSMO='34002' AND Letter<>'E'

UPDATE c SET AmountPaymentAcc=AmountPayment-p.AmountPaymentAccept
FROM #tCase34 c INNER JOIN (
							SELECT rf_idCase,SUM(AmountDeduction) AS AmountPaymentAccept FROM dbo.t_PaymentAcceptedCase2 WHERE DateRegistration>'20190101'	GROUP BY rf_idCase
							) p ON
		c.id=p.rf_idCase                            

SELECT *
FROM #tCase34 WHERE AmountPaymentAcc<0
GO
DROP TABLE #tCase34