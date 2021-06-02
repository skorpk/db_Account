USE AccountOMS
GO
DECLARE @dateStart DATETIME='20180101',
		@dateEnd DATETIME=GETDATE(),
		@reportYear SMALLINT=2018

--;WITH cte
--AS(
SELECT (CASE WHEN f.CodeM='611001' THEN 2 ELSE 1 END) AS PRIZNAK,z.PID, p.ENP,MAX(c.DateEnd) AS LASTDATE ,count(c.id) AS COUNT_Case 
INTO PeopleAttach.dbo.ZL2
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient											                 					
					INNER JOIN PeopleAttach.dbo.zl z ON
			p.Enp=z.enp
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear>=@reportYear AND f.CodeM IN('711001','611001')
GROUP BY (CASE WHEN f.CodeM='611001' THEN 2 ELSE 1 END),z.PID, p.ENP
--)
--SELECT *
--FROM cte c INNER JOIN cte c2 ON
--		c.enp=c2.enp
--		AND c.PRIZNAK<>c2.PRIZNAK