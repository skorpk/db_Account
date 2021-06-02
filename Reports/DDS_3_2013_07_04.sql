USE AccountOMS
GO
DECLARE @reportYear SMALLINT=2013,
		@quarter TINYINT=2
declare @t as table
(
		MonthID tinyint
		,QuarterID tinyint		
)

--insert @t values(1,1),(2,1),(3,1),
--				(4,2),(5,2),(6,2),
--				(7,3),(8,3),(9,3),
--				(10,4),(11,4),(12,4)
				
CREATE TABLE #tmpAccount(Account VARCHAR(25),ReportMonth TINYINT, CodeM CHAR(6),CodeSMO CHAR(5))
INSERT #tmpAccount
		( Account ,
		  ReportMonth ,
		  CodeM ,
		  CodeSMO
		)
SELECT Account, ReportMonth,CodeM,PrefixNumberRegister AS CodeSMO
FROM dbo.vw_getIdFileNumber
WHERE DateRegistration>='20130610' AND ISNULL(Letter,'Z')='D' AND ReportYear=2013
				
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
		SELECT distinct f.CodeM,c.id,1 AS Step,c.rf_idV009,c.AmountPayment
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles					
							INNER JOIN #tmpAccount ta ON
					f.CodeM=ta.codeM
					AND a.Account=ta.Account
					AND a.ReportMonth=ta.ReportMonth
					AND a.rf_idSMO=ta.CodeSMO
					AND a.ReportYear=2013
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.IsCompletedCase=1					
					--AND c.DateEnd>='20130101'
							INNER JOIN dbo.t_MES mes ON
					c.id=mes.rf_idCase
							INNER JOIN dbo.vw_sprMUCompletedCase mu ON
					mes.MES=mu.MU
		WHERE a.Letter='D' AND mu.MUGroupCode=70 AND MUUnGroupCode=5 --AND f.DateRegistration>=@dateBeginQuarter AND f.DateRegistration<=@dateEnd		
		--------------------------------t_Meduslugi-----------------------------------------------------
		UNION ALL
		SELECT DISTINCT f.CodeM,c.id,2,c.rf_idV009,c.AmountPayment
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN #tmpAccount ta ON
					f.CodeM=ta.codeM
					AND a.Account=ta.Account
					AND a.ReportMonth=ta.ReportMonth
					AND a.rf_idSMO=ta.CodeSMO
					AND a.ReportYear=2013
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.IsCompletedCase=0
							INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase					
		WHERE a.Letter='D' AND m.MUGroupCode=2 AND MUUnGroupCode=83 --AND f.DateRegistration>=@dateBeginQuarter AND f.DateRegistration<=@dateEnd
		
		) t
GROUP BY t.CodeM,t.id,t.Step,t.rf_idV009,t.AmountPayment

SELECT c.CodeM AS col1,l.names AS col2,
		CAST(SUM(c.AmountPayment) AS MONEY) AS col3,
		SUM(CASE WHEN c.Step=1 THEN 1 ELSE 0 END) AS col4,
		CAST(SUM(CASE WHEN c.Step=1 THEN c.AmountPayment ELSE 0 END) AS MONEY) AS col5,
		SUM(CASE WHEN c.Step=2 THEN 1 ELSE 0 END) AS col6,
		CAST(SUM(CASE WHEN c.Step=2 THEN c.AmountPayment ELSE 0 END) AS MONEY) AS col7,
		CAST(SUM(ISNULL(f.TotalAmountPayment,0)) AS MONEY) AS col8,
		CAST(SUM(CASE WHEN isnull(f.Step,3)=1 THEN f.TotalAmountPayment ELSE 0 END) AS MONEY) AS col9,
		CAST(SUM(CASE WHEN isnull(f.Step,3)=2 THEN f.TotalAmountPayment ELSE 0 END) AS MONEY) AS col10,
		SUM(CASE WHEN c.rf_idV009=320 THEN 1 ELSE 0 END) AS col11,
		SUM(CASE WHEN c.rf_idV009=321 THEN 1 ELSE 0 END) AS col12,
		SUM(CASE WHEN c.rf_idV009=322 THEN 1 ELSE 0 END) AS col13,
		SUM(CASE WHEN c.rf_idV009=323 THEN 1 ELSE 0 END) AS col14,
		SUM(CASE WHEN c.rf_idV009=324 THEN 1 ELSE 0 END) AS col15
from #tCase c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
			LEFT JOIN (
						SELECT f.CodeM,c.Step,c.id,SUM(sc.AmountPayment) AS TotalAmountPayment
						FROM ExchangeFinancing.dbo.t_DFileIn f INNER JOIN ExchangeFinancing.dbo.t_PaymentDocument p ON
									f.id=p.rf_idDFile
																INNER JOIN ExchangeFinancing.dbo.t_SettledAccount a ON
									p.id=a.rf_idPaymentDocument
																INNER JOIN ExchangeFinancing.dbo.t_SettledCase sc ON
									a.id=sc.rf_idSettledAccount
																INNER JOIN #tCase c ON
									sc.rf_idCase=c.id
						WHERE a.Account LIKE '%D'
						GROUP BY f.CodeM,c.id,c.Step
						) f ON
				c.id=f.id
				AND c.Step=f.Step
GROUP BY c.CodeM,l.names 
ORDER BY c.CodeM
--clear

GO
DROP TABLE #tCase
DROP TABLE #tmpAccount