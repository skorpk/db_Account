USE AccountOMS
go
--Для всех случаев с IDSP=4 PVT заполняется 0 и все эти случаи исключаются из дальнейшего рассмотрения
UPDATE s SET IsDisableCheck=1 FROM dbo.t_SendingDataIntoFFOMS s WHERE TypeCases=10
--версия в которой заменил IDPeople на ЕНП
;WITH doubleDS
AS(
  SELECT rf_idCase,ENP,DS1,DateBegin, DateEnd,rf_idV006
  FROM t_SendingDataIntoFFOMS 
  WHERE PVT=0 AND IsUnload=0
  GROUP BY rf_idCase,ENP,DS1,DateBegin,DateEnd,rf_idV006
),PVT3 as (SELECT s.ENP,s.DS1,d.dateBegin,d.DateEnd,d.rf_idV006
			   FROM doubleDS d INNER JOIN (SELECT DISTINCT rf_idCase,ENP,DS1,DateBegin,DateEnd,rf_idV006 FROM  dbo.t_SendingDataIntoFFOMS WHERE /*rf_idV006=@v6 AND*/ IsUnload=0) s ON	
					d.ENP=s.ENP
					AND d.DS1=s.DS1
					AND d.dateBegin=s.DateBegin		
					AND d.DateEnd=s.DateEnd
					AND d.rf_idV006=s.rf_idV006
				GROUP BY s.ENP,s.DS1,d.dateBegin,d.DateEnd,d.rf_idV006
				HAVING COUNT(*)>1)
UPDATE s SET s.IsFullDoubleDate=1,s.IsUnload=1
FROM PVT3 d INNER JOIN dbo.t_SendingDataIntoFFOMS s ON	
					d.ENP=s.ENP
					AND d.DS1=s.DS1
					AND d.dateBegin=s.DateBegin
					AND d.DateEnd=s.DateEnd
					AND d.rf_idV006=s.rf_idV006
WHERE IsUnload=0
GO	  	  
---------------------------------------------------------------------------------------------------------------------
--выполняется только после того как исключили записи отвергнутые экспертами
/*

update dbo.t_SendingDataIntoFFOMS SET PVT=0 WHERE PVT>0 and IsUnload=0 and IsFullDoubleDate=0 and IsDisableCheck=0

*/
--update dbo.t_SendingDataIntoFFOMS SET IsDisableCheck=0 WHERE IsDisableCheck=1 
--Step 1 Простовляю IsDisableCheck=1 для курсовой реабилитации, что бы не учитывать ее в дальнейшем
UPDATE s SET IsDisableCheck=1
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN (VALUES ('31',1),('32',1),('33',1),('84',1),('136',1),('137',1),('138',1),('139',1),('140',1),('141',1),('142',1),('143',1),('179',1),('295',1),
													 ('299',1),('13',2),('14',2),('15',2),('21',2),('22',2),('23',2),('24',2),('31',2),('35',2),('36',2),('41',2),('42',2),('44',2),('45',2),
													('46',2),('50',2),('51',2),('52',2),('53',2),('54',2),('71',2),('109',2),
													------------------------2017-----------------
													('31',1),('32',1),('33',1),('300',1),('84',1),('142',1),('143',1),('144',1),('145',1),('146',1),('147',1),('148',1),('149',1),('185',1),
													('302',1),('306',1),('13',2),('14',2),('15',2),('21',2),('22',2),('23',2),('24',2),('25',2),('32',2),('36',2),('41',2),('42',2),('44',2),
													('45',2),('46',2),('50',2),('51',2),('52',2),('53',2),('54',2),('71',2),('108',2),('111',2),
													------------------------2017-----------------
													('34',1),('314',1),('86',1),('144',1),('145',1),('146',1),('147',1),('157',1),('160',1),('161',1),('162',1),('198',1),('316',1),('320',1),
													('148',1),('149',1),('150',1),('151',1),('152',1),('153',1),('154',1),('155',1),('156',1),('158',1),('14',2),('15',2),('16',2),('22',2),
													('23',2),('24',2),('25',2),('26',2),('33',2),('38',2),('118',2),('43',2),('44',2),('46',2),('47',2),('48',2),('52',2),('53',2),('54',2),
													('55',2),('63',2),('80',2),('121',2),('56',2),('57',2),('58',2),('59',2),('60',2),('61',2),('62',2)) v(csg,v6) ON
			              s.K_KSG=v.csg
						  AND s.rf_idV006=v.v6
WHERE IsFullDoubleDate=0 AND IsUnload=0						                                     
 ---------------------------------------------------------------------------------------------------------------------
--Убираем случаи из выборки у которых DateBegin=DateEnd и результат обращения равен 102
UPDATE dbo.t_SendingDataIntoFFOMS SET IsDisableCheck=1 WHERE DateBegin=DateEnd AND rf_idV009=102 AND IsUnload=0

