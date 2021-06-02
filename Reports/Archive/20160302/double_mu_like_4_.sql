USE AccountOMS
GO
DECLARE @codeM CHAR(6)='125901',
		@reportYear SMALLINT=2016,
		@dateStart DATETIME='20160120',
		@dateEnd DATETIME=GETDATE(),
		@dateEndPay DATETIME=GETDATE()

CREATE TABLE #tPeople(
					 rf_idCase BIGINT,
					  MU VARCHAR(9),						  
					  Policy VARCHAR(30),					  
					  rf_idDirectMO varchar(6),
					  DateEnd DATE,
					  AmountPayment DECIMAL(11,2), 
					  Quantity DECIMAL(11,2),
					  IsDouble BIT NOT NULL DEFAULT(0),
					  FIO nvarchar(80),
					  DR date					  
					  )
INSERT #tPeople( rf_idCase,MU ,Policy ,rf_idDirectMO ,DateEnd ,AmountPayment ,Quantity,FIO, DR)
SELECT c.id,m.MU,r.NumberPolis,c.rf_idDirectMO,c.DateEnd,c.AmountPayment,m.Quantity,p.Fam+' '+p.Im+' '+ISNULL(p.Ot,'') AS FIO,p.BirthDay
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles			
			AND f.CodeM=@codeM					
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles                  
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase																				
					INNER JOIN (VALUES(4,11),(4,12),(4,13),(4,15)) v(MUGroupCode,MUUnGroupCode) ON
			m.MUGroupCode=v.MUGroupCode
			AND m.MUUnGroupCode=v.MUUnGroupCode
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=3 AND a.ReportYear=@reportYear  
--GROUP BY m.MU,r.NumberPolis,c.rf_idDirectMO,c.DateEnd,c.AmountPayment

/*SELECT m.MU,r.NumberPolis,c.rf_idDirectMO,c.DateEnd,c.AmountPayment,SUM(m.Quantity) AS Quantity
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles			
			AND f.CodeM=@codeM					
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase																				
					INNER JOIN (VALUES(4,11),(4,12),(4,13),(4,15)) v(MUGroupCode,MUUnGroupCode) ON
			m.MUGroupCode=v.MUGroupCode
			AND m.MUUnGroupCode=v.MUUnGroupCode
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=3 AND a.ReportYear=@reportYear  
GROUP BY m.MU,r.NumberPolis,c.rf_idDirectMO,c.DateEnd,c.AmountPayment
HAVING SUM(m.Quantity)>1
*/
UPDATE p SET p.IsDouble=1
from #tPeople p INNER JOIN (
							SELECT Policy,MU,DateEnd,SUM(Quantity) AS Quantity
							FROM #tPeople p 
							GROUP BY Policy,MU,DateEnd
							HAVING SUM(Quantity)>1
							) t ON
				  p.Policy=t.Policy
				  AND p.MU=t.MU
				  AND p.DateEnd=t.DateEnd                        


--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile
													AND f.CodeM=@codeM
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
													a.id=c.rf_idCheckedAccount 														
							WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEndPay	 
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE IsDouble=1

SELECT *
FROM #tPeople WHERE IsDouble=1 AND Policy='131702479'

SELECT p.MU,m.MUName,FIO, DR,Policy,p.DateEnd,l.CodeM, l.NAMES,SUM(Quantity)
FROM #tPeople p INNER JOIN dbo.vw_sprMUAll m ON
		p.MU=m.MU
				INNER JOIN dbo.vw_sprT001 l ON
		p.rf_idDirectMO=l.mcod              
WHERE AmountPayment>0 AND IsDouble=1
GROUP BY p.MU,m.MUName,FIO, DR,Policy,p.DateEnd,l.CodeM, l.NAMES
ORDER BY MU
GO
DROP TABLE #tPeople