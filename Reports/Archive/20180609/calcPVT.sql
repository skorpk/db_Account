USE AccountOMS
GO

;WITH doubleCase
AS(
	SELECT rf_idCase,ENP,DS1,rf_idV006 
	FROM t_OrderAdult_104_2018 
	WHERE PVT=0  
	GROUP BY rf_idCase,ENP,DS1,rf_idV006
),doubleDS as(SELECT ENP,DS1,rf_idV006 FROM doubleCase GROUP BY ENP,DS1,rf_idV006 HAVING COUNT(*)>1), 
cteMin AS (SELECT TOP 1 WITH TIES d.ENP,d.DS1,DateBegin AS MinDateBegin,s.rf_idV006
			FROM doubleDS d INNER JOIN dbo.t_OrderAdult_104_2018 s ON	
					d.ENP=s.ENP
					AND d.DS1=s.DS1
					AND d.rf_idV006=s.rf_idV006
			ORDER BY ROW_NUMBER() OVER(PARTITION BY d.ENP,d.DS1,s.rf_idV006 ORDER BY DateBegin,DateEnd)
			
			)
SELECT  d.ENP, d.DS1,s.DateEnd,rf_idCase,s.rf_idV006
INTO #tmpDateBeg
FROM cteMin d INNER JOIN dbo.t_OrderAdult_104_2018 s ON	
					d.ENP=s.ENP
					AND d.DS1=s.DS1
					AND d.MinDateBegin=s.DateBegin
					AND d.rf_idV006=s.rf_idV006
GROUP BY d.ENP, d.DS1,s.DateEnd,rf_idCase,s.rf_idV006
-----------------------------------------------------------------------------------------------------------------------
--второй этап. Ќеобходимо проставить PVT только дл€ новых случаев, но пока что это не точно.
;WITH cteRepeat
AS(
	SELECT distinct ROW_NUMBER() OVER(PARTITION BY d.ENP,d.DS1,d.rf_idV006 ORDER BY s.DateBegin,s.DateEnd) AS id,
			 s.rf_idCase, s.ENP,s.DS1,s.DateBegin,s.DateEnd,s.rf_idV006			 	
	FROM #tmpDateBeg d inner JOIN (SELECT DISTINCT ENP,DS1,DateBegin,DateEnd,rf_idCase,s.rf_idV006
								   from dbo.t_OrderAdult_104_2018 s ) s ON	
			d.ENP=s.ENP
			AND d.DS1=s.DS1	
			AND d.rf_idV006=s.rf_idV006
)
SELECT s.rf_idCase,(CASE WHEN DATEDIFF(d,c1.DateEnd,c2.DateBegin)>0 AND DATEDIFF(d,c1.DateEnd,c2.DateBegin)+1<=28 THEN 1 
						WHEN DATEDIFF(d,c1.DateEnd,c2.DateBegin)>29 AND DATEDIFF(d,c1.DateEnd,c2.DateBegin)+1<=90 THEN 2
					ELSE 0 END ) AS PVT
INTO #tt
from cteRepeat c1 inner JOIN cteRepeat c2 ON
		c1.ENP=c2.ENP
		AND c1.DS1=c2.DS1
		AND c1.id+1=c2.id
		AND c1.rf_idV006=c2.rf_idV006
				INNER JOIN dbo.t_OrderAdult_104_2018 s ON
		c2.rf_idCase=s.rf_idCase 
		AND c2.rf_idV006=s.rf_idV006

UPDATE s SET s.PVT=T.PVT
FROM dbo.t_OrderAdult_104_2018 s INNER JOIN #tt t ON	
			s.rf_idCase=t.rf_idCase 

DROP TABLE #tmpDateBeg
DROP TABLE #tt