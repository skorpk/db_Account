USE AccountOMS
go
DECLARE @dateStartReg DATETIME='20170101',
		@dateEndReg DATETIME='20190125',
		@dateStartRegRAK DATETIME='20170101',
		@dateEndRegRAK DATETIME=GETDATE()

DECLARE @dd DATE='20190101'		

SELECT DiagnosisCode ,MainDS INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #tDiag SELECT DiagnosisCode ,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D48'

SELECT DiagnosisCode ,MainDS INTO #tDiag2 FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #tDiag2 SELECT DiagnosisCode ,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'


CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tDiag(DiagnosisCode)
CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tDiag2(DiagnosisCode)
---------------------------------------------------2018-------------------------------------------------
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportMonth,a.ReportYear,CASE WHEN d.MainDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DS1=d.DiagnosisCode
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=2018 AND f.TypeFile='H' AND c.rf_idV006 =3 AND a.rf_idSMO<>'34'

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportMonth,a.ReportYear,CASE WHEN d.MainDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient						
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear =2018  AND f.TypeFile='F'
	 AND c.rf_idV006 =3   AND a.rf_idSMO<>'34'

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportMonth,a.ReportYear,CASE WHEN d.MainDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient						
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear =2018 AND f.TypeFile='F' AND c.rf_idV006 =3  AND a.rf_idSMO<>'34'

-------------------------------------------2017-----------------------------------------
INSERT #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportMonth,2017,CASE WHEN d.MainDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP p ON
            c.id=p.rf_idCase
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DS1=d.DiagnosisCode					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=2017 AND f.TypeFile='H' AND c.rf_idV006 <4 AND a.rf_idSMO<>'34'
	AND p.enp IS NOT NULL


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT * INTO tmpOnkologia2018 FROM #t WHERE AmountPayment>0
GO
DROP TABLE #t
go
DROP TABLE #tDiag
GO
DROP TABLE #tDiag2