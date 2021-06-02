USE AccountOMS
GO
---------------------------------------------2018---------------------------------------------
DECLARE @dateStart DATETIME='20180101',
		@dateEnd DATETIME='20190122',
		@dateEndPay DATETIME='20190124'
		,@reportYear INT=2018


SELECT DISTINCT c.id AS rf_idCase, f.CodeM, c.AmountPayment,c.rf_idRecordCasePatient, c.AmountPayment AS AmmPay,p.ENP,m.MES,c.DateEnd
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=2 AND c.rf_idV010=43 AND c.rf_idV002=137 AND a.rf_idSMO<>'34'

UPDATE p SET p.AmmPay=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
DELETE FROM #tCases WHERE AmmPay<=0.0
PRINT(@@ROWCOUNT )
	

SELECT  c.id
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN (	
								SELECT DISTINCT c.DateEnd,c.ENP
								FROM #tCases c INNER JOIN (SELECT rf_idCase FROM dbo.t_Meduslugi WHERE MUSurgery IN('A11.20.017' ,'A11.20.031') GROUP BY rf_idCase HAVING COUNT(*)=2) mm ON
										c.rf_idCase=mm.rf_idCase
								WHERE NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.rf_idCase AND m.MUSurgery NOT IN('A11.20.017','A11.20.031'))
							) t ON
			p.enp=t.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
					INNER JOIN dbo.t_Meduslugi m ON
            c.id=m.rf_idCase
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=2 AND c.rf_idV010=43 AND c.rf_idV002=137 AND t.DateEnd<c.DateEnd AND m.MUSurgery='A11.20.017'
	AND EXISTS (SELECT 1 FROM dbo.t_Meduslugi mm WHERE c.id=mm.rf_idCase AND mm.MUSurgery IN ('A11.20.028','A11.20.031','A11.20.036','A11.20.025.001','A11.20.030.001') )

SELECT COUNT(DISTINCT t.id) AS Col2
	,COUNT(distinct CASE WHEN p.TypeCheckup=2 THEN p.rf_idCase ELSE NULL end)	AS Col3
	,COUNT(distinct CASE WHEN p.AmountDeduction>0 AND p.TypeCheckup=2 THEN p.rf_idCase ELSE NULL end)	AS Col4
	,COUNT(distinct CASE WHEN p.TypeCheckup=3 THEN p.rf_idCase ELSE NULL end)	AS Col5
	,COUNT(distinct CASE WHEN p.AmountDeduction>0 AND p.TypeCheckup=3 THEN p.rf_idCase ELSE NULL end)	AS Col6
FROM #t t INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		t.id=p.rf_idCase
GO
DROP TABLE #t
GO
DROP TABLE #tCases