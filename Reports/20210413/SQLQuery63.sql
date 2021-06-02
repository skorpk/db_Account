USE AccountOMS
GO

DECLARE @dateStartReg DATETIME='20210101',
		@dateEndReg DATETIME=GETDATE(),
		@reportYear SMALLINT=2021,
		@reportMonth TINYINT=MONTH(GETDATE())

SELECT f.CodeM, p.ENP,f.DateRegistration,ReportYear,a.ReportMonth
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					inner JOIN t_PurposeOfVisit pv ON
             c.id=pv.rf_idCase								 
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND f.TypeFile='H' AND a.ReportMonth<=@reportMonth
	 AND c.rf_idV006 =3 AND pv.rf_idV025='1.3' AND c.Age>17 AND a.rf_idSMO<>'34' AND c.rf_idV002 IN(29,42,53,57,97) AND f.CodeM=r.AttachLPU

SELECT f.CodeM, p.ENP,f.DateRegistration,ReportYear,a.ReportMonth
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					inner JOIN t_PurposeOfVisit pv ON
             c.id=pv.rf_idCase								 
WHERE f.DateRegistration>='20210101' AND f.DateRegistration<GETDATE()  AND a.ReportYear>2021 AND f.TypeFile='H' AND a.ReportMonth<=MONTH(GETDATE())
	 AND c.rf_idV006 =3 AND pv.rf_idV025='1.3' AND c.Age>17 AND a.rf_idSMO<>'34' AND c.rf_idV002 IN(29,42,53,57,97) AND f.CodeM=r.AttachLPU