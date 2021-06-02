USE AccountOMS
go
--UPDATE dbo.t_SendingDataIntoFFOMS SET PVT=0
/* для полных дублей
DECLARE @v6 TINYINT=2
;WITH doubleDS
AS(
  SELECT rf_idCase,IdPeople,DS1,DateBegin, DateEnd 
  FROM t_SendingDataIntoFFOMS 
  WHERE PVT=0 AND rf_idV006=@v6
  GROUP BY rf_idCase,IdPeople,DS1,DateBegin,DateEnd
),PVT3 as (SELECT s.IDPeople,s.DS1,d.dateBegin,d.DateEnd
			   FROM doubleDS d INNER JOIN (SELECT DISTINCT rf_idCase,IdPeople,DS1,DateBegin,DateEnd FROM  dbo.t_SendingDataIntoFFOMS WHERE rf_idV006=@v6) s ON	
					d.IDPeople=s.IDPeople
					AND d.DS1=s.DS1
					AND d.dateBegin=s.DateBegin		
					AND d.DateEnd=s.DateEnd
				GROUP BY s.IDPeople,s.DS1,d.dateBegin,d.DateEnd HAVING COUNT(*)>1)
UPDATE s SET s.IsFullDoubleDate=1
FROM PVT3 d INNER JOIN dbo.t_SendingDataIntoFFOMS s ON	
					d.IDPeople=s.IDPeople
					AND d.DS1=s.DS1
					AND d.dateBegin=s.DateBegin
					AND d.DateEnd=s.DateEnd
WHERE rf_idV006=@v6
*/
/*
--Step 1 определяем PVT=3. Делать не нужно т.к полные дубли мы исключили
DECLARE @v6 TINYINT=2
;WITH doubleCase
AS(
  SELECT rf_idCase,IdPeople,DS1,DateBegin 
  FROM t_SendingDataIntoFFOMS 
  WHERE PVT=0 AND rf_idV006=@v6
  GROUP BY rf_idCase,IdPeople,DS1,DateBegin
),doubleDS as(SELECT IdPeople,DS1,MIN(dateBegin) AS dateBegin FROM doubleCase GROUP BY IdPeople,DS1 ),
	PVT3 AS (SELECT s.IDPeople,s.DS1,d.dateBegin
			FROM doubleDS d INNER JOIN (SELECT DISTINCT rf_idCase,IdPeople,DS1,DateBegin FROM  dbo.t_SendingDataIntoFFOMS WHERE rf_idV006=@v6) s ON	
					d.IDPeople=s.IDPeople
					AND d.DS1=s.DS1
					AND d.dateBegin=s.DateBegin		
		GROUP BY s.IDPeople,s.DS1,d.dateBegin HAVING COUNT(*)>1)
UPDATE s SET s.PVT=3
FROM PVT3 d INNER JOIN dbo.t_SendingDataIntoFFOMS s ON	
					d.IDPeople=s.IDPeople
					AND d.DS1=s.DS1
					AND d.dateBegin=s.DateBegin
WHERE rf_idV006=@v6
*/
---------------------------------------------------------------------------------------------------------------------
-- update dbo.t_SendingDataIntoFFOMS SET PVT=0 WHERE PVT>0
--update dbo.t_SendingDataIntoFFOMS SET IsDisableCheck=0 WHERE IsDisableCheck=1 
--Step 1 Простовляю IsDisableCheck=1 для курсовой реабилитации, что бы не учитывать ее в дальнейшем
UPDATE s SET IsDisableCheck=1
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN (VALUES (1,'1300111'),(1,'1300112'),(1,'1300113'),(1,'1303111'),(1,'1303112'),(1,'1303113'),(1,'1500111'),(1,'1500112'),(1,'1500113'),(1,'1300035'),
													 (1,'1300036'),(1,'1300107'),(1,'1300108'),(1,'1300109'),(1,'1300110'),(1,'1303108'),(1,'1303109'),(1,'1303110'),(1,'1307035'),(1,'1307036'),
													 (1,'1307107'),(1,'1307108'),(1,'1307109'),(1,'1307110'),(2,'2500111'),(2,'2500112'),(2,'2500113'),(2,'2303111'),(2,'2303112'),(2,'2303113'),
													 (2,'2500099'),(2,'2500100'),(2,'2300108'),(2,'2300109'),(2,'2300110'),(2,'2303108'),(2,'2303109'),(2,'2303110')) v(v6,Mes) ON
			              s.rf_idV006=v.v6
						  AND s.MEs=v.MES 
