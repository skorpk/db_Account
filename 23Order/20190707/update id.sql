USE AccountOMSReports
GO
--ALTER TABLE dbo.t_SendingDataIntoFFOMS2019 ADD id BIGINT NULL

SELECT  DENSE_RANK() OVER(ORDER BY rf_idCase ,ReportYear,ReportMonth) AS id, rf_idCase
INTO #t
 FROM dbo.t_SendingDataIntoFFOMS2019
BEGIN TRANSACTION
 UPDATE	s SET s.id=T.id
from t_SendingDataIntoFFOMS2019 s INNER JOIN #t T ON
			s.rf_idCase=T.rf_idCase 
commit
GO
DROP TABLE #t