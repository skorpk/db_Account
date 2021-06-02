USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME=GETDATE(),
		@reportYear SMALLINT=2019	
	
SELECT COUNT(r.id)/10
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts                  	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportMonth>=1 AND a.ReportMonth<=10 AND a.ReportYear=@reportYear
