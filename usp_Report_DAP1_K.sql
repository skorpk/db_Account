use AccountOMS
go
if OBJECT_ID('usp_Report_DAP1_K',N'P') is not null
drop proc usp_Report_DAP1_K
go
create procedure usp_Report_DAP1_K
					@reportYear SMALLINT,
					@quarter TINYINT,
					@dateBegin DATETIME,
					@dateEnd DATETIME
AS
declare @t as table
(
		MonthID tinyint
		,QuarterID tinyint		
)

insert @t values(1,1),(2,1),(3,1),
				(4,2),(5,2),(6,2),
				(7,3),(8,3),(9,3),
				(10,4),(11,4),(12,4)
				
DECLARE @dateBeginQuarter DATETIME,
		@dateEndQuarter DATE
SELECT 	@dateBeginQuarter =CAST(@reportYear AS CHAR(4))+ CASE WHEN @quarter=1 THEN '0101' WHEN @quarter=2 THEN '0401' WHEN @quarter=3 THEN '0701'
																ELSE '1001' END,
		@dateEndQuarter=CAST(@reportYear AS CHAR(4))+ CASE WHEN @quarter=1 THEN '0331' WHEN @quarter=2 THEN '0630' WHEN @quarter=3 THEN '0930'
																ELSE '1231' END

CREATE table #tCase (id bigint,Step TINYINT,rf_idV009 smallint,AmountPayment decimal(11,2), Comments varCHAR(10),Age TINYINT,Sex CHAR(1),AmountPaymentAccept decimal(11,2))

INSERT #tCase( id, Step, rf_idV009,AmountPayment,Comments,Age,Sex )
SELECT t.id,t.Step,t.rf_idV009,t.AmountPayment,Comments,Age,Sex
from (				
		SELECT c.id,1 AS Step,c.rf_idV009,c.AmountPayment,c.Comments,c.Age,p.Sex
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN @t t ON
					a.ReportMonth=t.MonthID
					AND t.QuarterID=@quarter
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
						  INNER JOIN dbo.t_RegisterPatient p ON
					f.id=p.rf_idFiles
					AND r.id=p.rf_idRecordCase
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.IsCompletedCase=1
					AND c.DateEnd<=@dateEndQuarter
					AND c.DateEnd>='20130101'
							INNER JOIN dbo.t_MES mes ON
					c.id=mes.rf_idCase
							INNER JOIN dbo.vw_sprMUCompletedCase mu ON
					mes.MES=mu.MU
		WHERE a.Letter='O' AND mu.MUGroupCode=70 AND MUUnGroupCode=3 AND f.DateRegistration>=@dateBeginQuarter AND f.DateRegistration<=@dateEnd
				AND c.Comments IS NOT NULL
		UNION ALL 
		SELECT c.id,1,c.rf_idV009,c.AmountPayment,c.Comments,c.Age,p.Sex
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN @t t ON
					a.ReportMonth=t.MonthID
					AND t.QuarterID=(@quarter-1)
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
						   INNER JOIN dbo.t_RegisterPatient p ON
					f.id=p.rf_idFiles
					AND r.id=p.rf_idRecordCase
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.IsCompletedCase=1
					AND c.DateEnd<=@dateEndQuarter
					AND c.DateEnd>='20130101'
							INNER JOIN dbo.t_MES mes ON
					c.id=mes.rf_idCase
							INNER JOIN dbo.vw_sprMUCompletedCase mu ON
					mes.MES=mu.MU
		WHERE a.Letter='O' AND mu.MUGroupCode=70 AND MUUnGroupCode=3 AND f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd
		--------------------------------t_Meduslugi-----------------------------------------------------
		UNION ALL
		SELECT DISTINCT c.id,2,c.rf_idV009,c.AmountPayment,c.Comments,c.Age,p.Sex
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN @t t ON
					a.ReportMonth=t.MonthID
					AND t.QuarterID=@quarter
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
						   INNER JOIN dbo.t_RegisterPatient p ON
					f.id=p.rf_idFiles
					AND r.id=p.rf_idRecordCase
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.IsCompletedCase=0
							INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase					
		WHERE a.Letter='O' AND m.MUGroupCode=2 AND MUUnGroupCode=84 AND f.DateRegistration>=@dateBeginQuarter AND f.DateRegistration<=@dateEnd
		UNION ALL 
		SELECT DISTINCT c.id,2,c.rf_idV009,c.AmountPayment,c.Comments,c.Age,p.Sex
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN @t t ON
					a.ReportMonth=t.MonthID
					AND t.QuarterID=(@quarter-1)
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
						   INNER JOIN dbo.t_RegisterPatient p ON
					f.id=p.rf_idFiles
					AND r.id=p.rf_idRecordCase
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.IsCompletedCase=1
							INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase					
		WHERE a.Letter='O' AND m.MUGroupCode=2 AND MUUnGroupCode=84 AND f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd	
		) t
