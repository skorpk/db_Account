USE AccountOMS
GO
DECLARE @dtStart DATETIME='20160101',
		@dtEnd DATETIME='20170208 23:59:59'

SELECT DISTINCT c.id,c.idRecordCase,f.CodeM,c.AmountPayment,d.DiagnosisCode,c.DateBegin,c.DateEnd, c.rf_idV009,m.MUSurgery
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles	
			AND f.CodeM<>'103001'			
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient				
				INNER JOIN (VALUES(31),(32)) v(idV008) ON
		c.rf_idV008=v.idV008              
				INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase	
				INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase											
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=2016 AND c.rf_idV006 IN(1,2) AND a.rf_idSMO<>'34' 
		AND d.DiagnosisCode LIKE 'C%' AND d.TypeDiagnosis=1 AND m.MUSurgery IS NOT NULL

ALTER TABLE #tmpPeople ADD AmountPaymentAcc DECIMAL(11,2)

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountMEE+c.AmountEKMP+c.AmountMEK) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																							
								WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd
								GROUP BY c.rf_idCase
							) r ON
			p.id=r.rf_idCase

SELECT l.CodeM,l.CodeM+'-'+l.NAMES,ROW_NUMBER() OVER(ORDER BY l.CodeM), RTRIM(mkb.DiagnosisCode)+' - '+mkb.Diagnosis
		,v1.RBNAME+' - '+p.MUSurgery,p.DateBegin,p.DateEnd,v9.name AS RSLT
FROM #tmpPeople p INNER JOIN dbo.vw_sprT001 l ON
			p.CodeM=l.CodeM
				  INNER JOIN dbo.vw_sprMKB10 mkb ON
			p.DiagnosisCode=mkb.DiagnosisCode                
				  INNER JOIN RegisterCases.dbo.vw_sprV009 v9 ON
			p.rf_idV009=v9.id                
					INNER JOIN oms_nsi.dbo.V001 v1 ON
			p.MUSurgery=v1.IDRB                  
WHERE AmountPaymentAcc>0
ORDER BY l.CodeM

GO
DROP TABLE #tmpPeople