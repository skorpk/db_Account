USE AccountOMS
GO
DECLARE @dateEnd DATETIME='20150410 23:59:59',
		@dateEndPay DATETIME='20150430',
		@reportYear smallint=2015
		
declare	@dateStart DATETIME=CAST(@reportYear AS CHAR(4))+'0101'

CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  DS1 CHAR(6),
					  AmountPayment DECIMAL(11,2),
					  FIO VARCHAR(60),
					  DR DATE,
					  DateBegin DATE,
					  DateEnd DATE,
					  rf_idV002 SMALLINT,
					  rf_idV012 SMALLINT,
					  CodeM CHAR(6),
					  Account VARCHAR(15),
					  DateAccount DATE,
					  MES VARCHAR(15),
					  NumberCase BIGINT,
					  Quantity DECIMAL(11,2) NOT NULL DEFAULT 0,
					  rf_idV010 TINYINT,
					  rf_idV006 TINYINT
					  )


INSERT #tPeople( rf_idCase ,DS1 ,AmountPayment ,FIO ,DR ,DateBegin ,DateEnd ,rf_idV002 ,rf_idV012 ,CodeM ,Account, DateAccount ,MES ,NumberCase, rf_idV010,rf_idV006)
SELECT c.id,RTRIM(d.DS1),c.AmountPayment, p.Fam+' '+p.im+' '+isnull(p.Ot,''),p.BirthDay,c.DateBegin,c.DateEnd,c.rf_idV002 ,c.rf_idV012 
		,f.CodeM ,a.Account, a.DateRegister ,m.MES ,c.idRecordCase,c.rf_idV010,c.rf_idV006
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles	
			AND a.rf_idSMO<>'34'															
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient						
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase	
					INNER JOIN (VALUES ('I20.0'),('I21'),('I21.0'),('I21.1'),('I21.2'),('I21.3'),('I21.4'),('I21.9'),('I22'),('I22.0'),('I22.1'),('I22.8'),
										('I22.9'),('I60'),('I60.0'),('I60.1'),('I60.2'),('I60.3'),('I60.4'),('I60.5'),('I60.6'),('I60.7'),('I60.8'),('I60.9'),
										('I61'),('I61.0'),('I61.1'),('I61.2'),('I61.3'),('I61.4'),('I61.5'),('I61.6'),('I61.8'),('I61.9'),('I62'),('I62.0'),
										('I62.1'),('I62.9'),('I63'),('I63.0'),('I63.1'),('I63.2'),('I63.3'),('I63.4'),('I63.5'),('I63.6'),('I63.8'),('I63.9'),('I64'))v(DS) ON
			d.DS1=v.DS
					INNER JOIN dbo.t_RegisterPatient p ON
			p.rf_idFiles=f.id
			AND p.rf_idRecordCase=r.id	
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=3 AND a.ReportYear=@reportYear
		AND /*c.rf_idV006=1 AND c.rf_idV010=33 AND*/ a.Letter='H'
--------------------------Calc quantity----------------------------

UPDATE p SET Quantity=m.Quantity
from #tPeople p INNER JOIN (
								SELECT p.rf_idCase,SUM(m.Quantity) AS Quantity
								FROM #tPeople p INNER JOIN dbo.t_Meduslugi m ON
										p.rf_idCase=m.rf_idCase
								WHERE m.MUGroupCode=1 AND m.MUUnGroupCode=11 AND m.MUCode>0 AND m.MUCode<3
								GROUP BY p.rf_idCase
							) m ON
					p.rf_idCase=m.rf_idCase


--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction 
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase a 
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay 
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
			
SELECT  p.CodeM+' - '+l.NAMES ,p.FIO ,p.DR ,p.DateBegin ,p.DateEnd ,p.DS1,p.Quantity ,p.MES ,v002.name,v012.name ,p.Account ,P.DateAccount
		,p.NumberCase,CAST(p.AmountPayment AS MONEY),V006.name,V010.name
FROM #tPeople p INNER JOIN RegisterCases.dbo.vw_sprV002 v002 ON
		p.rf_idV002=v002.id	
				INNER JOIN RegisterCases.dbo.vw_sprV012 v012 ON
		p.rf_idV012=v012.id
				INNER JOIN dbo.vw_sprT001 l ON
		p.CodeM=l.CodeM
				INNER JOIN RegisterCases.dbo.vw_sprV006 v006 ON
		p.rf_idV006=v006.id
				INNER JOIN RegisterCases.dbo.vw_sprV010 v010 ON
		p.rf_idV010=v010.id
WHERE p.AmountPayment>0	
ORDER BY p.CodeM+' - '+l.NAMES,Account,NumberCase				

go

DROP TABLE #tPeople


