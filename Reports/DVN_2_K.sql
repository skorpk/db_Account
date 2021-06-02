USE AccountOMS
go
DECLARE @reportYear SMALLINT=2013,
		@quarter TINYINT=3,
		--@dateBegin DATETIME='20130501',
		@dateEnd DATETIME='20130723 10:40'

declare @t as table
(
		MonthID tinyint
		,QuarterID tinyint		
)

insert @t values(1,1),(2,1),(3,1),
				(4,2),(5,2),(6,2),
				(7,3),(8,3),(9,3),
				(10,4),(11,4),(12,4)
DECLARE @monthMax TINYINT=(SELECT max(MonthID) FROM @t WHERE QuarterID=@quarter)

CREATE table #tCase (id bigint,Step TINYINT,rf_idV009 smallint,AmountPayment decimal(11,2), Comments varCHAR(10),Age TINYINT,Sex CHAR(1),AmountPaymentAccept decimal(11,2),CodeM CHAR(6))

INSERT #tCase( id, Step, rf_idV009,AmountPayment,Comments,Age,Sex,CodeM )
SELECT t.id,t.Step,t.rf_idV009,t.AmountPayment,Comments,Age,Sex,rf_idMO
from (				
		SELECT c.id,1 AS Step,c.rf_idV009,c.AmountPayment,c.Comments,c.Age,p.Sex,c.rf_idMO
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth>=1					
					AND a.ReportYear=2013							
					AND a.ReportMonth<=@monthMax		
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
						  INNER JOIN dbo.t_RegisterPatient p ON
					f.id=p.rf_idFiles
					AND r.id=p.rf_idRecordCase
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.IsCompletedCase=1
					AND c.DateEnd<=@dateEnd
					AND c.DateEnd>='20130101'
							INNER JOIN dbo.t_MES mes ON
					c.id=mes.rf_idCase
							INNER JOIN dbo.vw_sprMUCompletedCase mu ON
					mes.MES=mu.MU
		WHERE a.Letter='R' AND mu.MUGroupCode=72 AND MUUnGroupCode=1 AND f.DateRegistration>='20130501' AND f.DateRegistration<=@dateEnd
				AND c.Comments IS NOT NULL	
		) t
GROUP BY t.id,t.Step,t.rf_idV009,t.AmountPayment,Comments,Age,Sex,t.rf_idMO
			
SELECT c.CodeM,l.NameS,1 RowID,'Всего взрослых' AS Col1,		
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4
FROM #tCase c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
GROUP BY c.CodeM,l.NameS		
UNION ALL
SELECT c.CodeM,l.NameS,2,'МУЖ' AS Col1,		
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4		
FROM #tCase c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE sex='М'
GROUP BY c.CodeM,l.NameS
UNION ALL
SELECT c.CodeM,l.NameS,3,'ЖЕН' AS Col1,	
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4
FROM #tCase c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE sex='Ж'
GROUP BY c.CodeM,l.NameS
-------------Работающие-----------------------
UNION ALL
SELECT c.CodeM,l.NameS,4,'Работающие граждане' AS Col1,		
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4
FROM #tCase c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE Comments='20'
GROUP BY c.CodeM,l.NameS
UNION ALL
SELECT c.CodeM,l.NameS,5,'МУЖ' AS Col1,		
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4
FROM #tCase c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE sex='М' AND Comments='20'
GROUP BY c.CodeM,l.NameS
UNION ALL
SELECT c.CodeM,l.NameS,6,'ЖЕН' AS Col1,		
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4
FROM #tCase c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE sex='Ж' AND Comments='20'
GROUP BY c.CodeM,l.NameS
-------------неРаботающие-----------------------
UNION ALL
SELECT c.CodeM,l.NameS,7,'Неработающие граждане' AS Col1,		
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4
FROM #tCase c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE Comments='10'
GROUP BY c.CodeM,l.NameS
UNION ALL
SELECT c.CodeM,l.NameS,8,'МУЖ' AS Col1,		
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4
FROM #tCase c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE sex='М' AND Comments='10'
GROUP BY c.CodeM,l.NameS
UNION ALL
SELECT c.CodeM,l.NameS,9,'ЖЕН' AS Col1,		
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4
FROM #tCase c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE sex='Ж' AND Comments='10'
GROUP BY c.CodeM,l.NameS
-------------Обучающиеся-----------------------
UNION ALL
SELECT c.CodeM,l.NameS,11,'Обучающиеся граждане' AS Col1,		
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4
FROM #tCase c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE Comments='14'
GROUP BY c.CodeM,l.NameS
UNION ALL
SELECT c.CodeM,l.NameS,12,'МУЖ' AS Col1,		
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4
FROM #tCase c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE sex='М' AND Comments='14'
GROUP BY c.CodeM,l.NameS
UNION ALL
SELECT c.CodeM,l.NameS,13,'ЖЕН' AS Col1,		
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4
FROM #tCase c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE sex='Ж' AND Comments='14'
GROUP BY c.CodeM,l.NameS
ORDER BY c.CodeM,RowId
--clear
DROP TABLE #tCase
GO