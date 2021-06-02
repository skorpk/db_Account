USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20160101',	
		@dtEndReg DATETIME=GETDATE(),
		@dtBeginAkt DATETIME='20170101',	
		@dtEndAkt DATETIME='20170420 23:59:59',
		@reportYear SMALLINT=2016
				
SELECT c.id	AS rf_idCase,ReportMonth,f.DateRegistration
INTO #tmpCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.Letter='H' 

--SELECT * FROM #tmpCase ORDER BY DateRegistration

SELECT RTRIM(sf.Reason)+' - '+ sf.Name,COUNT(c.rf_idCase),SUM(c.AmountDeduction) AS AmountDeduction
FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
						f.id=d.rf_idAFile
									INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
						d.id=a.rf_idDocumentOfCheckup
							INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
						a.id=c.rf_idCheckedAccount
							INNER JOIN #tmpCase cc ON
						c.rf_idCase=cc.rf_idCase 																							
							INNER JOIN ExchangeFinancing.dbo.t_ReasonDenialPayment rp ON
						c.id=rp.rf_idCheckedCase
							INNER JOIN OMS_NSI.dbo.sprF014 sf ON
						rp.CodeReason=sf.ID                         
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg
GROUP BY RTRIM(sf.Reason)+' - '+sf.Name	   
go 
DROP TABLE #tmpCase