GROUP BY t.id,t.Step,t.rf_idV009,t.AmountPayment,Comments,Age,Sex

UPDATE c  
SET c.AmountPaymentAccept=c1.AmountPaymentAccept
FROM #tCase c INNER JOIN (
							select c.id,SUM(sc.AmountPaymentAccept) AS AmountPaymentAccept
							FROM dbo.t_PaidCase sc INNER JOIN #tCase c ON
												sc.rf_idCase=c.id
							WHERE sc.DateRegistration>=@dateBegin AND sc.DateRegistration<=@dateEnd AND sc.Letter='O'
							GROUP BY c.id
							) c1 ON c.id=c1.id
						
			
SELECT 'Всего взрослых' AS Col1,
		SUM(c.AmountPayment) AS col3,
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4,
		SUM(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) AS col5,
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col6,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) AS col7,
		SUM(ISNULL(c.AmountPaymentAccept,0)) AS col8,
		SUM(CASE WHEN c.Step=1 THEN ISNULL(c.AmountPaymentAccept,0) ELSE 0 END) AS col9,
		SUM(CASE WHEN c.Step=2 THEN isnull(c.AmountPaymentAccept,0) ELSE 0 END) AS col10,
		SUM(CASE WHEN c.rf_idV009=316 THEN 1 ELSE 0 END) AS col11,
		SUM(CASE WHEN c.rf_idV009=317 THEN 1 ELSE 0 END) AS col12,
		SUM(CASE WHEN c.rf_idV009=318 THEN 1 ELSE 0 END) AS col13,
		SUM(CASE WHEN c.rf_idV009=319 THEN 1 ELSE 0 END) AS col14
FROM #tCase c
UNION ALL
SELECT 'МУЖ' AS Col1,
		SUM(c.AmountPayment) AS col3,
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4,
		SUM(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) AS col5,
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col6,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) AS col7,
		SUM(ISNULL(c.AmountPaymentAccept,0)) AS col8,
		SUM(CASE WHEN c.Step=1 THEN ISNULL(c.AmountPaymentAccept,0) ELSE 0 END) AS col9,
		SUM(CASE WHEN c.Step=2 THEN isnull(c.AmountPaymentAccept,0) ELSE 0 END) AS col10,
		SUM(CASE WHEN c.rf_idV009=316 THEN 1 ELSE 0 END) AS col11,
		SUM(CASE WHEN c.rf_idV009=317 THEN 1 ELSE 0 END) AS col12,
		SUM(CASE WHEN c.rf_idV009=318 THEN 1 ELSE 0 END) AS col13,
		SUM(CASE WHEN c.rf_idV009=319 THEN 1 ELSE 0 END) AS col14
FROM #tCase c
WHERE sex='М'
UNION ALL
SELECT 'ЖЕН' AS Col1,
		SUM(c.AmountPayment) AS col3,
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4,
		SUM(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) AS col5,
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col6,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) AS col7,
		SUM(ISNULL(c.AmountPaymentAccept,0)) AS col8,
		SUM(CASE WHEN c.Step=1 THEN ISNULL(c.AmountPaymentAccept,0) ELSE 0 END) AS col9,
		SUM(CASE WHEN c.Step=2 THEN isnull(c.AmountPaymentAccept,0) ELSE 0 END) AS col10,
		SUM(CASE WHEN c.rf_idV009=316 THEN 1 ELSE 0 END) AS col11,
		SUM(CASE WHEN c.rf_idV009=317 THEN 1 ELSE 0 END) AS col12,
		SUM(CASE WHEN c.rf_idV009=318 THEN 1 ELSE 0 END) AS col13,
		SUM(CASE WHEN c.rf_idV009=319 THEN 1 ELSE 0 END) AS col14
FROM #tCase c
WHERE sex='Ж'
-------------Работающие-----------------------
UNION ALL
SELECT 'Работающие граждане' AS Col1,
		SUM(c.AmountPayment) AS col3,
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4,
		SUM(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) AS col5,
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col6,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) AS col7,
		SUM(ISNULL(c.AmountPaymentAccept,0)) AS col8,
		SUM(CASE WHEN c.Step=1 THEN ISNULL(c.AmountPaymentAccept,0) ELSE 0 END) AS col9,
		SUM(CASE WHEN c.Step=2 THEN isnull(c.AmountPaymentAccept,0) ELSE 0 END) AS col10,
		SUM(CASE WHEN c.rf_idV009=316 THEN 1 ELSE 0 END) AS col11,
		SUM(CASE WHEN c.rf_idV009=317 THEN 1 ELSE 0 END) AS col12,
		SUM(CASE WHEN c.rf_idV009=318 THEN 1 ELSE 0 END) AS col13,
		SUM(CASE WHEN c.rf_idV009=319 THEN 1 ELSE 0 END) AS col14
