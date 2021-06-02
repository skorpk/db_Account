USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20180101',
		@dateEndReg DATETIME='20190122',
		@dateStartReg2 DATETIME='20190101',
		@dateEndReg2 DATETIME='20200118',
		@dateEndReg3 DATETIME='20200123',
		@reportYear SMALLINT=2018,
		@reportYear2 SMALLINT=2019

SELECT id,name AS V002Name INTO #v002 FROM vw_sprV002 ORDER BY Id
INSERT #v002(id,V002Name) VALUES(999,'Высокотехнологичная медицинская помощь')

SELECT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.ReportYear,c.rf_idV006,c.rf_idV002
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006<4 AND f.CodeM='131940'
		AND c.rf_idv008<>32 AND a.rf_idSMO<>'34'
UNION ALL
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.ReportYear,c.rf_idV006,c.rf_idV002
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient					
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND c.rf_idV006<4 AND f.CodeM='131940'
		AND c.rf_idv008<>32 AND a.rf_idSMO<>'34'
------------------32 vidpom-------------------------------
/*
INSERT #tCases
SELECT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.ReportYear,c.rf_idV006,999
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006<4 AND f.CodeM='131940'
		AND c.rf_idv008=32 AND a.rf_idSMO<>'34'

PRINT('ВМП' + CAST(@@ROWCOUNT AS VARCHAR(10)))

INSERT #tCases
SELECT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.ReportYear,c.rf_idV006,999
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient					
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND c.rf_idV006<4 AND f.CodeM='131940'
		AND c.rf_idv008=32 AND a.rf_idSMO<>'34'
PRINT('ВМП' + CAST(@@ROWCOUNT AS VARCHAR(10)))
*/
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction,2018 AS reportYear
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
			AND r.reportYear = p.ReportYear

			UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction,2019 AS reportYear
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg2 AND c.DateRegistration<@dateEndReg3
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
			AND r.reportYear = p.ReportYear

-------------------------------------------Get help in other MO----------------------------------------------------------------------------------
SELECT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.ReportYear,c.rf_idV006,c.rf_idV002
INTO #tCasesOther
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient
					INNER JOIN #tCases cc ON
			p.ENP=cc.ENP
			AND cc.rf_idV002 = c.rf_idV002
			AND cc.ReportYear = a.ReportYear
			AND cc.rf_idV006 = c.rf_idV006					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006<4 AND f.CodeM<>'131940'
		AND c.rf_idv008<>32 AND cc.rf_idV002<999 AND c.AmountPayment>0 AND a.rf_idSMO<>'34'
UNION ALL
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.ReportYear,c.rf_idV006,c.rf_idV002
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient	
					INNER JOIN #tCases cc ON
			p.ENP=cc.ENP
			AND cc.rf_idV002 = c.rf_idV002
			AND cc.ReportYear = a.ReportYear
			AND cc.rf_idV006 = c.rf_idV006				
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND c.rf_idV006<4 AND f.CodeM<>'131940'
		AND c.rf_idv008<>32 AND cc.rf_idV002<999 AND c.AmountPayment>0 AND a.rf_idSMO<>'34'
------------------32 vidpom-------------------------------
/*
INSERT #tCasesOther
SELECT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.ReportYear,c.rf_idV006,999
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient		
					INNER JOIN #tCases cc ON
			p.ENP=cc.ENP
			AND cc.ReportYear = a.ReportYear
			AND cc.rf_idV006 = c.rf_idV006				
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006<4 AND f.CodeM<>'131940'
		AND c.rf_idv008=32 AND cc.rf_idV002=999 AND c.AmountPayment>0 AND a.rf_idSMO<>'34'

INSERT #tCasesOther
SELECT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.ReportYear,c.rf_idV006,999
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient	
					INNER JOIN #tCases cc ON
			p.ENP=cc.ENP
			AND cc.ReportYear = a.ReportYear
			AND cc.rf_idV006 = c.rf_idV006				
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND c.rf_idV006<4 AND f.CodeM<>'131940'
		AND c.rf_idv008=32 AND cc.rf_idV002=999 AND c.AmountPayment>0 AND a.rf_idSMO<>'34'
*/
-----------------------------------------------------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCasesOther p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction,2018 AS reportYear
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
			AND r.reportYear = p.ReportYear

			UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCasesOther p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction,2019 AS reportYear
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg2 AND c.DateRegistration<@dateEndReg3
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
			AND r.reportYear = p.ReportYear

