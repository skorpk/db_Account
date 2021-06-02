USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200301',
		@dateEnd DATETIME='20201008',
		@dateEndPay DATETIME='20201008'

SELECT ENP--,CASE WHEN Amobulance_Source=1 THEN 3 ELSE 1 END AS V006,CodeM_Source AS CodeM
INTO #tCovidRegister
FROM PeopleAttach.dbo.t_CovidRegister202011103 WHERE ENP IS NOT NULL

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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=1
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='U07.1' --AND a.rf_idSMO<>'34'
		

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,cc.id AS rf_idRecordCasePatient
,cc.AmountPayment AS AmmPay,ENP, CASE WHEN d.TypeDiagnosis=3 AND d.DiagnosisCode ='B34.2' THEN d.DiagnosisCode ELSE NULL END AS DS2
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
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='B34.2' --AND a.rf_idSMO<>'34'
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<7 AND c.rf_idV006=3
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='U07.1'-- AND a.rf_idSMO<>'34'
		AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82) )

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, c.AmountPayment,3 AS TypeRequest, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,c.rf_idRecordCasePatient
,c.AmountPayment AS AmmPay,ENP, CASE WHEN d.TypeDiagnosis=3 AND d.DiagnosisCode ='B34.2' THEN d.DiagnosisCode ELSE NULL END AS DS2
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
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode='B34.2'-- AND a.rf_idSMO<>'34'
	AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82) )

UPDATE p SET p.AmountDeduction=r.AmountDeduction, p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE AmountPayment=0.0
----------------------------------------------------------------------------------------------
create table #t
(
	nrec bigint not null,		
	pid int null,			
	penp varchar(16) null,	
	sKey varchar(3) null,	
	sid	int null,			
	q varchar(5) null,		
	lid int null,			
	lpu varchar(6) null,	
	spol varchar(20) null,
	npol varchar(20) null,
	enp varchar(16) null,
	fam varchar(40) null,
	im varchar(40) null,
	ot varchar(40) null,
	dr datetime null,
	mr varchar(100) null,
	docn varchar(20) null,
	ss varchar(14) NULL,
	dd DATE NOT NULL,
	IsDelete TINYINT NULL,
	Step TINYINT  NOT NULL DEFAULT 9,
	DateBeg DATE,
	Sex TINYINT 
)
INSERT #t( nrec ,spol ,npol ,enp ,fam ,im ,ot ,dr , mr ,docn ,ss,dd,DateBeg, Sex)
SELECT distinct c.rf_idRecordCasePatient,r.SeriaPolis,r.NumberPolis,c.ENP,p.Fam,p.im,p.ot, p.BirthDay,p.BirthPlace,d.NumberDocument,d.SNILS,c1.DateEnd,c1.DateBegin,p.rf_idV005
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case cc ON
			r.id=cc.rf_idRecordCasePatient
			INNER JOIN dbo.t_CompletedCase c1 ON
			r.id=c1.rf_idRecordCasePatient
					INNER join #tCases c ON
			cc.id=c.rf_idCase           
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
					LEFT JOIN t_RegisterPatientDocument d ON
			p.id=d.rf_idRegisterPatient

exec Utility.dbo.sp_GetPid 
SELECT * FROM #t WHERE fam='Овсеенко'

UPDATE  c SET c.enp=t.penp
FROM #t t INNER JOIN #tCases c ON
		t.nrec=c.rf_idRecordCasePatient
---------------------------------------------------------------
SELECT c.rf_idCase,cc.rf_idRecordCasePatient, f.CodeM,a.Account,a.DateRegister AS DateAccount,cc.idRecordCase,c.ENP,cc.DateBegin
,cc.DateEnd,CAST(c.AmountPayment AS MONEY) AS AmountPayment,CASE WHEN c.TypeRequest=1 THEN 'Стационарно' ELSE 'Амбулаторно' END AS V006, 1 AS TypeQuery
,p.Fam+' '+ ISNULL(p.im,'')+' '+ISNULL(p.ot,'') AS FIO, p.BirthDay,d.SNILS,r.rf_idF008,r.NumberPolis,cc.rf_idV009 AS RSLT,cc.rf_idV012 AS ISHOD,c.DS2
,p.Sex
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
WHERE NOT EXISTS(SELECT 1 FROM #tCovidRegister cr WHERE /*cr.CodeM=c.CodeM  AND*/ cr.ENP=c.ENP)


GO
DROP TABLE #tCases
GO
DROP TABLE #tCovidRegister
GO
DROP TABLE #t