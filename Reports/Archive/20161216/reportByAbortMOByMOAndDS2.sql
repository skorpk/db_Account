USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20160101',	
		@dtEnd DATETIME='20161219 23:59:59',
		@reportYear SMALLINT=2016,
		@reportMonth TINYINT=11
				
SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment,d.DS1, d1.DiagnosisCode AS DS2,a.Account,c.idRecordCase AS NumberCase
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
					left JOIN dbo.t_Diagnosis d1 ON
			c.id=d1.rf_idCase                  
			AND d1.TypeDiagnosis=3
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND MainDS='O04'
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
	    
--SELECT rf_idCase
--FROM #tmpCases
--GROUP BY rf_idCase
--HAVING COUNT(*)>1


SELECT DISTINCT c.CodeM,l.NAMES ,Account,NumberCase,rf_idCase,RTRIM(DS1)+' '+m1.Diagnosis AS DS1, ISNULL(RTRIM(DS2)+' '+m2.Diagnosis,'') AS DS2
FROM #tmpCases c INNER JOIN dbo.vw_sprT001 l ON
	       c.CodeM=l.CodeM
				 INNER JOIN dbo.vw_sprMKB10 m1 ON
			c.DS1=m1.DiagnosisCode               
				left JOIN dbo.vw_sprMKB10 m2 ON
			c.DS2=m2.DiagnosisCode  
WHERE c.Ds2 IS NOT NULL AND c.AmountPayment>0
ORDER BY c.CodeM,Account,NumberCase				 
go 
DROP TABLE #tmpCases


