USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200301',
		@dateEnd DATETIME='20201026',
		@dateEndPay DATETIME='20201026'

SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient,cc.AmountPayment AS AmmPay
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient	
			AND cc.DateEnd BETWEEN '20200301' AND '20200501'									
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=1
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='B33.8' AND a.rf_idSMO<>'34'
INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient,cc.AmountPayment AS AmmPay
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient	
			AND cc.DateEnd>='20200501'
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=1
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='U07.2' AND a.rf_idSMO<>'34'
-----------------------------------------Амбулаторная помощь------------------------------------
INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,3 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient,cc.AmountPayment AS AmmPay
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient	
			AND cc.DateEnd BETWEEN '20200301' AND '20200501'									
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=3
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='B33.8' AND a.rf_idSMO<>'34'
	AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82) )

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,3 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient,cc.AmountPayment AS AmmPay
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient	
			AND cc.DateEnd>='20200501'
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=3
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='U07.2' AND a.rf_idSMO<>'34'
	AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82) )
-----------------------------------------Скорая помощь------------------------------------
INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM,2428.6 as AmountPayment,4 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,c.rf_idRecordCasePatient,2428.6 AS  AmmPay
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient	
			AND cc.DateEnd BETWEEN '20200301' AND '20200501'									
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=4
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='B33.8' AND a.rf_idSMO<>'34'

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM,2428.6 as AmountPayment,4 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,c.rf_idRecordCasePatient,2428.6 AS  AmmPay
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient	
			AND cc.DateEnd>='20200501'
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=4
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='U07.2' AND a.rf_idSMO<>'34'

UPDATE p SET p.AmountDeduction=r.AmountDeduction, p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
						   FROM dbo.t_PaymentAcceptedCase2 c
						   WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
						   GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


SELECT 1 AS ColName
		,cast(SUM(CASE WHEN TypeRequest=1 THEN amountDeduction ELSE 0 END) as money) AS ColStacionarNonCovid
		,cast(SUM(CASE WHEN TypeRequest=3 THEN amountDeduction ELSE 0 END) as money) AS ColAMPNonCovid
		,cast(SUM(CASE WHEN TypeRequest=4 THEN amountDeduction ELSE 0 END) as money) AS ColSMPNonCovid
FROM (SELECT DISTINCT rf_idRecordCasePatient,TypeRequest,AmountDeduction FROM #tCases WHERE AmountDeduction>0) t
UNION all
SELECT 2 AS ColName
		,cast(SUM(CASE WHEN TypeRequest=1 THEN AmountPayment ELSE 0 END) as money) AS ColStacionarNonCovid
		,cast(SUM(CASE WHEN TypeRequest=3 THEN AmountPayment ELSE 0 END) as money) AS ColAMPNonCovid
		,cast(SUM(CASE WHEN TypeRequest=4 THEN AmountPayment ELSE 0 END) as money) AS ColSMPNonCovid
FROM (SELECT DISTINCT rf_idRecordCasePatient,TypeRequest,AmountPayment FROM #tCases) t
GO
DROP TABLE #tCases