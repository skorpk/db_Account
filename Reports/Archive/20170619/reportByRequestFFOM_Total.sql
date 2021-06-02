USE AccountOMS
GO
declare @dateStartReg DATETIME,
		@dateEndReg DATETIME='20170616 23:59:59',
		@reportYear SMALLINT=2014

SET @dateStartReg=CAST(@reportYear AS VARCHAR(4))+'0101'

DECLARE @dt1 DATE =CAST(@reportYear AS VARCHAR(4))+'1201',
		@dt2 DATE,
		@dt3 DATE

SELECT @dt2=DATEADD(DAY,10,@dt1), @dt3=DATEADD(DAY,20,@dt1)                

SELECT @dt1,@dt2,@dt3

SELECT c.id AS rf_idCase,c.AmountPayment,c.DateEnd,a.ReportMonth,a.ReportYear
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient										
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear>=@reportYear 
		 AND c.AmountPayment>0	AND a.rf_idSMO<>'34'

ALTER TABLE #tmpPeople ADD AmountPaymentAcc DECIMAL(15,2) NOT NULL DEFAULT(0)
UPDATE #tmpPeople SET AmountPaymentAcc=AmountPayment
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON #tmpPeople ([AmountPaymentAcc])
INCLUDE (ReportYear,rf_idCase)
GO

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																							
								WHERE d.TypeCheckup=1 and f.DateRegistration>=@dateStartReg AND f.DateRegistration<'20170617'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT ReportYear, SUM(AmountPaymentAcc)
FROM #tmpPeople
WHERE AmountPaymentAcc>0 
GROUP BY ReportYear
ORDER BY ReportYear
GO
DROP TABLE #tmpPeople