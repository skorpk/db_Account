USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20200708',
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME='20200710',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=7


SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,a.rf_idSMO AS SMO
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
              r.id=cc.rf_idRecordCasePatient	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND  c.rf_idV006=1 AND c.rf_idV008=31 AND c.rf_idV014 IN(1,2) AND a.ReportMonth<@reportMonth

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT 2019,COUNT(CASE WHEN SMO<>'34' THEN t.rf_idCase ELSE NULL end) AS Col1
		,CAST(SUM(CASE WHEN SMO<>'34' THEN t.AmountPayment ELSE NULL end) AS MONEY) AS Col2
	,COUNT(CASE WHEN SMO='34' THEN t.AmountPayment ELSE NULL end) AS Col3
	,CAST(SUM(CASE WHEN SMO='34' THEN t.AmountPayment  ELSE NULL end) AS money) AS Col4
FROM #t t
WHERE t.AmountPayment>0
GO
DROP TABLE #t
GO
