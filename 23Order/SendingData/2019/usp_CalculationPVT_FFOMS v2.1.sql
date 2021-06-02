USE [AccountOMSReports]
GO
/****** Object:  StoredProcedure [dbo].[usp_CalculationPVT_FFOMS]    Script Date: 09.02.2019 12:10:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[usp_CalculationPVT_FFOMS2019]
as
--Для всех случаев с IDSP=4 или 28 PVT заполняется 0 и все эти случаи исключаются из дальнейшего рассмотрения
UPDATE s SET IsDisableCheck=1 FROM dbo.t_SendingDataIntoFFOMS s WHERE IDSP IN(4,28)
/*Для случаев IDSP=43 или =33 в условиях оказания 2 – в дневном стационаре, при наличии в случае оплаты по КСГ ds18.002 PVT заполняется 0 и все эти случаи исключаются из дальнейшего рассмотрения*/
UPDATE s SET IsDisableCheck=1 FROM dbo.t_SendingDataIntoFFOMS s WHERE IDSP IN(43,33) AND rf_idV006=2 AND MES='ds18.002'
/*
Из процедуры определения признака повторности лечения для случаев оказания медицинской помощи в стационарных условиях и в условиях дневного стационара (раздельно для каждого условия) 
исключаются все случаи, имеющие в качестве основного диагноза на уровне случая любой из кодов рубрики O (лат.) 
*/
UPDATE s SET IsDisableCheck=1 FROM dbo.t_SendingDataIntoFFOMS s WHERE DS1 LIKE 'O%' AND ReportMonth>4 AND ReportYear>2017
--версия в которой заменил IDPeople на ЕНП
;WITH doubleDS
AS(
  SELECT rf_idCase,ENP,DS1,DateBegin, DateEnd,rf_idV006
  FROM t_SendingDataIntoFFOMS 
  WHERE PVT=0 AND IsUnload=0
  GROUP BY rf_idCase,ENP,DS1,DateBegin,DateEnd,rf_idV006
),PVT3 as (SELECT s.ENP,s.DS1,d.dateBegin,d.DateEnd,d.rf_idV006
			   FROM doubleDS d INNER JOIN (SELECT DISTINCT rf_idCase,ENP,DS1,DateBegin,DateEnd,rf_idV006 FROM  dbo.t_SendingDataIntoFFOMS WHERE IsUnload=0) s ON	
					d.ENP=s.ENP
					AND d.DS1=s.DS1
					AND d.dateBegin=s.DateBegin		
					AND d.DateEnd=s.DateEnd
					AND d.rf_idV006=s.rf_idV006
				GROUP BY s.ENP,s.DS1,d.dateBegin,d.DateEnd,d.rf_idV006
				HAVING COUNT(*)>1)

UPDATE s SET s.IsFullDoubleDate=1--,s.IsUnload=1
FROM PVT3 d INNER JOIN dbo.t_SendingDataIntoFFOMS s ON	
					d.ENP=s.ENP
					AND d.DS1=s.DS1
					AND d.dateBegin=s.DateBegin
					AND d.DateEnd=s.DateEnd
					AND d.rf_idV006=s.rf_idV006
