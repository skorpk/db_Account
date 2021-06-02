USE AccountOMS
GO
DECLARE @letter CHAR(1)='O',
		@codeM CHAR(6)='621001',
		@dateStart DATETIME='20130501',
		@dateEnd DATETIME='20141126 23:59:59',
		@dateEndPay DATETIME='20141126 23:59:59'
		
CREATE TABLE #tPeople(rf_idCase BIGINT,
					  DateBegin DATE, 
					  DateEnd DATE,
					  CodeM CHAR(6),
					  Account VARCHAR(15),
					  ReportMonth TINYINT,						  
					  AmountPayment DECIMAL(11,2), 
					  AmountRAK DECIMAL(11,2),
					  rf_idSMO CHAR(5),
					  NumberHistoryCase VARCHAR(50),
					  Policy VARCHAR(30),
					  DateAccount DATE,
					  NumberCase bigint
					  )
INSERT #tPeople( rf_idCase ,DateBegin ,DateEnd ,CodeM ,Account ,AmountPayment,rf_idSMO,NumberHistoryCase,Policy,DateAccount,NumberCase)
SELECT c.id,c.DateBegin,c.DateEnd,f.CodeM,a.Account,c.AmountPayment,a.rf_idSMO,c.NumberHistoryCase,r.NumberPolis,a.DateRegister,c.idRecordCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.Letter=@letter
			AND f.CodeM=@codeM
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient															
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=12 AND a.ReportYear=2013 AND a.Letter='O'
		AND m.MES LIKE '70.3.%'

INSERT #tPeople( rf_idCase ,DateBegin ,DateEnd ,CodeM ,Account ,AmountPayment,rf_idSMO,NumberHistoryCase,Policy,DateAccount,NumberCase)
SELECT c.id,c.DateBegin,c.DateEnd,f.CodeM,a.Account,c.AmountPayment,a.rf_idSMO,c.NumberHistoryCase,r.NumberPolis,a.DateRegister,c.idRecordCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.Letter=@letter
			AND f.CodeM=@codeM
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient															
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=12 AND a.ReportYear=2013 AND a.Letter='O'
		AND m.MU LIKE '2.84.%'
		--AND m.MUGroupCode=2 AND m.MUUnGroupCode=84
--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountRAK=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction 
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase a 
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay AND a.Letter=@letter AND a.CodeM=@codeM
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT p1.FAM+' '+p1.IM+' '+p1.OT,CAST(p1.DR AS DATE) AS DR,p.Policy,s.sNameS,p.NumberHistoryCase,d.DS1,p.Account,p.NumberCase,p.DateAccount,
		p.DateBegin,p.DateEnd,CAST(ISNULL(p.AmountPayment,0) AS MONEY)
FROM #tPeople p INNER JOIN dbo.t_Case_PID_ENP en ON
		p.rf_idCase=en.rf_idCase
				INNER JOIN dbo.vw_Diagnosis d ON
		p.rf_idCase=d.rf_idCase
				INNER JOIN PolicyRegister.dbo.PEOPLE p1 ON
		en.pid=p1.ID
				INNER JOIN dbo.vw_sprSMO s ON
		p.rf_idSMO=s.smocod
WHERE p.AmountRAK>0				
--ORDER BY FIO

go

DROP TABLE #tPeople


