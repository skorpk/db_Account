USE AccountOMS
GO
CREATE TABLE #tPeople(rf_idCase BIGINT,					  					  
					  AmountPayment DECIMAL(11,2),
					  Age tinyint					  					  	
					  )
INSERT #tPeople (rf_idCase,Age,AmountPayment) 	
SELECT c.id, c.Age,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				  
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
WHERE f.DateRegistration>'20161001' AND f.DateRegistration<GETDATE() AND a.ReportMonth>9 AND a.ReportMonth<=12 AND a.ReportYear=2016 AND rf_idV002='158'
	AND f.CodeM='101001'

SELECT COUNT(rf_idCase),SUM(AmountPayment)
FROM #tPeople

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction 
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase a 
							WHERE DateRegistration>='20161001' AND DateRegistration<GETDATE()
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT COUNT(rf_idCase),SUM(AmountPayment)
FROM #tPeople
WHERE AmountPayment>0
GO
DROP TABLE #tPeople