WHERE IsUnload=0
---------------------------------------------------------------------------------------------------------------------
--выполняется только после того как исключили записи отвергнутые экспертами
/*	  
update dbo.t_SendingDataIntoFFOMS SET PVT=0 WHERE PVT>0 and IsUnload=0 and IsFullDoubleDate=0 and IsDisableCheck=0
*/
/* с 2019 отменили
CREATE TABLE #tSurgery(ID VARCHAR(25))
INSERT #tSurgery( ID )
VALUES  ('A16.03.022.002'),('A16.03.022.004'),('A16.03.022.005'),('A16.03.022.006'),('A16.03.024.005'),('A16.03.024.007'),('A16.03.024.008'),('A16.03.024.009'),('A16.03.024.010'),('A16.03.033.002'),
('A16.04.014'),('A16.12.006'),('A16.12.006.001'),('A16.12.006.002'),('A16.12.006.003'),('A16.12.008.001'),('A16.12.008.002'),('A16.12.012'),('A16.20.032.007'),('A16.20.103'),('A16.20.043.001'),
('A16.20.043.002'),('A16.20.043.003'),('A16.20.043.004'),('A16.20.045'),('A16.20.047'),('A16.20.048'),('A16.20.049.001'),('A16.26.011'),('A16.26.019'),('A16.26.020'),('A16.26.021'),('A16.26.021.001'),
('A16.26.023'),('A16.26.079'),('A16.26.147'),('A22.26.004'),('A22.26.005'),('A22.26.006'),('A22.26.007'),('A22.26.009'),('A22.26.010'),('A22.26.019'),('A22.26.023'),('A16.26.075'),('A16.26.075.001'),
('A16.26.093.002'),('A16.26.094')

UPDATE s SET IsDisableCheck=1
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN #tSurgery k ON
			s.MUSurgery=k.ID
*/
--Step 1 Простовляю IsDisableCheck=1 для курсовой реабилитации, что бы не учитывать ее в дальнейшем
UPDATE s SET IsDisableCheck=1
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN (VALUES ('st05.010'),('st05.011'),('st08.001'),('st36.001'),('st15.008'),('st15.009'),
													 ('st05.006'),('st05.007'),('st19.027'),('st19.028'),('st05.009'),('st19.039'),
													 ('st19.040'),('st19.041'),('st19.042'),('st19.043'),('st19.044'),('st19.045'),
													 ('st19.046'),('st19.047'),('st19.048'),('st19.049'),('st19.050'),('st19.051'),
													 ('st19.052'),('st19.053'),('st19.054'),('st19.055'),('st25.004'),('st36.003'),
													 ('st36.007'),('st05.008'),('st19.029'),('st19.030'),('st19.031'),('st19.032'),
													 ('st19.033'),('st19.034'),('st19.035'),('st19.036'),('ds05.007'),('ds05.008'),
													 ('ds08.001'),('ds12.001'),('ds12.002'),('ds12.003'),('ds12.004'),('ds13.002'),
													 ('ds15.002'),('ds15.003'),('ds36.001'),('ds18.002'),('ds18.003'),('ds19.001'),
													 ('ds19.002'),('ds19.003'),('ds19.004'),('ds19.005'),('ds19.006'),('ds19.007'),
													 ('ds19.008'),('ds19.009'),('ds19.010'),('ds19.011'),('ds19.012'),('ds19.013'),
													 ('ds19.014'),('ds19.015'),('ds05.003'),('ds05.004'),('ds05.006'),('ds25.001'),
													 ('ds36.004'),('ds19.018'),('ds19.019'),('ds19.020'),('ds19.021'),('ds19.022'),
													 ('ds19.023'),('ds19.024'),('ds19.025'),('ds19.026'),('ds19.027'),('ds05.005')) v(csg) ON
			              s.MES=v.csg

 ---------------------------------------------------------------------------------------------------------------------
--Убираем случаи из выборки у которых DateBegin=DateEnd и результат обращения равен 102
UPDATE dbo.t_SendingDataIntoFFOMS SET IsDisableCheck=1 WHERE DateBegin=DateEnd AND rf_idV009=102 AND IsUnload=0

/*Step  определяем PVT=1 или PVT=2. Исключая случаи с курсовой реабилитацией и не учитываем случаи с IsFullDoubleDate=0
Расчитывать нужно ЗМЕ и на тех записях которые отдали в ФФОМС
получаем так называемый первый случай из всего списка лечения
*/
DECLARE @reportYear SMALLINT=2018

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
PRINT ('create #tmpDateBeg')
-----------------------------------------------------------------------------------------------------------------------
--второй этап. Необходимо проставить PVT только для новых случаев, но пока что это не точно.

SELECT distinct ROW_NUMBER() OVER(PARTITION BY d.ENP,d.DS1,d.rf_idV006 ORDER BY s.DateBegin,s.DateEnd) AS id,
		 s.rf_idCase, s.ENP,s.DS1,s.DateBegin,s.DateEnd,s.rf_idV006			 	
INTO #t1
FROM #tmpDateBeg d inner JOIN (SELECT DISTINCT ENP,DS1,DateBegin,DateEnd,rf_idCase,s.rf_idV006
							   from dbo.t_SendingDataIntoFFOMS s
							   WHERE s.IsFullDoubleDate=0 AND ReportYear=@reportYear) s ON	
		d.ENP=s.ENP
		AND d.DS1=s.DS1	
		AND d.rf_idV006=s.rf_idV006

SELECT s.rf_idCase,(CASE WHEN DATEDIFF(d,c1.DateEnd,c2.DateBegin)>0 AND DATEDIFF(d,c1.DateEnd,c2.DateBegin)+1<=30 THEN 1 ELSE 0 END ) AS PVT
INTO #tt
from #t1 c1 inner JOIN #t1 c2 ON
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


DROP TABLE #tmpDateBeg
DROP TABLE #tt

