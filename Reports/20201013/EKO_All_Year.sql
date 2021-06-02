USE AccountOMS
GO
---------------------------------------------2018---------------------------------------------
DECLARE @dateStart DATETIME='20180101',
		@dateEnd DATETIME='20190122',
		@dateEndPay DATETIME='20190124'
		,@reportYear INT=2018


SELECT DISTINCT c.id AS rf_idCase, f.CodeM, c.AmountPayment,c.rf_idRecordCasePatient, c.AmountPayment AS AmmPay,p.ENP,a.ReportYear,c.DateEnd
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient																							
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=2 AND c.rf_idV010=43 AND c.rf_idV002=137

UPDATE p SET p.AmmPay=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
DELETE FROM #tCases WHERE AmmPay<=0.0
PRINT(@@ROWCOUNT )

SELECT 3 AS Step, c.rf_idCase,c.CodeM,c.AmountPayment,c.ENP,c.ReportYear,c.DateEnd
INTO #tTotal
FROM #tCases c 
WHERE EXISTS(SELECT m.rf_idCase FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.rf_idCase AND m.MUSurgery IN('A11.20.017','A11.20.028','A11.20.031') GROUP BY m.rf_idCase HAVING COUNT(*)=3)
UNION ALL
SELECT 4 AS Step, c.rf_idCase,c.CodeM,c.AmountPayment,c.ENP,c.ReportYear,c.DateEnd
FROM #tCases c INNER JOIN (SELECT rf_idCase FROM dbo.t_Meduslugi WHERE MUSurgery IN('A11.20.017' ,'A11.20.031') GROUP BY rf_idCase HAVING COUNT(*)=2) mm ON
		c.rf_idCase=mm.rf_idCase
WHERE NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.rf_idCase AND m.MUSurgery NOT IN('A11.20.017','A11.20.031'))

INSERT #tTotal
SELECT distinct 31 AS Step,c.id AS rf_idCase, f.CodeM, c.AmountPayment,p.ENP,a.ReportYear,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN #tTotal t ON
			p.enp=t.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=2 AND c.rf_idV010=43 AND c.rf_idV002=137 AND t.rf_idCase!=c.id
	AND t.Step=3 AND EXISTS (SELECT 1 FROM dbo.t_Meduslugi mm WHERE c.id=mm.rf_idCase AND mm.MUSurgery IN ('A11.20.017','A11.20.028','A11.20.031','A11.20.036','A11.20.025.001') )

INSERT #tTotal
SELECT distinct 41 AS Step,c.id AS rf_idCase, f.CodeM, c.AmountPayment,p.ENP,a.ReportYear,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN #tTotal t ON
			p.enp=t.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=2 AND c.rf_idV010=43 AND c.rf_idV002=137 AND t.rf_idCase<>c.id
	AND t.Step=4 AND EXISTS (SELECT 1 FROM dbo.t_Meduslugi mm WHERE c.id=mm.rf_idCase AND mm.MUSurgery IN ('A11.20.017','A11.20.028','A11.20.031','A11.20.036','A11.20.025.001','A11.20.030.001') )
GO
DROP TABLE #tCases
---------------------------------------------2019---------------------------------------------
DECLARE @dateStart DATETIME='20190101'
		,@dateEnd DATETIME='20200118'
		,@dateEndPay DATETIME='20200118'
		,@reportYear INT=2019


SELECT DISTINCT c.id AS rf_idCase, f.CodeM, c.AmountPayment,c.rf_idRecordCasePatient, c.AmountPayment AS AmmPay,p.ENP,m.MES,a.ReportYear,c.DateEnd
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
					INNER JOIN t_MES m ON
			c.id=m.rf_idCase																
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=2 AND c.rf_idV010=43 AND c.rf_idV002=137

UPDATE p SET p.AmmPay=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
DELETE FROM #tCases WHERE AmmPay<=0.0
PRINT(@@ROWCOUNT )

INSERT #tTotal(step,rf_idcase,CodeM,AmountPayment,ENP,ReportYear,DateEnd)
SELECT 3 AS Step, c.rf_idCase,c.CodeM,c.AmountPayment,c.ENP,c.ReportYear,c.DateEnd
FROM #tCases c 
WHERE EXISTS(SELECT m.rf_idCase FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.rf_idCase AND m.MUSurgery IN('A11.20.017','A11.20.028','A11.20.031') GROUP BY m.rf_idCase HAVING COUNT(*)=3)

INSERT #tTotal(step,rf_idcase,CodeM,AmountPayment,ENP,ReportYear,DateEnd)
SELECT 4 AS Step, c.rf_idCase,c.CodeM,c.AmountPayment,c.ENP,c.ReportYear,c.DateEnd
FROM #tCases c INNER JOIN (SELECT rf_idCase FROM dbo.t_Meduslugi WHERE MUSurgery IN('A11.20.017' ,'A11.20.031') GROUP BY rf_idCase HAVING COUNT(*)=2) mm ON
		c.rf_idCase=mm.rf_idCase
