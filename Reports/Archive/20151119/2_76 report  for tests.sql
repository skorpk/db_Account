USE AccountOMS
GO
DECLARE @codeM CHAR(6)='391001',
		@reportYear SMALLINT=2015,
		@dateStart DATETIME='20150101',
		@dateEnd DATETIME='20151005 23:59:59',
		@dateEndPay DATETIME=GETDATE()


CREATE TABLE #tPeople(rf_idCase BIGINT,
					  DateBegin DATE, 
					  DateEnd DATE,
					  CodeM CHAR(6),
					  Account VARCHAR(15),
					  ReportMonth TINYINT,						  
					  AmountPayment DECIMAL(11,2), 
					  rf_idSMO CHAR(5),
					  NumberHistoryCase VARCHAR(50),
					  Policy VARCHAR(30),
					  DateAccount DATE,
					  NumberCase BIGINT,
					  MU VARCHAR(9)
					  )
INSERT #tPeople( rf_idCase ,DateBegin ,DateEnd ,CodeM ,Account ,AmountPayment,rf_idSMO,NumberHistoryCase,Policy,DateAccount,NumberCase,MU)
SELECT c.id,c.DateBegin,c.DateEnd,f.CodeM,a.Account,c.AmountPayment,a.rf_idSMO,c.NumberHistoryCase,r.NumberPolis,a.DateRegister,c.idRecordCase, m.MU
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles			
			AND a.rf_idSMO<>'34'					
			AND a.Letter='J'
			AND f.CodeM=@codeM
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient																				
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=9 AND a.ReportYear=@reportYear 
		AND m.MU LIKE '2.76.%'


--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT rf_idCase,SUM(c.AmountMEK) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile																
													AND f.CodeM=@codeM
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
													a.id=c.rf_idCheckedAccount 														
							WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEndPay	 AND d.TypeCheckup=1 
										AND NOT EXISTS(SELECT rf_idCase
														FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
																		f.id=d.rf_idAFile
																		AND f.CodeM=@codeM
																						INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
																				d.id=a.rf_idDocumentOfCheckup
																					INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c1 ON
																				a.id=c1.rf_idCheckedAccount 														
														WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEndPay AND d.TypeCheckup>1 
																AND c1.rf_idCase=c.rf_idCase	 
													)
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT p1.FAM+' '+p1.IM+' '+ISNULL(p1.OT,'') AS FIO,CAST(p1.DR AS DATE) AS DR,p.Policy,s.sNameS,p.NumberHistoryCase,d.DS1,p.Account,p.DateAccount,p.NumberCase,
		p.DateBegin,p.DateEnd,CAST(ISNULL(p.AmountPayment,0) AS MONEY),p.MU,m.MUName
FROM #tPeople p INNER JOIN dbo.t_Case_PID_ENP en ON
		p.rf_idCase=en.rf_idCase
				INNER JOIN dbo.vw_Diagnosis d ON
		p.rf_idCase=d.rf_idCase
				INNER JOIN PolicyRegister.dbo.PEOPLE p1 ON
		en.pid=p1.ID
				INNER JOIN dbo.vw_sprSMO s ON
		p.rf_idSMO=s.smocod
				INNER JOIN dbo.vw_sprMUAll m ON
		p.MU=m.MU
		              
WHERE p.AmountPayment>0			
ORDER BY FIO


go

DROP TABLE #tPeople


