USE AccountOMS
GO
DECLARE @dateStart DATETIME='20180101',	--всегда с начало года
		@dateEnd DATETIME='20190311',
		@reportYear SMALLINT=2018,
		@dateEndAkt DATETIME='20190311'		

SELECT DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'	
AND MainDS NOT IN('C81','C82','C83','C84','C85','C86','C88','C90', 'C91','C92','C93','C94','C95','C96')


SELECT c.id AS rf_idCase, c.AmountPayment,ps.ENP,c.rf_idV010 AS IDSP, c.AmountPayment AS AmountPay ,a.ReportYear
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN #tD dd ON
			d.DS1=dd.DiagnosisCode     										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient  					   					  					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=3 AND f.TypeFile='H'

INSERT #tCases 
SELECT c.id AS rf_idCase, cc.AmountPayment,ps.ENP,c.rf_idV010 AS IDSP,cc.AmountPayment AS AmountPay,a.ReportYear
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN #tD dd ON
			d.DS1=dd.DiagnosisCode     										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient  					   					  					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2019 AND c.rf_idV006=3 AND a.ReportMonth<3 AND f.TypeFile='H'
		
UPDATE p SET p.AmountPay=p.AmountPay-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndAkt	 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

--SELECT COUNT(DISTINCT rf_idCase), IDSP FROM #tCases WHERE AmountPay>0 AND IDSP NOT IN(4,12,29,30,41) AND ReportYear=2018 GROUP BY  IDSP 
--SELECT COUNT(rf_idCase), IDSP FROM #tCases WHERE AmountPay>0 AND IDSP NOT IN(4,12,29,30,41) AND ReportYear=2019 GROUP BY  IDSP 

SELECT COUNT(DISTINCT CASE WHEN ReportYear=2018 then ENP ELSE NULL end) AS Col1
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 then ENP ELSE NULL end) AS Col2
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2018 then rf_idCase ELSE NULL end) AS Col3
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 then rf_idCase ELSE NULL end) AS Col4
	   ,cast(sum(CASE WHEN ReportYear=2018 then AmountPay ELSE 0.0 end) as money) AS Col5
	   ,cast(sum(CASE WHEN ReportYear=2019 then AmountPay ELSE 0.0 end) as money) AS Col6
	   --------------------------------2----------------------------------------
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2018  and IDSP=30 then ENP ELSE NULL end) AS Col7
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 and IDSP=30 then ENP ELSE NULL end) AS Col8
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2018 and IDSP=30 then rf_idCase ELSE NULL end) AS Col9
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 and IDSP=30 then rf_idCase ELSE NULL end) AS Col10
	   ,cast(sum(CASE WHEN ReportYear=2018 AND IDSP=30 then AmountPay ELSE 0.0 end) as money) AS Col11
	   ,cast(sum(CASE WHEN ReportYear=2019 AND IDSP=30 then AmountPay ELSE 0.0 end) as money) AS Col12
	     --------------------------------3----------------------------------------
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2018  and IDSP in(12,29,41) then ENP ELSE NULL end) AS Col13
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 and IDSP in(12,29,41) then ENP ELSE NULL end) AS Col14
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2018 and IDSP in(12,29,41) then rf_idCase ELSE NULL end) AS Col15
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 and IDSP in(12,29,41) then rf_idCase ELSE NULL end) AS Col116
	   ,cast(sum(CASE WHEN ReportYear=2018 AND IDSP in(12,29,41) then AmountPay ELSE 0.0 end) as money) AS Col17
	   ,cast(sum(CASE WHEN ReportYear=2019 AND IDSP in(12,29,41) then AmountPay ELSE 0.0 end) as money) AS Col18
	      --------------------------------4----------------------------------------
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2018  and IDSP=4 then ENP ELSE NULL end) AS Col7
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 and IDSP=4 then ENP ELSE NULL end) AS Col8
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2018 and IDSP=4 then rf_idCase ELSE NULL end) AS Col9
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 and IDSP=4 then rf_idCase ELSE NULL end) AS Col10
	   ,cast(sum(CASE WHEN ReportYear=2018 AND IDSP=4 then AmountPay ELSE 0.0 end) as money) AS Col11
	   ,cast(sum(CASE WHEN ReportYear=2019 AND IDSP=4 then AmountPay ELSE 0.0 end) as money) AS Col12
FROM #tCases
WHERE AmountPay>0 
go

DROP TABLE #tCases
DROP TABLE #tD