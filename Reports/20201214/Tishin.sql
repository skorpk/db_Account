USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200808',
		@dateEnd DATETIME='20201208',
		@dateEndPay DATETIME='20201209'


SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,a.rf_idSMO AS CodeSMO,CAST(0.0 AS DECIMAL(15,2)) AS AmountDeduction,cc.id
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient												
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND cc.AmountPayment>0 AND a.rf_idSMO<>'34'

UPDATE p SET p.AmountDeduction=r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT c.CodeM,l.NAMES
		,cast(sum(c.AmountPayment) AS MONEY) AS AmountAll
		,cast(sum(CASE WHEN c.CodeSMO='34007' then c.AmountPayment ELSE 0.0 end) AS MONEY) AS Amount34007
		,cast(sum(CASE WHEN c.CodeSMO='34002' then c.AmountPayment ELSE 0.0 end) AS MONEY) AS Amount34002
FROM (SELECT DISTINCT id,codeM,CodeSMO,AmountPayment,AmountDeduction FROM #tCases) c INNER JOIN dbo.vw_sprT001 l ON
		l.CodeM = c.CodeM
GROUP BY c.CodeM,l.NAMES
ORDER BY c.CodeM
-------------------------------------Deduction----------------------------------------------------
SELECT c.CodeM,l.NAMES
		,cast(sum(c.AmountDeduction) AS MONEY)AS AmountAll
		,cast(sum(CASE WHEN c.CodeSMO='34007' then c.AmountDeduction ELSE 0.0 end) AS MONEY)AS Amount34007
		,cast(sum(CASE WHEN c.CodeSMO='34002' then c.AmountDeduction ELSE 0.0 end) AS MONEY)AS Amount34002
FROM (SELECT DISTINCT id,codeM,CodeSMO,AmountPayment,AmountDeduction FROM #tCases) c INNER JOIN dbo.vw_sprT001 l ON
		l.CodeM = c.CodeM
GROUP BY c.CodeM,l.NAMES
ORDER BY c.CodeM
------------------------------------Accepted-------------------
SELECT c.CodeM,l.NAMES
		,cast(sum(c.AmountPayment- c.AmountDeduction) AS MONEY)AS AmountAll
		,cast(sum(CASE WHEN c.CodeSMO='34007' then c.AmountPayment-c.AmountDeduction ELSE 0.0 end) AS MONEY) AS Amount34007
		,cast(sum(CASE WHEN c.CodeSMO='34002' then c.AmountPayment-c.AmountDeduction ELSE 0.0 end) AS MONEY) AS Amount34002
FROM (SELECT DISTINCT id,codeM,CodeSMO,AmountPayment,AmountDeduction FROM #tCases) c INNER JOIN dbo.vw_sprT001 l ON
		l.CodeM = c.CodeM
GROUP BY c.CodeM,l.NAMES
ORDER BY c.CodeM
GO
DROP TABLE #tCases
