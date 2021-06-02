USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATETIME='20170324',
		@dtEnd DATETIME='20170301',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=2
				
SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment,a.rf_idSMO AS CodeSMO,a.Account, a.DateRegister, c.idRecordCase AS NumberCase
	,d.DS1,mkb.Diagnosis,p.Fam,p.Im, p.Ot,p.BirthDay, c.NumberHistoryCase, c.DateBegin,c.DateEnd,c.rf_idV006,ce.pid
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
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase              
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND MainDS IN('O01','O02','O03','O04','O05','O06','O07','O08','O09','O00')
	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<@dtEndReg AND c.rf_idV006 IN(1,2)

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
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

SELECT distinct  c.CodeM,l.NAMES,c1.CodeM, l1.NAMES ,c.Fam ,c.Im ,c.Ot ,c.BirthDay,c.DS1+' '+c.Diagnosis,c1.DS1+' '+c1.Diagnosis,
		CONVERT(VARCHAR(10),c.DateBegin,104)+' - '+CONVERT(VARCHAR(10),c.DateEnd,104) AS DateStacionar,
		CONVERT(VARCHAR(10),c1.DateBegin,104)+' - '+CONVERT(VARCHAR(10),c1.DateEnd,104) AS DateDnevnoiStacionar
FROM #tmpCases c INNER JOIN #tmpCases c1 ON
		c.pid=c1.PID
				INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
				INNER JOIN dbo.vw_sprT001 l1 ON
		c1.CodeM=l1.CodeM              
WHERE c.AmountPayment>0 AND c1.AmountPayment>0 AND c.rf_idV006=1 AND c1.rf_idV006=2

GO
DROP TABLE #tmpCases