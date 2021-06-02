USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20160101',	
		@dtEnd DATETIME='20161219 23:59:59',
		@reportYear SMALLINT=2016,
		@reportMonth TINYINT=11
				
SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment,c.rf_idV006,MainDS
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
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND MainDS IN('O05','O06')
	AND a.rf_idSMO<>'34'

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																							
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEnd
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase         
	    

SELECT  t.CodeM ,l.NAMES,
        t.Pokazatel ,
        t.CountCasesStacionar ,
        t.AmountCasesStacionar ,
        t.CountCasesDnStacionar ,
        t.AmountCasesDnStacionar ,
        t.CountCasesAmb ,
        t.AmountCasesAmb ,
        t.CountCasesSkoray ,
        t.AmountCasesSkoray
FROM (
SELECT CodeM ,'O06' AS Pokazatel,count(CASE WHEN MainDS='O06' AND AmountPayment>0 AND rf_idV006=1 THEN rf_idCase ELSE NULL END) AS CountCasesStacionar
			       ,SUM(CASE WHEN MainDS='O06'  AND AmountPayment>0 AND rf_idV006=1 THEN AmountPayment ELSE 0 end) AS AmountCasesStacionar
				 ,count(CASE WHEN MainDS='O06' AND AmountPayment>0 AND rf_idV006=2 THEN rf_idCase ELSE NULL END) AS CountCasesDnStacionar
				   ,SUM(CASE WHEN MainDS='O06'  AND AmountPayment>0 AND rf_idV006=2 THEN AmountPayment ELSE 0 end) AS AmountCasesDnStacionar
				 ,count(CASE WHEN MainDS='O06' AND AmountPayment>0 AND rf_idV006=3 THEN rf_idCase ELSE NULL END) AS CountCasesAmb
			       ,SUM(CASE WHEN MainDS='O06'  AND AmountPayment>0 AND rf_idV006=3 THEN AmountPayment ELSE 0 end) AS AmountCasesAmb
				 ,count(CASE WHEN MainDS='O06' AND AmountPayment=0 AND rf_idV006=4 THEN rf_idCase ELSE NULL END) AS CountCasesSkoray
			       ,SUM(CASE WHEN MainDS='O06'  AND AmountPayment=0 AND rf_idV006=4 THEN AmountPayment ELSE 0 end) AS AmountCasesSkoray
FROM #tmpCases	    
GROUP BY CodeM
UNION ALL
SELECT CodeM, 'O05',count(CASE WHEN MainDS='O05' AND AmountPayment>0 AND rf_idV006=1 THEN rf_idCase ELSE NULL END) AS CountCasesStacionar
			       ,SUM(CASE WHEN MainDS='O05'  AND AmountPayment>0 AND rf_idV006=1 THEN AmountPayment ELSE 0 end) AS AmountCasesStacionar
				 ,count(CASE WHEN MainDS='O05' AND AmountPayment>0 AND rf_idV006=2 THEN rf_idCase ELSE NULL END) AS CountCasesDnStacionar
				   ,SUM(CASE WHEN MainDS='O05'  AND AmountPayment>0 AND rf_idV006=2 THEN AmountPayment ELSE 0 end) AS AmountCasesDnStacionar
				 ,count(CASE WHEN MainDS='O05' AND AmountPayment>0 AND rf_idV006=3 THEN rf_idCase ELSE NULL END) AS CountCasesAmb
			       ,SUM(CASE WHEN MainDS='O05'  AND AmountPayment>0 AND rf_idV006=3 THEN AmountPayment ELSE 0 end) AS AmountCasesAmb
				 ,count(CASE WHEN MainDS='O05' AND AmountPayment=0 AND rf_idV006=4 THEN rf_idCase ELSE NULL END) AS CountCasesSkoray
			       ,SUM(CASE WHEN MainDS='O05'  AND AmountPayment=0 AND rf_idV006=4 THEN AmountPayment ELSE 0 end) AS AmountCasesSkoray
FROM #tmpCases	  
GROUP BY CodeM  
) t INNER JOIN dbo.vw_sprT001 l ON
		t.CodeM=l.CodeM
ORDER BY CodeM

go 
DROP TABLE #tmpCases


