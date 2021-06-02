USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME=GETDATE(),
		@reportYear SMALLINT=2019
	


SELECT c.id AS rf_idCase, c.AmountPayment AS AmountPaymentAcc,c.AmountPayment, r.id, c.rf_idV006, f.CodeM
INTO #tmpPeople 
FROM AccountOMS.dbo.t_File f INNER JOIN AccountOMS.dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN AccountOMS.dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts                  
					INNER JOIN AccountOMS.dbo.t_Case c ON
		r.id = c.rf_idRecordCasePatient 
					INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase  					  
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportMonth>=1 AND a.ReportMonth<=10 AND a.ReportYear=@reportYear
AND c.rf_idV002=158 AND c.Age>59
		 



UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM AccountOMS.dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<'20191105'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT l.CodeM,l.NAMES AS LPU,v6.name AS USL_OK,COUNT(DISTINCT p.id) AS KolId,SUM(p.AmountPaymentAcc) AS AmountPay
FROM #tmpPeople p INNER JOIN dbo.vw_sprT001 l ON
		p.CodeM=l.CodeM
					INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
		p.rf_idV006=v6.id
WHERE AmountPaymentAcc>0
GROUP BY l.CodeM,l.NAMES,v6.name            
ORDER BY l.CodeM,USL_OK
GO

DROP TABLE #tmpPeople