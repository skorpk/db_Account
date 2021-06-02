USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20190412',
		@dateEndPay DATETIME='20190412',
		@reportYearStart SMALLINT=2019,
		@reportMonthStart TINYINT=1,
		@reportYearEnd SMALLINT=2019,
		@reportMonthEnd TINYINT=3

DECLARE @startPeriod INT=CAST(CAST(@reportYearStart AS VARCHAR(4))+RIGHT('0'+CAST(@reportMonthStart AS VARCHAR(2)),2) AS INT),
		@endPeriod int=CAST(CAST(@reportYearEnd AS VARCHAR(4))+RIGHT('0'+CAST(@reportMonthEnd AS VARCHAR(2)),2) AS INT)

SELECT distinct c.id AS rf_idCase, f.CodeM, c.AmountPayment,c.AmountPayment AS AmountPaymentAcc
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegisterPatient pp ON
			f.id=pp.rf_idFiles
			AND r.id=pp.rf_idRecordCase											                 																									
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYearMonth>=@startPeriod AND a.ReportYearMonth<=@endPeriod
		AND c.rf_idV002=158	 AND (CASE WHEN pp.Sex='Æ' AND c.Age>54 THEN 1 WHEN pp.Sex='Ì' AND c.Age>59 THEN 1 ELSE 0 end)=1

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay	
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT CAST(SUM(AmountPayment) AS MONEY), cast(SUM(AmountPaymentAcc) AS MONEY)
FROM #tCases		
go

DROP TABLE #tCases