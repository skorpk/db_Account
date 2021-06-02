USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20160101',	
		@dtEnd DATETIME='20161118 23:00:00'
				
SELECT c.id AS rf_idCase,c.AmountPayment,CodeM,CAST(0 AS DECIMAL(11,2)) AS AmountPaid,MES
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			--	  INNER JOIN (VALUES ('185905'),('801926'),('801934'),('801935')) v(CodeLPU) ON
			--f.CodeM=v.CodeLPU                
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
			--		INNER JOIN dbo.t_Case_PID_ENP ce ON
			--c.id=ce.rf_idCase 
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase                 
WHERE f.DateRegistration>@dtBegin AND f.DateRegistration<@dtEnd AND a.ReportYear=2016 AND a.ReportMonth<=10 AND c.rf_idV006=2 AND m.MES LIKE '2___005'
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
							  WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<@dtEnd
							  GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase         

UPDATE c SET c.AmountPaid=p.AmountPaymentAccept
from #tmpCases c INNER JOIN (SELECT sc.rf_idCase, CAST(SUM(sc.AmountPayment) AS DECIMAL(15,2)) AS AmountPaymentAccept
							 FROM  ExchangeFinancing.dbo.t_DFileIn f INNER JOIN ExchangeFinancing.dbo.t_PaymentDocument p ON 
							 							f.id = p.rf_idDFile 
							 										INNER JOIN ExchangeFinancing.dbo.t_SettledAccount a ON 
							 							p.id = a.rf_idPaymentDocument 
							 										INNER JOIN ExchangeFinancing.dbo.t_SettledCase sc ON 
							 							a.id = sc.rf_idSettledAccount
							 WHERE f.DateRegistration >=@dtBegin AND f.DateRegistration<@dtEnd
							 GROUP BY sc.rf_idCase
							 ) p ON
			c.rf_idCase=p.rf_idCase
                             

;WITH cteCases
AS
(
	SELECT CodeM,Mes,COUNT(rf_idCase) AS CountCase,CAST(SUM(AmountPayment) AS MONEY) AS AmountPayment
	FROM #tmpCases c
	WHERE c.AmountPayment>0 AND c.AmountPayment<=c.AmountPaid
	GROUP BY CodeM,Mes	
)
SELECT c.CodeM,l.NAMES,c.MES,CountCase, AmountPayment
FROM cteCases c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
ORDER BY c.CodeM,c.MES
go 
DROP TABLE #tmpCases