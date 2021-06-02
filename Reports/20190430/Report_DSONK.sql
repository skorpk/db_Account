USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME=GETDATE(),
		@dateEndPay DATETIME=GETDATE(),
		@reportYear SMALLINT=2019

CREATE TABLE #tCasesDisp
(
	rf_idCase BIGINT,
	CodeM CHAR(6),
	AmountPayment DECIMAL(15,2),
	ENP VARCHAR(16),
	DateEnd DATE	
)	

CREATE TABLE #tCases
(
	rf_idCase BIGINT,
	CodeM CHAR(6),
	AmountPayment DECIMAL(15,2),
	AmountPaymentAcc DECIMAL(15,2),
	ENP VARCHAR(16)
)		
CREATE UNIQUE NONCLUSTERED INDEX IX_Case ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY

SELECT DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
UNION all
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0[0-9]%'
--
;WITH cte AS
(
SELECT ROW_NUMBER() OVER(PARTITION BY p.ENP ORDER BY c.DateEnd desc) AS idRow, c.id, f.CodeM, c.AmountPayment,p.ENP,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient	
					INNER JOIN dbo.t_DispInfo d ON
			c.id=d.rf_idCase															                 
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND a.Letter IN('O','R') AND d.IsOnko=1
)
INSERT #tCasesDisp( rf_idCase, CodeM,AmountPayment,ENP, DateEnd)
SELECT  id ,CodeM ,AmountPayment ,ENP ,DateEnd FROM cte WHERE idRow=1


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCasesDisp p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase




INSERT #tCases( rf_idCase, CodeM,AmountPayment,ENP,AmountPaymentAcc)
SELECT distinct c.id, f.CodeM, c.AmountPayment,p.ENP,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient                  
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient	
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase      
					INNER JOIN #tD dd ON
			d.DS1=dd.DiagnosisCode            
					INNER JOIN #tCasesDisp k ON
			p.ENP=k.ENP
			AND k.AmountPayment>0										                 
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND c.rf_idV006<4
		AND k.DateEnd<cc.DateBegin AND f.TypeFile='H' 

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


SELECT l.CodeM+' - '+l.NAMES, COUNT(DISTINCT ENP) 
FROM #tCases c INNER JOIN vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE AmountPaymentAcc>0
GROUP BY l.CodeM+' - '+l.NAMES
ORDER BY l.CodeM+' - '+l.NAMES
go
DROP TABLE #tCases
DROP TABLE #tCasesDisp
DROP TABLE #tD

