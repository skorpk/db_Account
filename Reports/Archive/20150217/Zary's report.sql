USE AccountOMS
GO		
DECLARE @dtStart DATETIME='20140101',
		@dtEnd DATETIME='20150123 23:59:59',
		@reportYear SMALLINT=2014

CREATE TABLE #tPeople(rf_idCase BIGINT,
					  CodeM CHAR(6),
					  AmountPayment DECIMAL(11,2), 
					  MU varchar(12),
					  Quantity DECIMAL(6,2)
					  )
					  
--INSERT #tPeople( rf_idCase,CodeM ,AmountPayment ,MU,Quantity)
--SELECT c.id,f.CodeM,c.AmountPayment,m.MU,SUM(m.Quantity)
--FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
--			f.id=a.rf_idFiles
--					INNER JOIN (VALUES('185905'),('801926') ) l(CodeM) ON
--			f.CodeM=l.CodeM
--					INNER JOIN dbo.t_RecordCasePatient r ON
--			a.id=r.rf_idRegistersAccounts
--					INNER JOIN dbo.t_Case c ON
--			r.id=c.rf_idRecordCasePatient
--					INNER JOIN dbo.t_Meduslugi m ON
--			c.id=m.rf_idCase					
--WHERE f.DateRegistration>@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.rf_idV006=2 AND m.MU='55.1.5'
--GROUP BY c.id,f.CodeM,c.AmountPayment,m.MU

INSERT #tPeople( rf_idCase,CodeM ,AmountPayment,MU ,Quantity)
SELECT c.id,f.CodeM,c.AmountPayment,mes.MES,SUM(m.Quantity)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
				  INNER JOIN (VALUES('185905'),('801926') ) l(CodeM) ON
			f.CodeM=l.CodeM
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES mes ON
			c.id=mes.rf_idCase		
					INNER JOIN (VALUES('55.5.22'),('55.5.35'),('55.5.36'),('55.5.37'),('55.8.37') ) v(MU) ON
			mes.MES=v.MU
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase			
WHERE f.DateRegistration>@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.rf_idV006=2 AND m.MUGroupCode=55
GROUP BY c.id,f.CodeM,c.AmountPayment,mes.MES
--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT  sc.rf_idCase, SUM(ISNULL(sc.AmountEKMP, 0) + ISNULL(sc.AmountMEE, 0) + ISNULL(sc.AmountMEK, 0)) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN ExchangeFinancing.dbo.t_DocumentOfCheckup p ON 
														f.id = p.rf_idAFile 
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON 
														p.id = a.rf_idDocumentOfCheckup 
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedCase sc ON 
														a.id = sc.rf_idCheckedAccount
							WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<'20150128'
							GROUP BY sc.rf_idCase
							) r ON						
			p.rf_idCase=r.rf_idCase

SELECT CodeM,SUM(Quantity)
from #tPeople
WHERE AmountPayment>0			
GROUP BY CodeM
			
GO
DROP TABLE #tPeople			