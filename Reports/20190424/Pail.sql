USE AccountOMS
GO
DECLARE @dateStart DATETIME='20180101',
		@dateEnd DATETIME='20190125',
		@dateEndPay DATETIME='20190411',
		@reportYear SMALLINT=2018

CREATE TABLE #tCasesKDP
(
	rf_idCase BIGINT,
	CodeM CHAR(6),
	AmountPayment DECIMAL(15,2),
	ENP VARCHAR(16)	,
	DateEnd DATE,
	USL_OK TINYINT
)	

CREATE TABLE #tCases
(
	rf_idCase BIGINT,
	CodeM CHAR(6),
	AmountPayment DECIMAL(15,2),
	AmountPaymentAcc DECIMAL(15,2),
	ENP VARCHAR(16)	,
	DateBegin DATE,
	DateEnd DATE,
	FOR_POM TINYINT
)		
CREATE UNIQUE NONCLUSTERED INDEX IX_Case ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY

INSERT #tCasesKDP( rf_idCase, CodeM,AmountPayment,ENP,DateEnd, USL_OK)
SELECT distinct c.id, f.CodeM, c.AmountPayment,p.ENP, m.DateHelpEnd, c.rf_idV006
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase											                 
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND f.CodeM='125901' AND c.rf_idV006=3
		AND m.MUGroupCode<>2 AND m.Price>0 AND m.DateHelpBegin=m.DateHelpEnd

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCasesKDP p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

INSERT #tCases( rf_idCase, CodeM,AmountPayment,ENP,AmountPaymentAcc, DateBegin,DateEnd, FOR_POM)
SELECT distinct c.id, f.CodeM, c.AmountPayment,p.ENP,c.AmountPayment, c.DateBegin,c.DateEnd, c.rf_idV014
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient	
					INNER JOIN #tCasesKDP k ON
			p.ENP=k.ENP
			AND k.AmountPayment>0										                 
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND c.rf_idV006=1
		AND k.DateEnd>c.DateBegin AND k.DateEnd<c.DateEnd

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

--SELECT TOP 10 *
--FROM #tCases c
--WHERE AmountPaymentAcc>0 AND rf_idCase=80387726

--SELECT FOR_POM, COUNT(rf_idCase)
--FROM #tCases c WHERE AmountPaymentAcc>0 GROUP BY FOR_POM

--SELECT * FROM #tCasesKDP WHERE enp='3449430896000173'

SELECT l.CodeM+' - '+l.NAMES, COUNT(DISTINCT rf_idCase),COUNT(DISTINCT ENP) ,SUM(AmountPayment)
FROM #tCases c INNER JOIN vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE AmountPaymentAcc>0
GROUP BY l.CodeM+' - '+l.NAMES
ORDER BY l.CodeM+' - '+l.NAMES
go
DROP TABLE #tCases
DROP TABLE #tCasesKDP
