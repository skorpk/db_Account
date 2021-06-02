USE AccountOMS
go
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME=GETDATE(),
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME=GETDATE(),
		@year INT=2020
		



SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,p.ENP,a.ReportMonth,a.ReportYear,dd.DS1,cc.DateEnd
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
					inner JOIN t_PurposeOfVisit pv ON
             c.id=pv.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@year AND f.TypeFile='H'
	 AND c.rf_idV006 =3 AND pv.DN IN (1,2) AND a.rf_idSMO<>'34'

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,p.ENP,a.ReportMonth,a.ReportYear,dd.DiagnosisCode,cc.DateEnd
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@year AND f.TypeFile='F'
	 AND c.rf_idV006 =3 AND c.IsNeedDisp IN(1,2) AND a.rf_idSMO<>'34'

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,p.ENP,a.ReportMonth,a.ReportYear,dd.DiagnosisCode,cc.DateEnd
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@year AND f.TypeFile='F'
	 AND c.rf_idV006 =3 AND dd.IsNeedDisp IN(1,2) AND a.rf_idSMO<>'34'


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
--DROP TABLE tmpPeopleDN_2019

DROP TABLE tmpPeopleDN_2020

--SELECT rf_idCase,ENP,ReportMonth,ReportYear,DS1,DateEnd INTO tmpPeopleDN_2019 
--FROM #t WHERE AmountPayment>0 AND ReportYear=2019

SELECT rf_idCase,ENP,ReportYear,DS1,DateEnd, CAST(NULL AS CHAR(1)) AS W INTO tmpPeopleDN_2020 FROM #t WHERE AmountPayment>0 AND ReportYear=2020 AND ReportMonth<7
GO
DROP TABLE #t
go
