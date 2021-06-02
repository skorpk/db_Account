USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20180101',
		@dateEndReg DATETIME=GETDATE(),
		@reportYearStart SMALLINT=2018,
		@reportYearEnd SMALLINT=2020


SELECT MainDS,DiagnosisCode INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS IN('E10','E11','E12','E13','E14')

create table #t
(
	nrec bigint IDENTITY(1,1) NOT NULL,		
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


INSERT #t(spol ,npol ,enp ,fam ,im ,ot ,dr , mr ,docn ,ss,dd,DateBeg, Sex)
SELECT DISTINCT r.SeriaPolis,r.NumberPolis,pp.ENP,p.Fam,p.im,p.ot, p.BirthDay,p.BirthPlace,doc.NumberDocument,doc.SNILS,'20200101' AS DateEnd,'20200101' AS DateBeg,p.rf_idV005
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
			AND p.rf_idRecordCase = r.id
					INNER JOIN dbo.t_PatientSMO pp ON
            r.id=pp.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase												
					INNER JOIN #tDiag d ON
            dd.DiagnosisCode=d.DiagnosisCode
					LEFT JOIN t_RegisterPatientDocument doc ON
			p.id=doc.rf_idRegisterPatient
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear BETWEEN @reportYearStart AND @reportYearEnd AND  a.rf_idSMO<>'34'
AND dd.TypeDiagnosis=1 AND f.TypeFile='H' AND c.rf_idV006<4

INSERT #t(spol ,npol ,enp ,fam ,im ,ot ,dr , mr ,docn ,ss,dd,DateBeg, Sex)
SELECT DISTINCT r.SeriaPolis,r.NumberPolis,pp.ENP,p.Fam,p.im,p.ot, p.BirthDay,p.BirthPlace,doc.NumberDocument,doc.SNILS,'20200101' AS DateEnd,'20200101' AS DateBeg,p.rf_idV005
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
			AND p.rf_idRecordCase = r.id
					INNER JOIN dbo.t_PatientSMO pp ON
            r.id=pp.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase												
					INNER JOIN #tDiag d ON
            dd.DiagnosisCode=d.DiagnosisCode
					LEFT JOIN t_RegisterPatientDocument doc ON
			p.id=doc.rf_idRegisterPatient
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear BETWEEN @reportYearStart AND @reportYearEnd AND  a.rf_idSMO<>'34'
AND f.TypeFile='F' AND c.rf_idV006=3

INSERT #t(spol ,npol ,enp ,fam ,im ,ot ,dr , mr ,docn ,ss,dd,DateBeg, Sex)
SELECT DISTINCT r.SeriaPolis,r.NumberPolis,pp.ENP,p.Fam,p.im,p.ot, p.BirthDay,p.BirthPlace,doc.NumberDocument,doc.SNILS,'20200101' AS DateEnd,'20200101' AS DateBeg,p.rf_idV005
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
			AND p.rf_idRecordCase = r.id
					INNER JOIN dbo.t_PatientSMO pp ON
            r.id=pp.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase												
					INNER JOIN #tDiag d ON
            dd.DiagnosisCode=d.DiagnosisCode
					LEFT JOIN t_RegisterPatientDocument doc ON
			p.id=doc.rf_idRegisterPatient
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear BETWEEN @reportYearStart AND @reportYearEnd AND  a.rf_idSMO<>'34'
AND f.TypeFile='F' AND c.rf_idV006=3
----------------------------------Определяем живых------------------------
exec Utility.dbo.sp_GetPid 

DELETE FROM #t
FROM #t p INNER JOIN PolicyRegister.dbo.PEOPLE vp ON
		p.PID=vp.ID		
WHERE ISNULL(vp.ds,'22220101')<'20200101' 
--------------------------------Ковид----------------------------------------------------------
DECLARE @dateStart DATETIME='20200101',
		@dateEnd DATETIME=GETDATE()
SELECT COUNT(DISTINCT penp), COUNT(DISTINCT ENP) FROM #t
	
SELECT t.penp, tt.rf_idCase,
             tt.CodeM,
             tt.AmountPayment,
             tt.TypeRequest,
             tt.rf_idCompletedCase,
             tt.AmmPay,
             tt.CodeSMO,
             tt.rf_idV009,
             tt.DiagnosisCode,
             tt.Age,
             tt.ENP
INTO #tECovid
FROM #t t LEFT JOIN (		
					SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, cc.id AS rf_idCompletedCase,cc.AmountPayment AS AmmPay,a.rf_idSMO AS CodeSMO,c.rf_idV009,d.DiagnosisCode,c.Age
						,ps.ENP
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
					WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode IN('U07.1','U07.2') AND c.rf_idV006<4
				) tt on
				t.penp=tt.enp

SELECT COUNT(DISTINCT penp) AS AllPeople,COUNT(DISTINCT enp) AS AllSickPeople,COUNT(DISTINCT CASE WHEN rf_idV009 IN(105,106,205,206,313,405,406,411) THEN enp ELSE NULL END) AS AllDiedPeople
FROM #tECovid 
GO
DROP TABLE #tDiag
GO
DROP TABLE #t
GO
DROP TABLE #tECovid