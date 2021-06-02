USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20160101',	
		@dtEndReg DATETIME=GETDATE(),
		@reportYear SMALLINT=2016,
		@reportMonth TINYINT=12,
		@idV006 TINYINT=4
				
SELECT c.id AS rf_idCase,c.AmountPayment,c.AmountPayment AS AmmountPayment2,r.AttachLPU,ce.PID,c.DateBegin, c.rf_idV014
INTO #tmpEKO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts						
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase  								
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND c.rf_idV006=@idV006 
		AND a.rf_idSMO<>'34'

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpEKO c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountEKMP+c.AmountMEE+c.AmountMEK) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCaseVZ c INNER JOIN #tmpEKO cc ON
														c.rf_idCase=cc.rf_idCase 																							
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase


--SELECT COUNT(*) FROM #tmpEKO WHERE NOT EXISTS(SELECT * FROM dbo.vw_sprT001 WHERE CodeM=AttachLPU)
;WITH cte
AS(			
SELECT rf_idCase,rf_idV014
FROM #tmpEKO 
WHERE AmmountPayment2=0 AND AmountPayment<0
UNION ALL
SELECT rf_idCase, rf_idV014
FROM #tmpEKO 
WHERE AmmountPayment2>0 AND AmountPayment=0
)
SELECT 'Общее количество не принятых вызовов', COUNT(CASE WHEN rf_idV014=1 then rf_idCase ELSE NULL END )AS CountCaseEkstrennay
	,COUNT(CASE WHEN rf_idV014=2 then rf_idCase ELSE NULL END )AS CountCaseNeotl
	,COUNT(CASE WHEN rf_idV014=3 then rf_idCase ELSE NULL END )AS CountCasePlan
FROM cte c INNER JOIN oms_nsi.dbo.sprV014 v14 ON
		c.rf_idV014=v14.IDFRMMP			

;WITH cte
AS(			
SELECT rf_idCase,rf_idV014
FROM #tmpEKO 
WHERE AmmountPayment2=0 AND AmountPayment=0
UNION ALL
SELECT rf_idCase, rf_idV014
FROM #tmpEKO 
WHERE AmmountPayment2>0 AND AmountPayment>0
)
SELECT 'Общее количество вызовов', COUNT(CASE WHEN rf_idV014=1 then rf_idCase ELSE NULL END )AS CountCaseEkstrennay
	,COUNT(CASE WHEN rf_idV014=2 then rf_idCase ELSE NULL END )AS CountCaseNeotl
	,COUNT(CASE WHEN rf_idV014=3 then rf_idCase ELSE NULL END )AS CountCasePlan
FROM cte c INNER JOIN oms_nsi.dbo.sprV014 v14 ON
		c.rf_idV014=v14.IDFRMMP			
GO
DROP TABLE #tmpEKO