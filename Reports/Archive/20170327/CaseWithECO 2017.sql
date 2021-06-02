USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATETIME='20170310 23:59:59',
		@dtEnd DATETIME='20170310 23:59:59',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=2
				
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
	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<=@dtEndReg AND c.rf_idV002=137
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
	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<=@dtEndReg AND c.rf_idV002=137
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
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 


INSERT #tmpEKO (rf_idCase,AmountPayment,DateEnd,PID,ENP) 
SELECT 0,100,DATEADD(DAY,-2,CAST(cast(v.DateEnd AS datetime) AS DATE)),v.PID,v.ENP
FROM (VALUES (2017,2413473,'3457500898000303',42761),(2017,2655174,'3447210873000343',42766),(2017,2800329,'1649620892000662',42766),(2017,3078004,'7756110895002945',42766)) v(ReportYear,PID,ENP,DateEnd)



SELECT c.id AS rf_idCase,c.AmountPayment,d.DS1,c.DateBegin,c.DateEnd,ce.pid,ce.ENP,e.rf_idCase AS rf_idCaseEKO
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
WHERE f.DateRegistration>=@dtBegin AND c.rf_idV002 IN(136,137) AND c.rf_idV006=3 AND c.DateBegin>=e.DateEnd AND e.AmountPayment>0

--SELECT *
--FROM #tmpEKO WHERE ENP IS NULL

--SELECT *
--FROM #tmpCases WHERE ENP IS NULL
   
SELECT e.ENP,e.DateEnd,'Волгоградская область',c.DateBegin,c.DateEnd,c.DS1,m.Diagnosis
FROM #tmpEKO e INNER JOIN #tmpCases c ON
		e.ENP=c.ENP
				INNER JOIN dbo.vw_sprMKB10 m ON
		c.DS1=m.DiagnosisCode              

GO
DROP TABLE #tmpCases
DROP TABLE #tmpEKO