USE AccountOMSReports
GO
SELECT rf_idCase,idMU,MUSurgery
INTO #t
FROM dbo.t_SendingDataIntoFFOMS 
WHERE ReportMonth=5 AND idMU IS NOT NULL AND TypeCases=10
GROUP BY rf_idCase,idMU,MUSurgery
HAVING COUNT(*)>1
BEGIN TRANSACTION
DELETE FROM dbo.t_SendingDataIntoFFOMS
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN #t t ON
				s.rf_idCase=t.rf_idCase
				AND t.idMU = s.idMU
				AND t.MUSurgery = s.MUSurgery
WHERE s.TotalPriceMU IS null
commit
GO
DROP TABLE #t