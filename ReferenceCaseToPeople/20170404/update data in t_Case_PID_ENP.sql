USE AccountOMS
GO

UPDATE ce SET ce.PID=p.PIDNew
FROM dbo.tmpPeopleCase p INNER JOIN dbo.t_Case_PID_ENP ce ON
			p.id=ce.rf_idCase
WHERE ce.PID<>p.PIDNew