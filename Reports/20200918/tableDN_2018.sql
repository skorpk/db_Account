USE AccountOMS
go
DECLARE @dateStartReg DATETIME='20180101',
		@dateEndReg DATETIME='20190127',
		@dateStartRegRAK DATETIME='20190101',
		@dateEndRegRAK DATETIME='20180127',
		@year INT=2017

SELECT m.DiagnosisCode INTO #tDiag FROM dbo.vw_sprMKB10 m WHERE m.MainDS LIKE 'C%'
INSERT #tDiag SELECT m.DiagnosisCode FROM dbo.vw_sprMKB10 m WHERE m.MainDS BETWEEN 'D00' AND 'D09'
INSERT #tDiag SELECT m.DiagnosisCode FROM dbo.vw_sprMKB10 m WHERE m.MainDS BETWEEN 'I00' AND 'I99'
INSERT #tDiag SELECT m.DiagnosisCode FROM dbo.vw_sprMKB10 m WHERE m.DiagnosisCode BETWEEN 'E10.0' AND 'E14.9'
INSERT #tDiag SELECT m.DiagnosisCode FROM dbo.vw_sprMKB10 m WHERE m.DiagnosisCode BETWEEN 'J40' AND 'J98.2'



SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportYear,dd.DS1,c.DateEnd,pp.Sex AS W
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase										
					INNER JOIN #tDiag d ON
            dd.DS1=d.DiagnosisCode					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@year AND f.TypeFile='H' AND c.rf_idV006 =3 AND a.rf_idSMO<>'34'

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,p.ENP,a.ReportYear,dd.DiagnosisCode,cc.DateEnd,pp.Sex
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient	
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id		
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase		
					INNER JOIN #tDiag d ON
            dd.DiagnosisCode=d.DiagnosisCode									
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@year AND f.TypeFile='F'
	 AND c.rf_idV006 =3  AND a.rf_idSMO<>'34'

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportYear,dd.DiagnosisCode,c.DateEnd,pp.Sex
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient	
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id		
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase				
					INNER JOIN #tDiag d ON
            dd.DiagnosisCode=d.DiagnosisCode			
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@year AND f.TypeFile='F'
	 AND c.rf_idV006 =3  AND a.rf_idSMO<>'34'

---------------------------------------------------------------------------------------------------------------
INSERT #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,2018,dd.DS1,c.DateEnd,pp.Sex
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase										
					INNER JOIN #tDiag d ON
            dd.DS1=d.DiagnosisCode					
WHERE f.DateRegistration>='20170101' AND f.DateRegistration<'20180127'  AND a.ReportYear=2017 AND c.rf_idV006 <4 AND a.rf_idSMO<>'34'

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,p.ENP,2018,dd.DiagnosisCode,cc.DateEnd,pp.Sex
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient	
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id		
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase		
					INNER JOIN #tDiag d ON
            dd.DiagnosisCode=d.DiagnosisCode									
WHERE f.DateRegistration>='20170101' AND f.DateRegistration<'20180127'  AND a.ReportYear=2017 AND f.TypeFile='F' AND c.rf_idV006 =3  AND a.rf_idSMO<>'34'

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,2018,dd.DiagnosisCode,c.DateEnd,pp.Sex
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient	
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id		
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase				
					INNER JOIN #tDiag d ON
            dd.DiagnosisCode=d.DiagnosisCode			
WHERE f.DateRegistration>='20170101' AND f.DateRegistration<'20180127'  AND a.ReportYear=2017 AND f.TypeFile='F'  AND c.rf_idV006 =3  AND a.rf_idSMO<>'34'
----------------------------------------------------------------------------------------------------------------


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT rf_idCase,ENP,ReportYear,DS1,DateEnd,W INTO tmpPeopleDN_2018
FROM #t WHERE AmountPayment>0 
GO
DROP TABLE #t
GO
DROP TABLE #tDiag