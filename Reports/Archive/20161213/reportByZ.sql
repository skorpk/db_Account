USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20160101',	
		@dtEnd DATETIME='20161214',--íà ýòî äàòó. ÂÍÈÌÀÍÈÅ
		@reportYear SMALLINT=2016,
		@reportMonth TINYINT=11
				
SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment,d.DS1,mkb.Diagnosis
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN dbo.vw_sprMKB10 mkb ON
			d.DS1=mkb.DiagnosisCode                  
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.rf_idV006=3 AND MainDS LIKE 'Z%' 


UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT p.rf_idCase, SUM(p.AmountDeduction) AS AmountDeduction
							  FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase p
							  WHERE p.DateRegistration>@dtBegin AND p.DateRegistration<@dtEnd
							  GROUP BY p.rf_idCase) p ON
			c.rf_idCase=p.rf_idCase    


SELECT Ds1,Diagnosis,COUNT(DISTINCT rf_idCase)
FROM #tmpCases
WHERE AmountPayment>0
GROUP BY Ds1,Diagnosis
ORDER BY DS1
GO
DROP TABLE #tmpCases