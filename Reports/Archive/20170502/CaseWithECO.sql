USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20160101',	
		@dtEndReg DATETIME='20170119 23:59:59',
		@dtEndAmb DATETIME=GETDATE(),
		@dtEnd DATE='20161231',
		@reportYear SMALLINT=2016,
		@reportMonth TINYINT=12
				
SELECT c.id AS rf_idCase,c.AmountPayment,c.DateEnd,ce.pid,ce.ENP,f.CodeM,m.MES
INTO #tmpEKO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase  										
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase 
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<=@dtEnd AND c.rf_idV006=2
	AND m.MES IN ('2004005','2504005','2001005','2002005','2003005')

INSERT #tmpEKO (rf_idCase,AmountPayment,DateEnd,PID,ENP, CodeM,MES)
SELECT c.id AS rf_idCase,c.AmountPayment,c.DateEnd,ce.pid,ce.ENP,f.CodeM,m.MES
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase  										
					inner JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase 
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<=@dtEnd AND c.rf_idV006=2
	AND m.MES IN ('2004005','2504005','2001005','2002005','2003005') AND ce.PID IS NULL	


UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpEKO c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount
															INNER JOIN #tmpEKO cc ON
														c.rf_idCase=cc.rf_idCase 																							
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 

UPDATE c SET c.ENP=p.ENP
FROM #tmpEKO c INNER JOIN PolicyRegister.dbo.PEOPLE p ON
			c.pid=p.id
WHERE c.ENP IS null


SELECT c.id AS rf_idCase,c.AmountPayment,d.DS1,c.DateBegin,c.DateEnd,ce.pid,ce.ENP,e.rf_idCase AS rf_idCaseEKO
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase  
					INNER JOIN #tmpEKO e ON
			ce.ENP=e.ENP					                  
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<@dtEndAmb AND c.rf_idV002=136 AND c.rf_idV006=3 AND c.DateBegin>=e.DateEnd AND a.ReportYearMonth<=201704
		AND e.AmountPayment>0

   
SELECT e.ENP,e.MES,e.DateEnd, e.CodeM,l.NAMES AS LPu ,c.DateBegin,c.DateEnd,c.DS1,m.Diagnosis
FROM #tmpEKO e INNER JOIN #tmpCases c ON
		e.ENP=c.ENP
				INNER JOIN dbo.vw_sprMKB10 m ON
		c.DS1=m.DiagnosisCode 
				INNER JOIN dbo.vw_sprT001 l ON
		e.CodeM=l.CodeM 
WHERE c.AmountPayment>0

GO
DROP TABLE #tmpCases
DROP TABLE #tmpEKO