WHERE IsFullDoubleDate=0						                                     

UPDATE s SET IsDisableCheck=1
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN (VALUES(1,'1500013','A16.20.036.003'),(1,'1500138','A16.26.132'),(1,'1500232','A16.14.037'),(1,'1505232','A16.14.037')
													,(2,'2303232','A16.14.037'),(2,'2500013','A16.20.036.003'),(2,'2500138','A16.26.132'),(2,'2500232','A16.14.037') ) v(v6,Mes,MUSurgery) ON
			              s.rf_idV006=v.v6
						  AND s.MEs=v.MES
						  AND s.MUSurgery=v.MUSurgery
WHERE IsFullDoubleDate=0


---------------------------------------------------------------------------------------------------------------------
--Убираем случаи из выборки у которых DateBegin=DateEnd и результат обращения равен 102
UPDATE dbo.t_SendingDataIntoFFOMS SET IsDisableCheck=1 WHERE DateBegin=DateEnd AND rf_idV009=102


--Step 1 определяем PVT=1 или PVT=2. Исключая случаи с курсовой реабилитацией и не учитываем случаи с IsFullDoubleDate=0
DECLARE @v6 TINYINT=2

;WITH doubleCase
AS(
SELECT rf_idCase,IdPeople,DS1 FROM t_SendingDataIntoFFOMS WHERE PVT=0 AND rf_idV006=@v6 AND IsDisableCheck=0 AND IsFullDoubleDate=0 GROUP BY rf_idCase,IdPeople,DS1
),doubleDS as(SELECT IdPeople,DS1 FROM doubleCase GROUP BY IdPeople,DS1 HAVING COUNT(*)>1), 
cteMin AS (SELECT TOP 1 WITH TIES d.IDPeople,d.DS1,DateBegin AS MinDateBegin
			FROM doubleDS d INNER JOIN dbo.t_SendingDataIntoFFOMS s ON	
					d.IDPeople=s.IDPeople
					AND d.DS1=s.DS1
			WHERE s.rf_idV006=@v6 AND s.IsDisableCheck=0 AND s.IsFullDoubleDate=0
			ORDER BY ROW_NUMBER() OVER(PARTITION BY d.IDPeople,d.DS1 ORDER BY DateBegin,DateEnd)
			
			)
SELECT d.IDPeople, d.DS1,s.DateEnd,rf_idCase
INTO #tmpDateBeg
FROM cteMin d INNER JOIN dbo.t_SendingDataIntoFFOMS s ON	
					d.IDPeople=s.IDPeople
					AND d.DS1=s.DS1
					AND d.MinDateBegin=s.DateBegin
WHERE s.rf_idV006=@v6 AND s.IsDisableCheck=0 AND s.IsFullDoubleDate=0
-----------------------------------------------------------------------------------------------------------------------
;WITH cteRepeat
AS(
	SELECT distinct ROW_NUMBER() OVER(PARTITION BY d.IDPeople,d.DS1 ORDER BY s.DateBegin,s.DateEnd) AS id,
			 s.rf_idCase, s.IDPeople,s.DS1,s.DateBegin,s.DateEnd	
	FROM #tmpDateBeg d inner JOIN dbo.t_SendingDataIntoFFOMS s ON	
			d.IDPeople=s.IDPeople
			AND d.DS1=s.DS1
	WHERE s.IsFullDoubleDate=0 AND s.rf_idV006=@v6
)
UPDATE s SET s.PVT=(CASE WHEN DATEDIFF(d,c1.DateEnd,c2.DateBegin)>0 AND DATEDIFF(d,c1.DateEnd,c2.DateBegin)+1<=28 THEN 1 
	         WHEN DATEDIFF(d,c1.DateEnd,c2.DateBegin)+1>28 AND DATEDIFF(d,c1.DateEnd,c2.DateBegin)+1<=90 THEN 2 ELSE 0 END )
from cteRepeat c1 inner JOIN cteRepeat c2 ON
		c1.IDPeople=c2.IDPeople
		AND c1.DS1=c2.DS1
		AND c1.id+1=c2.id
				INNER JOIN dbo.t_SendingDataIntoFFOMS s ON
		c2.rf_idCase=s.rf_idCase 
WHERE s.rf_idV006=@v6 AND IsDisableCheck=0 AND s.IsFullDoubleDate=0		

			   
DROP TABLE #tmpDateBeg
