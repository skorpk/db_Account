USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATETIME='20170607 23:59:59',
		@dtEndRegRAK DATETIME='20170607 23:59:59',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=5
				
SELECT a.rf_idSMO AS CodeSMO ,c.id AS rf_idCase,c.AmountPayment,c.DateEnd,ce.pid,ps.ENP,ds.TypeFailure,f.DateRegistration,a.ReportMonth,p.NAZR
INTO #tmp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts		
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_DispInfo ds ON
			c.id=ds.rf_idCase					
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase 
					INNER JOIN dbo.t_Prescriptions p ON
			c.id=p.rf_idCase                    
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO IN('34007','34002') /*AND c.rf_idV009 IN(352, 353, 357, 358 )*/ AND a.Letter='O' AND ds.TypeDisp='ÄÂ2' 


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
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndRegRAK
								GROUP BY c.rf_idCase 
							) p ON
			c.rf_idCase=p.rf_idCase 

SELECT t.CodeSMO,COUNT(DISTINCT CASE WHEN t.NAZR=4THEN t.ENP ELSE NULL END) as Col1,
				COUNT(t.ENP) AS Col2,
		COUNT(DISTINCT CASE WHEN t.NAZR=5 THEN t.ENP ELSE NULL END) as Col3
FROM #tmp t 
WHERE AmountPayment>0
GROUP BY t.CodeSMO
GO
DROP TABLE #tmp