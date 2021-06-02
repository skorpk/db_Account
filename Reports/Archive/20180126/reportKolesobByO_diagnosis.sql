USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATETIME='20180125',
		@dtEnd DATETIME='20180101',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=12
				
SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment,d.DS1,mkb.Diagnosis,c.rf_idV006
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
			--		INNER JOIN dbo.t_PatientSMO s ON
			--r.id=s.rf_idRecordCasePatient                  
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN dbo.vw_sprMKB10 mkb ON
			d.DS1=mkb.DiagnosisCode             
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND MainDS IN ('O91','O92')	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<@dtEndReg AND c.rf_idV006 <4

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c INNER JOIN #tmpCases cc ON
										c.rf_idCase=cc.rf_idCase																							
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase    

SELECT distinct  c.CodeM,l.NAMES,c.DS1,
		COUNT(CASE WHEN c.rf_idV006=1 THEN c.rf_idCase ELSE null END) AS Stacionar,
		COUNT(CASE WHEN c.rf_idV006=2 THEN c.rf_idCase ELSE null END) AS DnevnoiStacionar,
		COUNT(CASE WHEN c.rf_idV006=3 THEN c.rf_idCase ELSE null END) AS Ambulatorno,
		COUNT(c.rf_idV006) AS AllCases
FROM #tmpCases c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM				
WHERE c.AmountPayment>0 
GROUP BY c.CodeM,l.NAMES,c.DS1

GO
DROP TABLE #tmpCases