FROM #tCase c
WHERE Comments='20'
UNION ALL
SELECT 'МУЖ' AS Col1,
		SUM(c.AmountPayment) AS col3,
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4,
		SUM(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) AS col5,
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col6,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) AS col7,
		SUM(ISNULL(c.AmountPaymentAccept,0)) AS col8,
		SUM(CASE WHEN c.Step=1 THEN ISNULL(c.AmountPaymentAccept,0) ELSE 0 END) AS col9,
		SUM(CASE WHEN c.Step=2 THEN isnull(c.AmountPaymentAccept,0) ELSE 0 END) AS col10,
		SUM(CASE WHEN c.rf_idV009=316 THEN 1 ELSE 0 END) AS col11,
		SUM(CASE WHEN c.rf_idV009=317 THEN 1 ELSE 0 END) AS col12,
		SUM(CASE WHEN c.rf_idV009=318 THEN 1 ELSE 0 END) AS col13,
		SUM(CASE WHEN c.rf_idV009=319 THEN 1 ELSE 0 END) AS col14
FROM #tCase c
WHERE sex='М' AND Comments='20'
UNION ALL
SELECT 'ЖЕН' AS Col1,
		SUM(c.AmountPayment) AS col3,
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4,
		SUM(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) AS col5,
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col6,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) AS col7,
		SUM(ISNULL(c.AmountPaymentAccept,0)) AS col8,
		SUM(CASE WHEN c.Step=1 THEN ISNULL(c.AmountPaymentAccept,0) ELSE 0 END) AS col9,
		SUM(CASE WHEN c.Step=2 THEN isnull(c.AmountPaymentAccept,0) ELSE 0 END) AS col10,
		SUM(CASE WHEN c.rf_idV009=316 THEN 1 ELSE 0 END) AS col11,
		SUM(CASE WHEN c.rf_idV009=317 THEN 1 ELSE 0 END) AS col12,
		SUM(CASE WHEN c.rf_idV009=318 THEN 1 ELSE 0 END) AS col13,
		SUM(CASE WHEN c.rf_idV009=319 THEN 1 ELSE 0 END) AS col14
FROM #tCase c
WHERE sex='Ж' AND Comments='20'
-------------неРаботающие-----------------------
UNION ALL
SELECT 'Неработающие граждане' AS Col1,
		SUM(c.AmountPayment) AS col3,
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4,
		SUM(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) AS col5,
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col6,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) AS col7,
		SUM(ISNULL(c.AmountPaymentAccept,0)) AS col8,
		SUM(CASE WHEN c.Step=1 THEN ISNULL(c.AmountPaymentAccept,0) ELSE 0 END) AS col9,
		SUM(CASE WHEN c.Step=2 THEN isnull(c.AmountPaymentAccept,0) ELSE 0 END) AS col10,
		SUM(CASE WHEN c.rf_idV009=316 THEN 1 ELSE 0 END) AS col11,
		SUM(CASE WHEN c.rf_idV009=317 THEN 1 ELSE 0 END) AS col12,
		SUM(CASE WHEN c.rf_idV009=318 THEN 1 ELSE 0 END) AS col13,
		SUM(CASE WHEN c.rf_idV009=319 THEN 1 ELSE 0 END) AS col14
FROM #tCase c
WHERE Comments='10'
UNION ALL
SELECT 'МУЖ' AS Col1,
		SUM(c.AmountPayment) AS col3,
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4,
		SUM(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) AS col5,
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col6,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) AS col7,
		SUM(ISNULL(c.AmountPaymentAccept,0)) AS col8,
		SUM(CASE WHEN c.Step=1 THEN ISNULL(c.AmountPaymentAccept,0) ELSE 0 END) AS col9,
		SUM(CASE WHEN c.Step=2 THEN isnull(c.AmountPaymentAccept,0) ELSE 0 END) AS col10,
		SUM(CASE WHEN c.rf_idV009=316 THEN 1 ELSE 0 END) AS col11,
		SUM(CASE WHEN c.rf_idV009=317 THEN 1 ELSE 0 END) AS col12,
		SUM(CASE WHEN c.rf_idV009=318 THEN 1 ELSE 0 END) AS col13,
		SUM(CASE WHEN c.rf_idV009=319 THEN 1 ELSE 0 END) AS col14
