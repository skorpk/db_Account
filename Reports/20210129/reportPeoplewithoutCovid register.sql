USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200501',
		@dateEnd DATETIME='20210116'

SELECT DISTINCT [���] AS ENP INTO #tCovidRegister FROM PeopleAttach.dbo.t_CovidRegister20210129 WHERE [���] IS NOT NULL

SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient
,cc.AmountPayment AS AmmPay,ENP,c.rf_idV006,CASE WHEN d.TypeDiagnosis=3 THEN d.DiagnosisCode ELSE NULL END AS DS2
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
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase									
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND f.CodeM IN('173801','121501')
AND d.TypeDiagnosis IN(1,3)

/*
UPDATE p SET p.AmountDeduction=r.AmountDeduction, p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<GETDATE() AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE AmountPayment=0.0
*/
SELECT c.rf_idCase,cc.rf_idRecordCasePatient, f.CodeM,a.Account,a.DateRegister AS DateAccount,cc.idRecordCase,c.ENP,cc.DateBegin
,cc.DateEnd,CAST(c.AmountPayment AS MONEY) AS AmountPayment, c.rf_idV006 AS V006,p.Fam+ ' '+ISNULL(p.im,'')+' '+ISNULL(p.ot,'') AS FIO, p.BirthDay,d.SNILS
,r.rf_idF008,r.NumberPolis,cc.rf_idV009 AS RSLT,cc.rf_idV012 AS ISHOD, c.DS2,p.Sex
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

SELECT t.CodeM+' - '+l.NAMES AS LPU, t.Account,t.DateAccount,t.idRecordCase,t.DateBegin,t.DateEnd,t.AmountPayment,t.V006
,t.FIO,t.BirthDay,t.Sex,ISNULL(t.SNILS,'') AS SNILS,t.ENP,tt.Name AS TypePolis,t.NumberPolis,d.DS1,t.DS2,v9.name AS RSLT,v12.name AS ISHOD
--INTO tmpCovidCases
FROM #tTotal t INNER JOIN dbo.vw_Diagnosis d ON
		t.rf_idCase=d.rf_idCase
				INNER JOIN dbo.vw_sprT001 l ON
        t.CodeM=l.CodeM
				INNER JOIN oms_nsi.dbo.sprInsuranceFactDocumentType tt ON
        t.rf_idF008=tt.Id
				INNER JOIN dbo.vw_sprV009 v9 ON
        t.RSLT=v9.id
				INNER JOIN dbo.vw_sprV012 v12 ON
        t.ISHOD=v12.id
WHERE l.CodeM='173801'
--------------------------------------------------------------------------------------
SELECT t.CodeM+' - '+l.NAMES AS LPU, t.Account,t.DateAccount,t.idRecordCase,t.DateBegin,t.DateEnd,t.AmountPayment,t.V006
,t.FIO,t.BirthDay,t.Sex,ISNULL(t.SNILS,'') AS SNILS,t.ENP,tt.Name AS TypePolis,t.NumberPolis,d.DS1,t.DS2,v9.name AS RSLT,v12.name AS ISHOD
--INTO tmpCovidCases
FROM #tTotal t INNER JOIN dbo.vw_Diagnosis d ON
		t.rf_idCase=d.rf_idCase
				INNER JOIN dbo.vw_sprT001 l ON
        t.CodeM=l.CodeM
				INNER JOIN oms_nsi.dbo.sprInsuranceFactDocumentType tt ON
        t.rf_idF008=tt.Id
				INNER JOIN dbo.vw_sprV009 v9 ON
        t.RSLT=v9.id
				INNER JOIN dbo.vw_sprV012 v12 ON
        t.ISHOD=v12.id
WHERE l.CodeM='121501'
GO
DROP TABLE #tCases
GO
DROP TABLE #tCovidRegister
GO
DROP TABLE #tTotal        