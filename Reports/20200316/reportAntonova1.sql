USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME='20200122',
		@reportYear SMALLINT=2019,
		----------------------
		@dateStartReg2 DATETIME='20200210',
		@dateEndReg2 DATETIME='20200311',
		@reportYear2 SMALLINT=2020,
		@reportMonth TINYINT=2



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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006>1 AND c.rf_idV006<4 AND f.TypeFile='H' AND a.ReportMonth<=12 
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
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND c.rf_idV006>1 AND c.rf_idV006<4 AND f.TypeFile='H' AND a.rf_idSMO<>'34' 
		
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND c.rf_idV008 IN(31,32) AND f.TypeFile='H' AND a.ReportMonth<=12 
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
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND c.rf_idV006=1 AND c.rf_idV008 IN(31,32) AND f.TypeFile='H' AND a.rf_idSMO<>'34'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg2 AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

;WITH cte
AS(
SELECT c.CodeM,l.NAMES AS LPU
		------------------------------Stacionar 31----------------------------
		,CAST(SUM(CASE WHEN ReportMonth=11 AND rf_idV006=1 AND rf_idV008=31 THEN AmountPayment ELSE 0.0 END) AS DECIMAL(15,2))/12.0 AS Stac31NovSum
		,SUM(CASE WHEN ReportMonth=12 AND rf_idV006=1 AND rf_idV008=31 THEN AmountPayment ELSE 0.0 END) AS Stac31DecSum
		,count(CASE WHEN ReportMonth=11 AND rf_idV006=1 AND rf_idV008=31 THEN id ELSE Null END)/12 AS Stac31NovCase
		,count(CASE WHEN ReportMonth=12 AND rf_idV006=1 AND rf_idV008=31 THEN id ELSE Null END) AS Stac31DecCase
		
        -------------------------------Stacionar 32----------------------
		,CAST(SUM(CASE WHEN ReportMonth=11 AND rf_idV006=1 AND rf_idV008=32 THEN AmountPayment ELSE 0.0 END) AS DECIMAL(15,2))/12.0 AS Stac32NovSum
		,SUM(CASE WHEN ReportMonth=12      AND rf_idV006=1 AND rf_idV008=32 THEN AmountPayment ELSE 0.0 END) AS Stac32DecSum
		,count(CASE WHEN ReportMonth=11    AND rf_idV006=1 AND rf_idV008=32 THEN id ELSE null END)/12 AS Stac32NovCase
		,count(CASE WHEN ReportMonth=12    AND rf_idV006=1 AND rf_idV008=32 THEN id ELSE null END) AS Stac32DecCase
        -------------------------------DnevnoiStacionar----------------------
		,CAST(SUM(CASE WHEN ReportMonth=11 AND rf_idV006=2 THEN AmountPayment ELSE 0.0 END) AS DECIMAL(15,2))/12.0 AS DnStacNovSum
		,SUM(CASE WHEN ReportMonth=12      AND rf_idV006=2 THEN AmountPayment ELSE 0.0 END) AS DnStacDecSum
		,count(CASE WHEN ReportMonth=11    AND rf_idV006=2 THEN id ELSE null END)/12 AS DnStacNovCase
		,count(CASE WHEN ReportMonth=12    AND rf_idV006=2 THEN id ELSE null END) AS DnStacDecCase
        -------------------------------Ambulatorka----------------------
		,CAST(SUM(CASE WHEN ReportMonth=11 AND rf_idV006=3 THEN AmountPayment ELSE 0.0 END) AS DECIMAL(15,2))/12.0 AS AmbulNovSum
		,SUM(CASE WHEN ReportMonth=12      AND rf_idV006=3 THEN AmountPayment ELSE 0.0 END) AS AmbulDecSum
		,count(CASE WHEN ReportMonth=11    AND rf_idV006=3 THEN id ELSE null END)/12 AS AmbulNovCase
		,count(CASE WHEN ReportMonth=12    AND rf_idV006=3 THEN id ELSE null END) AS AmbulDecCase
FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON
		l.CodeM = c.CodeM
WHERE AmountPayment>0.0
GROUP BY c.CodeM,l.NAMES
)
SELECT cte.CodeM,cte.LPU,
       cast(cte.Stac31NovSum  as money),
	   cast(cte.Stac31DecSum as money),
	   cte.Stac31NovCase ,
	   cte.Stac31DecCase ,
	   CAST(cte.Stac31NovSum/REPLACE(cte.Stac31NovCase,0,1) as int) AS AvgNovem31,
	   CAST(cte.Stac31DecSum/REPLACE(cte.Stac31DecCase,0,1) as int) AS AvgDecember31,
	   ----------------------------
       cast(cte.Stac32NovSum  as money),
	   cast(cte.Stac32DecSum  as money),
	   cte.Stac32NovCase,
	   cte.Stac32DecCase,
	   cast(cte.Stac32NovSum/REPLACE(cte.Stac32NovCase,0,1) as int)  AS AvgNovem32,
	   cast(cte.Stac32DecSum/REPLACE(cte.Stac32DecCase,0,1) as int)  AS AvgDecember32,
	   -----------------------------
       cast(cte.DnStacNovSum  as money),
	   cast(cte.DnStacDecSum  as money),
	   cte.DnStacNovCase,
	   cte.DnStacDecCase,
	   cast(cte.DnStacNovSum/REPLACE(cte.DnStacNovCase,0,1) as int) ,
	   cast(cte.DnStacDecSum/REPLACE(cte.DnStacDecCase,0,1) as int) ,
	   -----------------------------
       cast(cte.AmbulNovSum as money),
	   cast(cte.AmbulDecSum as money),
	   cte.AmbulNovCase,
	   cte.AmbulDecCase,
	   cast(cte.AmbulNovSum/REPLACE(cte.AmbulNovCase,0,1) as int) ,
	   cast(cte.AmbulDecSum/REPLACE(cte.AmbulDecCase,0,1) as int) 
FROM cte ORDER BY cte.CodeM
GO

DROP TABLE #tCases