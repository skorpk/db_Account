USE AccountOMSReports
go
DECLARE @dateStartReg DATETIME='20210101',
		@dateEndReg DATETIME=GETDATE(),
		@reportYear SMALLINT=2021,
		@reportMonth TINYINT=12

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,cc.id AS rf_idCompletedCase,a.ReportMonth,cc.AmountPayment AS AmountPaymentLPU,c.rf_idV006 AS USL_OK
,f.DateRegistration,a.ReportYear
INTO t_CaseReportOblKomIT
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear>=@reportYear AND a.ReportMonth<=@reportMonth