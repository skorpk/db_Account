USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200301',
		@dateEnd DATETIME=GETDATE(),
		@dateEndPay DATETIME=GETDATE(),
		-----2019-----
		@dateStart2020 DATETIME='20200101',
		@dateEnd2020 DATETIME=GETDATE(),
		@dateEndPay2020 DATETIME=GETDATE(),
		@reportYear SMALLINT=2020

;WITH cte
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY ENP ORDER BY cc.DateEnd desc) AS idrow, c.id AS rf_idCase, f.CodeM, cc.AmountPayment,cc.id AS rf_idRecordCasePatient,cc.AmountPayment AS AmmPay,ENP,cc.DateEnd
	--INTO #tCasesENP
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_PatientSMO ps ON
				r.id=ps.rf_idRecordCasePatient
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient	
						INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCasePatient						
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND EXISTS(SELECT 1 FROM dbo.t_Diagnosis d WHERE c.id=d.rf_idCase	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode IN('U07.1','U07.2'))
	AND a.rf_idSMO<>'34'
)
SELECT *
INTO #tCasesENP
FROM cte WHERE cte.idrow=1
PRINT('Insert')
PRINT(@@ROWCOUNT)


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCasesENP p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCasesENP WHERE AmountPayment=0.0
PRINT('Удаляем')
PRINT(@@ROWCOUNT)
---------------------------2019------------------------------
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,cc.id AS rf_idRecordCasePatient,cc.AmountPayment AS AmmPay,ps.ENP,c.rf_idV006 AS USL_OK, c.rf_idV002,m.MainDS
INTO #tCases2020
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient	
					INNER JOIN #tCasesENP e ON
			e.ENP = ps.ENP
					INNER JOIN dbo.t_Diagnosis d ON
            c.id=d.rf_idCase
					INNER JOIN dbo.vw_sprMKB10 m ON
            d.DiagnosisCode=m.DiagnosisCode
WHERE f.DateRegistration>@dateStart2020 AND f.DateRegistration<@dateEnd2020 AND a.ReportYear=@reportYear AND cc.DateBegin>=e.DateEnd AND a.rf_idSMO<>'34' AND d.TypeDiagnosis=1

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases2020 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases2020 WHERE 1=(CASE WHEN AmmPay=0.0 and AmountPayment<0.0 THEN 1 WHEN AmmPay>0.0 and AmountPayment=0.0 THEN 1 ELSE 0 END)

ALTER TABLE #tCases2020 ADD IsAmbType TINYINT
-----обращения
UPDATE t SET IsAmbType=3
FROM #tCases2020 t INNER JOIN dbo.t_MES m ON
			t.rf_idCase=m.rf_idCase
WHERE m.MES LIKE '2.78.%' AND USL_OK=3

DELETE FROM #tCases2020 WHERE USL_OK=3 AND IsAmbType IS null


SELECT  'Всего' AS Profil
	   ,COUNT(DISTINCT c.ENP) AS Col2
	   ,COUNT(DISTINCT CASE WHEN USL_OK=4 THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col2
	   ,NULL,null
	   ,COUNT(DISTINCT CASE WHEN USL_OK=3 AND c.IsAmbType=3 THEN c.rf_idRecordCasePatient ELSE NULL end)	AS Col5
	   ,COUNT(DISTINCT CASE WHEN USL_OK=1 THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col6
	   ,COUNT(DISTINCT CASE WHEN USL_OK=1 AND dd.ENP IS NOT NULL THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col7
	   ,COUNT(DISTINCT CASE WHEN USL_OK=1 AND dd.ENP IS null THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col8
	   ,COUNT(DISTINCT CASE WHEN USL_OK=2 THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col9
FROM #tCases2020 c LEFT JOIN dbo.T_DNPERSONS_DS_2020 dd ON
        c.enp=dd.ENP
		AND c.MainDS=dd.DS_Rubr
UNION all
SELECT  v2.name
	   ,COUNT(DISTINCT c.ENP) AS Col2
	   ,COUNT(DISTINCT CASE WHEN USL_OK=4 THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col2
	   ,NULL,null
	   ,COUNT(DISTINCT CASE WHEN USL_OK=3 AND c.IsAmbType=3 THEN c.rf_idRecordCasePatient ELSE NULL end)	AS Col5
	   ,COUNT(DISTINCT CASE WHEN USL_OK=1 THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col6
	   ,COUNT(DISTINCT CASE WHEN USL_OK=1 AND dd.ENP IS NOT NULL THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col7
	   ,COUNT(DISTINCT CASE WHEN USL_OK=1 AND dd.ENP IS null THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col8
	   ,COUNT(DISTINCT CASE WHEN USL_OK=2 THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col9
FROM  #tCases2020 c INNER JOIN vw_sprV002 v2 ON
		c.rf_idV002=v2.id
				LEFT JOIN dbo.T_DNPERSONS_DS_2020 dd ON
        c.enp=dd.ENP
		AND c.MainDS=dd.DS_Rubr
GROUP BY v2.name



GO
DROP TABLE #tCases2020
GO
DROP TABLE #tCasesENP