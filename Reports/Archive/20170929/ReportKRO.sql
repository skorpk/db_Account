USE AccountOMS
GO
DECLARE @codeM CHAR(6)='371001',
		@reportYear SMALLINT=2016,
		@dateStart DATETIME,
		@dateEnd DATETIME='20170715 23:59:59',
		@mmBegin TINYINT=1,
		@mmEnd TINYINT=12,
		@dateEndPay DATETIME='20170927'
SET @dateStart=CAST(@reportYear AS VARCHAR(4))+'0101'

CREATE TABLE #tPeople(rf_idCase BIGINT,
					  DateBegin DATE, 
					  DateEnd DATE,
					  CodeM CHAR(6),
					  Account VARCHAR(15),
					  Letter CHAR(1),
					  ReportMonth TINYINT,						  
					  AmountPayment DECIMAL(11,2), 
					  rf_idSMO CHAR(5),
					  NumberHistoryCase VARCHAR(50),
					  Policy VARCHAR(30),
					  DateAccount DATE,
					  NumberCase BIGINT,
					  AmountPayment2 DECIMAL(11,2) NOT NULL DEFAULT 0.0,
					  rf_idV006 TINYINT
					  )

CREATE UNIQUE NONCLUSTERED INDEX UQ_IdCase ON #tPeople(rf_idCase) WITH IGNORE_DUP_KEY

INSERT #tPeople( rf_idCase ,DateBegin ,DateEnd ,CodeM ,Account , Letter,AmountPayment,rf_idSMO,NumberHistoryCase,Policy,DateAccount,NumberCase, rf_idV006,AmountPayment2)
SELECT DISTINCT c.id,c.DateBegin,c.DateEnd,f.CodeM,a.Account, a.Letter,c.AmountPayment,a.rf_idSMO,c.NumberHistoryCase,r.NumberPolis,a.DateRegister,c.idRecordCase,c.rf_idV006,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles			
			AND f.CodeM=@codeM
			AND a.rf_idSMO<>'34'
					INNER JOIN (VALUES('O'),('F') ,('U')  ) v(letter) ON
			a.Letter=v.letter
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase																				
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>@mmBegin AND a.ReportMonth<=@mmEnd AND a.ReportYear=@reportYear AND m.rf_idV002 IN(162, 163)

INSERT #tPeople( rf_idCase ,DateBegin ,DateEnd ,CodeM ,Account , Letter,AmountPayment,rf_idSMO,NumberHistoryCase,Policy,DateAccount,NumberCase, rf_idV006,AmountPayment2)
SELECT c.id,c.DateBegin,c.DateEnd,f.CodeM,a.Account, a.Letter,c.AmountPayment,a.rf_idSMO,c.NumberHistoryCase,r.NumberPolis,a.DateRegister,c.idRecordCase,c.rf_idV006, c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles			
			AND f.CodeM=@codeM
			AND a.rf_idSMO<>'34'					
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient				                
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>@mmBegin AND a.ReportMonth<=@mmEnd AND a.ReportYear=@reportYear 
	AND a.Letter NOT IN ('S','Z','B','E') AND c.rf_idV002 IN(162,163)

--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountPayment2=p.AmountPayment2-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAccepted_371001												
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay	 
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT s.smocod,s.sNameS,p.Policy, p.NumberHistoryCase,d.DS1,p.DateBegin,p.DateEnd,p.DateAccount,p.Account,p.NumberCase,
		CAST(ISNULL(p.AmountPayment,0) AS MONEY) AS AmountCase
		,CAST(ISNULL(p.AmountPayment2,0) AS MONEY),v6.name AS V006
FROM #tPeople p INNER JOIN dbo.vw_Diagnosis d ON
		p.rf_idCase=d.rf_idCase				
				INNER JOIN dbo.vw_sprSMO s ON
		p.rf_idSMO=s.smocod
				INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
		p.rf_idV006=v6.id              
WHERE p.AmountPayment2>0			
ORDER BY s.smocod
go
DROP TABLE #tPeople
--DROP TABLE #v002
