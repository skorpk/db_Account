USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20160101',	
		@dtEndReg DATETIME='20170420',
		@dteEndAKT DATETIME='20170420',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=3
				
SELECT a.rf_idSMO AS CodeSMO ,c.id AS rf_idCase,c.AmountPayment,c.DateEnd,ce.pid,ce.ENP,a.ReportMonth,f.DateRegistration
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
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dteEndAKT
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 

;WITH cte
AS(
SELECT t.CodeSMO,CASE WHEN t.ReportMonth=3 THEN t.rf_idCase ELSE NULL END AS CountMonthCase,CASE WHEN t.ReportMonth=3 THEN t.ENP ELSE NULL END AS CountMonthENP
		,t.rf_idCase, t.ENP 
FROM #tmp t 
WHERE AmountPayment>0
UNION ALL 
SELECT t.CodeSMO,CASE WHEN t.DateRegistration>='20170320' and t.DateRegistration<=@dtEndReg AND ReportMonth<3 THEN t.rf_idCase ELSE NULL END
		,CASE WHEN t.DateRegistration>='20170320' and t.DateRegistration<=@dtEndReg AND ReportMonth<3 THEN t.ENP ELSE NULL END AS CountMonthCase
		,NULL,null
FROM #tmp t 
WHERE AmountPayment>0
)
SELECT CodeSMO,COUNT(CountMonthCase) AS CountMonthCases, COUNT(rf_idCase) AS CountYearCases, COUNT(DISTINCT CountMonthENP) AS CountMonthENP, COUNT(DISTINCT ENP) ENPYear FROM cte GROUP BY codeSMO
GO
DROP TABLE #tmp