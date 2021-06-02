USE AccountOMS
go
DECLARE @dateStartReg DATETIME='20190601',
		@dateEndReg DATETIME='20190716',
		@dateStartRegRAK DATETIME='20190601',
		@dateEndRegRAK DATETIME='20200716',
		@reportYear SMALLINT=2019,
		@reportMonth TINYINT=6,
		@codeSMO CHAR(5)='34007'
		

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,a.rf_idSMO,cc.id, a.ReportMonth, c.rf_idV006 AS USL_OK, 0 AS  Quantity
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
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,a.rf_idSMO,cc.id, a.ReportMonth, c.rf_idV006 AS USL_OK,SUM(m.Quantity)
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


SELECT usl_ok,c1.id,SUM(c2.AmountDeduction) AS AmountDeduction,c1.Quantity
INTO #tExpertiseMEK
FROM #tCases c1 INNER JOIN dbo.t_PaymentAcceptedCase2 c2 ON
		c1.rf_idCase=c2.rf_idCase
WHERE c2.DateRegistration>=@dateStartRegRAK AND c2.DateRegistration<@dateEndRegRAK AND c2.TypeCheckup=1
GROUP BY usl_ok,c1.id,c1.Quantity
			
;WITH cte
AS(
SELECT DISTINCT usl_ok,@codeSMO AS CodeSMO,ENP, id, AmountPayment,NULL AS Col5, CAST(0.0 AS decimal(15,2)) AS Col7 FROM #tCases WHERE USL_OK<3
UNION ALL
SELECT usl_ok,@codeSMO,NULL,NULL,0.0,CASE WHEN AmountDeduction>0 THEN id ELSE NULL END AS id,AmountDeduction FROM #tExpertiseMEK  WHERE USL_OK<3
)
SELECT c.CodeSMO
	--------------stacionar-------------------------
	,COUNT(DISTINCT CASE WHEN usl_ok=1 THEN ENP ELSE NULL END) AS Col2
	,COUNT(CASE WHEN usl_ok=1 THEN id ELSE NULL END) AS Col3
	,SUM(CASE WHEN usl_ok=1 THEN amountPayment ELSE 0.0 END) AS Col4
	,COUNT(CASE WHEN usl_ok=1 THEN Col5 ELSE NULL END) AS Col5
	,'' AS Col6
	,SUM(CASE WHEN usl_ok=1 THEN Col7 ELSE 0.0 END) AS Col7
	,0 AS Col8 
	--------------dnevnoi stacionar-------------------------
	,COUNT(DISTINCT CASE WHEN usl_ok=2 THEN ENP ELSE NULL END) AS Col9
	,COUNT(CASE WHEN usl_ok=2 THEN id ELSE NULL END) AS Col10
	,SUM(CASE WHEN usl_ok=2 THEN amountPayment ELSE 0.0 END) AS Col11
	,COUNT(CASE WHEN usl_ok=2 THEN Col5 ELSE NULL END) AS Col12
	,'' AS Col13
	,SUM(CASE WHEN usl_ok=3 THEN Col7 ELSE 0.0 END) AS Col14
	,0 AS Col15 
FROM cte c GROUP BY CodeSMO 
----------------Skoray---------------------
;WITH cte
AS(
SELECT DISTINCT @codeSMO AS CodeSMO,ENP, id, AmountPayment,NULL AS Col5, CAST(0.0 AS decimal(15,2)) AS AmountDeduction,Quantity,0 AS CaseMEK FROM #tCases WHERE USL_OK=4
UNION ALL
SELECT @codeSMO,NULL,NULL,0.0,id,AmountDeduction,0,CASE WHEN AmountDeduction>0 THEN Quantity ELSE 0 END  FROM #tExpertiseMEK WHERE USL_OK=4
)
SELECT c.CodeSMO
	,COUNT(DISTINCT ENP ) AS Col25
	,SUM(c.Quantity) AS Col26
	,SUM(amountPayment) AS Col27
	,SUM(c.CaseMEK) AS Col28
	,SUM(AmountDeduction) AS Col29	
FROM cte c GROUP BY CodeSMO 


GO
DROP TABLE #tExpertiseMEK
GO
DROP TABLE #tCases