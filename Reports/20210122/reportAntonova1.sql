USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME=GETDATE(),
		@reportYear SMALLINT=2020



SELECT c.id AS rf_idCase, c.AmountPayment,c.rf_idv008,c.rf_idV006,11 AS ReportMonth,f.CodeM,p.id
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase p ON
			r.id=p.rf_idRecordCasePatient					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<'20201211'  AND a.ReportYear=@reportYear AND c.rf_idV006>1 AND c.rf_idV006<4 AND f.TypeFile='H' AND a.ReportMonth<12 
		AND a.rf_idSMO<>'34'
UNION ALL
SELECT c.id AS rf_idCase, c.AmountPayment,c.rf_idv008,c.rf_idV006,12,f.CodeM,p.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase p ON
			r.id=p.rf_idRecordCasePatient					
WHERE f.DateRegistration>='20201211' AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006>1 AND c.rf_idV006<4 AND f.TypeFile='H' AND a.rf_idSMO<>'34'
UNION ALL-----------------------Stacionar
SELECT c.id AS rf_idCase, c.AmountPayment,c.rf_idv008,c.rf_idV006,11 AS ReportMonth,f.CodeM,p.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase p ON
			r.id=p.rf_idRecordCasePatient					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<'20201211'  AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND c.rf_idV008 IN(31,32) AND f.TypeFile='H' AND a.ReportMonth<12 
		AND a.rf_idSMO<>'34'
UNION ALL
SELECT c.id AS rf_idCase, c.AmountPayment,c.rf_idv008,c.rf_idV006,12,f.CodeM,p.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase p ON
			r.id=p.rf_idRecordCasePatient					
WHERE f.DateRegistration>='20201211' AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND c.rf_idV008 IN(31,32) AND f.TypeFile='H' AND a.rf_idSMO<>'34'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

