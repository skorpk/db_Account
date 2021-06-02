USE AccountOMS
GO
DECLARE @dtStart DATETIME='20170101',
		@dtEnd DATETIME='20170711',
		@dtEndRAK DATETIME='20170711',
		@Year SMALLINT=2017,
		@month TINYINT=6 

SELECT DISTINCT c.id,c.AmountPayment,c.rf_idV006, c.rf_idV002, CASE WHEN p.rf_idV005=1 AND c.Age>59 THEN 1 WHEN p.rf_idV005=2 AND c.Age>54 THEN 2 ELSE 0 END AS IsGood
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles	
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient				
				INNER JOIN dbo.vw_RegisterPatient p ON
		r.id=p.rf_idRecordCase
		AND f.id=p.rf_idFiles              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@Year AND a.ReportMonth<=@month AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtStart AND c.DateEnd<@dtEnd
		AND c.rf_idV006 IN(1,2) AND c.rf_idV002=14 
		
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountMEE+c.AmountEKMP+c.AmountMEK) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 
															INNER JOIN #tmpPeople p ON
														c.rf_idCase=p.id																							
								WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEndRAK AND p.IsGood>0 
								GROUP BY c.rf_idCase
							) r ON
			p.id=r.rf_idCase

SELECT v6.name, COUNT(p.id) AS CountCase, CAST(SUM(p.AmountPayment) AS MONEY) AS SumPayment
FROM #tmpPeople p INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
		p.rf_idV006=v6.id
WHERE p.AmountPayment>0	AND p.IsGood>0
GROUP BY v6.name
GO
DROP TABLE #tmpPeople