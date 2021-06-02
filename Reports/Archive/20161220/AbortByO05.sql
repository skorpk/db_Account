USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20160101',	
		@dtEnd DATETIME='20161219 23:59:59',
		@reportYear SMALLINT=2016,
		@reportMonth TINYINT=11
				
SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment,a.rf_idSMO AS CodeSMO,a.Account, a.DateRegister, c.idRecordCase AS NumberCase
	,d.DS1,p.Fam,p.Im, p.Ot,p.BirthDay, c.NumberHistoryCase, c.DateBegin,c.DateEnd
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN dbo.vw_sprMKB10 mkb ON
			d.DS1=mkb.DiagnosisCode                  
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles                  
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND MainDS ='O05'
	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<@dtEnd

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																							
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEnd
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase    
SELECT  CodeM ,CodeSMO , Account ,DateRegister AS DateAccount ,NumberCase ,DS1 ,Fam ,Im ,Ot ,BirthDay ,NumberHistoryCase 
		,DateBegin ,DateEnd,AmountPayment  
FROM #tmpCases c 
WHERE AmountPayment>0
GO
DROP TABLE #tmpCases