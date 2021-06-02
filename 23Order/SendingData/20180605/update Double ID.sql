USE AccountOMS
GO
WITH cte 
AS(
SELECT MIN(s.id) AS IdMin,s.rf_idCase
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN dbo.t_SendingDataIntoFFOMS s1 ON
			s.rf_idCase = s1.rf_idCase
			AND s.id <> s1.id
WHERE s.ReportMonth=5 --AND s.K_KSG='DIAL' --AND s.rf_idCase=85141291
GROUP BY s.rf_idCase
)
UPDATE s SET id=c.IdMin
FROM cte c INNER JOIN dbo.t_SendingDataIntoFFOMS s ON
		c.rf_idCase=s.rf_idCase
WHERE c.IdMin<>s.id