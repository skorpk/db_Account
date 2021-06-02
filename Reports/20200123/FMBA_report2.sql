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

SELECT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.ReportYear,c.rf_idV006,c.rf_idV002,u.UnitCode,u.Qunatity
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_UnitCode_V006 u ON
			c.id=u.rf_idCase
			AND c.rf_idV006=u.V006					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006<4 AND f.CodeM='131940'
		AND c.rf_idv008<>32 AND a.rf_idSMO<>'34'
UNION ALL
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.ReportYear,c.rf_idV006,c.rf_idV002,u.UnitCode,u.Qunatity
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient	
					INNER JOIN dbo.t_Case_UnitCode_V006 u ON
			c.id=u.rf_idCase
			AND c.rf_idV006=u.V006				
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND c.rf_idV006<4 AND f.CodeM='131940'
		AND c.rf_idv008<>32 AND a.rf_idSMO<>'34'
----------VID_POM=32 в ФМБА отсутствует--------------------------
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
SELECT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.ReportYear,c.rf_idV006,c.rf_idV002,u.UnitCode,u.Qunatity
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
				INNER JOIN dbo.t_Case_UnitCode_V006 u ON
			c.id=u.rf_idCase
			AND c.rf_idV006=u.V006				
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006<4 AND f.CodeM<>'131940'
		AND c.rf_idv008<>32 AND cc.rf_idV002<999 AND c.AmountPayment>0 AND a.rf_idSMO<>'34'
UNION ALL
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.ReportYear,c.rf_idV006,c.rf_idV002,u.UnitCode,u.Qunatity
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
					INNER JOIN dbo.t_Case_UnitCode_V006 u ON
			c.id=u.rf_idCase
			AND c.rf_idV006=u.V006		
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND c.rf_idV006<4 AND f.CodeM<>'131940'
		AND c.rf_idv008<>32 AND cc.rf_idV002<999 AND c.AmountPayment>0 AND a.rf_idSMO<>'34'
------------------32 vidpom-------------------------------

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
/*-----------------------------------Посещение профилактическое-----------------------------------*/
	,COUNT(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=3 AND c.UnitCode IN (30,38,145,260,261,317,262) THEN c.Qunatity ELSE NULL END) AS Col1_2018
	,COUNT(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=3 AND c.UnitCode IN (30,38,145,260,261,317,262) THEN c.Qunatity ELSE NULL END) AS Col2_2019
	---------------------------------SUM-----------------------------
	,cast(Sum(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=3 AND c.UnitCode IN (30,38,145,260,261,317,262) THEN c.AmountPayment ELSE 0.0 END) as money) AS Col3_2018
	,cast(Sum(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=3 AND c.UnitCode IN (30,38,145,260,261,317,262) THEN c.AmountPayment ELSE 0.0 END) as money) AS Col4_2019
	/*-----------------------------------Посещение неотложное-----------------------------------*/
	,COUNT(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=3 AND c.UnitCode IN (31,146) THEN c.Qunatity ELSE NULL END) AS Col5_2018
	,COUNT(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=3 AND c.UnitCode IN (31,146) THEN c.Qunatity ELSE NULL END) AS Col6_2019
	---------------------------------SUM-----------------------------
	,cast(Sum(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=3 AND c.UnitCode IN (31,146) THEN c.AmountPayment ELSE 0.0 END)as money) AS Col7_2018
	,cast(Sum(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=3 AND c.UnitCode IN (31,146) THEN c.AmountPayment ELSE 0.0 END)as money) AS Col8_2019
	/*-----------------------------------Обращение-----------------------------------*/
	,COUNT(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=3 AND c.UnitCode IN (32,147,205) THEN c.Qunatity ELSE NULL END) AS Col9_2018
	,COUNT(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=3 AND c.UnitCode IN (32,147,205) THEN c.Qunatity ELSE NULL END) AS Col10_2019
	---------------------------------SUM-----------------------------
	,cast(Sum(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=3 AND c.UnitCode IN (32,147,205) THEN c.AmountPayment ELSE 0.0 END)as money) AS Col11_2018
	,cast(Sum(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=3 AND c.UnitCode IN (32,147,205) THEN c.AmountPayment ELSE 0.0 END)as money) AS Col12_2019
	/*-----------------------------------Дневной стационар-----------------------------------*/
	,COUNT(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=2 THEN c.rf_idCase ELSE NULL END) AS Col13_2018
	,COUNT(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=2 THEN c.rf_idCase ELSE NULL END) AS Col14_2019
	---------------------------------SUM-----------------------------
	,cast(Sum(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=2 THEN c.AmountPayment ELSE 0.0 END) as money) AS Col15_2018
	,cast(Sum(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=2 THEN c.AmountPayment ELSE 0.0 END) as money) AS Col16_2019
	/*-----------------------------------Cтационар-----------------------------------*/
	,COUNT(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=1 THEN c.rf_idCase ELSE NULL END) AS Col13_2018
	,COUNT(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=1 THEN c.rf_idCase ELSE NULL END) AS Col14_2019
	---------------------------------SUM-----------------------------
	,cast(Sum(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=1 THEN c.AmountPayment ELSE 0.0 END) as money) AS Col15_2018
	,cast(Sum(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=1 THEN c.AmountPayment ELSE 0.0 END) as money) AS Col16_2019
