USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200101',
		@dateEnd DATETIME='20201116',
		@dateEndPay DATETIME='20201116'


SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment, cc.id AS rf_idCompletedCase,m.MUGroupCode,m.MUUnGroupCode,m.MUCode
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth<11 AND c.rf_idV006=3 AND m.MUGroupCode=60 AND m.MUUnGroupCode=4
--AND a.rf_idSMO<>'34'

	UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
DELETE FROM #tCases WHERE AmountPayment=0.0
SELECT * 
FROM #tCases

SELECT l.codem+'-'+l.NAMES AS LPU
	,COUNT(c.rf_idCase) AS col2,SUM(c.AmountPayment) AS col3
	,COUNT(CASE WHEN c.MUCode=20 THEN c.rf_idCase ELSE NULL end)  as Col4 ,sum(CASE WHEN c.MUCode=20 THEN c.AmountPayment ELSE 0.0 end) as Col5
	,COUNT(CASE WHEN c.MUCode=21 THEN c.rf_idCase ELSE NULL end)  as Col6 ,sum(CASE WHEN c.MUCode=21 THEN c.AmountPayment ELSE 0.0 end) as Col7
	,COUNT(CASE WHEN c.MUCode=22 THEN c.rf_idCase ELSE NULL end)  as Col8 ,sum(CASE WHEN c.MUCode=22 THEN c.AmountPayment ELSE 0.0 end) as Col9
	,COUNT(CASE WHEN c.MUCode=513 THEN c.rf_idCase ELSE NULL end) as Col10 ,sum(CASE WHEN c.MUCode=513 THEN c.AmountPayment ELSE 0.0 end)as Col11
	,COUNT(CASE WHEN c.MUCode=514 THEN c.rf_idCase ELSE NULL end) as Col12 ,sum(CASE WHEN c.MUCode=514 THEN c.AmountPayment ELSE 0.0 end)as Col13
	,COUNT(CASE WHEN c.MUCode=561 THEN c.rf_idCase ELSE NULL end) as Col14 ,sum(CASE WHEN c.MUCode=561 THEN c.AmountPayment ELSE 0.0 end)as Col15
	,COUNT(CASE WHEN c.MUCode IN (20,21,22,513,514,561) THEN c.rf_idCase ELSE NULL end),sum(CASE WHEN c.MUCode IN (20,21,22,513,514,561) THEN c.AmountPayment ELSE 0.0 end)
FROM #tCases c INNER JOIN vw_sprT001 l ON
		c.CodeM=l.CodeM
GROUP BY l.codem,l.NAMES
ORDER BY LPU
GO
DROP TABLE #tCases