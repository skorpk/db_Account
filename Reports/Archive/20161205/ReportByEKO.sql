USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20160101',	
		@dtEnd DATETIME='20161111'
				
SELECT c.id AS rf_idCase,ce.PID,c.AmountPayment,CodeM,0 AS AmountPaid
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
				  INNER JOIN (VALUES ('185905'),('801926'),('801934'),('801935')) v(CodeLPU) ON
			f.CodeM=v.CodeLPU                
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase 
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase                 
WHERE f.DateRegistration>@dtBegin AND f.DateRegistration<@dtEnd AND a.ReportYear=2016 AND a.ReportMonth<11 AND c.rf_idV006=2 AND m.MES LIKE '2___005'
	AND a.rf_idSMO<>'34'

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
							  FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
							  						f.id=d.rf_idAFile
							  									INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
							  						d.id=a.rf_idDocumentOfCheckup
							  							INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
							  						a.id=c.rf_idCheckedAccount 				
							  							INNER JOIN #tmpCases c1 ON
							  						c.rf_idCase=c1.rf_idCase																																
							  WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<GETDATE() 
							  GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase         
--;WITH cteCases
--AS
--(
--	SELECT CodeM,COUNT(rf_idCase) AS CountCase,Pid
--	FROM #tmpCases c
--	WHERE c.AmountPayment>0
--	GROUP BY CodeM,PID
--)
--SELECT codeM,COUNT(CASE WHEN CountCase=1 THEN pid ELSE NULL END) AS Col1
--		,COUNT(CASE WHEN CountCase=2 THEN pid ELSE NULL END) AS Col2
--		,COUNT(CASE WHEN CountCase>2 THEN pid ELSE NULL END) AS Col3
--FROM cteCases
--GROUP BY CodeM

;WITH cteCases
AS
(
	SELECT COUNT(rf_idCase) AS CountCase,Pid
	FROM #tmpCases c
	WHERE c.AmountPayment>0
	GROUP BY PID
)
SELECT COUNT(CASE WHEN CountCase=1 THEN pid ELSE NULL END) AS Col1
		,COUNT(CASE WHEN CountCase=2 THEN pid ELSE NULL END) AS Col2
		,COUNT(CASE WHEN CountCase>2 THEN pid ELSE NULL END) AS Col3
FROM cteCases
go 
DROP TABLE #tmpCases