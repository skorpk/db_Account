USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200301',
		@dateEndReg DATETIME='20200508',
		@dateStartRegRAK DATETIME='20200301',
		@dateEndRegRAK DATETIME=GETDATE(),
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=2


SELECT 1 AS idRow,DiagnosisCode ,MainDS INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'I%'
INSERT #tDiag SELECT 2,DiagnosisCode ,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #tDiag SELECT 2,DiagnosisCode ,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'
INSERT #tDiag SELECT 3,DiagnosisCode ,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'J%'
INSERT #tDiag SELECT 4,DiagnosisCode ,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'K%'
INSERT #tDiag SELECT 5,DiagnosisCode ,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'E%'




SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,c.rf_idv008,f.CodeM,p.ENP,pp.BirthDay,pv.rf_idV025,d.idRow,dd.DS1, c.rf_idV006 AS USL_OK,d.MainDS,c.rf_idRecordCasePatient
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DS1=d.DiagnosisCode
					LEFT JOIN t_PurposeOfVisit pv ON
             c.id=pv.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth>@reportMonth AND f.TypeFile='H'
	 AND c.rf_idV006 IN(1,3) AND c.Age>17 AND a.rf_idSMO<>'34'



UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT c.idRow
		----------------ambulance----------------------
		,COUNT(DISTINCT CASE WHEN c.USL_OK=3 THEN c.ENP ELSE NULL end) AS AllPeopleAmb
		,COUNT(DISTINCT CASE WHEN c.USL_OK=3 AND c.BirthDay<'19600101' THEN c.ENP ELSE NULL end) AS AllPeople60Amb
		,COUNT(DISTINCT CASE WHEN c.USL_OK=3 THEN c.rf_idCase ELSE NULL end) AS AllCaseAmb
		,COUNT(DISTINCT CASE WHEN c.USL_OK=3 AND c.BirthDay<'19600101' THEN c.rf_idRecordCasePatient ELSE NULL end) AS AllCase60Amb
		,COUNT(DISTINCT CASE WHEN c.USL_OK=3 AND c.rf_idV025='1.3' THEN c.rf_idRecordCasePatient ELSE NULL end) AS AllCaseDNAmb
		,COUNT(DISTINCT CASE WHEN c.USL_OK=3 AND c.rf_idV025='1.3' and c.BirthDay<'19600101' THEN c.rf_idCase ELSE NULL end) AS AllCaseDN60Amb
		---------------stacionar----------------------------
		,COUNT(DISTINCT CASE WHEN c.USL_OK=1 THEN c.ENP ELSE NULL end) AS AllPeopleStacionar
		,COUNT(DISTINCT CASE WHEN c.USL_OK=1 AND c.BirthDay<'19600101' THEN c.ENP ELSE NULL end) AS AllPeople60Stacionar
		,COUNT(DISTINCT CASE WHEN c.USL_OK=1 THEN c.rf_idRecordCasePatient ELSE NULL end) AS AllCaseStacionar
		,COUNT(DISTINCT CASE WHEN c.USL_OK=1 AND c.BirthDay<'19600101' THEN c.rf_idCase ELSE NULL end) AS AllCase60Stacionar
FROM #tCases c 
WHERE c.AmountPayment>0
GROUP by idrow
UNION ALL
SELECT 6 AS idRow
		----------------ambulance----------------------
		,COUNT(DISTINCT CASE WHEN c.USL_OK=3 THEN c.ENP ELSE NULL end) AS AllPeopleAmb
		,COUNT(DISTINCT CASE WHEN c.USL_OK=3 AND c.BirthDay<'19600101' THEN c.ENP ELSE NULL end) AS AllPeople60Amb
		,COUNT(DISTINCT CASE WHEN c.USL_OK=3 THEN c.rf_idRecordCasePatient ELSE NULL end) AS AllCaseAmb
		,COUNT(DISTINCT CASE WHEN c.USL_OK=3 AND c.BirthDay<'19600101' THEN c.rf_idRecordCasePatient ELSE NULL end) AS AllCase60Amb
		,COUNT(DISTINCT CASE WHEN c.USL_OK=3 AND c.rf_idV025='1.3' THEN c.rf_idRecordCasePatient ELSE NULL end) AS AllCaseDNAmb
		,COUNT(DISTINCT CASE WHEN c.USL_OK=3 AND c.rf_idV025='1.3' and c.BirthDay<'19600101' THEN c.rf_idCase ELSE NULL end) AS AllCaseDN60Amb
		---------------stacionar----------------------------
		,COUNT(DISTINCT CASE WHEN c.USL_OK=1 THEN c.ENP ELSE NULL end) AS AllPeopleStacionar
		,COUNT(DISTINCT CASE WHEN c.USL_OK=1 AND c.BirthDay<'19600101' THEN c.ENP ELSE NULL end) AS AllPeople60Stacionar
		,COUNT(DISTINCT CASE WHEN c.USL_OK=1 THEN c.rf_idRecordCasePatient ELSE NULL end) AS AllCaseStacionar
		,COUNT(DISTINCT CASE WHEN c.USL_OK=1 AND c.BirthDay<'19600101' THEN c.rf_idCase ELSE NULL end) AS AllCase60Stacionar
FROM #tCases c 
WHERE c.AmountPayment>0 AND c.idRow=5 AND c.MainDS BETWEEN 'E10' AND 'E14'
GROUP by idrow
GO
DROP TABLE #tCases
GO
DROP TABLE #tDiag