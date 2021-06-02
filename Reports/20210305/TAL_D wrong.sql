USE AccountOMS
GO
DECLARE @dateStart DATETIME='20210109',
		@dateEnd DATETIME=GETDATE()


SELECT DISTINCT c.id, f.CodeM,s.*,p.BirthDay,1 AS TypeQ
INTO #t
FROM dbo.t_File f JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles					
					JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					JOIN dbo.t_RegisterPatient p ON
            f.id=p.rf_idFiles
			AND r.id=p.rf_idRecordCase
					JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient											
					JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient																
					JOIN dbo.t_SlipOfPaper s ON
            c.id=s.rf_idCase
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2021 AND DATEDIFF(DAY,s.DateHospitalization,p.BirthDay)>0--s.DateHospitalization <=CAST(p.BirthDay AS DATETIME)
UNION all
SELECT DISTINCT c.id, f.CodeM,s.*,c.DateEnd,1 AS TypeQ
FROM dbo.t_File f JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles					
					JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient											
					JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient																
					JOIN dbo.t_SlipOfPaper s ON
            c.id=s.rf_idCase
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2021 AND DATEDIFF(DAY,s.DateHospitalization,c.DateEnd)<0
SELECT * FROM #t 


SELECT t.CodeM+' - '+l.NAMES AS LPU,COUNT(DISTINCT id) 
FROM #t t INNER JOIN dbo.vw_sprT001 l ON
		t.CodeM=l.CodeM
GROUP BY t.CodeM+' - '+l.NAMES
GO
DROP TABLE #t