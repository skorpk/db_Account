use AccountOMS
go
if OBJECT_ID('usp_Report_DDS_7',N'P') is not null
drop proc usp_Report_DDS_7
go
create procedure usp_Report_DDS_7
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
																
		DECLARE @tMES AS TABLE(MUGroupCode tinyint, MUUnGroupCode TINYINT,Letter CHAR(1),[TYPE] TINYINT,Step TINYINT) ---For first step
		INSERT @tMES( MUGroupCode ,MUUnGroupCode ,Letter,[TYPE],Step) VALUES( 72 ,2,'F',1,1),( 72 ,3,'V',2,1),( 72 ,4,'I',3,0)
		
		DECLARE @tMU AS TABLE(MUGroupCode tinyint, MUUnGroupCode TINYINT,Letter CHAR(1),[TYPE] TINYINT,Step TINYINT) --For second step
		INSERT @tMU( MUGroupCode ,MUUnGroupCode ,Letter,[TYPE],Step) VALUES	( 2 ,85,'F',1,2),( 2 ,86,'V',2,2)

CREATE table #tCase (
	id bigint,
	[TYPE] tinyint,
	Step TINYINT,
	rf_idV009 smallint,
	AmountPayment decimal(15,2), 
	AmountPaymentAccept decimal(15,2)
	)

INSERT #tCase( id, [Type],Step, rf_idV009,AmountPayment )
SELECT t.id,t.[TYPE],t.Step,t.rf_idV009,t.AmountPayment
from (	
----------------------------MES----------------------------			
		SELECT c.id,tMes.[TYPE], tMes.Step,c.rf_idV009,c.AmountPayment
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN @t t ON
					a.ReportMonth=t.MonthID
					AND t.QuarterID=@quarter
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts						  
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.IsCompletedCase=1
					AND c.DateEnd<=@dateEndQuarter
					AND c.DateEnd>='20130101'
							INNER JOIN dbo.t_MES mes ON
					c.id=mes.rf_idCase
							INNER JOIN dbo.vw_sprMUCompletedCase mu ON
					mes.MES=mu.MU
							INNER JOIN @tMES tMes ON
					a.Letter=tMes.Letter
					AND mu.MUGroupCode=tMes.MUGroupCode
					AND mu.MUUnGroupCode=tMes.MUUnGroupCode
		WHERE f.DateRegistration>=@dateBeginQuarter AND f.DateRegistration<=@dateEnd		
		UNION ALL
		SELECT c.id,tMes.[TYPE], tMes.Step,c.rf_idV009,c.AmountPayment
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN @t t ON
					a.ReportMonth=t.MonthID
					AND t.QuarterID=(@quarter-1)
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts						  
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.IsCompletedCase=1
					AND c.DateEnd<=@dateEndQuarter
					AND c.DateEnd>='20130101'
							INNER JOIN dbo.t_MES mes ON
					c.id=mes.rf_idCase
							INNER JOIN dbo.vw_sprMUCompletedCase mu ON
					mes.MES=mu.MU
							INNER JOIN @tMES tMes ON
					a.Letter=tMes.Letter
					AND mu.MUGroupCode=tMes.MUGroupCode
					AND mu.MUUnGroupCode=tMes.MUUnGroupCode
		WHERE f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd		
		--------------------------------t_Meduslugi-----------------------------------------------------
		UNION ALL
		SELECT DISTINCT c.id,tMU.[TYPE], tMU.Step,c.rf_idV009,c.AmountPayment
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN @t t ON
					a.ReportMonth=t.MonthID
					AND t.QuarterID=@quarter
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts						   
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.IsCompletedCase=0
							INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase				
							INNER JOIN @tMU tMU ON
					a.Letter=tMU.Letter
					AND m.MUGroupCode=tmu.MUGroupCode
					AND m.MUUnGroupCode=tMU.MUUnGroupCode
		WHERE f.DateRegistration>=@dateBeginQuarter AND f.DateRegistration<=@dateEnd	
		UNION ALL
		SELECT DISTINCT c.id,tMU.[TYPE],tMU.Step,c.rf_idV009,c.AmountPayment
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN @t t ON
					a.ReportMonth=t.MonthID
					AND t.QuarterID=(@quarter-1)
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts						   
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.IsCompletedCase=0
							INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase				
							INNER JOIN @tMU tMU ON
					a.Letter=tMU.Letter
					AND m.MUGroupCode=tmu.MUGroupCode
					AND m.MUUnGroupCode=tMU.MUUnGroupCode
		WHERE f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd	
		) t
