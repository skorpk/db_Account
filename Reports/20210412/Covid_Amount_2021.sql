USE AccountOMS
GO
DECLARE @dateStart DATETIME='20210101',
		@dateEnd DATETIME='20210211',
		@dateEndPay DATETIME='20210112',
		@reportMonth TINYINT=1

SELECT DISTINCT a.ReportMonth,c.id AS rf_idCase, CASE WHEN c.rf_idV006= 4 AND cc.AmountPayment=0.0 THEN 2713.4 ELSE cc.AmountPayment END AS AmountPayment
	,cc.id AS rf_idCompletedCase, CASE WHEN c.rf_idV006= 4 AND cc.AmountPayment=0.0 THEN 2713.4 ELSE cc.AmountPayment END AS AmPay
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient											
					JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient			
					JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase                    
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<(CASE WHEN a.ReportMonth=1 THEN @dateEnd WHEN a.ReportMonth=2 THEN '20210311' WHEN a.ReportMonth=3 THEN '20210411' END)
AND a.ReportYear=2021 AND a.rf_idSMO<>'34' AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode IN('U07.1','U07.2') AND a.ReportMonth<4

CREATE UNIQUE NONCLUSTERED INDEX IX_1 ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY

INSERT #tCases 
SELECT DISTINCT a.ReportMonth,c.id AS rf_idCase, cc.AmountPayment,cc.id AS rf_idCompletedCase, cc.AmountPayment 
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient											
					JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient						
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<(CASE WHEN a.ReportMonth=1 THEN @dateEnd WHEN a.ReportMonth=2 THEN '20210311' WHEN a.ReportMonth=3 THEN '20210411' END)AND a.ReportYear=2021 AND a.rf_idSMO<>'34' AND c.rf_idV006=3
AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE c.id=m.rf_idCase AND m.MU IN('4.17.787','4.17.788','4.27.1','4.15.747')) AND a.ReportMonth<4

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM #tCases a JOIN dbo.t_PaymentAcceptedCase2 c on
										a.rf_idCase=c.rf_idCase
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<(CASE WHEN a.ReportMonth=1 THEN @dateEndPay WHEN a.ReportMonth=2 THEN '20210312' WHEN a.ReportMonth=3 THEN '20210412' END)
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE AmountPayment=0.0

SELECT rf_idCompletedCase FROM #tCases GROUP BY rf_idCompletedCase HAVING COUNT(*)>1

;WITH cteSum
AS
(
	SELECT DISTINCT ReportMonth,rf_idCompletedCase,AmountPayment FROM #tCases
)
SELECT c.ReportMonth,CAST(SUM(c.AmountPayment) AS MONEY) FROM cteSum c GROUP BY c.ReportMonth ORDER BY c.ReportMonth
	
GO
DROP TABLE #tCases