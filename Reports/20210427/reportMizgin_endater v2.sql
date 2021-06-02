USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20200118',
		@dateEndPay DATETIME='20200121',
		@reportYear SMALLINT=2019


SELECT DISTINCT c.id AS rf_idCase, f.CodeM, c.AmountPayment,c.rf_idRecordCasePatient
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient											
					JOIN dbo.t_MES m ON
            c.id=m.rf_idCase
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND m.MES IN('st29.008', 'st29.013') AND a.rf_idSMO<>'34'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE AmountPayment=0.0

SELECT 2019, COUNT(DISTINCT c.rf_idCase) AS Col2,
count(distinct CASE WHEN m.MUSurgery IN('A16.04.021','A16.04.021.007') THEN c.rf_idCase ELSE NULL END) AS Col3
FROM #tCases c LEFT JOIN dbo.t_Meduslugi m ON
		m.rf_idCase = c.rf_idCase			
GO
DROP TABLE #tCases
GO
-----------------------------------------------2020-----------------------------------------------
DECLARE @dateStart DATETIME='20200101',
		@dateEnd DATETIME='20210116',
		@dateEndPay DATETIME='20210119',
		@reportYear SMALLINT=2020


SELECT DISTINCT c.id AS rf_idCase, f.CodeM, c.AmountPayment,c.rf_idRecordCasePatient
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient											
					JOIN dbo.t_MES m ON
            c.id=m.rf_idCase
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND m.MES IN('st29.008', 'st29.013') AND a.rf_idSMO<>'34'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE AmountPayment=0.0

SELECT 2020, COUNT(DISTINCT c.rf_idCase) AS Col2,
count(distinct CASE WHEN m.MUSurgery IN('A16.04.021','A16.04.021.007') THEN c.rf_idCase ELSE NULL END) AS Col3
FROM #tCases c LEFT JOIN dbo.t_Meduslugi m ON
		m.rf_idCase = c.rf_idCase		
GO
DROP TABLE #tCases