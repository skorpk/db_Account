USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME='20200808',
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME=GETDATE(),
		@reportYear SMALLINT=2019,
		@codeSMO CHAR(5)=34007

SELECT 1 AS typeGroup,DiagnosisCode,MainDS INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'I%'
UNION ALL
SELECT 2,DiagnosisCode,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C00' AND 'C97'
UNION ALL
SELECT 2,DiagnosisCode,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'
UNION ALL
SELECT 3 AS typeGroup,DiagnosisCode,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'J%'
UNION ALL
SELECT 4 AS typeGroup,DiagnosisCode,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'K%'
UNION ALL
SELECT 9 AS typeGroup,DiagnosisCode,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'E%'
UNION ALL
SELECT 7 AS typeGroup,DiagnosisCode,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'N%'

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,r.AttachLPU,a.ReportYear
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient		
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear>=@reportYear  AND  a.rf_idSMO<>'34'  AND dd.TypeDiagnosis=1 AND c.rf_idV006<4  AND c.Age>17

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,r.AttachLPU,a.ReportYear
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient		
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase																
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear>=@reportYear AND  a.rf_idSMO<>'34' AND f.TypeFile='F' AND dd.TypeDiagnosis<>1 AND c.rf_idV006=3  AND c.Age>17


INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,r.AttachLPU,a.ReportYear
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient	
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase					
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode										
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear>=@reportYear AND  a.rf_idSMO<>'34' AND f.TypeFile='F' AND c.rf_idV006=3 AND c.Age>17


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT DISTINCT AttachLPU,enp,t.ReportYear
FROM #t t 
WHERE AmountPayment>0 AND NOT EXISTS (SELECT 1 FROM PolicyRegister.dbo.PEOPLE pe WHERE pe.ENP=t.enp
									  UNION ALL
                                      SELECT 1 FROM PolicyRegister.dbo.HISTENP h WHERE h.enp=t.enp  
									  )
ORDER BY t.ReportYear,t.AttachLPU
/*
BEGIN TRANSACTION
INSERT DNVPersons2020(ENP,Place,STEP)
SELECT DISTINCT enp,0,2
FROM #t t 
WHERE AmountPayment>0 AND NOT EXISTS(SELECT 1 FROM dbo.DNVPersons2020 v WHERE v.ENP=t.ENP)

commit
*/
GO
DROP TABLE #t
GO
DROP TABLE #tDiag