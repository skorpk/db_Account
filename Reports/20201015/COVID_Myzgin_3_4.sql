USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200301',
		@dateEnd DATETIME='20201008',
		@dateEndPay DATETIME='20201008'

CREATE TABLE #tDiag(DS1 VARCHAR(10),TypeDS tinyint)

INSERT #tDiag VALUES('U07.1',1),('U07.2',1),('Z03.8',2),('Z22.8',2),('Z20.8',2),('Z11.5',2),('B33.8',2),('B34.2',2)

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
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN #tDiag dd ON
            d.DiagnosisCode=dd.DS1
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=3
	AND d.TypeDiagnosis IN(1,3) AND dd.TypeDS=1 AND a.rf_idSMO<>'34' AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82))
---проверка
--SELECT SUM(AmountPayment) FROM #tCases

PRINT ('Non Covid')
INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,2 AS TypeCovid, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient,cc.AmountPayment AS AmmPay
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN (SELECT ds1 FROM #tDiag WHERE TypeDS=2) dd ON
            d.DiagnosisCode=dd.DS1
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=3
	AND d.TypeDiagnosis IN(1,3) AND a.rf_idSMO<>'34' AND NOT EXISTS(SELECT 1 FROM #tCases c1 WHERE c1.rf_idRecordCasePatient=cc.id)
	AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82))
---проверка
--SELECT SUM(AmountPayment) FROM #tCases WHERE TypeRequest=2

UPDATE p SET p.AmountDeduction=r.AmountDeduction, p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT 1 AS ColName,SUM(CASE WHEN TypeRequest=1 THEN amountDeduction ELSE 0 END) AS Col1_Amb,CAST(0.0 AS decimal(15,2)) AS Col1_SMP
		,SUM(CASE WHEN TypeRequest=2 THEN amountDeduction ELSE 0 END) AS Col2_Amb
		,CAST(0.0 AS decimal(15,2)) AS Col2_SMP
INTO #tTotal
FROM (SELECT DISTINCT rf_idRecordCasePatient,TypeRequest,AmountDeduction FROM #tCases WHERE AmountDeduction>0) t
UNION all
SELECT 2 AS ColName,SUM(CASE WHEN TypeRequest=1 THEN AmountPayment ELSE 0 END) AS Col1_Amb,0 AS Col1_SMP
		,SUM(CASE WHEN TypeRequest=2 THEN AmountPayment ELSE 0 END) AS Col2_Amb,0 AS Col2_SMP
FROM (SELECT DISTINCT rf_idRecordCasePatient,TypeRequest,AmountPayment FROM #tCases /*WHERE AmountPayment>0*/) t
GO
DROP TABLE #tCases
GO
DROP TABLE #tDiag
DECLARE @dateStart DATETIME='20200301',
		@dateEnd DATETIME='20201008',
		@dateEndPay DATETIME='20201008'

CREATE TABLE #tDiag(DS1 VARCHAR(10),TypeDS tinyint)

INSERT #tDiag VALUES('U07.1',1),('U07.2',1),('Z03.8',2),('Z22.8',2),('Z20.8',2),('Z11.5',2),('B33.8',2),('B34.2',2)

SELECT DISTINCT c.id AS rf_idCase, f.CodeM, 2428.6 AS AmountPayment,1 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient,2428.6 AS  AmmPay
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN #tDiag dd ON
            d.DiagnosisCode=dd.DS1
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=4
	AND d.TypeDiagnosis IN(1,3) AND dd.TypeDS=1 AND a.rf_idSMO<>'34' 
---проверка
--SELECT SUM(AmountPayment) FROM #tCases

PRINT ('Non Covid')
INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, 2428.6 AS AmountPayment,2 AS TypeCovid, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient,2428.6 AS AmmPay
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN (SELECT ds1 FROM #tDiag WHERE TypeDS=2) dd ON
            d.DiagnosisCode=dd.DS1
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=4
	AND d.TypeDiagnosis IN(1,3) AND a.rf_idSMO<>'34' AND NOT EXISTS(SELECT 1 FROM #tCases c1 WHERE c1.rf_idRecordCasePatient=cc.id)

---проверка
--SELECT SUM(AmountPayment) FROM #tCases WHERE TypeRequest=2

UPDATE p SET p.AmountDeduction=r.AmountDeduction, p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

INSERT #tTotal
SELECT 1 AS ColName,0,SUM(CASE WHEN TypeRequest=1 THEN amountDeduction ELSE 0 END) AS Col1_SMP
		,0,SUM(CASE WHEN TypeRequest=2 THEN amountDeduction ELSE 0 END) AS Col2_SMP
FROM (SELECT DISTINCT rf_idRecordCasePatient,TypeRequest,AmountDeduction FROM #tCases WHERE AmountDeduction>0) t
UNION all
SELECT 2 AS ColName,0,SUM(CASE WHEN TypeRequest=1 THEN AmountPayment ELSE 0 END) AS Col1_SMP
		,0,SUM(CASE WHEN TypeRequest=2 THEN AmountPayment ELSE 0 END) AS Col2_SMP
FROM (SELECT DISTINCT rf_idRecordCasePatient,TypeRequest,AmountPayment FROM #tCases) t
GO
DROP TABLE #tCases
GO
DROP TABLE #tDiag
GO
SELECT ColName
	,cast(SUM(Col1_Amb) as money) AS Col1_Amb
	,cast(SUM(Col1_SMP) as money) AS Col1_SMP
	,cast(SUM(Col2_Amb) as money) AS Col2_Amb
	,cast(SUM(Col2_SMP) as money) AS Col2_SMP FROM #tTotal GROUP BY ColName
GO
DROP TABLE #tTotal