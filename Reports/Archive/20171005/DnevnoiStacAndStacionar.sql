USE AccountOMS
GO
DECLARE @reportYear SMALLINT=2016,
		@dateStart DATETIME,
		@dateEnd DATETIME='20170123 23:59:59',
		@mmBegin TINYINT=1,
		@mmEnd TINYINT=12,
		@dateEndPay DATETIME=GETDATE()

--DECLARE @reportYear SMALLINT=2017,
--		@dateStart DATETIME,
--		@dateEnd DATETIME='20170710 23:59:59',
--		@mmBegin TINYINT=1,
--		@mmEnd TINYINT=6,
--		@dateEndPay DATETIME=GETDATE()

SET @dateStart=CAST(@reportYear AS VARCHAR(4))+'0101' 
CREATE TABLE #tPeople(
					  CodeM VARCHAR(6),
					  rf_idCase BIGINT,					  					  
					  AmountPayment DECIMAL(11,2), 
					  rf_idSMO CHAR(5),	
					  PID INT,
					  DateBegin DATE,
					  DateEnd DATE,
					  rf_idV006 tinyint      
					  )


INSERT #tPeople ( CodeM ,rf_idCase ,AmountPayment ,rf_idSMO ,PID ,DateBegin ,DateEnd ,rf_idV006)  
SELECT DISTINCT f.CodeM ,c.id ,c.AmountPayment ,a.rf_idSMO ,ps.PID ,c.DateBegin ,c.DateEnd ,c.rf_idV006
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles			
			AND a.rf_idSMO<>'34'				
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
					INNER JOIN dbo.t_Case_PID_ENP ps ON
			c.id=ps.rf_idCase			
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>=@mmBegin AND a.ReportMonth<=@mmEnd AND a.ReportYear=@reportYear AND c.rf_idV006 IN(1,2)
AND pid IS NOT NULL

; WITH cteAmb
AS(
--SELECT *
--FROM #tPeople p WHERE rf_idV006=2 AND EXISTS(SELECT 1 FROM #tPeople WHERE rf_idV006=1 AND P.DateBegin>DateBegin AND p.DateBegin<DateEnd AND pid=p.pid AND rf_idSMO=p.rf_idSMO)
--UNION 
--SELECT *
--FROM #tPeople p WHERE rf_idV006=2 AND EXISTS(SELECT 1 FROM #tPeople WHERE rf_idV006=1 AND P.DateEnd>DateBegin AND p.DateEnd<DateEnd AND pid=p.pid AND rf_idSMO=p.rf_idSMO)
SELECT *
FROM #tPeople p WHERE rf_idV006=2 AND EXISTS(SELECT 1 FROM #tPeople WHERE rf_idV006=1 AND P.DateBegin<DateEnd AND p.DateEnd>DateBegin AND pid=p.pid AND rf_idSMO=p.rf_idSMO)
)
SELECT * INTO #tmpAmb FROM cteAmb

; WITH cteStac
AS(
--SELECT *
--FROM #tPeople p WHERE rf_idV006=1 AND EXISTS(SELECT 1 FROM #tPeople WHERE rf_idV006=2 AND P.DateBegin>DateBegin AND p.DateBegin<DateEnd AND pid=p.pid AND rf_idSMO=p.rf_idSMO)
--UNION 
--SELECT *
--FROM #tPeople p WHERE rf_idV006=1 AND EXISTS(SELECT 1 FROM #tPeople WHERE rf_idV006=2 AND P.DateEnd>DateBegin AND p.DateEnd<DateEnd AND pid=p.pid AND rf_idSMO=p.rf_idSMO)
SELECT *
FROM #tPeople p WHERE rf_idV006=1 AND EXISTS(SELECT 1 FROM #tPeople WHERE rf_idV006=2 AND P.DateBegin<DateEnd AND p.DateEnd>DateBegin AND pid=p.pid AND rf_idSMO=p.rf_idSMO)
)
SELECT * INTO #tmpStac FROM cteStac

