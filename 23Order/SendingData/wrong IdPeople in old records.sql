USE AccountOMS
GO

--SELECT c.rf_idCase,c.IDPeople,s.IDPeople
--FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN dbo.t_People_Case c ON
--			s.rf_idCase=c.rf_idCase
--WHERE s.IDPeople<>c.IDPeople AND s.ReportYear=206
--поиск дублированных записей
;WITH cte
AS(
SELECT s.id,s.IDPeople,DS1
FROM dbo.t_SendingDataIntoFFOMS s
WHERE s.IsUnload=0 AND ReportYear=2016 AND EXISTS(SELECT * FROM dbo.t_SendingDataIntoFFOMS WHERE IDPeople=s.IDPeople AND DS1=s.DS1 AND IsUnload=1 AND ReportYear=2016 AND rf_idV006=s.rf_idV006)
)
SELECT s.rf_idCase,s.IDPeople
INTO #t
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN cte c ON
		s.IDPeople=c.IDPeople
		AND s.DS1=c.DS1
WHERE s.IsUnload=1
ORDER BY s.IDPeople, s.DateBegin

BEGIN TRANSACTION
UPDATE s SET s.IDPeople=p.IdPeople
FROM #t t INNER JOIN dbo.t_People_Case p ON
		t.rf_idCase=p.rf_idCase
			INNER JOIN dbo.t_SendingDataIntoFFOMS s ON
		t.rf_idCase=s.rf_idCase          
commit
go

--DROP TABLE #t