;WITH cteH
AS(
SELECT c.CodeM,l.NAMES AS LPU
		------------------------------Stacionar 31----------------------------
		,CAST(CAST(SUM(CASE WHEN ReportMonth=11 AND rf_idV006=1 AND rf_idV008=31 THEN AmountPayment ELSE 0.0 END) AS DECIMAL(15,2))/11.0 AS MONEY) AS Stac31NovSum
		,CAST(SUM(CASE WHEN ReportMonth=12 AND rf_idV006=1 AND rf_idV008=31 THEN AmountPayment ELSE 0.0 END)AS MONEY) AS Stac31DecSum
		,cast(ROUND(CAST(count(CASE WHEN ReportMonth=11 AND rf_idV006=1 AND rf_idV008=31 THEN id ELSE Null END)/11.0  AS DECIMAL(11,2)) ,0) AS INT) AS Stac31NovCase
		,count(CASE WHEN ReportMonth=12 AND rf_idV006=1 AND rf_idV008=31 THEN id ELSE Null END) AS Stac31DecCase
		--,NULL,NULL
        -------------------------------Stacionar 32----------------------
		,cast(CAST(SUM(CASE WHEN ReportMonth=11 AND rf_idV006=1 AND rf_idV008=32 THEN AmountPayment ELSE 0.0 END) AS DECIMAL(15,2))/11.0 AS MONEY) AS Stac32NovSum
		,cast(SUM(CASE WHEN ReportMonth=12      AND rf_idV006=1 AND rf_idV008=32 THEN AmountPayment ELSE 0.0 END) AS MONEY) AS Stac32DecSum
		,CAST(ROUND(CAST(count(CASE WHEN ReportMonth=11    AND rf_idV006=1 AND rf_idV008=32 THEN id ELSE null END)/11.0  AS DECIMAL(11,2)) ,0) AS INT)AS Stac32NovCase
		,count(CASE WHEN ReportMonth=12    AND rf_idV006=1 AND rf_idV008=32 THEN id ELSE null END) AS Stac32DecCase
		--,NULL,NULL
        -------------------------------DnevnoiStacionar----------------------
		,cast(CAST(SUM(CASE WHEN ReportMonth=11 AND rf_idV006=2 THEN AmountPayment ELSE 0.0 END) AS DECIMAL(15,2))/11.0 AS MONEY) AS DnStacNovSum
		,cast(SUM(CASE WHEN ReportMonth=12      AND rf_idV006=2 THEN AmountPayment ELSE 0.0 END) AS MONEY) AS DnStacDecSum
		,CAST(ROUND(CAST(count(CASE WHEN ReportMonth=11    AND rf_idV006=2 THEN id ELSE null END)/11.0  AS DECIMAL(11,2)) ,0) AS INT) AS DnStacNovCase
		,count(CASE WHEN ReportMonth=12    AND rf_idV006=2 THEN id ELSE null END) AS DnStacDecCase
		--,NULL,NULL
        -------------------------------Ambulatorka----------------------
		,cast(CAST(SUM(CASE WHEN ReportMonth=11 AND rf_idV006=3 THEN AmountPayment ELSE 0.0 END) AS DECIMAL(15,2))/11.0 AS MONEY) AS AmbulNovSum
		,cast(SUM(CASE WHEN ReportMonth=12      AND rf_idV006=3 THEN AmountPayment ELSE 0.0 END) AS MONEY) AS AmbulDecSum
		,CAST(ROUND(CAST(count(CASE WHEN ReportMonth=11    AND rf_idV006=3 THEN id ELSE null END)/11.0  AS DECIMAL(11,2)) ,0) AS INT) AS AmbulNovCase
		,count(CASE WHEN ReportMonth=12    AND rf_idV006=3 THEN id ELSE null END) AS AmbulDecCase
		--,NULL,NULL
FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON
		l.CodeM = c.CodeM
WHERE AmountPayment>0.0
GROUP BY c.CodeM,l.NAMES
)
SELECT h.CodeM,
       h.LPU,
	   ------------------------------------------------
       h.Stac31NovSum,
       h.Stac31DecSum,
       h.Stac31NovCase,
       h.Stac31DecCase,
	   CAST(ROUND(h.Stac31NovSum/(CASE WHEN h.Stac31NovCase=0 THEN 1 ELSE Stac31NovCase end),2) AS MONEY), 
	   h.Stac31DecSum/(CASE WHEN h.Stac31DecCase=0 THEN 1 ELSE Stac31DecCase end),
	   -------------------------------------------------
       h.Stac32NovSum,
       h.Stac32DecSum,
       h.Stac32NovCase,
       h.Stac32DecCase,
	   CAST(ROUND(h.Stac32NovSum/(CASE WHEN h.Stac32NovCase=0 THEN 1 ELSE Stac32NovCase end),2) AS MONEY),
	   CAST(h.Stac32DecSum/(CASE WHEN h.Stac32DecCase=0 THEN 1 ELSE Stac32DecCase end) AS MONEY),
	   ---------------------------------------------------
       h.DnStacNovSum,
       h.DnStacDecSum,
       h.DnStacNovCase,
       h.DnStacDecCase,
	   CAST(ROUND(h.DnStacNovSum/(CASE WHEN h.DnStacNovCase=0 THEN 1 ELSE DnStacNovCase end),2) AS MONEY),
	   CAST(h.DnStacDecSum/(CASE WHEN h.DnStacDecCase=0 THEN 1 ELSE DnStacDecCase end) AS MONEY),
	   ---------------------------------------------------
       h.AmbulNovSum,
       h.AmbulDecSum,
       h.AmbulNovCase,
       h.AmbulDecCase,
	   CAST(ROUND(h.AmbulNovSum/(CASE WHEN h.AmbulNovCase=0 THEN 1 ELSE AmbulNovCase end),2) AS MONEY),
	   CAST(h.AmbulDecSum/(CASE WHEN h.AmbulDecCase=0 THEN 1 ELSE AmbulDecCase end) AS MONEY)
FROM cteH h 
ORDER BY h.CodeM
GO

DROP TABLE #tCases