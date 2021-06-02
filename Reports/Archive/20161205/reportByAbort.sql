USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20160101',	
		@dtEnd DATETIME='20161206',--на это дату. ВНИМАНИЕ
		--@codeM CHAR(6)='185905',
		@reportYear SMALLINT=2016,
		@reportMonth TINYINT=11
				
SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment,c.rf_idV006, 0 AS Col037, 0 AS Col005, 0 AS Col079
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
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear /*AND a.ReportMonth<=@reportMonth */AND c.rf_idV006 IN (1,2,3) AND MainDS IN(/*'O02',*/'O03','O04','O05','O06','O07')

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT p.rf_idCase, SUM(p.AmountDeduction) AS AmountDeduction
							  FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase p
							  WHERE p.DateRegistration>@dtBegin AND p.DateRegistration<@dtEnd
							  GROUP BY p.rf_idCase) p ON
			c.rf_idCase=p.rf_idCase         

UPDATE c SET c.Col037=1
FROM #tmpCases c INNER JOIN dbo.t_Meduslugi m ON
		c.rf_idCase=m.rf_idCase
WHERE m.MUSurgery='A16.20.037'

UPDATE c SET c.Col079=1
FROM #tmpCases c INNER JOIN dbo.t_Meduslugi m ON
		c.rf_idCase=m.rf_idCase
WHERE m.MUSurgery='A16.20.079'

UPDATE c SET c.Col005=1
FROM #tmpCases c INNER JOIN dbo.t_Meduslugi m ON
		c.rf_idCase=m.rf_idCase
WHERE m.MUSurgery='B03.001.005'

SELECT c.CodeM, l.NAMES AS lpu,'Количество случаев с диагнозом O03.*-O07.*',COUNT(CASE WHEN c.rf_idV006=1 THEN c.rf_idCase ELSE NULL END) AS Stacionar,
		COUNT(CASE WHEN c.rf_idV006=2 THEN c.rf_idCase ELSE NULL END) AS DnevStacionar
		,COUNT(CASE WHEN c.rf_idV006=3 THEN c.rf_idCase ELSE NULL END) AS Ambulance, 1 AS RowOrder
FROM #tmpCases c INNER JOIN dbo.vw_sprT001 l ON
			c.CodeM=l.CodeM
WHERE AmountPayment>0
GROUP BY c.CodeM, l.NAMES
UNION ALL
SELECT c.CodeM, l.NAMES AS lpu,'A16.20.03',SUM(CASE WHEN c.rf_idV006=1 THEN c.Col037 ELSE 0 END) AS Stacionar,
		SUM(CASE WHEN c.rf_idV006=2 THEN c.Col037 ELSE 0 END) AS DnevStacionar
		,sum(CASE WHEN c.rf_idV006=3 THEN c.Col037 ELSE 0 END) AS Ambulance,2 AS RowOrder
FROM #tmpCases c INNER JOIN dbo.vw_sprT001 l ON
			c.CodeM=l.CodeM
WHERE AmountPayment>0 
GROUP BY c.CodeM, l.NAMES
UNION ALL
SELECT c.CodeM, l.NAMES AS lpu,'B03.001.005',SUM(CASE WHEN c.rf_idV006=1 THEN c.Col005 ELSE 0 END) AS Stacionar,
		SUM(CASE WHEN c.rf_idV006=2 THEN c.Col005 ELSE 0 END) AS DnevStacionar
		,SUM(CASE WHEN c.rf_idV006=3 THEN c.Col005 ELSE 0 END) AS Ambulance,3 AS RowOrder
FROM #tmpCases c INNER JOIN dbo.vw_sprT001 l ON
			c.CodeM=l.CodeM
WHERE AmountPayment>0 
GROUP BY c.CodeM, l.NAMES
UNION ALL
SELECT c.CodeM, l.NAMES AS lpu, 'A16.20.079',SUM(CASE WHEN c.rf_idV006=1 THEN c.Col079 ELSE 0 END) AS Stacionar,
		SUM(CASE WHEN c.rf_idV006=2 THEN c.Col079 ELSE 0 END) AS DnevStacionar
		,SUM(CASE WHEN c.rf_idV006=3 THEN c.Col079 ELSE 0 END) AS Ambulance,4 AS RowOrder
FROM #tmpCases c INNER JOIN dbo.vw_sprT001 l ON
			c.CodeM=l.CodeM
WHERE AmountPayment>0
GROUP BY c.CodeM, l.NAMES
UNION ALL
SELECT c.CodeM, l.NAMES AS lpu,'Стоимость по строке 1',sum(CASE WHEN c.rf_idV006=1 THEN c.AmountPayment ELSE 0 END) AS Stacionar,
		sum(CASE WHEN c.rf_idV006=2 THEN c.AmountPayment ELSE 0 END) AS DnevStacionar
		,SUM(CASE WHEN c.rf_idV006=3 THEN c.AmountPayment ELSE 0 END) AS Ambulance,5 AS RowOrder
FROM #tmpCases c INNER JOIN dbo.vw_sprT001 l ON
			c.CodeM=l.CodeM
WHERE AmountPayment>0 
GROUP BY c.CodeM, l.NAMES
ORDER BY c.CodeM, rowOrder

go 
DROP TABLE #tmpCases


