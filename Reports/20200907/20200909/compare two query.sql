USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20200811',
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME=GETDATE(),
		@reportYear SMALLINT=2020

declare @firstDayNextMonth DATE='20200801'

SELECT DiagnosisCode,MainDS INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'I00' AND 'I99'
--UNION ALL
--SELECT DiagnosisCode,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS ='G45'

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,@firstDayNextMonth AS dd,d.MainDS,p1.DN
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
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode	
					INNER JOIN dbo.t_PurposeOfVisit p1 on
			c.id=p1.rf_idCase			
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<8 AND a.rf_idSMO<>'34'  AND dd.TypeDiagnosis=1 AND c.rf_idV006=3 AND p1.DN IN(1,2)

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,@firstDayNextMonth AS dd,d.MainDS,c.IsNeedDisp
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
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase																
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode				
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<8 AND a.rf_idSMO<>'34' AND f.TypeFile='F' /*AND dd.TypeDiagnosis<>1*/ AND c.Age>17 AND c.IsNeedDisp IN(1,2)
	AND c.rf_idV006=3


INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,@firstDayNextMonth AS dd,d.MainDS,dd.IsNeedDisp
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
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase					
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode													
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<8 AND a.rf_idSMO<>'34' AND f.TypeFile='F'  AND dd.IsNeedDisp IN(1,2) AND c.rf_idV006=3

DELETE FROM #t WHERE Age<18

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT COUNT(*) FROM #t WHERE AmountPayment>0

SELECT COUNT(*) FROM tmpDSB2020

GO
--DROP TABLE #t
--GO
--DROP TABLE #tDiag