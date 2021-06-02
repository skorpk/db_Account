USE AccountOMS
GO		
IF OBJECT_ID('tmpEKO34',N'U') IS NOT NULL
	DROP TABLE tmpEKO34
go

DECLARE @dtBegin DATETIME='20160101',	
		@dtEndReg DATETIME='20170119 23:59:59',
		@dtEnd DATE='20161231',
		@reportYear SMALLINT=2016,
		@reportMonth TINYINT=12

SELECT TOP 1 WITH TIES c.id AS rf_idCase,c.AmountPayment,d.DS1,c.DateBegin,c.DateEnd,ce.pid,ce.ENP
INTO #tmpEKO
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
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase            
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<=@dtEnd  AND c.rf_idV002=137
	AND m.MES LIKE '2__4005' 
ORDER BY ROW_NUMBER() OVER(PARTITION BY ce.PID ORDER BY c.DateBegin desc)

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpEKO c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																							
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 
-----------------------------------------------------------------

SELECT @dtBegin ='20170101',	@dtEndReg ='20170331',@dtEnd ='20170420 23:59:59',@reportYear =2017,@reportMonth=3

INSERT #tmpEKO
SELECT TOP 1 WITH TIES c.id AS rf_idCase,c.AmountPayment,d.DS1,c.DateBegin,c.DateEnd,ce.pid,ce.ENP
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
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase            
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<=@dtEnd AND c.rf_idV002=137 AND m.MES LIKE '2__40005'	
ORDER BY ROW_NUMBER() OVER(PARTITION BY ce.PID ORDER BY c.DateBegin desc)	

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpEKO c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																							
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 

SELECT *
INTO tmpEKO34
FROM #tmpEKO WHERE AmountPayment>0

UPDATE c SET c.ENP=p.ENP
FROM dbo.tmpEKO34 c INNER JOIN PolicyRegister.dbo.PEOPLE p ON
			c.pid=p.id
WHERE c.ENP IS null	

go
DROP TABLE #tmpEKO