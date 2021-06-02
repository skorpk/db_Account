USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200801',
		@dateEnd DATETIME='20201110',
		@dateEndPay DATETIME='20201121'

SELECT DISTINCT c.id AS rf_idCase, f.CodeM,CASE WHEN c.rf_idV006=4 AND cc.AmountPayment=0.0 THEN 2428.6 else cc.AmountPayment END AS AmountPayment
,1 AS TypeRequest, cc.id AS rf_idCompletedCase,cc.AmountPayment AS AmmPay,ENP,a.rf_idSMO AS CodeSMO
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient	
			AND cc.DateEnd>='20200801'									
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>7 AND a.ReportMonth<11 AND d.TypeDiagnosis IN(1,3)
 AND d.DiagnosisCode IN('U07.1','U07.2') AND a.rf_idSMO<>'34'
 
 CREATE UNIQUE NONCLUSTERED INDEX UQ_1 ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY

 INSERT #tCases
 SELECT DISTINCT c.id AS rf_idCase, f.CodeM, CASE WHEN c.rf_idV006=4 AND cc.AmountPayment=0.0 THEN 2428.6 else cc.AmountPayment END AS AmountPayment,11 AS TypeRequest,cc.id AS rf_idCompletedCase,cc.AmountPayment AS AmmPay,ENP,a.rf_idSMO AS CodeSMO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient	
			AND cc.DateEnd>='20200801'	
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>7 AND a.ReportMonth<11 AND a.rf_idSMO<>'34'
AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.MU IN('4.17.784','4.17.785','4.27.1') AND m.rf_idCase=c.id)
------------------------------Остальные случаи------------------------
INSERT #tCases
 SELECT DISTINCT c.id AS rf_idCase, f.CodeM, CASE WHEN c.rf_idV006=4 AND cc.AmountPayment=0.0 THEN 2428.6 else cc.AmountPayment END AS AmountPayment
 ,2 AS TypeRequest,cc.id AS rf_idCompletedCase,cc.AmountPayment AS AmmPay, ENP,a.rf_idSMO AS CodeSMO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient	
			AND cc.DateEnd>='20200801'	
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>7 AND a.ReportMonth<11 AND a.rf_idSMO<>'34'
AND NOT EXISTS(SELECT 1 FROM #tCases m WHERE m.rf_idCompletedCase=cc.id)

ALTER TABLE #tCases ADD AmountPaid DECIMAL(15,2) NOT NULL DEFAULT (0.0)

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE AmountPayment=0.0

UPDATE p SET  p.AmountPaid=r.AmountPaymentAccept
FROM #tCases p INNER JOIN (SELECT s.rf_idCompletedCase,SUM(c.AmountPaymentAccept) AS AmountPaymentAccept
								FROM dbo.t_PaidCase c INNER JOIN #tCases s ON
										c.rf_idCase=s.rf_idCase
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY s.rf_idCompletedCase
							) r ON
			p.rf_idCompletedCase=r.rf_idCompletedCase

--SELECT l.CodeM,l.NAMES
--	,cast(SUM(CASE WHEN CodeSMO='34007' AND TypeRequest IN(1,11) AND AmountPayment<>AmountPaid THEN AmountPayment ELSE 0.0 END) AS MONEY) AS Col3
--	,cast(SUM(CASE WHEN CodeSMO='34007' AND TypeRequest=2 AND AmountPayment<>AmountPaid THEN AmountPayment ELSE 0.0 END) AS MONEY) AS Col4
--	-------------------------------------34002----------------
--	,cast(SUM(CASE WHEN CodeSMO='34002' AND TypeRequest IN(1,11) AND AmountPayment<>AmountPaid THEN AmountPayment ELSE 0.0 END) AS MONEY) AS Col3
--	,cast(SUM(CASE WHEN CodeSMO='34002' AND TypeRequest=2 AND AmountPayment<>AmountPaid THEN AmountPayment ELSE 0.0 END) AS MONEY) AS Col4
--FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON
--		c.CodeM=l.CodeM
--GROUP BY l.CodeM,l.NAMES
--ORDER BY l.CodeM
--SELECT * FROM #tCases WHERE AmountPayment<AmountPaid

SELECT l.CodeM,l.NAMES
	,cast(SUM(CASE WHEN CodeSMO='34007' AND TypeRequest IN(1,11) AND c.AmountPayment>=AmountPaid THEN AmountPayment-AmountPaid  ELSE 0.0 END) AS MONEY) AS Col3
	,cast(SUM(CASE WHEN CodeSMO='34007' AND TypeRequest=2 AND c.AmountPayment>=AmountPaid THEN AmountPayment-AmountPaid ELSE 0.0 END) AS MONEY) AS Col4
	-------------------------------------34002----------------
	,cast(SUM(CASE WHEN CodeSMO='34002' AND TypeRequest IN(1,11) AND c.AmountPayment>=AmountPaid THEN AmountPayment-AmountPaid ELSE 0.0 END) AS MONEY) AS Col3
	,cast(SUM(CASE WHEN CodeSMO='34002' AND TypeRequest=2 AND c.AmountPayment>=AmountPaid THEN AmountPayment-AmountPaid ELSE 0.0 END) AS MONEY) AS Col4
FROM (SELECT DISTINCT CodeM,rf_idCompletedCase,CodeSMO,TypeRequest,AmountPayment, AmountPaid FROM #tCases) c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
GROUP BY l.CodeM,l.NAMES
ORDER BY l.CodeM
GO
DROP TABLE #tCases
