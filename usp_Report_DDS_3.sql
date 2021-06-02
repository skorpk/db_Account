use AccountOMS
go
if OBJECT_ID('usp_Report_DDS_3',N'P') is not null
drop proc usp_Report_DDS_3
go
create procedure usp_Report_DDS_3
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

CREATE table #tCase (CodeM CHAR(6),id bigint,Step TINYINT,rf_idV009 smallint,AmountPayment decimal(11,2))

INSERT #tCase( CodeM, id, Step, rf_idV009,AmountPayment )
SELECT t.CodeM,t.id,t.Step,t.rf_idV009,t.AmountPayment
from (				
		SELECT f.CodeM,c.id,1 AS Step,c.rf_idV009,c.AmountPayment
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
		WHERE a.Letter='D' AND mu.MUGroupCode=70 AND MUUnGroupCode=5 AND f.DateRegistration>=@dateBeginQuarter AND f.DateRegistration<=@dateEnd
		UNION ALL 
		SELECT f.CodeM,c.id,1,c.rf_idV009,c.AmountPayment
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
		WHERE a.Letter='D' AND mu.MUGroupCode=70 AND MUUnGroupCode=5 AND f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd
		--------------------------------t_Meduslugi-----------------------------------------------------
		UNION ALL
		SELECT DISTINCT f.CodeM,c.id,2,c.rf_idV009,c.AmountPayment
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
		WHERE a.Letter='D' AND m.MUGroupCode=2 AND MUUnGroupCode=83 AND f.DateRegistration>=@dateBeginQuarter AND f.DateRegistration<=@dateEnd
		UNION ALL 
		SELECT DISTINCT f.CodeM,c.id,2,c.rf_idV009,c.AmountPayment
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
		WHERE a.Letter='D' AND m.MUGroupCode=2 AND MUUnGroupCode=83 AND f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd	
		) t
GROUP BY t.CodeM,t.id,t.Step,t.rf_idV009,t.AmountPayment

SELECT c.CodeM AS col1,l.names AS col2,
		SUM(c.AmountPayment) AS col3,
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4,
		SUM(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) AS col5,
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col6,
		SUM(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) AS col7,
		SUM(ISNULL(f.TotalAmountPayment,0)) AS col8,
		SUM(CASE WHEN isnull(f.Step,3)=1 THEN f.TotalAmountPayment ELSE 0 END) AS col9,
		SUM(CASE WHEN isnull(f.Step,3)=2 THEN f.TotalAmountPayment ELSE 0 END) AS col10,
		SUM(CASE WHEN c.rf_idV009=320 THEN 1 ELSE 0 END) AS col11,
		SUM(CASE WHEN c.rf_idV009=321 THEN 1 ELSE 0 END) AS col12,
		SUM(CASE WHEN c.rf_idV009=322 THEN 1 ELSE 0 END) AS col13,
		SUM(CASE WHEN c.rf_idV009=323 THEN 1 ELSE 0 END) AS col14,
		SUM(CASE WHEN c.rf_idV009=324 THEN 1 ELSE 0 END) AS col15
from #tCase c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
			LEFT JOIN (
						SELECT sc.CodeM,c.Step,c.id,SUM(sc.AmountPaymentAccept) AS TotalAmountPayment
						FROM t_PaidCase sc INNER JOIN #tCase c ON
									sc.rf_idCase=c.id
						WHERE sc.DateRegistration>=@dateBegin AND sc.DateRegistration<=@dateEnd AND sc.Letter='D'
						GROUP BY sc.CodeM,c.Step,c.id
						) f ON
				c.id=f.id
				AND c.Step=f.Step
GROUP BY c.CodeM,l.names 
ORDER BY c.CodeM
--clear
DROP TABLE #tCase
GO