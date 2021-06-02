USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20201110',
		@dateEndRegRAK DATETIME='20201111',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=11



SELECT c.id AS rf_idCase, c.AmountPayment,c.rf_idv008,c.rf_idV006,11 AS ReportMonth,f.CodeM,p.id,p.AmountPayment AS AmountPay
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase p ON
			r.id=p.rf_idRecordCasePatient					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<'20201008'  AND a.ReportYear=@reportYear AND c.rf_idV006>1 AND c.rf_idV006<4 AND f.TypeFile='H' 
AND a.ReportMonth<10 AND a.rf_idSMO<>'34'
UNION ALL
SELECT c.id AS rf_idCase, c.AmountPayment,c.rf_idv008,c.rf_idV006,12,f.CodeM,p.id,p.AmountPayment AS AmountPay
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase p ON
			r.id=p.rf_idRecordCasePatient					
WHERE f.DateRegistration>='20201008' AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006>1 AND c.rf_idV006<4 
		AND f.TypeFile='H' AND a.rf_idSMO<>'34' AND a.ReportMonth<@reportMonth
UNION ALL-----------------------Stacionar
SELECT c.id AS rf_idCase, c.AmountPayment,c.rf_idv008,c.rf_idV006,11 AS ReportMonth,f.CodeM,p.id,p.AmountPayment AS AmountPay
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase p ON
			r.id=p.rf_idRecordCasePatient					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<'20201008'  AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND c.rf_idV008 IN(31,32) 
AND f.TypeFile='H' AND a.ReportMonth<10 AND a.rf_idSMO<>'34'
UNION ALL
SELECT c.id AS rf_idCase, c.AmountPayment,c.rf_idv008,c.rf_idV006,12,f.CodeM,p.id,p.AmountPayment AS AmountPay
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase p ON
			r.id=p.rf_idRecordCasePatient					
WHERE f.DateRegistration>='20201008' AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND c.rf_idV008 IN(31,32) 
AND f.TypeFile='H' AND a.rf_idSMO<>'34' AND a.ReportMonth<@reportMonth

UPDATE p SET p.AmountPayment=p.AmountPay-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
delete FROM #tCases WHERE AmountPay<=0

SELECT c.CodeM,l.NAMES AS LPU
		------------------------------Stacionar 31----------------------------
		,cast(CAST(SUM(CASE WHEN ReportMonth=11 AND rf_idV006=1 AND rf_idV008=31 THEN AmountPayment ELSE 0.0 END) AS DECIMAL(15,2))/11.0 AS MONEY) AS Stac31NovSum
		,cast(SUM(CASE WHEN ReportMonth=12 AND rf_idV006=1 AND rf_idV008=31 THEN AmountPayment ELSE 0.0 END) AS MONEY) AS Stac31DecSum
		,count( CASE WHEN ReportMonth=11 AND rf_idV006=1 AND rf_idV008=31 THEN id ELSE Null END)/11 AS Stac31NovCase
		,count( CASE WHEN ReportMonth=12 AND rf_idV006=1 AND rf_idV008=31 THEN id ELSE Null END) AS Stac31DecCase
		,NULL,NULL
        -------------------------------Stacionar 32----------------------
		,cast(CAST(SUM(CASE WHEN ReportMonth=11 AND rf_idV006=1 AND rf_idV008=32 THEN AmountPayment ELSE 0.0 END) AS DECIMAL(15,2))/11.0 AS MONEY) AS Stac31NovSum
		,cast(SUM(CASE WHEN ReportMonth=12      AND rf_idV006=1 AND rf_idV008=32 THEN AmountPayment ELSE 0.0 END) AS MONEY) AS Stac32DecSum
		,count(CASE WHEN ReportMonth=11    AND rf_idV006=1 AND rf_idV008=32 THEN id ELSE null END)/11 AS Stac31NovCase
		,count(CASE WHEN ReportMonth=12    AND rf_idV006=1 AND rf_idV008=32 THEN id ELSE null END) AS Stac32DecCase
		,NULL,NULL
        -------------------------------DnevnoiStacionar----------------------
		,cast(CAST(SUM(CASE WHEN ReportMonth=11 AND rf_idV006=2 THEN AmountPayment ELSE 0.0 END) AS DECIMAL(15,2))/11.0 AS MONEY) AS DnStacNovSum
		,cast(SUM(CASE WHEN ReportMonth=12      AND rf_idV006=2 THEN AmountPayment ELSE 0.0 END) AS MONEY) AS DnStacDecSum
		,count(CASE WHEN ReportMonth=11    AND rf_idV006=2 THEN id ELSE null END)/11 AS DnStacNovCase
		,count(CASE WHEN ReportMonth=12    AND rf_idV006=2 THEN id ELSE null END) AS DnStacDecCase
		,NULL,NULL
        -------------------------------Ambulatorka----------------------
		,cast(CAST(SUM(CASE WHEN ReportMonth=11 AND rf_idV006=3 THEN AmountPayment ELSE 0.0 END) AS DECIMAL(15,2))/11.0 AS MONEY) AS AmbulNovSum
		,cast(SUM(CASE WHEN ReportMonth=12      AND rf_idV006=3 THEN AmountPayment ELSE 0.0 END) AS MONEY) AS AmbulDecSum
		,count(CASE WHEN ReportMonth=11    AND rf_idV006=3 THEN id ELSE null END)/11 AS AmbulNovCase
		,count(CASE WHEN ReportMonth=12    AND rf_idV006=3 THEN id ELSE null END) AS AmbulDecCase
		,NULL,NULL
FROM (SELECT CodeM,id,rf_idV008,rf_idV006,ReportMonth,SUM(AmountPayment) AS AmountPayment FROM #tCases GROUP BY CodeM,id,rf_idV008,rf_idV006,ReportMonth) c INNER JOIN dbo.vw_sprT001 l ON
		l.CodeM = c.CodeM
WHERE AmountPayment>0.0
GROUP BY c.CodeM,l.NAMES
ORDER BY c.CodeM
GO

DROP TABLE #tCases