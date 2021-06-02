USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME='20191205',
		@reportYear SMALLINT=2019

SELECT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.rf_idSMO, CAST(0.0 AS DECIMAL(15,2)) AS AmountPaid
INTO #tCasesDisp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient	
					INNER JOIN dbo.t_DispInfo d ON
			c.id=d.rf_idCase															                 
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.Letter ='O' AND d.TypeDisp IN('ÄÂ1','ÄÂ3')


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCasesDisp p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

UPDATE p SET p.AmountPaid=r.AmountPaymentAccept
FROM #tCasesDisp p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountPaymentAccept) AS AmountPaymentAccept
								FROM dbo.t_PaidCase c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT rf_idSMO,COUNT(DISTINCT rf_idCase) AS Count_Case, COUNT(DISTINCT ENP) Count_ENP,SUM(AmountPayment) AS AmountPayment,SUM(AmountPaid) AS AmountPaymentAccept
FROM #tCasesDisp
WHERE AmountPayment>0
GROUP BY rf_idSMO

GO

DROP TABLE #tCasesDisp
