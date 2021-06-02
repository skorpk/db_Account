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
					  AmountDeduction DECIMAL(11,2), 
					  rf_idSMO CHAR(5),	
					  PID INT,
					  DateBegin DATE,
					  DateEnd DATE,
					  rf_idV006 TINYINT,
					  DS1 VARCHAR(9),
					  Policy VARCHAR(20),
					  AmountPayment DECIMAL(11,2),
					  Account VARCHAR(15),
					  DateAccount DATE,
					  NumberCase INT, 
					  ISHOD SMALLINT,
					  RSLT SMALLINT,
					  DateDeath DATE
					  )

INSERT #tPeople ( CodeM ,rf_idCase ,AmountDeduction ,rf_idSMO ,PID ,DateBegin ,DateEnd ,rf_idV006,DS1, Policy,AmountPayment,Account,DateAccount,NumberCase,ISHOD,RSLT,DateDeath )  
SELECT DISTINCT f.CodeM ,c.id ,c.AmountPayment ,a.rf_idSMO ,ps.PID ,c.DateBegin ,c.DateEnd ,c.rf_idV006,d.DS1,r.NumberPolis, c.AmountPayment,a.Account,a.DateRegister,c.idRecordCase,c.rf_idV009, c.rf_idV012,dd.DS
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
					INNER JOIN PeopleAttach.dbo.v_dead_2016 dd ON
			ps.PID=dd.ID                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>=@mmBegin AND a.ReportMonth<=@mmEnd AND a.ReportYear=@reportYear AND c.DateEnd>dd.DS AND pid IS NOT NULL

UPDATE p SET AmountPayment=AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT rf_idCase, SUM(AmountMEK+AmountMEE+AmountEKMP) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCaseVZ
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay	
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT  p1.CodeM ,l.NAMES,rf_idSMO ,Account ,DateAccount ,NumberCase ,DateBegin ,p1.DateEnd ,rf_idV006 ,DS1 ,Policy ,AmountPayment ,AmountDeduction , v12.name AS ISHOD ,v9.Name AS RSLT ,DateDeath
FROM #tPeople p1 INNER JOIN RegisterCases.dbo.vw_sprV012 v12 ON
		p1.ISHOD=v12.id
				INNER JOIN RegisterCases.dbo.vw_sprV009 v9 ON
		p1.RSLT=v9.id              
				INNER JOIN dbo.vw_sprT001 l ON
		p1.CodeM=l.CodeM

go

DROP TABLE #tPeople

