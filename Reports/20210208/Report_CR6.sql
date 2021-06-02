USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200901',
		@dateEnd DATETIME='20210116',
		@dateEndPay DATETIME='20210119'
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, cc.id AS rf_idCompletedCase,m.MES,a.ReportMonth,c.rf_idRecordCasePatient, c.KD
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_MES m ON
            c.id=m.rf_idCase
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient															
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>8 AND a.ReportMonth<=12 AND c.rf_idV006=1 AND m.MES LIKE 'st12.013.1'
	AND EXISTS(SELECT 1 FROM dbo.t_AdditionalCriterion ac WHERE ac.rf_idCase=c.id AND ac.rf_idAddCretiria='cr6' ) AND a.rf_idSMO<>'34'
--------------------------------------------------------------------------------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

;WITH cte
AS
(
	SELECT DISTINCT CodeM,rf_idCompletedCase, SUM(KD) AS KD,AmountPayment FROM #tCases WHERE AmountPayment>0 GROUP BY CodeM,rf_idCompletedCase,AmountPayment
)
SELECT l.CodeM+'-'+l.NAMES AS LPU, COUNT(c.rf_idCompletedCase) AS AllCases,SUM(kd) AS kd,CAST(SUM(c.AmountPayment) AS MONEY) AS AmountPayment
FROM cte c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
GROUP BY l.CodeM+'-'+l.NAMES
ORDER BY LPU
GO
DROP TABLE #tCases
----------------------------------------------------------------------------------------------------------------
GO
DECLARE @dateStart DATETIME='20200901',
		@dateEnd DATETIME='20210116',
		@dateEndPay DATETIME='20210119'
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, cc.id AS rf_idCompletedCase,m.MES,a.ReportMonth,c.rf_idRecordCasePatient, c.KD
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_MES m ON
            c.id=m.rf_idCase
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient															
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>8 AND a.ReportMonth<=12 AND c.rf_idV006=1 AND m.MES LIKE 'st12.013.1'
	AND EXISTS(SELECT 1 FROM dbo.t_AdditionalCriterion ac WHERE ac.rf_idCase=c.id AND ac.rf_idAddCretiria='cr6' ) AND a.rf_idSMO='34'
--------------------------------------------------------------------------------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

;WITH cte
AS
(
	SELECT DISTINCT CodeM,rf_idCompletedCase, SUM(KD) AS KD,AmountPayment FROM #tCases WHERE AmountPayment>0 GROUP BY CodeM,rf_idCompletedCase,AmountPayment
)
SELECT l.CodeM+'-'+l.NAMES AS LPU, COUNT(c.rf_idCompletedCase) AS AllCases,SUM(kd) AS kd,CAST(SUM(c.AmountPayment) AS MONEY) AS AmountPayment
FROM cte c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
GROUP BY l.CodeM+'-'+l.NAMES
ORDER BY LPU
GO
DROP TABLE #tCases
