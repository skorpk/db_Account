USE AccountOMS
GO
DECLARE @dtStart DATETIME='20160901',
		@dtEnd DATETIME='20161231 23:59:59'

SELECT DISTINCT c.id,c.AmountPayment,c.rf_idV006 
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient				
				INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase												
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=2016 AND c.rf_idV006 IN(1,2,3,4) AND a.rf_idSMO<>'34' 
		AND d.DiagnosisCode LIKE 'C%' AND d.TypeDiagnosis=1 AND a.ReportMonth>8

ALTER TABLE #tmpPeople ADD AmountPaymentAcc DECIMAL(11,2)

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountMEE+c.AmountEKMP+c.AmountMEK) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																							
								WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<'20170115 23:59:59'
								GROUP BY c.rf_idCase
							) r ON
			p.id=r.rf_idCase

SELECT count(CASE WHEN AmountPaymentAcc>0 AND rf_idV006=1 THEN c.id ELSE NULL END) AS Stacionar
		,count(CASE WHEN AmountPaymentAcc>0 AND rf_idV006=2 THEN c.id ELSE NULL END) AS Dnevnoi
		,count(CASE WHEN AmountPaymentAcc>0 AND rf_idV006=3 THEN c.id ELSE NULL END) AS Ambulatorka
		,count(CASE WHEN AmountPayment>0 and AmountPaymentAcc>0 AND rf_idV006=4 THEN c.id 
					WHEN AmountPayment=0 and AmountPaymentAcc=0 AND rf_idV006=4 THEN c.id ELSE NULL END) AS [EMERGENCY]
from #tmpPeople c
GO
DROP TABLE #tmpPeople