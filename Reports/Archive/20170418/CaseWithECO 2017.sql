USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATE='20170430',
		@dtEnd DATETIME='20170520 23:59:59',
		@dtEndAmb DATETIME='20170521',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=4
				
SELECT TOP 1 WITH TIES c.id AS rf_idCase,c.AmountPayment,c.DateEnd,ce.pid,ce.ENP
INTO #tmpEKO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase  
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase            
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<=@dtEndReg AND c.rf_idV002=137 AND c.rf_idV006=2
	AND m.MES LIKE '2__40005' AND ce.PID IS NULL
ORDER BY ROW_NUMBER() OVER(PARTITION BY ce.ENP ORDER BY c.DateEnd desc)		

INSERT #tmpEKO (rf_idCase,AmountPayment,DateEnd,PID,ENP)
SELECT TOP 1 WITH TIES c.id AS rf_idCase,c.AmountPayment,c.DateEnd,ce.pid,ce.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase  
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase            
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<=@dtEndReg AND c.rf_idV002=137 AND c.rf_idV006=2
	AND m.MES LIKE '2__40005' AND ce.PID IS NOT NULL
ORDER BY ROW_NUMBER() OVER(PARTITION BY ce.PID ORDER BY c.DateEnd desc)

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpEKO c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
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


INSERT #tmpEKO (rf_idCase,AmountPayment,DateEnd,PID,ENP) 
SELECT 0,100,DATEADD(DAY,-2,CAST(cast(v.DateEnd AS datetime) AS DATE)),v.PID,v.ENP
FROM (VALUES (2017,2413473,'3457500898000303',42761),(2017,2655174,'3447210873000343',42766),
(2017,2800329,'1649620892000662',42766),(2017,3078004,'7756110895002945',42766)) v(ReportYear,PID,ENP,DateEnd)

INSERT #tmpEKO (rf_idCase,AmountPayment,DateEnd,ENP) VALUES (0,100,'20170131','1649620842000662')



SELECT c.id AS rf_idCase,c.AmountPayment,d.DS1,c.DateBegin,c.DateEnd,ce.pid,ce.ENP,e.rf_idCase AS rf_idCaseEKO, c.Comments
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase  
					INNER JOIN #tmpEKO e ON
			ce.ENP=e.ENP
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<@dtEndAmb AND c.rf_idV002=136 AND c.rf_idV006=3 AND c.DateBegin>=e.DateEnd AND a.ReportYearMonth<=201704 AND e.AmountPayment>0

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 
															INNER JOIN #tmpCases cc ON
														c.rf_idCase=cc.rf_idCase																							
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<@dtEndAmb
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 
   
SELECT e.ENP,e.DateEnd,'Волгоградская область',c.DateBegin,c.DateEnd,c.DS1,m.Diagnosis, c.Comments
FROM #tmpEKO e INNER JOIN #tmpCases c ON
		e.ENP=c.ENP
				INNER JOIN dbo.vw_sprMKB10 m ON
		c.DS1=m.DiagnosisCode      
WHERE m.MainDS IN('O10','O11','O12','O13','O14','O15','O16','O20','O21','O22','O23','O24','O25','O26','O28','O30','O31','O32','O33','O36','O40','O41','O43','O44','O45','O46','O47','O98','O99'
				,'Z33','Z34','Z35','Z36')		            		            		       
	AND c.AmountPayment>0

GO
DROP TABLE #tmpCases
DROP TABLE #tmpEKO