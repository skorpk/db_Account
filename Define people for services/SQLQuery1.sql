USE AccountOMS
GO
/*
UPDATE e SET e.PID=p.id
FROM dbo.t_Case_PID_ENP e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
				e.ENP=p.ENP
WHERE e.ReportYear>2014 AND e.PID IS NULL
*/
UPDATE e SET e.PID=p.id
FROM dbo.t_Case_PID_ENP e INNER JOIN PolicyRegister.dbo.HISTENP p ON
				e.ENP=p.ENP
WHERE e.ReportYear>2014 AND e.PID IS NULL
---отбираем ЕНП, по нашим застрахованным и не найденым в нашей базе
SELECT DISTINCT ENP
FROM dbo.t_Case_PID_ENP e 
WHERE  e.ReportYear>2014 AND e.PID IS NULL 
