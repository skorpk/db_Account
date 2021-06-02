USE AccountOMS
GO
DECLARE @dateStart DATETIME='20180101',	--всегда с начало года
		@dateEnd DATETIME='20190130',
		@reportYear SMALLINT=2018

------берем с диагнозом из списка
SELECT COUNT(DISTINCT ENP),COUNT(DISTINCT c.id)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient					  										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient																	   					  					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear 

SELECT a.ReportMonth, COUNT(DISTINCT c.id)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient					  										     
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear 
GROUP BY a.ReportMonth
ORDER BY a.ReportMonth

SELECT a.ReportMonth, SUM(DATALENGTH(f.FileZIP))/128
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles										
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear 
GROUP BY a.ReportMonth
ORDER BY a.ReportMonth