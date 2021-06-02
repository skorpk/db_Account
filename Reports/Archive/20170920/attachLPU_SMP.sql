USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20160101',	
		@dtEndReg DATETIME=GETDATE(),
		@reportYear SMALLINT=2016,
		@reportMonth TINYINT=12,
		@idV006 TINYINT=4,
		@idV014 TINYINT=1
				
SELECT c.id AS rf_idCase,c.AmountPayment,c.AmountPayment AS AmmountPayment2,r.AttachLPU,ce.PID,c.DateBegin
INTO #tmpEKO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts						
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase  								
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND c.rf_idV006=@idV006 --AND c.rf_idV014 =@idV014
		AND a.rf_idSMO<>'34'

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpEKO c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountEKMP+c.AmountMEE+c.AmountMEK) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCaseVZ c INNER JOIN #tmpEKO cc ON
														c.rf_idCase=cc.rf_idCase 																							
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase

UPDATE #tmpEKO SET AttachLPU='131020' WHERE AttachLPU='135509'
UPDATE #tmpEKO SET AttachLPU='251003' WHERE AttachLPU='254504'
UPDATE #tmpEKO SET AttachLPU='251002' WHERE AttachLPU='255802'
UPDATE #tmpEKO SET AttachLPU='571001' WHERE AttachLPU='571002'
--SELECT AttachLPU,PID,DateBegin
--FROM #tmpEKO t 
--WHERE AttachLPU IN ('135509','254504','255802','571002') 
--ORDER BY AttachLPU,pId

--;WITH cte
--AS
--(
--SELECT TOP 1 WITH TIES AttachLPU,LPU,LPUDT,PID,DateBegin
--FROM #tmpEKO t INNER JOIN RegisterCases.dbo.vw_PeopleDefineLPU dp ON
--		t.pid=dp.ID 
--WHERE AttachLPU IN ('135509','254504','255802','571002') AND LPUDT<DateBegin
--ORDER BY ROW_NUMBER() OVER(PARTITION BY pID ORDER BY dp.LPUDT desc)
--) SELECT * FROM cte WHERE AttachLPU<>LPU
;WITH cte
AS(			
SELECT AttachLPU,rf_idCase
FROM #tmpEKO 
WHERE AmmountPayment2=0 AND AmountPayment=0
UNION ALL
SELECT AttachLPU,rf_idCase
FROM #tmpEKO 
WHERE AmmountPayment2>0 AND AmountPayment>0
)
SELECT l.CodeM,l.NameS, COUNT(rf_idCase) AS CountCase
FROM cte c INNER JOIN dbo.vw_sprT001_Report l ON
		c.AttachLPU=l.CodeM
GROUP BY CodeM,Names
ORDER BY CodeM
GO
DROP TABLE #tmpEKO