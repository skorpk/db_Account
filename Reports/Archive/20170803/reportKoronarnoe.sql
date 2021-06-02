USE AccountOMS
GO
DECLARE @dtStart DATETIME='20170101',
		@dtEnd DATETIME='20170803'

SELECT DISTINCT c.id, f.CodeM,c.AmountPayment,m.MUSurgery, mes.MES
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles	
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient				
				INNER JOIN (VALUES(31)) v(idV008) ON
		c.rf_idV008=v.idV008              
				INNER JOIN dbo.t_MES mes ON
		c.id=mes.rf_idCase	
				INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase													
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=2017 AND a.ReportMonth<8 AND c.rf_idV006 IN(1,2) AND a.rf_idSMO<>'34' 
		AND m.MUSurgery IN('A06.10.006','A06.10.006.002')
				

ALTER TABLE #tmpPeople ADD AmountPaymentAcc DECIMAL(11,2)

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountMEE+c.AmountEKMP+c.AmountMEK) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																							
								WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd
								GROUP BY c.rf_idCase
							) r ON
			p.id=r.rf_idCase

SELECT l.CodeM,l.NAMES,p.MUSurgery, COUNT(DISTINCT p.id) AS CountCases,p.MES		
FROM #tmpPeople p INNER JOIN dbo.vw_sprT001 l ON
			p.CodeM=l.CodeM						  				      
WHERE AmountPaymentAcc>0
GROUP BY l.CodeM,l.NAMES,p.MUSurgery,p.MES
ORDER BY l.CodeM

GO
DROP TABLE #tmpPeople