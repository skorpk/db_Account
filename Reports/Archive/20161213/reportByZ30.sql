USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20160101',	
		@dtEnd DATETIME='20161214',
		@reportYear SMALLINT=2016
				
SELECT c.id AS rf_idCase,c.AmountPayment,c.rf_idV006
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase			
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.rf_idV006 IN (1,2,3) AND d.DS1='Z30.3'

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT p.rf_idCase, SUM(p.AmountDeduction) AS AmountDeduction
							  FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase p
							  WHERE p.DateRegistration>@dtBegin AND p.DateRegistration<@dtEnd
							  GROUP BY p.rf_idCase) p ON
			c.rf_idCase=p.rf_idCase         

SELECT 'Количество случаев с диагнозом Z30.3',COUNT(CASE WHEN c.rf_idV006=1 THEN c.rf_idCase ELSE NULL END) AS Stacionar,
		COUNT(CASE WHEN c.rf_idV006=2 THEN c.rf_idCase ELSE NULL END) AS DnevStacionar
		,COUNT(CASE WHEN c.rf_idV006=3 THEN c.rf_idCase ELSE NULL END) AS Ambulatory, 1 AS RowOrder
FROM #tmpCases c 
WHERE AmountPayment>0


go 
DROP TABLE #tmpCases