WHERE NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.rf_idCase AND m.MUSurgery NOT IN('A11.20.017','A11.20.031'))


INSERT #tTotal
SELECT distinct 31 AS Step,c.id AS rf_idCase, f.CodeM, c.AmountPayment,p.ENP,a.ReportYear,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN #tTotal t ON
			p.enp=t.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=2 AND c.rf_idV010=43 AND c.rf_idV002=137 AND t.rf_idCase!=c.id
	AND t.Step=3 AND EXISTS (SELECT 1 FROM dbo.t_Meduslugi mm WHERE c.id=mm.rf_idCase AND mm.MUSurgery IN ('A11.20.017','A11.20.028','A11.20.031','A11.20.036','A11.20.025.001') )

INSERT #tTotal
SELECT distinct 41 AS Step,c.id AS rf_idCase, f.CodeM, c.AmountPayment,p.ENP,a.ReportYear,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN #tTotal t ON
			p.enp=t.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=2 AND c.rf_idV010=43 AND c.rf_idV002=137 AND t.rf_idCase<>c.id
	AND t.Step=4 AND EXISTS (SELECT 1 FROM dbo.t_Meduslugi mm WHERE c.id=mm.rf_idCase AND mm.MUSurgery IN ('A11.20.017','A11.20.028','A11.20.031','A11.20.036','A11.20.025.001','A11.20.030.001') )
GO
DROP TABLE #tCases
GO
---------------------------------------------2020---------------------------------------------
DECLARE @dateStart DATETIME='20200101'
		,@dateEnd DATETIME='20200715'
		,@dateEndPay DATETIME='20201012'
		,@reportYear INT=2020
		,@reportMonth TINYINT=7


SELECT DISTINCT c.id AS rf_idCase, f.CodeM, c.AmountPayment,c.rf_idRecordCasePatient, c.AmountPayment AS AmmPay,p.ENP,m.MES,a.ReportYear,c.DateEnd
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
					INNER JOIN t_MES m ON
			c.id=m.rf_idCase																
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=2 AND c.rf_idV010 IN(33,43) AND c.rf_idV002=137 AND a.ReportMonth<@reportMonth

UPDATE p SET p.AmmPay=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
DELETE FROM #tCases WHERE AmmPay<=0.0
PRINT(@@ROWCOUNT )


INSERT #tTotal(step,rf_idcase,CodeM,AmountPayment,ENP,ReportYear,DateEnd)
SELECT 3 AS Step, c.rf_idCase,c.CodeM,c.AmountPayment,c.ENP,c.ReportYear,c.DateEnd
FROM #tCases c 
WHERE EXISTS(SELECT m.rf_idCase FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.rf_idCase AND m.MUSurgery IN('A11.20.017','A11.20.028','A11.20.031') GROUP BY m.rf_idCase HAVING COUNT(*)=3)

INSERT #tTotal(step,rf_idcase,CodeM,AmountPayment,ENP,ReportYear,DateEnd)
SELECT 4 AS Step, c.rf_idCase,c.CodeM,c.AmountPayment,c.ENP,c.ReportYear,c.DateEnd
FROM #tCases c INNER JOIN (SELECT rf_idCase FROM dbo.t_Meduslugi WHERE MUSurgery IN('A11.20.017' ,'A11.20.031') GROUP BY rf_idCase HAVING COUNT(*)=2) mm ON
		c.rf_idCase=mm.rf_idCase
WHERE NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.rf_idCase AND m.MUSurgery NOT IN('A11.20.017','A11.20.031'))



INSERT #tTotal
SELECT distinct 31 AS Step,c.id AS rf_idCase, f.CodeM, c.AmountPayment,p.ENP,a.ReportYear,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN #tTotal t ON
			p.enp=t.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=2 AND c.rf_idV010 IN(33,43) AND c.rf_idV002=137 AND t.rf_idCase!=c.id
	AND t.Step=3 AND EXISTS (SELECT 1 FROM dbo.t_Meduslugi mm WHERE c.id=mm.rf_idCase AND mm.MUSurgery IN ('A11.20.017','A11.20.028','A11.20.031','A11.20.036','A11.20.025.001') )

INSERT #tTotal
SELECT distinct 41 AS Step,c.id AS rf_idCase, f.CodeM, c.AmountPayment,p.ENP,a.ReportYear,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN #tTotal t ON
			p.enp=t.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=2 AND c.rf_idV010 IN(33,43) AND c.rf_idV002=137 AND t.rf_idCase<>c.id
	AND t.Step=4 AND EXISTS (SELECT 1 FROM dbo.t_Meduslugi mm WHERE c.id=mm.rf_idCase AND mm.MUSurgery IN ('A11.20.017','A11.20.028','A11.20.031','A11.20.036','A11.20.025.001','A11.20.030.001') )

DROP TABLE tmpEko_ALL

--SELECT * INTO tmpEko_ALL FROM #tTotal
GO
DROP TABLE #tCases
GO
DROP TABLE #tTotal