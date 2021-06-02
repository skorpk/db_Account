USE AccountOMS
GO
DECLARE --@codeSMO CHAR(5)='34002',
		@dateBegin DATETIME='20150101',
		@dateEndAccount DATETIME='20151020 23:59:59'

CREATE TABLE #Cases
(
	CodeM VARCHAR(6),
	ReportMonth SMALLINT,
	id BIGINT,
	AmountPayment DECIMAL(11,2),
	AmountDeduction DECIMAL(11,2) 
)
INSERT #Cases( CodeM ,ReportMonth ,id ,AmountPayment)
SELECT f.CodeM,a.ReportMonth,c.id,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.Letter='T'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase				
WHERE f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEndAccount AND a.ReportYear=2015 AND a.ReportMonth<10
	  AND a.rf_idSMO<>'34' AND m.MU='57.1.57' 
	  AND EXISTS (SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=c.id and MU='57.1.7') 
GROUP BY f.CodeM,a.ReportMonth,c.id,c.AmountPayment

UPDATE p SET p.AmountDeduction=p.AmountPayment-r.AmountDeduction
FROM #Cases p INNER JOIN (
							SELECT rf_idCase,SUM(c.AmountMEE+c.AmountEKMP+c.AmountMEK) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
													a.id=c.rf_idCheckedAccount 														
							WHERE f.DateRegistration>=@dateBegin AND f.DateRegistration<GETDATE()	 										
							GROUP BY rf_idCase
							) r ON
			p.id=r.rf_idCase

SELECT CodeM,ReportMonth,COUNT(id)
FROM #Cases
WHERE AmountDeduction>0
GROUP BY CodeM,ReportMonth
ORDER BY CodeM,ReportMonth