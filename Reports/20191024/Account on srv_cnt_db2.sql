USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190901',
		@dateEnd DATETIME=GETDATE(),
		@reportYear SMALLINT=2019,
		@reportMonth TINYINT=10

SELECT DISTINCT f.FileNameHR,f.CodeM,a.rf_idSMO AS CodeSMO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles					    					
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND f.CodeM IN('141023','251001') 
		AND a.ReportMonth=@reportMonth AND f.FileNameHR LIKE 'H%'
ORDER BY CodeSMO,CodeM, FileNameHR
		

GO
