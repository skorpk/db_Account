USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200101',
		@dateEnd DATETIME='20210116',
		@dateEndPay DATETIME='20210119'

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,cc.id AS rf_idCompletedCase,cc.AmountPayment AS AmmPay,cc.GUID_ZSL,c.GUID_Case
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND c.rf_idV006<4 AND a.rf_idSMO<>'34'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay AND c.TypeCheckup>1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT SUM(AmmPay) ,COUNT(DISTINCT rf_idCompletedCase),COUNT(DISTINCT GUID_ZSL) FROM #tCases WHERE AmountPayment=0.0

DELETE FROM #tCases WHERE AmountPayment>0.0
SELECT * FROM #tCases

SELECT SUM(t.AmountPayment),COUNT(t.rf_idCompletedCase),COUNT(DISTINCT t.GUID_ZSL)
FROM (
		SELECT cc.AmountPayment,c1.rf_idCompletedCase,cc.GUID_ZSL
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts			
								INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient	
							JOIN dbo.t_CompletedCase cc ON
		            r.id=cc.rf_idRecordCasePatient			
							JOIN #tCases c1 ON
		            c.GUID_Case=c1.GUID_Case
		WHERE f.DateRegistration>@dateStart AND f.DateRegistration<GETDATE() AND a.ReportYear=2020 AND c.rf_idV006<4 AND a.rf_idSMO<>'34'
		AND NOT EXISTS(SELECT 1 FROM #tCases ccc WHERE c.id=ccc.rf_idCase)
		GROUP BY cc.AmountPayment,c1.rf_idCompletedCase,cc.GUID_ZSL
	) t
GO
DROP TABLE #tCases