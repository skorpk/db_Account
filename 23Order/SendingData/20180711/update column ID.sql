USE AccountOMS
GO
SELECT DENSE_RANK() OVER(ORDER BY rf_idCase ,ReportYear,ReportMonth) AS id,*
FROM dbo.t_SendingDataIntoFFOMS WHERE ReportMonth=6 AND ReportYear=2018 AND id=1

--SELECT rf_idCase
--FROM dbo.t_SendingDataIntoFFOMS WHERE ReportMonth=6 AND ReportYear=2018 AND id=722
--GROUP BY rf_idCase
--HAVING COUNT(*)>1
/*
BEGIN TRANSACTION
;WITH cte
AS(
SELECT DENSE_RANK() OVER(ORDER BY rf_idCase ,ReportYear,ReportMonth) AS id,rf_idCase 
FROM dbo.t_SendingDataIntoFFOMS 
WHERE ReportMonth=6 AND ReportYear=2018
)
UPDATE s SET s.id=cte.id
from dbo.t_SendingDataIntoFFOMS s INNER JOIN cte ON
		s.rf_idCase=cte.rf_idCase

SELECT COUNT(*)
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN dbo.t_SendingDataIntoFFOMS ss ON
		s.id=ss.id
		AND s.rf_idCase<>ss.rf_idCase
WHERE s.ReportMonth=6 AND ss.ReportMonth=6

commit
*/
