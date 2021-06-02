USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME='20210116',
		@dateStartRegRAK DATETIME='20210118',
		@dateEndRegRAK DATETIME=GETDATE()

SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,f.CodeM,p.ENP,a.rf_idSMO,c.rf_idV006 AS USL_OK, a.ReportYear
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient								
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase						
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND f.CodeM='451001' AND a.ReportYear IN (2019,2020) AND c.rf_idV006<4 AND dd.DS1 LIKE 'N%'


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE AmountPayment=0.0 

SELECT 'Волгоградская' AS NameCol
	  ,COUNT(DISTINCT CASE WHEN USL_OK=3 AND ReportYear=2019 THEN ENP ELSE NULL END ) AS CountAMP_2019
	  ,COUNT(DISTINCT CASE WHEN USL_OK=3 AND ReportYear=2020 THEN ENP ELSE NULL END ) AS CountAMP_2020
	  ---------------------Stacionar-----------------------------------------------------------------------
	  ,COUNT(DISTINCT CASE WHEN USL_OK=1 AND ReportYear=2019 THEN ENP ELSE NULL END ) AS CountStac_2019
	  ,COUNT(DISTINCT CASE WHEN USL_OK=1 AND ReportYear=2020 THEN ENP ELSE NULL END ) AS CountStac_2020
	  ---------------------DnevStacionar-----------------------------------------------------------------------
	  ,COUNT(DISTINCT CASE WHEN USL_OK=2 AND ReportYear=2019 THEN ENP ELSE NULL END ) AS CountDnevStac_2019
	  ,COUNT(DISTINCT CASE WHEN USL_OK=2 AND ReportYear=2020 THEN ENP ELSE NULL END ) AS CountDnevStac_2020
FROM #tCases WHERE rf_idSMO<>'34'
UNION ALL
SELECT 'Иногордние' 
	  ,COUNT(DISTINCT CASE WHEN USL_OK=3 AND ReportYear=2019 THEN ENP ELSE NULL END ) AS CountAMP_2019
	  ,COUNT(DISTINCT CASE WHEN USL_OK=3 AND ReportYear=2020 THEN ENP ELSE NULL END ) AS CountAMP_2020
	  ---------------------Stacionar-----------------------------------------------------------------------
	  ,COUNT(DISTINCT CASE WHEN USL_OK=1 AND ReportYear=2019 THEN ENP ELSE NULL END ) AS CountStac_2019
	  ,COUNT(DISTINCT CASE WHEN USL_OK=1 AND ReportYear=2020 THEN ENP ELSE NULL END ) AS CountStac_2020
	  ---------------------DnevStacionar-----------------------------------------------------------------------
	  ,COUNT(DISTINCT CASE WHEN USL_OK=2 AND ReportYear=2019 THEN ENP ELSE NULL END ) AS CountDnevStac_2019
	  ,COUNT(DISTINCT CASE WHEN USL_OK=2 AND ReportYear=2020 THEN ENP ELSE NULL END ) AS CountDnevStac_2020
FROM #tCases WHERE rf_idSMO='34'
GO
DROP TABLE #tCases
