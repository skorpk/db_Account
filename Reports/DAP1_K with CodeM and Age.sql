USE AccountOMS
GO
use AccountOMS
go
if OBJECT_ID('usp_Report_DAP1_K',N'P') is not null
drop proc usp_Report_DAP1_K
go
DECLARE @reportYear SMALLINT=2013,
		@quarter TINYINT=3,
		@dateBegin DATETIME='20130501',
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
		SELECT c.id,1 AS Step,c.rf_idV009,c.AmountPayment,c.Comments,DATEDIFF(yy,p.BirthDay,c.DateBegin) AS Age,p.Sex
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
		SELECT c.id,1,c.rf_idV009,c.AmountPayment,c.Comments,DATEDIFF(yy,p.BirthDay,c.DateBegin) AS Age,p.Sex
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
		SELECT DISTINCT c.id,2,c.rf_idV009,c.AmountPayment,c.Comments,DATEDIFF(yy,p.BirthDay,c.DateBegin) AS Age,p.Sex
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
		SELECT DISTINCT c.id,2,c.rf_idV009,c.AmountPayment,c.Comments,DATEDIFF(yy,p.BirthDay,c.DateBegin) AS Age,p.Sex
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

--UPDATE c  
--SET c.AmountPaymentAccept=c1.AmountPaymentAccept
--FROM #tCase c INNER JOIN (
--							select c.id,SUM(sc.AmountPaymentAccept) AS AmountPaymentAccept
--							FROM dbo.t_PaidCase sc INNER JOIN #tCase c ON
--												sc.rf_idCase=c.id
--							WHERE sc.DateRegistration>=@dateBegin AND sc.DateRegistration<=@dateEnd AND sc.Letter='O'
--							GROUP BY c.id
--							) c1 ON c.id=c1.id
						
SELECT l.CodeM,l.NameS,		
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col2,		
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col3,
		SUM(CASE WHEN c.Step=1 AND c.Age=21 THEN 1 ELSE 0 END) AS col4,		
		SUM(CASE WHEN c.Step=2 AND c.Age=21 THEN 1 ELSE 0 END) AS col5,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=24 THEN 1 ELSE 0 END) AS col6,		
		SUM(CASE WHEN c.Step=2 AND c.Age=24 THEN 1 ELSE 0 END) AS col7,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=27 THEN 1 ELSE 0 END) AS col4,		
		SUM(CASE WHEN c.Step=2 AND c.Age=27 THEN 1 ELSE 0 END) AS col5,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=30 THEN 1 ELSE 0 END) AS col6,		
		SUM(CASE WHEN c.Step=2 AND c.Age=30 THEN 1 ELSE 0 END) AS col7,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=33 THEN 1 ELSE 0 END) AS col8,		
		SUM(CASE WHEN c.Step=2 AND c.Age=33 THEN 1 ELSE 0 END) AS col9,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=36 THEN 1 ELSE 0 END) AS col10,		
		SUM(CASE WHEN c.Step=2 AND c.Age=36 THEN 1 ELSE 0 END) AS col11,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=39 THEN 1 ELSE 0 END) AS col12,		
		SUM(CASE WHEN c.Step=2 AND c.Age=39 THEN 1 ELSE 0 END) AS col13,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=42 THEN 1 ELSE 0 END) AS col14,		
		SUM(CASE WHEN c.Step=2 AND c.Age=42 THEN 1 ELSE 0 END) AS col15,				
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=45 THEN 1 ELSE 0 END) AS col16,		
		SUM(CASE WHEN c.Step=2 AND c.Age=45 THEN 1 ELSE 0 END) AS col17,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=48 THEN 1 ELSE 0 END) AS col18,		
		SUM(CASE WHEN c.Step=2 AND c.Age=48 THEN 1 ELSE 0 END) AS col19,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=51 THEN 1 ELSE 0 END) AS col20,		
		SUM(CASE WHEN c.Step=2 AND c.Age=51 THEN 1 ELSE 0 END) AS col21,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=54 THEN 1 ELSE 0 END) AS col22,		
		SUM(CASE WHEN c.Step=2 AND c.Age=54 THEN 1 ELSE 0 END) AS col23,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=57 THEN 1 ELSE 0 END) AS col24,		
		SUM(CASE WHEN c.Step=2 AND c.Age=57 THEN 1 ELSE 0 END) AS col25,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=60 THEN 1 ELSE 0 END) AS col26,		
		SUM(CASE WHEN c.Step=2 AND c.Age=60 THEN 1 ELSE 0 END) AS col27,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=63 THEN 1 ELSE 0 END) AS col28_1,		
		SUM(CASE WHEN c.Step=2 AND c.Age=63 THEN 1 ELSE 0 END) AS col29_1,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=66 THEN 1 ELSE 0 END) AS col28,		
		SUM(CASE WHEN c.Step=2 AND c.Age=66 THEN 1 ELSE 0 END) AS col29,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=69 THEN 1 ELSE 0 END) AS col30,		
		SUM(CASE WHEN c.Step=2 AND c.Age=69 THEN 1 ELSE 0 END) AS col31,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=72 THEN 1 ELSE 0 END) AS col32,		
		SUM(CASE WHEN c.Step=2 AND c.Age=72 THEN 1 ELSE 0 END) AS col33,
		----------------------------------------------------------		
		SUM(CASE WHEN c.Step=1 AND c.Age=75 THEN 1 ELSE 0 END) AS col35,		
		SUM(CASE WHEN c.Step=2 AND c.Age=75 THEN 1 ELSE 0 END) AS col36,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=78 THEN 1 ELSE 0 END) AS col37,		
		SUM(CASE WHEN c.Step=2 AND c.Age=78 THEN 1 ELSE 0 END) AS col38,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=81 THEN 1 ELSE 0 END) AS col39,		
		SUM(CASE WHEN c.Step=2 AND c.Age=81 THEN 1 ELSE 0 END) AS col40,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=84 THEN 1 ELSE 0 END) AS col41,		
		SUM(CASE WHEN c.Step=2 AND c.Age=84 THEN 1 ELSE 0 END) AS col42,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=87 THEN 1 ELSE 0 END) AS col43,		
		SUM(CASE WHEN c.Step=2 AND c.Age=87 THEN 1 ELSE 0 END) AS col44,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=90 THEN 1 ELSE 0 END) AS col45,		
		SUM(CASE WHEN c.Step=2 AND c.Age=90 THEN 1 ELSE 0 END) AS col46,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=93 THEN 1 ELSE 0 END) AS col45_1,		
		SUM(CASE WHEN c.Step=2 AND c.Age=93 THEN 1 ELSE 0 END) AS col46_1,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=96 THEN 1 ELSE 0 END) AS col47,		
		SUM(CASE WHEN c.Step=2 AND c.Age=96 THEN 1 ELSE 0 END) AS col48,
		----------------------------------------------------------
		SUM(CASE WHEN c.Step=1 AND c.Age=99 THEN 1 ELSE 0 END) AS col49,		
		SUM(CASE WHEN c.Step=2 AND c.Age=99 THEN 1 ELSE 0 END) AS col50
FROM #tCase c INNER JOIN t_Case c1 ON
		c.id=c1.id
			 INNER JOIN dbo.vw_sprT001 l ON
		c1.rf_idMO=l.CodeM
GROUP BY l.CodeM,l.NameS
ORDER BY CodeM


--clear
DROP TABLE #tCase
GO