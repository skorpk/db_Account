USE AccountOMS
GO
SELECT t.CodeSMO, s.sNameS,SUM(Col5) AS Col5, SUM(Col6) AS Col6, SUM(Col7) AS Col7, SUM(Col8) AS Col8, SUM(Col9) AS Col9
FROM (
-------------column 3----------------
SELECT SMO AS CodeSMO,COUNT(p.PID)  AS Col3,0 AS Col4,0 AS Col5,0 AS Col6, 0 AS Col7, 0 AS Col8, 0 AS Col9
FROM PeopleAttach.dbo.tempPeoplePolis p
GROUP BY p.SMO
-----------column 4-----------------------
UNION ALL
SELECT p.CodeSMO,0 AS Col3,COUNT(p.PID) AS Col4,0 AS Col5,0 AS Col6, 0 AS Col7, 0 AS Col8, 0 AS Col9
FROM dbo.tmpDeadPID p
GROUP BY p.CodeSMO
----------column 5---------------
UNION ALL
SELECT p.SMO,0 AS Col3,0 AS Col4,COUNT(p.PID) AS Col5,0 AS Col6, 0 AS Col7, 0 AS Col8, 0 AS Col9
FROM PeopleAttach.dbo.tempPeoplePolis p
WHERE NOT EXISTS(SELECT * FROM dbo.tmpReportForFFOMS WHERE PID=p.PID)
GROUP BY p.SMO
-----------column 6-----------------------
UNION ALL 
SELECT p.CodeSMO,0 AS Col3,0 AS Col4,0 AS Col5,COUNT(p.PID) AS Col6, 0 AS Col7, 0 AS Col8, 0 AS Col9
FROM dbo.tmpDeadPID p
WHERE NOT EXISTS(SELECT * FROM dbo.tmpReportForFFOMS WHERE PID=p.PID)
GROUP BY p.CodeSMO
-----------column 8-----------------------
UNION ALL
SELECT p.SMO,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6, 0 AS Col7, COUNT(p.PID) AS Col8, 0 AS Col9
FROM PeopleAttach.dbo.tempPeoplePolis p
WHERE EXISTS(SELECT * FROM dbo.tmpReportForFFOMS WHERE PID=p.PID AND IsDispAccount=1)
GROUP BY p.SMO
-----------column 9-----------------------
UNION ALL
SELECT p.CodeSMO,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6, 0 AS Col7, 0 AS Col8, COUNT(DISTINCT p.PID) AS Col9
FROM dbo.tmpDeadPID p
WHERE p.IsNeedDisp=1 AND NOT EXISTS(SELECT * FROM dbo.tmpReportForFFOMS WHERE PID=p.PID )
GROUP BY p.CodeSMO
) t INNER JOIN dbo.vw_sprSMO s ON
		t.CodeSMO=s.smocod
GROUP BY t.CodeSMO,s.sNameS
ORDER BY t.CodeSMO