UPDATE p SET AmountPayment=AmountPayment-r.AmountDeduction
FROM #tmpAmb p INNER JOIN (
							SELECT rf_idCase, SUM(AmountMEK+AmountMEE+AmountEKMP) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCaseVZ
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay	
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

UPDATE p SET AmountPayment=AmountPayment-r.AmountDeduction
FROM #tmpStac p INNER JOIN (
							SELECT rf_idCase, SUM(AmountMEK+AmountMEE+AmountEKMP) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCaseVZ
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay	
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT  t.rf_idSMO ,SUM(CountCase),SUM(t.MEK) ,SUM(t.MEE) ,SUM(t.EKMP) ,SUM(t.AmountDeduction) 
FROM(		
		SELECT rf_idSMO, COUNT(rf_idCase) AS CountCase,0 AS MEK,0 AS MEE,0 AS EKMP,0 AS AmountDeduction FROM #tmpAmb  GROUP BY rf_idSMO
		UNION ALL
		SELECT a.rf_idSMO, 0, COUNT(DISTINCT a.rf_idCase),0,0,0
		from #tmpAmb a INNER JOIN dbo.t_PaymentAcceptedCaseVZ p ON
				a.rf_idCase=p.rf_idCase
		WHERE TypeCheckup=1
		GROUP BY rf_idSMO
		UNION ALL
		SELECT a.rf_idSMO, 0, 0,COUNT(DISTINCT a.rf_idCase),0,0
		from #tmpAmb a INNER JOIN dbo.t_PaymentAcceptedCaseVZ p ON
				a.rf_idCase=p.rf_idCase
		WHERE TypeCheckup=2
		GROUP BY rf_idSMO
		UNION ALL
		SELECT a.rf_idSMO, 0,0,0, COUNT(DISTINCT a.rf_idCase),0
		from #tmpAmb a INNER JOIN dbo.t_PaymentAcceptedCaseVZ p ON
				a.rf_idCase=p.rf_idCase
		WHERE TypeCheckup=3
		GROUP BY rf_idSMO
		UNION ALL
		SELECT a.rf_idSMO, 0,0,0,0,COUNT(DISTINCT rf_idCase)
		from #tmpAmb a 
		WHERE AmountPayment=0
		GROUP BY rf_idSMO
		) t
GROUP BY rf_idSMO

SELECT  t.rf_idSMO,SUM(CountCase) ,SUM(t.MEK) ,SUM(t.MEE) ,SUM(t.EKMP) ,SUM(t.AmountDeduction) 
FROM(		
		SELECT rf_idSMO, COUNT(rf_idCase) CountCase,0 AS MEK,0 AS MEE,0 AS EKMP,0 AS AmountDeduction FROM #tmpStac GROUP BY rf_idSMO 
		UNION ALL
		SELECT a.rf_idSMO, 0, COUNT(DISTINCT a.rf_idCase),0,0,0
		from #tmpStac a INNER JOIN dbo.t_PaymentAcceptedCaseVZ p ON
				a.rf_idCase=p.rf_idCase
		WHERE TypeCheckup=1
		GROUP BY rf_idSMO
		UNION ALL
		SELECT a.rf_idSMO, 0, 0,COUNT(DISTINCT a.rf_idCase),0,0
		from #tmpStac a INNER JOIN dbo.t_PaymentAcceptedCaseVZ p ON
				a.rf_idCase=p.rf_idCase
		WHERE TypeCheckup=2
		GROUP BY rf_idSMO
		UNION ALL
		SELECT a.rf_idSMO, 0,0,0, COUNT(DISTINCT a.rf_idCase),0
		from #tmpStac a INNER JOIN dbo.t_PaymentAcceptedCaseVZ p ON
				a.rf_idCase=p.rf_idCase
		WHERE TypeCheckup=3
		GROUP BY rf_idSMO
		UNION ALL
		SELECT a.rf_idSMO, 0,0,0,0,COUNT(DISTINCT rf_idCase)
		from #tmpStac a  WHERE AmountPayment=0
		GROUP BY rf_idSMO
		) t
GROUP BY rf_idSMO
go
go

DROP TABLE #tPeople
DROP TABLE #tmpAmb
DROP TABLE #tmpStac

