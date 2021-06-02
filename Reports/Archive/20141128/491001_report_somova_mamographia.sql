USE AccountOMS
GO
DECLARE @letter CHAR(1)='O',
		@codeM CHAR(6)='491001',
		@dateStart DATETIME='20140101',	--параметр менять
		@dateEnd DATETIME='20140630 23:59:59',--параметр менять
		@dateEndPay DATETIME='20141126 23:59:59',
		@reportMMEnd TINYINT=7,			 --параметр менять
		@reportYYYYEnd SMALLINT=2014	--параметр менять
		
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=@reportMMEnd AND a.ReportYear=@reportYYYYEnd AND a.Letter='O'
		
		
--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountRAK=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction 
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase a 
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay AND a.Letter=@letter AND a.CodeM=@codeM
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT en.PID,p1.FAM+' '+p1.IM+' '+ISNULL(p1.OT,'') AS FIO,CAST(p1.DR AS DATE) AS DR,p.Policy,s.sNameS,p.NumberHistoryCase,d.DS1,p.Account,p.NumberCase
		,m.mu,'Маммография' AS MuName,m.DateHelpBegin,ISNULL(m.Comments,'') AS CommentU,mes.MES
		,p.DateAccount,
		p.DateBegin,p.DateEnd,CAST(ISNULL(p.AmountPayment,0) AS MONEY)
FROM #tPeople p INNER JOIN dbo.t_Case_PID_ENP en ON
		p.rf_idCase=en.rf_idCase
				INNER JOIN dbo.vw_Diagnosis d ON
		p.rf_idCase=d.rf_idCase				
				INNER JOIN dbo.vw_sprSMO s ON
		p.rf_idSMO=s.smocod
				INNER JOIN dbo.t_MES mes ON
		p.rf_idCase=mes.rf_idCase
				INNER JOIN dbo.t_Meduslugi m ON
		p.rf_idCase=m.rf_idCase
				inner JOIN PolicyRegister.dbo.PEOPLE p1 ON
		en.pid=p1.ID					
WHERE p.AmountRAK>0	AND YEAR(DateBegin)-YEAR(p1.DR)>38 AND p1.W=2 AND m.MU='7.57.3' --AND en.pid IS NOT NULL
UNION ALL
SELECT en.PID,p1.FAM+' '+p1.IM+' '+ISNULL(p1.OT,''),CAST(p1.DR AS DATE) AS DR,p.Policy,s.sNameS,p.NumberHistoryCase,d.DS1,p.Account,p.NumberCase
		,'',' ' AS MuName,'','' AS CommentU,mes.MES
		,p.DateAccount,
		p.DateBegin,p.DateEnd,CAST(ISNULL(p.AmountPayment,0) AS MONEY)
FROM #tPeople p INNER JOIN dbo.t_Case_PID_ENP en ON
		p.rf_idCase=en.rf_idCase
				INNER JOIN dbo.vw_Diagnosis d ON
		p.rf_idCase=d.rf_idCase				
				INNER JOIN dbo.vw_sprSMO s ON
		p.rf_idSMO=s.smocod
				INNER JOIN dbo.t_MES mes ON
		p.rf_idCase=mes.rf_idCase				
				inner JOIN PolicyRegister.dbo.PEOPLE p1 ON
		en.pid=p1.ID
WHERE p.AmountRAK>0	AND YEAR(DateBegin)-YEAR(p1.DR)>38 AND p1.W=2 
		AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=p.rf_idCase AND MU='7.57.3') 
ORDER BY FIO

go

DROP TABLE #tPeople