GO
/*Step  определяем PVT=1 или PVT=2. Исключая случаи с курсовой реабилитацией и не учитываем случаи с IsFullDoubleDate=0
Расчитывать нужно ЗМЕ и на тех записях которые отдали в ФФОМС
получаем так называемый первый случай из всего списка лечения
*/
DECLARE @reportYear SMALLINT=2017

;WITH doubleCase
AS(
	SELECT rf_idCase,ENP,DS1,rf_idV006 
	FROM t_SendingDataIntoFFOMS 
	WHERE PVT=0  AND IsDisableCheck=0 AND IsFullDoubleDate=0 AND ReportYear=@reportYear
	GROUP BY rf_idCase,ENP,DS1,rf_idV006
),doubleDS as(SELECT ENP,DS1,rf_idV006 FROM doubleCase GROUP BY ENP,DS1,rf_idV006 HAVING COUNT(*)>1), 
cteMin AS (SELECT TOP 1 WITH TIES d.ENP,d.DS1,DateBegin AS MinDateBegin,s.rf_idV006
			FROM doubleDS d INNER JOIN dbo.t_SendingDataIntoFFOMS s ON	
					d.ENP=s.ENP
					AND d.DS1=s.DS1
					AND d.rf_idV006=s.rf_idV006
			WHERE s.IsDisableCheck=0 AND s.IsFullDoubleDate=0 AND ReportYear=@reportYear
			ORDER BY ROW_NUMBER() OVER(PARTITION BY d.ENP,d.DS1,s.rf_idV006 ORDER BY DateBegin,DateEnd)
			
			)
SELECT  d.ENP, d.DS1,s.DateEnd,rf_idCase,s.rf_idV006
INTO #tmpDateBeg
FROM cteMin d INNER JOIN dbo.t_SendingDataIntoFFOMS s ON	
					d.ENP=s.ENP
					AND d.DS1=s.DS1
					AND d.MinDateBegin=s.DateBegin
					AND d.rf_idV006=s.rf_idV006
WHERE s.IsDisableCheck=0 AND s.IsFullDoubleDate=0 AND ReportYear=@reportYear
GROUP BY d.ENP, d.DS1,s.DateEnd,rf_idCase,s.rf_idV006
-----------------------------------------------------------------------------------------------------------------------
--второй этап. Необходимо проставить PVT только для новых случаев, но пока что это не точно.
;WITH cteRepeat
AS(
	SELECT distinct ROW_NUMBER() OVER(PARTITION BY d.ENP,d.DS1,d.rf_idV006 ORDER BY s.DateBegin,s.DateEnd) AS id,
			 s.rf_idCase, s.ENP,s.DS1,s.DateBegin,s.DateEnd,s.rf_idV006			 	
	FROM #tmpDateBeg d inner JOIN (SELECT DISTINCT ENP,DS1,DateBegin,DateEnd,rf_idCase,s.rf_idV006
								   from dbo.t_SendingDataIntoFFOMS s
								   WHERE s.IsFullDoubleDate=0 AND ReportYear=@reportYear) s ON	
			d.ENP=s.ENP
			AND d.DS1=s.DS1	
			AND d.rf_idV006=s.rf_idV006
)
--UPDATE s SET s.PVT=(CASE WHEN DATEDIFF(d,c1.DateEnd,c2.DateBegin)>0 AND DATEDIFF(d,c1.DateEnd,c2.DateBegin)+1<=28 THEN 1 
--	         WHEN DATEDIFF(d,c1.DateEnd,c2.DateBegin)+1>28 AND DATEDIFF(d,c1.DateEnd,c2.DateBegin)+1<=90 THEN 2 ELSE 0 END )
SELECT s.rf_idCase,(CASE WHEN DATEDIFF(d,c1.DateEnd,c2.DateBegin)>0 AND DATEDIFF(d,c1.DateEnd,c2.DateBegin)+1<=28 THEN 1 
	         WHEN DATEDIFF(d,c1.DateEnd,c2.DateBegin)+1>28 AND DATEDIFF(d,c1.DateEnd,c2.DateBegin)+1<=90 THEN 2 ELSE 0 END ) AS PVT
INTO #tt
from cteRepeat c1 inner JOIN cteRepeat c2 ON
		c1.ENP=c2.ENP
		AND c1.DS1=c2.DS1
		AND c1.id+1=c2.id
		AND c1.rf_idV006=c2.rf_idV006
				INNER JOIN dbo.t_SendingDataIntoFFOMS s ON
		c2.rf_idCase=s.rf_idCase 
		AND c2.rf_idV006=s.rf_idV006
WHERE IsDisableCheck=0 AND s.IsFullDoubleDate=0	AND IsUnload=0	

UPDATE s SET s.PVT=T.PVT
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN #tt t ON	
			s.rf_idCase=t.rf_idCase

go
DROP TABLE #tmpDateBeg
DROP TABLE #tt
