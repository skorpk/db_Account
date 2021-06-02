USE AccountOMS
GO
DECLARE @dateStart DATETIME='20140101',
		@dateEnd DATETIME=GETDATE()

;WITH cte
AS(
SELECT z.PID, z.ENP,c.DateEnd,c.id,f.CodeM
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
SELECT z.PID, z.ENP,c.DateEnd,c.id,f.CodeM
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
),
cte2
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY pid,enp ORDER BY DateEnd desc) AS idRow,PID,ENP, DateEnd AS lastdt_vlg, COUNT(id) AS cnt_vlg,CodeM
FROM cte GROUP BY pid,enp,DateEnd,CodeM
),
cte3
AS
(
	SELECT pid,COUNT(id) AS cnt_vl FROM cte GROUP BY pid
)
SELECT c.PID,c.ENP,lastdt_vlg,CodeM,cnt_vlg
INTO #t
FROM cte2 c INNER JOIN cte3 c1 ON
		c.pid=c1.pid
WHERE idRow=1

BEGIN TRANSACTION
UPDATE z SET z.lastdt=T.lastdt_vlg,z.cnt=T.cnt_vlg,LPU=CodeM
from PeopleAttach.dbo.ZL z INNER JOIN #t t ON
			z.pid=t.pid
			AND z.enp=t.enp
--SELECT *FROM PeopleAttach.dbo.ZL WHERE pid IN(2046551,2166721)

commit
GO
DROP TABLE #t