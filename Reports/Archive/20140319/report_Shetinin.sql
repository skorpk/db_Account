USE AccountOMSReports
GO
SELECT ID,V002,SUM(PeopleCount2) AS Col2,SUM(PeopleCount8) AS Col2
FROM (
	SELECT v002.Id,v002.Name AS V002,COUNT(DISTINCT pid.IDPeople) AS PeopleCount2,0 AS PeopleCount8
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient
						INNER JOIN  oms_NSI.dbo.sprV002 v002 ON
				c.rf_idV002=v002.Id
						INNER JOIN dbo.t_People_Case pid ON
				c.id=pid.rf_idCase
	WHERE f.DateRegistration>'20130101' AND f.DateRegistration<GETDATE() AND a.ReportYear=2013 AND c.rf_idV008 IN(3,31) AND c.rf_idV006=1 AND a.rf_idSMO<>'34'
	GROUP BY v002.Id,v002.Name
	UNION ALL
	SELECT v002.Id,v002.Name,0,COUNT(DISTINCT pid.IDPeople) 
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient
						INNER JOIN (VALUES(1),(11),(12),(13)) v(v008) ON
				c.rf_idV008=v.v008
						INNER JOIN  oms_NSI.dbo.sprV002 v002 ON
				c.rf_idV002=v002.Id
						INNER JOIN dbo.t_People_Case pid ON
				c.id=pid.rf_idCase
	WHERE f.DateRegistration>'20130101' AND f.DateRegistration<GETDATE() AND a.ReportYear=2013 AND c.rf_idV006=3 AND a.rf_idSMO<>'34'
	GROUP BY v002.Id,v002.Name
	) t
GROUP BY ID,V002
ORDER BY ID
