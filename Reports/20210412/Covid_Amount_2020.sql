USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200101',
		@dateEnd DATETIME='20210116',
		@dateEndPay DATETIME='20210119'



SELECT DISTINCT c.id AS rf_idCase, CASE WHEN c.rf_idV006=4 AND cc.AmountPayment=0.0 THEN 2428.6 ELSE cc.AmountPayment END AS AmountPayment
	,cc.id AS rf_idCompletedCase, CASE WHEN c.rf_idV006= 4 AND cc.AmountPayment=0.0 THEN 2428.6 ELSE cc.AmountPayment END AS AmPay,c.rf_idV006
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient											
					JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient			
					JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase                    
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.rf_idSMO<>'34'
AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode IN('U07.1','U07.2','B33.8','B34.2')

CREATE UNIQUE NONCLUSTERED INDEX IX_1 ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY

INSERT #tCases 
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,cc.id AS rf_idCompletedCase, cc.AmountPayment, c.rf_idV006
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient											
					JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient						
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.rf_idSMO<>'34' AND c.rf_idV006=3
AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE c.id=m.rf_idCase AND m.MU IN('4.17.785','4.17.786','4.27.1','4.15.747'))

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE AmountPayment=0.0

SELECT rf_idCompletedCase FROM #tCases GROUP BY rf_idCompletedCase HAVING COUNT(*)>1

;WITH cteSum
AS
(
	SELECT DISTINCT rf_idV006 AS USL_OK,rf_idCompletedCase,AmountPayment FROM #tCases
)
SELECT c.USL_OK,2020,SUM(c.AmountPayment) FROM cteSum c GROUP BY c.USL_OK
	
GO
DROP TABLE #tCases