USE AccountOMS
GO
DECLARE @dateStart DATETIME='20201001',
		@dateEnd DATETIME='20201119',
		@dateEndPay DATETIME='20201119'

SELECT DiagnosisCode INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J12' and 'J18'


SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, cc.id AS rf_idCompletedCase,cc.AmountPayment AS AmmPay,ENP,a.rf_idSMO AS CodeSMO
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
					INNER JOIN #tDiag dd ON
			d.DiagnosisCode=dd.DiagnosisCode				
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth=10 AND c.rf_idV006=1 AND d.TypeDiagnosis IN(1,3)
AND NOT EXISTS(SELECT  1 FROM dbo.t_Case c1 INNER JOIN dbo.t_Diagnosis d1 ON
							c1.id=d1.rf_idCase
				WHERE d1.DiagnosisCode IN('U07.1','U07.2') AND d1.TypeDiagnosis IN(1,3) AND c1.rf_idRecordCasePatient=c.rf_idRecordCasePatient
				)
AND a.rf_idMO IN ('340003','340004','340005','340006', '340007', '340015', '340032', '340325', '340047', '340055', '340056', '340057', '340064', '340065', '340074', '340081', '340323', '340091', '340324', '340104', '340105', '340106', '340119', '340124', '340127', '340128', '340138', '340142', '340143', '340155', '340159', '340161', '340167','340169')

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
DELETE FROM #tCases WHERE AmountPayment=0.0

;WITH cteTotal
AS(
SELECT distinct rf_idCompletedCase, AmmPay
FROM #tCases
)
SELECT COUNT(c.rf_idCompletedCase),CAST(SUM(c.AmmPay) AS MONEY)
FROM cteTotal c
GO
DROP TABLE #tCases
GO
DROP TABLE #tDiag