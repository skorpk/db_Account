USE AccountOMS
go
DECLARE @dateStartReg DATETIME='20200601',
		@dateEndReg DATETIME='20200716',
		@dateStartRegRAK DATETIME='20200601',
		@dateEndRegRAK DATETIME='20200716',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=6,
		@codeSMO CHAR(5)='34007'
		

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,a.rf_idSMO,cc.id, a.ReportMonth, c.rf_idV006 AS USL_OK, 0 AS  Quantity, 0 AS IsCovid
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006 IN(1,2) AND a.ReportMonth=@reportMonth AND a.rf_idSMO=@codeSMO

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,a.rf_idSMO,cc.id, a.ReportMonth, c.rf_idV006 AS USL_OK,SUM(m.Quantity), 0 AS IsCovid
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient					
					INNER JOIN dbo.t_Meduslugi m ON
            c.id=m.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006=4 AND a.ReportMonth=@reportMonth AND a.rf_idSMO=@codeSMO
		AND m.MUGroupCode>0
GROUP BY c.id , cc.AmountPayment,cc.AmountPayment,f.CodeM,p.ENP ,a.rf_idSMO,cc.id, a.ReportMonth, c.rf_idV006

UPDATE c set c.IsCovid=1
FROM #tCases c INNER JOIN dbo.t_Diagnosis d ON
		c.rf_idCase=d.rf_idCase
WHERE d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode IN('U07.1','U07.2')

SELECT usl_ok,c1.id,SUM(c2.AmountDeduction) AS AmountDeduction,c1.Quantity, c1.ISCovid
INTO #tExpertiseMEK
FROM #tCases c1 INNER JOIN dbo.t_PaymentAcceptedCase2 c2 ON
		c1.rf_idCase=c2.rf_idCase
WHERE c2.DateRegistration>=@dateStartRegRAK AND c2.DateRegistration<@dateEndRegRAK AND c2.TypeCheckup=1
GROUP BY usl_ok,c1.id,c1.Quantity,c1.IsCovid
			
;WITH cte
AS(
SELECT DISTINCT usl_ok,@codeSMO AS CodeSMO,ENP, id, AmountPayment,NULL AS Col5, CAST(0.0 AS decimal(15,2)) AS Col7, IsCovid FROM #tCases WHERE USL_OK<3
UNION ALL
SELECT usl_ok,@codeSMO,NULL,NULL,0.0,CASE WHEN AmountDeduction>0 THEN id ELSE NULL END AS id,AmountDeduction,IsCovid FROM #tExpertiseMEK  WHERE USL_OK<3
)
SELECT c.CodeSMO
	--------------stacionar-------------------------
	,COUNT(DISTINCT CASE WHEN usl_ok=1 THEN ENP ELSE NULL END) AS Col2
	,COUNT(DISTINCT CASE WHEN usl_ok=1 AND IsCovid=1 THEN ENP ELSE NULL END) AS Col3
	,COUNT(CASE WHEN usl_ok=1 THEN id ELSE NULL END) AS Col4
	,COUNT(CASE WHEN usl_ok=1 AND c.IsCovid=1 THEN id ELSE NULL END) AS Col5
	,SUM(CASE WHEN usl_ok=1 THEN amountPayment ELSE 0.0 END) AS Col6
	,SUM(CASE WHEN usl_ok=1 AND IsCovid=1 THEN amountPayment ELSE 0.0 END) AS Col7

	,COUNT(CASE WHEN usl_ok=1 THEN Col5 ELSE NULL END) AS Col8
	,COUNT(CASE WHEN usl_ok=1 AND IsCovid=1 THEN Col5 ELSE NULL END) AS Col9
	,'' AS Col10
	,SUM(CASE WHEN usl_ok=1 THEN Col7 ELSE 0.0 END) AS Col11
	,SUM(CASE WHEN usl_ok=1 AND c.IsCovid=1 THEN Col7 ELSE 0.0 END) AS Col12
	,0 AS Col13
	--------------dnevnoi stacionar-------------------------
	,COUNT(DISTINCT CASE WHEN usl_ok=2 THEN ENP ELSE NULL END) AS Col14
	,COUNT(DISTINCT CASE WHEN usl_ok=2 AND c.IsCovid=1 THEN ENP ELSE NULL END) AS Col15
	,COUNT(CASE WHEN usl_ok=2 THEN id ELSE NULL END) AS Col16
	,COUNT(CASE WHEN usl_ok=2 AND IsCovid=1 THEN id ELSE NULL END) AS Col17
	,SUM(CASE WHEN usl_ok=2 THEN amountPayment ELSE 0.0 END) AS Col18
	,SUM(CASE WHEN usl_ok=2 AND IsCovid=1 THEN amountPayment ELSE 0.0 END) AS Col19
	,COUNT(CASE WHEN usl_ok=2 THEN Col5 ELSE NULL END) AS Col120
	,COUNT(CASE WHEN usl_ok=2 AND IsCovid=1 THEN Col5 ELSE NULL END) AS Col121
	,'' AS Col22
	,SUM(CASE WHEN usl_ok=3 THEN Col7 ELSE 0.0 END) AS Col123
	,SUM(CASE WHEN usl_ok=3 AND c.IsCovid=1 THEN Col7 ELSE 0.0 END) AS Col124
	,0 AS Col25 
FROM cte c GROUP BY CodeSMO 
----------------Skoray---------------------
;WITH cte
AS(
SELECT DISTINCT @codeSMO AS CodeSMO,ENP, id, AmountPayment,NULL AS Col5, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,Quantity,0 AS CaseMEK, IsCovid FROM #tCases WHERE USL_OK=4
UNION ALL
SELECT @codeSMO,NULL,NULL,0.0,id,AmountDeduction,0,CASE WHEN AmountDeduction>0 THEN Quantity ELSE 0 END  , IsCovid FROM #tExpertiseMEK WHERE USL_OK=4
)
SELECT c.CodeSMO
	,COUNT(DISTINCT ENP ) AS Col40
	,COUNT(DISTINCT CASE WHEN c.IsCovid=1 then ENP ELSE NULL end) AS Col41
	,SUM(c.Quantity) AS Col42
	,SUM(CASE WHEN c.IsCovid=1 then c.Quantity ELSE 0 end) AS Col43
	,SUM(amountPayment) AS Col44
	,SUM(CASE WHEN c.IsCovid=1 then c.AmountPayment ELSE 0 end) AS Col45
	,SUM(c.CaseMEK) AS Col46
	,SUM(CASE WHEN c.IsCovid=1 then c.CaseMEK ELSE 0 end) AS Col47
	,SUM(AmountDeduction) AS Col48
	,SUM(CASE WHEN c.IsCovid=1 then c.AmountDeduction ELSE 0 end) AS Col49
FROM cte c GROUP BY CodeSMO 


GO
DROP TABLE #tExpertiseMEK
GO
DROP TABLE #tCases