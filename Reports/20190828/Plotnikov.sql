USE AccountOMS
GO
DECLARE @dateStart DATETIME='20140101',
		@dateEnd DATETIME=GETDATE()

;WITH cte
AS(
SELECT z.PID, z.ENP,c.DateEnd,c.id
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear>=2017
UNION ALL
SELECT z.PID, z.ENP,c.DateEnd,c.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_Case_PID_ENP pc ON
			c.id=pc.rf_idCase
					INNER JOIN PeopleAttach.dbo.zl z ON
			pc.PID=z.pid
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear>=2013 AND a.ReportYear<2017 --AND pc.PID IS NOT NULL 
)
SELECT PID,ENP, max(DateEnd) AS lastdt_vlg, COUNT(id) AS cnt_vlg
INTO #t
FROM cte GROUP BY pid,enp

BEGIN TRANSACTION
UPDATE z SET z.lastdt=T.lastdt_vlg,z.cnt=T.cnt_vlg
from PeopleAttach.dbo.ZL z INNER JOIN #t t ON
			z.pid=t.pid
			AND z.enp=t.enp
--SELECT *FROM PeopleAttach.dbo.ZL WHERE pid IN(2046551,2166721)

ROLLBACK
GO
DROP TABLE #t