USE AccountOMS
GO
DECLARE @reportYear SMALLINT=2015,
		@dateStart DATETIME='20150101',
		@dateEnd DATETIME='20151010 23:59:59'
	
CREATE TABLE #tPeople(rf_idCase BIGINT,
					  DateBegin DATE, 
					  DateEnd DATE,
					  CodeM CHAR(6),
					  Account VARCHAR(15),
					  AmountPayment DECIMAL(11,2), 
					  DateAccount DATE,
					  NumberCase BIGINT,
					  MES VARCHAR(20),
					  v002 SMALLINT,
					  V009 SMALLINT,
					  QuantityMU DECIMAL(11,2)
					  )
INSERT #tPeople( rf_idCase ,DateBegin ,DateEnd ,CodeM ,Account ,AmountPayment ,DateAccount ,NumberCase ,MES ,v002 ,V009)
SELECT c.id,c.DateBegin,c.DateEnd,f.CodeM,a.Account,c.AmountPayment,a.DateRegister,c.idRecordCase, m.MES, c.rf_idV002,c.rf_idV009
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles						
			AND a.rf_idSMO<>'34'					
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase	
					INNER JOIN dbo.vw_Diagnosis d ON 
			c.id=d.rf_idCase
					INNER JOIN (VALUES ('I20.0'),('I21'),('I21.0'),('I21.1'),('I21.2'),('I21.3'),('I21.4'),('I21.9'),('I22'),('I22.0'),('I22.1'),('I22.8'),('I22.9'),('I60'),('I60.0'),
										('I60.1'),('I60.2'),('I60.3'),('I60.4'),('I60.5'),('I60.6'),('I60.7'),('I60.8'),('I60.9'),('I61'),('I61.0'),('I61.1'),('I61.2'),('I61.3'),('I61.4'),
										('I61.5'),('I61.6'),('I61.8'),('I61.9'),('I62'),('I62.0'),('I62.1'),('I62.9'),('I63'),('I63.0'),('I63.1'),('I63.2'),('I63.3'),('I63.4'),('I63.5'),
										('I63.6'),('I63.8'),('I63.9'),('I64')) v(DS1) ON
			d.DS1=v.DS1                                      
																			
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=9 AND a.ReportYear=@reportYear 
		AND c.rf_idV006=1 AND c.DateEnd>='20150101' AND c.DateEnd<'20151001'
--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT rf_idCase,SUM(c.AmountMEK) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
													a.id=c.rf_idCheckedAccount 														
							WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd	 
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
--------------------------------------Update information about MU--------------------------------------

UPDATE p SET p.QuantityMU=m.QuantitySum
from #tPeople p INNER JOIN (SELECT rf_idCase,SUM(Quantity) AS QuantitySum from t_meduslugi WHERE MUGroupCode=1 AND MUUnGroupCode=11 AND MUCode IN (1,2) GROUP BY rf_idCase) m ON
		p.rf_idCase=m.rf_idCase


SELECT p.CodeM+' '+l.NAMES AS LPU,p1.FAM+' '+ISNULL(p1.IM,'')+' '+ISNULL(p1.OT,'') AS FIO,CAST(p1.DR AS DATE) AS DR,p.DateBegin,p.DateEnd,d.DS1, p.QuantityMU, p.MES
		,v2.name AS Profil, v9.name AS RSLT,p.Account,p.DateAccount,p.NumberCase,CAST(p.AmountPayment AS MONEY) AS AmountPayment
FROM #tPeople p inner JOIN dbo.t_Case_PID_ENP en ON
		p.rf_idCase=en.rf_idCase
				INNER JOIN dbo.vw_Diagnosis d ON
		p.rf_idCase=d.rf_idCase
				INNER JOIN PolicyRegister.dbo.PEOPLE p1 ON
		en.pid=p1.ID
				INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
		p.v002=v2.id 
				INNER JOIN RegisterCases.dbo.vw_sprV009 v9 ON
		p.v009=v9.id              			
				INNER JOIN dbo.vw_sprT001 l ON
		p.CodeM=l.CodeM              
WHERE p.AmountPayment>0 		
ORDER BY LPU 


go

DROP TABLE #tPeople