/*-------------------------Table 1---------------------------------------------------------------------*/
SELECT v2.id,v2.V002Name
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2018 AND c.rf_idV006=3 THEN c.ENP ELSE NULL END) AS Amb2018
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2019 AND c.rf_idV006=3 THEN c.ENP ELSE NULL END) AS Amb2019
	--------------------------DnevnoiStacionar---------------------------------------
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2018 AND c.rf_idV006=2 THEN c.ENP ELSE NULL END) AS DnStac2018
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2019 AND c.rf_idV006=2 THEN c.ENP ELSE NULL END) AS DnStac019
	--------------------------Stacionar---------------------------------------
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2018 AND c.rf_idV006=1 THEN c.ENP ELSE NULL END) AS Stac2018
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2019 AND c.rf_idV006=1 THEN c.ENP ELSE NULL END) AS Stac019
	
FROM #tCases c INNER JOIN #v002 v2 ON
		c.rf_idV002=v2.id
WHERE AmountPayment>0
GROUP BY id,v2.V002Name
UNION ALL
SELECT 9999,'Итого'
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2018 AND c.rf_idV006=3 THEN c.ENP ELSE NULL END) AS Amb2018
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2019 AND c.rf_idV006=3 THEN c.ENP ELSE NULL END) AS Amb2019
	--------------------------DnevnoiStacionar---------------------------------------
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2018 AND c.rf_idV006=2 THEN c.ENP ELSE NULL END) AS DnStac2018
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2019 AND c.rf_idV006=2 THEN c.ENP ELSE NULL END) AS DnStac019
	--------------------------Stacionar---------------------------------------
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2018 AND c.rf_idV006=1 THEN c.ENP ELSE NULL END) AS Stac2018
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2019 AND c.rf_idV006=1 THEN c.ENP ELSE NULL END) AS Stac019	
FROM #tCases c
WHERE AmountPayment>0
ORDER BY id
/*-------------------------Table 2---------------------------------------------------------------------*/

SELECT v2.id,v2.V002Name
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2018 AND c.rf_idV006=3 THEN c.ENP ELSE NULL END) AS Amb2018
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2019 AND c.rf_idV006=3 THEN c.ENP ELSE NULL END) AS Amb2019
	--------------------------DnevnoiStacionar---------------------------------------
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2018 AND c.rf_idV006=2 THEN c.ENP ELSE NULL END) AS DnStac2018
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2019 AND c.rf_idV006=2 THEN c.ENP ELSE NULL END) AS DnStac019
	--------------------------Stacionar---------------------------------------
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2018 AND c.rf_idV006=1 THEN c.ENP ELSE NULL END) AS Stac2018
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2019 AND c.rf_idV006=1 THEN c.ENP ELSE NULL END) AS Stac019	
FROM #tCasesOther c INNER JOIN #v002 v2 ON
		c.rf_idV002=v2.id
WHERE AmountPayment>0
GROUP BY id,v2.V002Name
UNION ALL
SELECT 9999,'Итого'
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2018 AND c.rf_idV006=3 THEN c.ENP ELSE NULL END) AS Amb2018
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2019 AND c.rf_idV006=3 THEN c.ENP ELSE NULL END) AS Amb2019
	--------------------------DnevnoiStacionar---------------------------------------
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2018 AND c.rf_idV006=2 THEN c.ENP ELSE NULL END) AS DnStac2018
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2019 AND c.rf_idV006=2 THEN c.ENP ELSE NULL END) AS DnStac019
	--------------------------Stacionar---------------------------------------
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2018 AND c.rf_idV006=1 THEN c.ENP ELSE NULL END) AS Stac2018
	,COUNT(DISTINCT CASE WHEN c.ReportYear=2019 AND c.rf_idV006=1 THEN c.ENP ELSE NULL END) AS Stac019	
FROM #tCasesOther c
WHERE AmountPayment>0
ORDER BY id

GO 
DROP TABLE #v002
DROP TABLE #tCases
DROP TABLE #tCasesOther