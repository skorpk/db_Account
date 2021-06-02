USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200701',
		@dateEnd DATETIME='20201201',
		@dateEndPay DATETIME='20201201',
		@startMonth TINYINT=6,
		@endMonth TINYINT=11

SELECT ENP_MY AS ENP INTO #tCovidRegister FROM PeopleAttach.dbo.t_CovidRegister20201130 WHERE ENP_My IS NOT NULL
union
SELECT ENP_My FROM PeopleAttach.dbo.t_CovidRegister20201026 WHERE ENP_My IS NOT null

SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient
,cc.AmountPayment AS AmmPay,ENP, CASE WHEN d.TypeDiagnosis=3 AND d.DiagnosisCode ='U07.1' THEN d.DiagnosisCode ELSE NULL END AS DS2
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>@startMonth AND a.ReportMonth<@endMonth AND c.rf_idV006=1
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='U07.1' --AND a.rf_idSMO<>'34'
		

---------------------------------------------Амбулаторная помощь------------------------------------
INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, c.AmountPayment,3 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,c.rf_idRecordCasePatient
,c.AmountPayment AS AmmPay,ENP, CASE WHEN d.TypeDiagnosis=3 AND d.DiagnosisCode ='U07.1' THEN d.DiagnosisCode ELSE NULL END AS DS2
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>@startMonth AND a.ReportMonth<@endMonth AND c.rf_idV006=3
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='U07.1'-- AND a.rf_idSMO<>'34'

UPDATE p SET p.AmountDeduction=r.AmountDeduction, p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE AmountPayment=0.0
----------------------------------------------------------------------------------------------


SELECT c.rf_idCase,cc.rf_idRecordCasePatient, f.CodeM,a.Account,a.DateRegister AS DateAccount,cc.idRecordCase,c.ENP,cc.DateBegin
,cc.DateEnd,CAST(c.AmountPayment AS MONEY) AS AmountPayment,CASE WHEN c.TypeRequest=1 THEN 'Стационарно' ELSE 'Амбулаторно' END AS V006, 1 AS TypeQuery
,p.Fam+' '+ ISNULL(p.im,'')+' '+ISNULL(p.ot,'') AS FIO, p.BirthDay,d.SNILS,r.rf_idF008,r.NumberPolis,cc.rf_idV009 AS RSLT,cc.rf_idV012 AS ISHOD,c.DS2
,p.Sex,a.PropertyNumberRegister
INTO #tTotal
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
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
					LEFT JOIN t_RegisterPatientDocument d ON
			p.id=d.rf_idRegisterPatient
WHERE NOT EXISTS(SELECT 1 FROM #tCovidRegister cr WHERE cr.ENP=c.ENP)

------------------------------------------------------------------------Подозрения--------------------------------------------------------------------------------------------

SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient
,cc.AmountPayment AS AmmPay,ENP, CASE WHEN d.TypeDiagnosis=3 AND d.DiagnosisCode ='U07.2' THEN d.DiagnosisCode ELSE NULL END AS DS2
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
			AND cc.DateEnd>='20200501'
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>@startMonth AND a.ReportMonth<@endMonth AND c.rf_idV006=1
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='U07.2' --AND a.rf_idSMO<>'34'
-----------------------------------------Амбулаторная помощь------------------------------------
INSERT #tCases2
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,3 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient
,cc.AmountPayment AS AmmPay,ENP,  CASE WHEN d.TypeDiagnosis=3 AND d.DiagnosisCode ='U07.2' THEN d.DiagnosisCode ELSE NULL END AS DS2
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>@startMonth AND a.ReportMonth<@endMonth AND c.rf_idV006=3
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='U07.2'

UPDATE p SET p.AmountDeduction=r.AmountDeduction, p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases2 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases2 WHERE AmountPayment=0.0
------------------------------------------------
INSERT #tTotal
SELECT c.rf_idCase,cc.rf_idRecordCasePatient, f.CodeM,a.Account,a.DateRegister AS DateAccount,cc.idRecordCase,c.ENP,cc.DateBegin
,cc.DateEnd,CAST(c.AmountPayment AS MONEY),CASE WHEN c.TypeRequest=1 THEN 'Стационарно' ELSE 'Амбулаторно' END AS V006,2
,p.Fam+ ' '+ISNULL(p.im,'')+' '+ISNULL(p.ot,'') AS FIO, p.BirthDay,d.SNILS,r.rf_idF008,r.NumberPolis,cc.rf_idV009 AS RSLT,cc.rf_idV012 AS ISHOD, c.DS2
,p.Sex,a.PropertyNumberRegister
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
					INNER JOIN dbo.t_RegisterPatient p ON
		r.id=p.rf_idRecordCase
					LEFT JOIN t_RegisterPatientDocument d ON
			p.id=d.rf_idRegisterPatient
WHERE NOT EXISTS(SELECT 1 FROM #tCovidRegister cr WHERE cr.ENP=c.ENP)

--SELECT c.FIO_Source,c.DR_My,c.ENP_My,c.FIO_Source,t.fio,t.BirthDay,t.enp
UPDATE c SET c.ENP_My=t.ENP
FROM #tTotal t INNER JOIN PeopleAttach.dbo.t_CovidRegister20201130 c ON
		t.FIO=c.FIO_Source
		AND t.BirthDay=c.DR_My
WHERE t.PropertyNumberRegister=2 AND t.ENP<>ISNULL(c.ENP_My,'bla-bla')
PRINT @@ROWCOUNT
--SELECT c.FIO_Source,c.DR_My,c.ENP_My,c.FIO_Source,t.fio,t.BirthDay,t.enp
UPDATE c SET c.ENP_My=t.ENP
FROM #tTotal t INNER JOIN PeopleAttach.dbo.t_CovidRegister20201130 c ON
		t.SNILS=c.SNILS_Source
		AND t.BirthDay=c.DR_My
WHERE t.PropertyNumberRegister=2 AND t.ENP<>ISNULL(c.ENP_My,'bla-bla')
PRINT @@ROWCOUNT

GO
DROP TABLE #tCases
GO
DROP TABLE #tCases2
GO
DROP TABLE #tCovidRegister
GO
DROP TABLE #tTotal
GO
