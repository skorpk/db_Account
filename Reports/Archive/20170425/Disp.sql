USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20160101',	
		@dtEndReg DATETIME='20170320',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=2
				
SELECT a.rf_idSMO AS CodeSMO ,c.id AS rf_idCase,c.AmountPayment,c.DateEnd,ce.pid,ce.ENP
INTO #tmp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_DispInfo ds ON
			c.id=ds.rf_idCase					
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase 
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO IN('34007','34002') AND c.rf_idV009 IN(352, 353, 357, 358 ) AND a.Letter='O' AND ds.TypeDisp='ÄÂ1' AND ds.TypeFailure=1


UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmp c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount
															INNER JOIN #tmp cc ON
														c.rf_idCase=cc.rf_idCase 																							
								WHERE f.DateRegistration>='20170320' AND f.DateRegistration<='20170420 23:59:59'
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 

SELECT t.CodeSMO,COUNT(t.rf_idCase) AS CountCases
FROM #tmp t WHERE AmountPayment=0
GROUP BY t.CodeSMO
GO
DROP TABLE #tmp