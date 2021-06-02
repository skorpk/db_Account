USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200301',
		@dateEnd DATETIME='20201008',
		@dateEndPay DATETIME='20201008'

SELECT ENP,CASE WHEN Amobulance_Source=1 THEN 3 ELSE 1 END AS V006,CodeM_Source AS CodeM
INTO #tCovidRegister
FROM PeopleAttach.dbo.t_CovidRegister20201026 WHERE ENP IS NOT NULL

SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient,cc.AmountPayment AS AmmPay,ENP
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
			AND cc.DateEnd>='20200501'									
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=1
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='U07.1' AND a.rf_idSMO<>'34'
		--AND NOT EXISTS(SELECT 1 FROM dbo.t_Diagnosis dd WHERE dd.rf_idCase=c.id AND d.TypeDiagnosis IN(1,3) AND dd.DiagnosisCode IN('B33.8','U07.2'))
		

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient,cc.AmountPayment AS AmmPay,ENP
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
			AND cc.DateEnd BETWEEN '20200301' AND '20200501'									
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=1
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='B34.2' AND a.rf_idSMO<>'34'
	--AND NOT EXISTS(SELECT 1 FROM dbo.t_Diagnosis dd WHERE dd.rf_idCase=c.id AND d.TypeDiagnosis IN(1,3) AND dd.DiagnosisCode IN('B33.8','U07.2'))
---------------------------------------------Амбулаторная помощь------------------------------------
INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, c.AmountPayment,3 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,c.rf_idRecordCasePatient,c.AmountPayment AS AmmPay,ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient						
			AND c.DateEnd>='20200501'									
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=3
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='U07.1' AND a.rf_idSMO<>'34'
		--AND NOT EXISTS(SELECT 1 FROM dbo.t_Diagnosis dd WHERE dd.rf_idCase=c.id AND d.TypeDiagnosis IN(1,3) AND dd.DiagnosisCode IN('B33.8','U07.2'))
		AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82) )

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, c.AmountPayment,3 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,c.rf_idRecordCasePatient,c.AmountPayment AS AmmPay,ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient						
			AND c.DateEnd BETWEEN '20200301' AND '20200501'									
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=3
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='B34.2' AND a.rf_idSMO<>'34'
	--AND NOT EXISTS(SELECT 1 FROM dbo.t_Diagnosis dd WHERE dd.rf_idCase=c.id AND d.TypeDiagnosis IN(1,3) AND dd.DiagnosisCode IN('B33.8','U07.2'))
	AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82) )

UPDATE p SET p.AmountDeduction=r.AmountDeduction, p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE AmountPayment=0.0

SELECT f.CodeM+' - '+l.NAMES AS LPU,a.Account,a.DateRegister AS DateAccount,cc.idRecordCase,c.ENP,cc.DateBegin,cc.DateEnd,CAST(c.AmountPayment AS MONEY),CASE WHEN c.TypeRequest=1 THEN 'Стационарно' ELSE 'Амбулаторно' END AS V006
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER join #tCases c ON
			cc.id=c.rf_idCase           
					INNER JOIN dbo.vw_sprT001 l ON
            f.CodeM=l.CodeM
WHERE NOT EXISTS(SELECT 1 FROM #tCovidRegister cr WHERE cr.CodeM=c.CodeM /*AND cr.V006=c.TypeRequest*/ AND cr.ENP=c.ENP)
ORDER BY LPU, a.Account

------------------------------------------------------------------------Подозрения--------------------------------------------------------------------------------------------
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient,cc.AmountPayment AS AmmPay,ENP
INTO #tCases2
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
			AND cc.DateEnd BETWEEN '20200301' AND '20200501'									
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=1
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='B33.8' AND a.rf_idSMO<>'34'

INSERT #tCases2
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient,cc.AmountPayment AS AmmPay,ENP
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
			AND cc.DateEnd>='20200501'
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=1
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='U07.2' AND a.rf_idSMO<>'34'
-----------------------------------------Амбулаторная помощь------------------------------------
INSERT #tCases2
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,3 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient,cc.AmountPayment AS AmmPay,ENP
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
			AND cc.DateEnd BETWEEN '20200301' AND '20200501'									
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=3
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='B33.8' AND a.rf_idSMO<>'34'
	AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82) )

INSERT #tCases2
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,3 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient,cc.AmountPayment AS AmmPay,ENP
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
			AND cc.DateEnd>='20200501'
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=3
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='U07.2' AND a.rf_idSMO<>'34'
	AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82) )

UPDATE p SET p.AmountDeduction=r.AmountDeduction, p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases2 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases2 WHERE AmountPayment=0.0

SELECT f.CodeM+' - '+l.NAMES AS LPU,a.Account,a.DateRegister AS DateAccount,cc.idRecordCase,c.ENP,cc.DateBegin,cc.DateEnd,CAST(c.AmountPayment AS MONEY),CASE WHEN c.TypeRequest=1 THEN 'Стационарно' ELSE 'Амбулаторно' END AS V006
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER join #tCases2 c ON
			cc.id=c.rf_idCase           
					INNER JOIN dbo.vw_sprT001 l ON
            f.CodeM=l.CodeM
WHERE NOT EXISTS(SELECT 1 FROM #tCovidRegister cr WHERE cr.CodeM=c.CodeM /*AND cr.V006=c.TypeRequest*/ AND cr.ENP=c.ENP)
ORDER BY LPU,a.Account

GO
DROP TABLE #tCases
GO
DROP TABLE #tCases2
GO
DROP TABLE #tCovidRegister