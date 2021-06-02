USE AccountOMS
GO
--DECLARE @reportYear SMALLINT=2016,
--		@dateStart DATETIME,
--		@dateEnd DATETIME='20170123 23:59:59',
--		@mmBegin TINYINT=1,
--		@mmEnd TINYINT=12,
--		@dateEndPay DATETIME=GETDATE()

DECLARE @reportYear SMALLINT=2017,
		@dateStart DATETIME,
		@dateEnd DATETIME='20170710 23:59:59',
		@mmBegin TINYINT=1,
		@mmEnd TINYINT=6,
		@dateEndPay DATETIME=GETDATE()

SET @dateStart=CAST(@reportYear AS VARCHAR(4))+'0101' 
CREATE TABLE #tPeople(
					  CodeM VARCHAR(6),
					  rf_idCase BIGINT,					  					  
					  AmountPayment DECIMAL(11,2), 
					  rf_idSMO CHAR(5),	
					  PID INT,
					  DateBegin DATE,
					  DateEnd DATE,
					  rf_idV006 TINYINT,
					  DS1 VARCHAR(9),
					  Policy VARCHAR(20),
					  AmountPayment2 DECIMAL(11,2),
					  Account VARCHAR(15),
					  DateAccount DATE,
					  NumberCase int      
					  )

INSERT #tPeople ( CodeM ,rf_idCase ,AmountPayment ,rf_idSMO ,PID ,DateBegin ,DateEnd ,rf_idV006,DS1, Policy,AmountPayment2,Account,DateAccount,NumberCase )  
SELECT DISTINCT f.CodeM ,c.id ,c.AmountPayment ,a.rf_idSMO ,ps.PID ,c.DateBegin ,c.DateEnd ,c.rf_idV006,d.DS1,r.NumberPolis, c.AmountPayment,a.Account,a.DateRegister,c.idRecordCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles			
			AND a.rf_idSMO<>'34'				
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
					INNER JOIN dbo.t_Case_PID_ENP ps ON
			c.id=ps.rf_idCase	
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase			
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>=@mmBegin AND a.ReportMonth<=@mmEnd AND a.ReportYear=@reportYear AND c.rf_idV006 IN(1,2)
AND pid IS NOT NULL

UPDATE p SET AmountPayment=AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT rf_idCase, SUM(AmountMEK+AmountMEE+AmountEKMP) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCaseVZ
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay	
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT DISTINCT p1.CodeM, l.NAMES ,p1.rf_idCase ,p1.rf_idSMO ,p1.PID ,p1.DateBegin ,p1.DateEnd ,p1.rf_idV006 ,p1.DS1 ,p1.Policy,CAST(p1.AmountPayment AS MONEY) AS [Сумма принятая] 
		,CAST(p1.AmountPayment2 AS MONEY) AS [Сумма выставлен.],p1.Account,p1.DateAccount,p1.NumberCase,
		p2.CodeM , l1.NAMES,p2.rf_idCase ,p2.rf_idSMO ,p2.PID ,p2.DateBegin ,p2.DateEnd ,p2.rf_idV006 ,p2.DS1 ,p2.Policy,CAST(p2.AmountPayment AS MONEY)  AS [Сумма принятая],
		CAST(p2.AmountPayment2 AS MONEY) AS [Сумма выставлен.],p2.Account,p2.DateAccount,p2.NumberCase
FROM #tPeople p1 INNER JOIN #tPeople p2 ON
		p1.rf_idV006=2  AND p2.rf_idV006=1
		AND P1.DateBegin<p2.DateEnd
		AND p1.DateEnd>p2.DateBegin
		AND p2.pid=p1.pid 
		AND p2.rf_idSMO=p1.rf_idSMO 
				INNER JOIN dbo.vw_sprT001 l ON
		p1.CodeM=l.CodeM       
				INNER JOIN dbo.vw_sprT001 l1 ON
		p2.CodeM=l1.CodeM              
go

DROP TABLE #tPeople

