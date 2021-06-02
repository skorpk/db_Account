USE AccountOMS
GO
/*
WITH cteA
AS
(
SELECT a.id,f.CodeM,l.NAMES,a.Account, a.DateRegister, a.ReportYear, a.ReportMonth, c.idRecordCase AS NumberCase,c.id AS rf_idCase,c.AmountPayment-t.AmountDeduction AS AmountPaymentAcc
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM    
					INNER JOIN (SELECT rf_idCase,SUM(c1.AmountDeduction) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c1 ON
														a.id=c1.rf_idCheckedAccount 																							
								WHERE f.DateRegistration>='20140101' AND f.DateRegistration<GETDATE() AND a.PayerAccount='34006'
								GROUP BY rf_idCase
								) t ON
			c.id=t.rf_idCase              
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20170221' AND a.rf_idSMO='34006' AND  
				NOT EXISTS(SELECT rf_idCase
							FROM ExchangeFinancing.dbo.t_DFileIn f INNER JOIN  ExchangeFinancing.dbo.t_PaymentDocument d ON
													f.id=d.rf_idDFile
																INNER JOIN ExchangeFinancing.dbo.t_SettledAccount a ON
													d.id=a.rf_idPaymentDocument
														INNER JOIN ExchangeFinancing.dbo.t_SettledCase c1 ON
													a.id=c1.rf_idSettledAccount
							WHERE f.DateRegistration>='20140101' AND f.DateRegistration<GETDATE() AND c1.rf_idCase=c.id)
)
SELECT c.CodeM ,c.NAMES ,c.Account ,c.DateRegister ,c.ReportYear ,c.ReportMonth ,c.NumberCase--COUNT(c.rf_idCase) AS CountCases
FROM cteA c 
WHERE c.AmountPaymentAcc>0
ORDER BY c.ReportYear,c.ReportMonth,c.CodeM
*/


;WITH cteA
AS
(
SELECT a.id,f.CodeM,l.NAMES,a.Account, a.DateRegister, a.ReportYear, a.ReportMonth, c.idRecordCase AS NumberCase,c.id AS rf_idCase,c.AmountPayment-t.AmountDeduction AS AmountPaymentAcc,
		pt.AmountPaymentD
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM    
					INNER JOIN (SELECT rf_idCase,SUM(c1.AmountDeduction) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c1 ON
														a.id=c1.rf_idCheckedAccount 																							
								WHERE f.DateRegistration>='20140101' AND f.DateRegistration<GETDATE() AND a.PayerAccount='34006'
								GROUP BY rf_idCase
								) t ON
			c.id=t.rf_idCase              
					INNER JOIN (SELECT rf_idCase,SUM(c1.AmountPayment) AS AmountPaymentD
								FROM ExchangeFinancing.dbo.t_DFileIn f INNER JOIN  ExchangeFinancing.dbo.t_PaymentDocument d ON
														f.id=d.rf_idDFile
																	INNER JOIN ExchangeFinancing.dbo.t_SettledAccount a ON
														d.id=a.rf_idPaymentDocument
															INNER JOIN ExchangeFinancing.dbo.t_SettledCase c1 ON
														a.id=c1.rf_idSettledAccount
								WHERE f.DateRegistration>='20140101' AND f.DateRegistration<GETDATE() AND a.PayerAccount='34006'
								GROUP BY rf_idCase)	pt ON
			c.id=pt.rf_idCase                              
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20170221' AND a.rf_idSMO='34006'				
)
SELECT c.CodeM ,c.NAMES ,c.Account ,c.DateRegister ,c.ReportYear ,c.ReportMonth ,c.NumberCase,AmountPaymentAcc,AmountPaymentD
FROM cteA c 
WHERE /*c.AmountPaymentAcc>0*/ AmountPaymentAcc<>AmountPaymentD
ORDER BY c.ReportYear,c.ReportMonth,c.CodeM

go
--DROP TABLE #t
