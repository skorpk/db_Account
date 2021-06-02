USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20200123',
		@reportYear SMALLINT=2019

SELECT c.id AS rf_idCase, ps.ENP,c.AmountPayment,f.CodeM,a.Account,f.DateRegistration,c.DateEnd,c.idRecordCase,a.DateRegister,a.rf_idSMO
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient				
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient					
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND a.Letter IN('O','R')

ALTER TABLE #tCases ADD AmountDeduction DECIMAL(15,2) NOT NULL DEFAULT(0.0)		


UPDATE p SET p.AmountDeduction=r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCase2 c
							WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEnd
							GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

--общее количество случаев по ДВ2 принятых к оплате
SELECT rf_idSMO,SUM(AmountDeduction)
FROM #tCases 
GROUP BY rf_idSMO


GO
DROP TABLE #tCases