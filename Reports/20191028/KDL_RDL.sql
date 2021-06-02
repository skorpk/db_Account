USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME=GETDATE() 
		
SELECT f.CodeM+' - '+l.NAMES AS LPU,Count(DISTINCT c.id) AS QuntityCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				                
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient											                 													
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase	
					INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM						
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=2019 
		AND  f.CodeM IN('125901','805965') AND c.rf_idDirectMO IN('340015','102604') AND m.MU LIKE '4.%' AND m.Price>0
GROUP BY f.CodeM+' - '+l.NAMES