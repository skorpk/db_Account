USE AccountOMS
GO
CREATE PROCEDURE usp_GetDataForReportDN
as
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME=GETDATE(),
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME=GETDATE(),
		@reportYear SMALLINT=2020
		


SELECT DiagnosisCode ,MainDS INTO #tDiag 
FROM dbo.vw_sprMKB10 WHERE MainDS between'I00' AND 'I98' --берем только до подрубрики I98 т.к I99 стоит в исключени€х
	AND DiagnosisCode NOT IN('I51.1','I51.2','I51.3','I65.0','I65.1','I65.2','I65.3','I65.8','I65.9','I67.6',
										'I67.8','I83.0','I83.1','I83.2','I83.9','I85.0','I85.9','I86.0','I86.1','I86.2','I86.8','I87.0','I87.1','I87.2',
										'I87.8','I87.9','I88.0','I88.1','I88.9','I89.0','I89.1','I89.8','I89.9','I97.8','I99')

CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tDiag(DiagnosisCode)

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,dd.DS1,c.rf_idRecordCasePatient,f.DateRegistration,a.ReportMonth,pv.DN
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND f.TypeFile='H'
	 AND c.rf_idV006 =3 AND pv.rf_idV025='1.3' AND pv.DN IN (1,2) AND c.Age>17

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,dd.DiagnosisCode,c.rf_idRecordCasePatient,f.DateRegistration,a.ReportMonth,c.IsNeedDisp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND f.TypeFile='F'
	 AND c.rf_idV006 =3 AND c.IsNeedDisp IN(1,2) AND c.Age>17

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,dd.DiagnosisCode,c.rf_idRecordCasePatient,f.DateRegistration,a.ReportMonth,dd.IsNeedDisp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear  AND f.TypeFile='F'
	 AND c.rf_idV006 =3 AND dd.IsNeedDisp IN(1,2) AND c.Age>17

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


SELECT ENP,DS1,DN,rf_idCase,DateRegistration,CAST(NULL AS INT) AS rf_D02Person,ReportMonth
INTO dbo.tmp_DN_I
FROM #tCases 
WHERE AmountPayment>0

DROP TABLE #tCases

DROP TABLE #tDiag
go
--DROP TABLE dbo.tmp_DN_I