GROUP BY t.id,t.[TYPE],t.Step,t.rf_idV009,t.AmountPayment

UPDATE c  
SET c.AmountPaymentAccept=c1.AmountPaymentAccept
FROM #tCase c INNER JOIN (
							select c.id,SUM(sc.AmountPaymentAccept) AS AmountPaymentAccept
							FROM t_PaidCase sc INNER JOIN (VALUES('F'),('V'),('I')) t(Letter) ON
										sc.Letter=t.Letter	
												INNER JOIN #tCase c ON
										sc.rf_idCase=c.id
							WHERE sc.DateRegistration>=@dateBegin AND sc.DateRegistration<=@dateEnd
							GROUP BY c.id
							) c1 ON c.id=c1.id
							
UPDATE #tCase SET AmountPaymentAccept=0 WHERE AmountPaymentAccept IS NULL						
			
SELECT 'профилактические',1 AS Col2,
		SUM(c.AmountPayment) AS col3,
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4,
		SUM(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) AS col5,
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col6,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) AS col7,
		SUM(c.AmountPaymentAccept) AS col8,		
		SUM(CASE WHEN c.Step=1 THEN c.AmountPaymentAccept ELSE 0 END) AS col9,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPaymentAccept ELSE 0 END) AS col10,
		SUM(CASE WHEN c.rf_idV009=325 THEN 1 ELSE 0 END) AS col11,
		SUM(CASE WHEN c.rf_idV009=326 THEN 1 ELSE 0 END) AS col12,
		SUM(CASE WHEN c.rf_idV009=327 THEN 1 ELSE 0 END) AS col13,
		SUM(CASE WHEN c.rf_idV009=328 THEN 1 ELSE 0 END) AS col14,
		SUM(CASE WHEN c.rf_idV009=329 THEN 1 ELSE 0 END) AS col15
FROM #tCase c WHERE [TYPE]=1
UNION ALL
SELECT 'предварительные',2 AS Col2,
		SUM(c.AmountPayment) AS col3,
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4,
		SUM(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) AS col5,
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col6,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) AS col7,
		SUM(c.AmountPaymentAccept) AS col8,		
		SUM(CASE WHEN c.Step=1 THEN c.AmountPaymentAccept ELSE 0 END) AS col9,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPaymentAccept ELSE 0 END) AS col10,
		SUM(CASE WHEN c.rf_idV009=330 THEN 1 ELSE 0 END) AS col11,
		SUM(CASE WHEN c.rf_idV009=331 THEN 1 ELSE 0 END) AS col12,
		SUM(CASE WHEN c.rf_idV009=332 THEN 1 ELSE 0 END) AS col13,
		SUM(CASE WHEN c.rf_idV009=333 THEN 1 ELSE 0 END) AS col14,
		SUM(CASE WHEN c.rf_idV009=334 THEN 1 ELSE 0 END) AS col15
FROM #tCase c WHERE [TYPE]=2
UNION ALL
SELECT 'периодические',1 AS Col2,
		SUM(c.AmountPayment) AS col3,0 AS col4,0 AS col5, 0 AS col6,0 AS col7,
		SUM(c.AmountPaymentAccept) AS col8,	0 AS col9,0 AS col10,0 AS col11,
		0 AS col12,	0 AS col13,0 AS col14,0 AS col15
FROM #tCase c WHERE [TYPE]=3

--clear
DROP TABLE #tCase
GO