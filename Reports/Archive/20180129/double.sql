USE AccountOMS
GO
;WITH cteDouble
AS(
SELECT enp,TypeDisp
FROM tmpDisp GROUP BY enp,TypeDisp HAVING COUNT(*)>1
) 
SELECT dd.*
FROM cteDouble d inner JOIN dbo.tmpDisp dd ON
		d.enp=dd.ENP
		AND d.TypeDisp = dd.TypeDisp
ORDER BY d.enp



