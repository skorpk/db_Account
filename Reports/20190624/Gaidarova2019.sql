USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20190415',
		@dateEndPay DATETIME=GETDATE(),
		@reportYear SMALLINT=2019

SELECT c.id AS rf_idCase,p.TypeCheckup,p.AmountDeduction,COUNT(rd.id) AS CountReason
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient						
					INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
			c.id=p.rf_idCase
					LEFT JOIN dbo.t_ReasonDenialPayment rd ON
			p.idAkt=rd.idAkt
			AND p.rf_idCase = rd.rf_idCase				
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND a.ReportMonth<4 AND a.Letter IN('O','R','F','D','U') 
		AND a.rf_idSMO<>'34'
GROUP BY c.id,p.TypeCheckup,p.AmountDeduction



SELECT TypeCheckup, CASE WHEN TypeCheckup=1 THEN 'Ã› ' WHEN TypeCheckup=2 THEN 'Ã››' ELSE '› Ãœ' END , COUNT(DISTINCT rf_idCase),COUNT(CountReason),SUM(AmountDeduction)
FROM #tCases   GROUP BY TypeCheckup	,CASE WHEN TypeCheckup=1 THEN 'Ã› ' WHEN TypeCheckup=2 THEN 'Ã››' ELSE '› Ãœ' END ORDER BY TypeCheckup
go

DROP TABLE #tCases