FROM #tCases c INNER JOIN #v002 v2 ON
		c.rf_idV002=v2.id
WHERE AmountPayment>0
GROUP BY id,v2.V002Name
ORDER BY id
/*-------------------------Table 2---------------------------------------------------------------------*/
SELECT v2.id,v2.V002Name
/*-----------------------------------Посещение профилактическое-----------------------------------*/
	,COUNT(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=3 AND c.UnitCode IN (30,38,145,260,261,317,262) THEN c.Qunatity ELSE NULL END) AS Col1_2018
	,COUNT(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=3 AND c.UnitCode IN (30,38,145,260,261,317,262) THEN c.Qunatity ELSE NULL END) AS Col2_2019
	---------------------------------SUM-----------------------------
	,cast(Sum(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=3 AND c.UnitCode IN (30,38,145,260,261,317,262) THEN c.AmountPayment ELSE 0.0 END) as money) AS Col3_2018
	,cast(Sum(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=3 AND c.UnitCode IN (30,38,145,260,261,317,262) THEN c.AmountPayment ELSE 0.0 END) as money) AS Col4_2019
	/*-----------------------------------Посещение неотложное-----------------------------------*/
	,COUNT(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=3 AND c.UnitCode IN (31,146) THEN c.Qunatity ELSE NULL END) AS Col5_2018
	,COUNT(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=3 AND c.UnitCode IN (31,146) THEN c.Qunatity ELSE NULL END) AS Col6_2019
	---------------------------------SUM-----------------------------
	,cast(Sum(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=3 AND c.UnitCode IN (31,146) THEN c.AmountPayment ELSE 0.0 END)as money) AS Col7_2018
	,cast(Sum(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=3 AND c.UnitCode IN (31,146) THEN c.AmountPayment ELSE 0.0 END)as money) AS Col8_2019
	/*-----------------------------------Обращение-----------------------------------*/
	,COUNT(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=3 AND c.UnitCode IN (32,147,205) THEN c.Qunatity ELSE NULL END) AS Col9_2018
	,COUNT(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=3 AND c.UnitCode IN (32,147,205) THEN c.Qunatity ELSE NULL END) AS Col10_2019
	---------------------------------SUM-----------------------------
	,cast(Sum(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=3 AND c.UnitCode IN (32,147,205) THEN c.AmountPayment ELSE 0.0 END)as money) AS Col11_2018
	,cast(Sum(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=3 AND c.UnitCode IN (32,147,205) THEN c.AmountPayment ELSE 0.0 END)as money) AS Col12_2019
	/*-----------------------------------Дневной стационар-----------------------------------*/
	,COUNT(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=2 THEN c.rf_idCase ELSE NULL END) AS Col13_2018
	,COUNT(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=2 THEN c.rf_idCase ELSE NULL END) AS Col14_2019
	---------------------------------SUM-----------------------------
	,cast(Sum(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=2 THEN c.AmountPayment ELSE 0.0 END) as money) AS Col15_2018
	,cast(Sum(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=2 THEN c.AmountPayment ELSE 0.0 END) as money) AS Col16_2019
	/*-----------------------------------Cтационар-----------------------------------*/
	,COUNT(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=1 THEN c.rf_idCase ELSE NULL END) AS Col13_2018
	,COUNT(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=1 THEN c.rf_idCase ELSE NULL END) AS Col14_2019
	---------------------------------SUM-----------------------------
	,cast(Sum(CASE WHEN c.ReportYear=2018 AND c.rf_idV006=1 THEN c.AmountPayment ELSE 0.0 END) as money) AS Col15_2018
	,cast(Sum(CASE WHEN c.ReportYear=2019 AND c.rf_idV006=1 THEN c.AmountPayment ELSE 0.0 END) as money) AS Col16_2019
FROM #tCasesOther c INNER JOIN #v002 v2 ON
		c.rf_idV002=v2.id
WHERE AmountPayment>0
GROUP BY id,v2.V002Name
ORDER BY id

GO 
DROP TABLE #v002
DROP TABLE #tCases
DROP TABLE #tCasesOther