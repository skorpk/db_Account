USE AccountOMS
GO
DECLARE @dateStart DATETIME='20180101',
		@dateEnd DATETIME='20190122',
		@dateEndPay DATETIME='20190122',
		@reportYear SMALLINT=2018

SELECT c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmmPay,c.rf_idV006, c.age,a.rf_idSMO
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient						
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear 
		AND c.DateEnd>'20171231' AND c.DateEnd<'20190101'	


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
--Волгоградская область
SELECT v6.id,v6.name AS USL_OK
		, cast(SUM(AmountPayment) AS MONEY) AS AmountPayAll
		, cast(SUM(CASE WHEN Age<18 THEN AmountPayment ELSE 0.0 END)  AS MONEY) AS AmountPay17
		, cast(SUM(CASE WHEN Age>17 AND Age<65 THEN AmountPayment ELSE 0.0 END)  AS MONEY) AS AmountPay65
		, cast(SUM(CASE WHEN Age>64 THEN AmountPayment ELSE 0.0 END)  AS MONEY)AS AmountPay100
FROM #tCases c INNER JOIN vw_sprV006 v6 ON
		c.rf_idV006=v6.id
WHERE rf_idSMO<>'34' AND AmmPay>0.0
GROUP BY v6.id, v6.name
UNION all	--строка 6, СМП с нулевым тарифом показываем количество случаев
SELECT v6.id,v6.name AS USL_OK
		,cast(count(DISTINCT rf_idCase)  AS MONEY) AS AmountPayAll
		,cast(count(DISTINCT CASE WHEN Age<18 THEN rf_idCase ELSE null END)  AS MONEY) AS AmountPay17
		,cast(count(distinct CASE WHEN Age>17 AND Age<65 THEN rf_idCase ELSE NULL END)  AS MONEY) AS AmountPay65
		,cast(count(distinct CASE WHEN Age>64 THEN rf_idCase ELSE null END)  AS MONEY) AS AmountPay100
FROM #tCases c INNER JOIN vw_sprV006 v6 ON
		c.rf_idV006=v6.id
WHERE rf_idSMO<>'34' AND rf_idV006=4 AND AmmPay=0.0
GROUP BY v6.id,v6.name
ORDER BY v6.id

--Иногородние
SELECT v6.id,v6.name AS USL_OK
		, cast(SUM(AmountPayment) AS MONEY) AS AmountPayAll
		, cast(SUM(CASE WHEN Age<18 THEN AmountPayment ELSE 0.0 END)  AS MONEY) AS AmountPay17
		, cast(SUM(CASE WHEN Age>17 AND Age<65 THEN AmountPayment ELSE 0.0 END)  AS MONEY) AS AmountPay65
		, cast(SUM(CASE WHEN Age>64 THEN AmountPayment ELSE 0.0 END)  AS MONEY)AS AmountPay100
FROM #tCases c INNER JOIN vw_sprV006 v6 ON
		c.rf_idV006=v6.id
WHERE rf_idSMO='34' 
GROUP BY v6.id,v6.name	
ORDER BY v6.id
GO
--DROP TABLE #tCases