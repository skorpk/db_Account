USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200301',
		@dateEnd DATETIME=GETDATE(),
		@dateEndPay DATETIME=GETDATE(),
		-----2019-----
		@dateStart2019 DATETIME='20190101',
		@dateEnd2019 DATETIME='20200301',
		@dateEndPay2019 DATETIME=GETDATE(),
		@reportYear SMALLINT=2019

SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,cc.id AS rf_idRecordCasePatient,cc.AmountPayment AS AmmPay,ENP
INTO #tCasesENP
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
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode IN('U07.1','U07.2')
AND a.rf_idSMO<>'34'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCasesENP p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCasesENP WHERE AmountPayment=0.0
PRINT('Удаляем')
PRINT(@@ROWCOUNT)
---------------------------2019------------------------------
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,cc.id AS rf_idRecordCasePatient,cc.AmountPayment AS AmmPay,ps.ENP,c.rf_idV006 AS USL_OK
INTO #tCases2019
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
					INNER JOIN #tCasesENP e ON
			e.ENP = ps.ENP
WHERE f.DateRegistration>@dateStart2019 AND f.DateRegistration<@dateEnd2019 AND a.ReportYear=@reportYear AND a.rf_idSMO<>'34'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases2019 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases2019 WHERE 1=(CASE WHEN AmmPay=0.0 and AmountPayment<0.0 THEN 1 WHEN AmmPay>0.0 and AmountPayment=0.0 THEN 1 ELSE 0 END)
PRINT('Удаляем')
PRINT(@@ROWCOUNT)
ALTER TABLE #tCases2019 ADD IsAmbType TINYINT
-----посещения
UPDATE t SET IsAmbType=1
FROM #tCases2019 t INNER JOIN dbo.t_Meduslugi m ON
			t.rf_idCase=m.rf_idCase
WHERE m.MUGroupCode=2 AND m.MUUnGroupCode IN(79,88) AND USL_OK=3
-----неотложная
UPDATE t SET IsAmbType=2
FROM #tCases2019 t INNER JOIN dbo.t_Meduslugi m ON
			t.rf_idCase=m.rf_idCase
WHERE m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82) AND USL_OK=3

-----обращения
UPDATE t SET IsAmbType=3
FROM #tCases2019 t INNER JOIN dbo.t_MES m ON
			t.rf_idCase=m.rf_idCase
WHERE m.MES LIKE '2.78.%' AND USL_OK=3

SELECT  COUNT(DISTINCT e.ENP) AS Col2
	   ,COUNT(DISTINCT CASE WHEN USL_OK=4 THEN c.ENP ELSE NULL end) AS Col2
	   ,COUNT(DISTINCT CASE WHEN USL_OK=3 AND c.IsAmbType=1 THEN c.ENP ELSE NULL end)	AS Col3
	   ,COUNT(DISTINCT CASE WHEN USL_OK=3 AND c.IsAmbType=2 THEN c.ENP ELSE NULL end)	AS Col4
	   ,COUNT(DISTINCT CASE WHEN USL_OK=3 AND c.IsAmbType=3 THEN c.ENP ELSE NULL end)	AS Col5
	   ,COUNT(DISTINCT CASE WHEN USL_OK=1 THEN c.ENP ELSE NULL end) AS Col6
	   ,COUNT(DISTINCT CASE WHEN USL_OK=2 THEN c.ENP ELSE NULL end) AS Col7
FROM #tCasesENP e left JOIN #tCases2019 c ON
		e.ENP=c.ENP
GO
DROP TABLE #tCasesENP
GO
DROP TABLE #tCases2019