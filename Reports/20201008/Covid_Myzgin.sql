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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=1
	AND d.TypeDiagnosis IN(1,3) AND dd.TypeDS=1 AND a.rf_idSMO<>'34'

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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=1
	AND d.TypeDiagnosis IN(1,3) AND a.rf_idSMO<>'34'
		AND NOT EXISTS(SELECT 1 FROM #tCases c1 WHERE c1.rf_idRecordCasePatient=cc.id)

--SELECT 'Missing',* FROM #tCases t  
--WHERE t.TypeRequest=2 AND NOT EXISTS(SELECT 1 FROM tmp_UnCovid cc WHERE cc.id=t.rf_idRecordCasePatient)

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,3 , CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient,cc.AmountPayment AS AmmPay
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Meduslugi m ON
            m.rf_idCase = c.id
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=3
	AND a.rf_idSMO<>'34' AND m.MUGroupCode=4 AND m.MUUnGroupCode=17 AND m.MUCode IN(784,785)

UPDATE p SET p.AmountDeduction=r.AmountDeduction, p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT 1 AS ColName,SUM(CASE WHEN TypeRequest=1 THEN amountDeduction ELSE 0 END) AS Col1
		,SUM(CASE WHEN TypeRequest=2 THEN amountDeduction ELSE 0 END) AS Col2
		,SUM(CASE WHEN TypeRequest=3 THEN amountDeduction ELSE 0 END) AS Col1
FROM (SELECT DISTINCT rf_idRecordCasePatient,TypeRequest,AmountDeduction FROM #tCases WHERE AmountDeduction>0) t
UNION all
SELECT 2 AS ColName,SUM(CASE WHEN TypeRequest=1 THEN AmountPayment ELSE 0 END) AS Col1
		,SUM(CASE WHEN TypeRequest=2 THEN AmountPayment ELSE 0 END) AS Col2
		,SUM(CASE WHEN TypeRequest=3 THEN AmountPayment ELSE 0 END) AS Col1
FROM (SELECT DISTINCT rf_idRecordCasePatient,TypeRequest,AmountPayment FROM #tCases /*WHERE AmountPayment>0*/) t

/*
SELECT SUM(AmountDeduction) FROM #tCases WHERE TypeRequest=2 --AND AmountDeduction>0

SELECT SUM(AmountPayment) FROM #tCases WHERE TypeRequest=2 AND AmountPayment<0

SELECT SUM(AmountPayment+AmountDeduction) FROM #tCases WHERE TypeRequest=2
;WITH cte
AS
(
SELECT rf_idRecordCasePatient,SUM(AmountPayment) AS AmountPayment, SUM(AmountDeduction) AS AmountDeduction,AmmPay
FROM #tCases WHERE TypeRequest=2 GROUP BY rf_idRecordCasePatient, AmmPay
)
SELECT *
FROM cte
WHERE (AmountDeduction+cte.AmountPayment)<>cte.AmmPay
*/
GO
DROP TABLE #tCases
GO
DROP TABLE #tDiag