FROM #tCase c
WHERE sex='М' AND Comments='10'
UNION ALL
SELECT 'ЖЕН' AS Col1,
		SUM(c.AmountPayment) AS col3,
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4,
		SUM(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) AS col5,
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col6,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) AS col7,
		SUM(ISNULL(c.AmountPaymentAccept,0)) AS col8,
		SUM(CASE WHEN c.Step=1 THEN ISNULL(c.AmountPaymentAccept,0) ELSE 0 END) AS col9,
		SUM(CASE WHEN c.Step=2 THEN isnull(c.AmountPaymentAccept,0) ELSE 0 END) AS col10,
		SUM(CASE WHEN c.rf_idV009=316 THEN 1 ELSE 0 END) AS col11,
		SUM(CASE WHEN c.rf_idV009=317 THEN 1 ELSE 0 END) AS col12,
		SUM(CASE WHEN c.rf_idV009=318 THEN 1 ELSE 0 END) AS col13,
		SUM(CASE WHEN c.rf_idV009=319 THEN 1 ELSE 0 END) AS col14
FROM #tCase c
WHERE sex='Ж' AND Comments='10'
-------------Обучающиеся-----------------------
UNION ALL
SELECT 'Обучающиеся граждане' AS Col1,
		SUM(c.AmountPayment) AS col3,
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4,
		SUM(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) AS col5,
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col6,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) AS col7,
		SUM(ISNULL(c.AmountPaymentAccept,0)) AS col8,
		SUM(CASE WHEN c.Step=1 THEN ISNULL(c.AmountPaymentAccept,0) ELSE 0 END) AS col9,
		SUM(CASE WHEN c.Step=2 THEN isnull(c.AmountPaymentAccept,0) ELSE 0 END) AS col10,
		SUM(CASE WHEN c.rf_idV009=316 THEN 1 ELSE 0 END) AS col11,
		SUM(CASE WHEN c.rf_idV009=317 THEN 1 ELSE 0 END) AS col12,
		SUM(CASE WHEN c.rf_idV009=318 THEN 1 ELSE 0 END) AS col13,
		SUM(CASE WHEN c.rf_idV009=319 THEN 1 ELSE 0 END) AS col14
FROM #tCase c
WHERE Comments='14'
UNION ALL
SELECT 'МУЖ' AS Col1,
		SUM(c.AmountPayment) AS col3,
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4,
		SUM(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) AS col5,
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col6,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) AS col7,
		SUM(ISNULL(c.AmountPaymentAccept,0)) AS col8,
		SUM(CASE WHEN c.Step=1 THEN ISNULL(c.AmountPaymentAccept,0) ELSE 0 END) AS col9,
		SUM(CASE WHEN c.Step=2 THEN isnull(c.AmountPaymentAccept,0) ELSE 0 END) AS col10,
		SUM(CASE WHEN c.rf_idV009=316 THEN 1 ELSE 0 END) AS col11,
		SUM(CASE WHEN c.rf_idV009=317 THEN 1 ELSE 0 END) AS col12,
		SUM(CASE WHEN c.rf_idV009=318 THEN 1 ELSE 0 END) AS col13,
		SUM(CASE WHEN c.rf_idV009=319 THEN 1 ELSE 0 END) AS col14
FROM #tCase c
WHERE sex='М' AND Comments='14'
UNION ALL
SELECT 'ЖЕН' AS Col1,
		SUM(c.AmountPayment) AS col3,
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4,
		SUM(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) AS col5,
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col6,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) AS col7,
		SUM(ISNULL(c.AmountPaymentAccept,0)) AS col8,
		SUM(CASE WHEN c.Step=1 THEN ISNULL(c.AmountPaymentAccept,0) ELSE 0 END) AS col9,
		SUM(CASE WHEN c.Step=2 THEN isnull(c.AmountPaymentAccept,0) ELSE 0 END) AS col10,
		SUM(CASE WHEN c.rf_idV009=316 THEN 1 ELSE 0 END) AS col11,
		SUM(CASE WHEN c.rf_idV009=317 THEN 1 ELSE 0 END) AS col12,
		SUM(CASE WHEN c.rf_idV009=318 THEN 1 ELSE 0 END) AS col13,
		SUM(CASE WHEN c.rf_idV009=319 THEN 1 ELSE 0 END) AS col14
FROM #tCase c
WHERE sex='Ж' AND Comments='14'


--clear
DROP TABLE #tCase
GO