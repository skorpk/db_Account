USE AccountOMS
go
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME='20200125',
		@dateStartRegRAK DATETIME='20190101',
		@dateEndRegRAK DATETIME=GETDATE(),
		@year INT=2019
		

SELECT DiagnosisCode ,MainDS INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #tDiag SELECT DiagnosisCode ,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D48'

SELECT DiagnosisCode ,MainDS INTO #tDiag2 FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #tDiag2 SELECT DiagnosisCode ,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'


CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tDiag(DiagnosisCode)
CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tDiag2(DiagnosisCode)


SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportMonth,a.ReportYear,CASE WHEN d.MainDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12
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
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DS1=d.DiagnosisCode
					inner JOIN t_PurposeOfVisit pv ON
             c.id=pv.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@year AND f.TypeFile='H' AND c.rf_idV006 =3 AND pv.DN IN (1,2)  AND a.rf_idSMO<>'34'

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportMonth,a.ReportYear,CASE WHEN d.MainDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12
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
	 AND c.rf_idV006 =3 AND c.IsNeedDisp IN(1,2) AND a.rf_idSMO<>'34'

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportMonth,a.ReportYear,CASE WHEN d.MainDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12
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
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@year  AND f.TypeFile='F'
	 AND c.rf_idV006 =3 AND dd.IsNeedDisp IN(1,2) AND a.rf_idSMO<>'34'


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT * INTO tmpOnkologia2019 FROM #t WHERE AmountPayment>0
GO
DROP TABLE #t
go
DROP TABLE #tDiag
GO
DROP TABLE #tDiag2