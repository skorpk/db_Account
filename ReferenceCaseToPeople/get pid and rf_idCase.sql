USE AccountOMS
GO
SELECT ce.rf_idCase,p.id AS PID, p.ENP,p.FAM,p.IM,p.OT,p.DR,p.SS AS SNILS,p.DOCTP,p.DOCS,p.DOCN
FROM dbo.t_Case_PID_ENP ce INNER JOIN PolicyRegister.dbo.PEOPLE p ON
			ce.pid=p.ID
WHERE ce.ReportYear=2016