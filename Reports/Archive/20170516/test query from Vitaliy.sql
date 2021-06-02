USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEnd DATE='20170515',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=4
				
SELECT distinct c.id AS rf_idCase,f.DateRegistration,a.Account,f.CodeM,c.AmountPayment,a.ReportMonth,c.rf_idMO,ce.PID,ce.ENP,CAST(0 AS DECIMAL(11,2)) AS AmountAccepted, d.TypeDisp
INTO #tmp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase                  
					INNER JOIN dbo.t_DispInfo d ON
			c.id=d.rf_idCase
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO<>'34' AND a.Letter='O' AND d.TypeDisp='ÄÂ1'

UPDATE c SET c.AmountAccepted=c.AmountPayment-p.AmountDeduction
from #tmp c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount
															INNER JOIN #tmp cc ON
														c.rf_idCase=cc.rf_idCase 																							
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEnd
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 
;WITH cteDouble
AS(
SELECT ENP 
FROM #tmp WHERE AmountAccepted>0 
GROUP BY ENP
HAVING COUNT(*)>1
)
SELECT t.*
FROM cteDouble c INNER JOIN #tmp t ON
		c.ENP=t.ENP
ORDER BY t.ENP

go

DROP TABLE #tmp
