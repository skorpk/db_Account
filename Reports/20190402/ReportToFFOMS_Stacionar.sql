USE AccountOMS
GO
DECLARE @dateStart DATETIME='20180101',	--всегда с начало года
		@dateEnd DATETIME='20190311',
		@reportYear SMALLINT=2018,
		@dateEndAkt DATETIME='20190311'		

SELECT DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'	
AND MainDS NOT IN('C81','C82','C83','C84','C85','C86','C88','C90', 'C91','C92','C93','C94','C95','C96')


SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,ps.ENP,m.MES, c.AmountPayment AS AmountPay ,a.ReportYear
		, CASE WHEN m.MES IN('1034.0','1146.0','1147.0','1148.0','1149.0','1150.0','1151.0','1152.0','1153.0','1154.0','1155.0') THEN 2 
				WHEN m.mes IN('1160.0','1161.0','1162.0') THEN 3 
				WHEN f.CodeM IN('103001','101004','104401','185905','101001') and mm.MUSurgery='A16' THEN 1 
				ELSE 5 END AS USL_TIP
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
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase		
					left JOIN (SELECT DISTINCT rf_idCase,  'A16' AS MUSurgery FROM dbo.t_Meduslugi) mm ON
			c.id=mm.rf_idCase													   					  					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND f.TypeFile='H' AND c.rf_idV010<>32 
----------------------------------ВМП 2018---------------------------------------
INSERT #tCases
SELECT c.id AS rf_idCase, c.AmountPayment,ps.ENP,m.MES, c.AmountPayment AS AmountPay ,a.ReportYear
		, CASE WHEN mm.MUGroupCode=1 AND mm.MUUnGroupCode=12 AND mm.MUCode=356 THEN 2 ELSE 1 END AS USL_TIP
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
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
					INNER JOIN dbo.t_Meduslugi mm ON
			c.id=mm.rf_idCase										   					  					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND f.TypeFile='H' AND c.rf_idV010=32
-----------------------------------------2019----------------------------------------
INSERT #tCases 
SELECT c.id AS rf_idCase, cc.AmountPayment,ps.ENP,m.MES,cc.AmountPayment AS AmountPay,a.ReportYear, ISNULL(u.rf_idN013,5)
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
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase 
					left JOIN dbo.t_ONK_USL u ON
			c.id=u.rf_idCase					   					  					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2019 AND c.rf_idV006=1 AND a.ReportMonth<3 AND f.TypeFile='H' AND c.rf_idV010<>32
----------------------------------------2019 ВМП-----
INSERT #tCases
SELECT c.id AS rf_idCase, c.AmountPayment,ps.ENP,m.MES, c.AmountPayment AS AmountPay ,a.ReportYear
		, CASE WHEN mm.MUGroupCode=1 AND mm.MUUnGroupCode=12 AND mm.MUCode=356 THEN 2 ELSE 1 END AS USL_TIP
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
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
					INNER JOIN dbo.t_Meduslugi mm ON
			c.id=mm.rf_idCase										   					  					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2019 AND c.rf_idV006=1 AND a.ReportMonth<3 AND f.TypeFile='H' AND c.rf_idV010=32


		
UPDATE p SET p.AmountPay=p.AmountPay-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndAkt	 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
/*
------------------------------проверка----------------------------------
SELECT rf_idCase,'ONK' AS TypeTbale INTO #t260 FROM dbo.t_260order_ONK WHERE USL_OK=1
UNION all
SELECT rf_idCase ,'VMP' FROM dbo.t_260order_VMP WHERE USL_OK=1

SELECT * FROM #tCases c WHERE c.ReportYear=2019 AND NOT EXISTS(SELECT 1 FROM #t260 WHERE rf_idCase=c.rf_idCase)

SELECT * INTO #tt FROM #t260 t260 WHERE NOT EXISTS(SELECT 1 FROM #tCases WHERE ReportYear=2019 AND rf_idCase=t260.rf_idCase)

SELECT o.DS1, COUNT(o.rf_idCase)
FROM dbo.t_260order_ONK o INNER JOIN #tt t ON
			o.rf_idCase = t.rf_idCase
						INNER JOIN dbo.t_ONK_USL u ON
			o.rf_idCase=u.rf_idCase 
GROUP BY o.DS1
ORDER BY o.DS1

--SELECT DISTINCT o.rf_idCase,o.DS1 
--FROM dbo.t_260order_ONK o INNER JOIN #tt t ON
--			o.rf_idCase = t.rf_idCase						
--ORDER BY o.DS1

SELECT DISTINCT o.DS1,o.rf_idCase, ss.DS1_T
FROM dbo.t_260order_ONK o INNER JOIN #tt t ON
			o.rf_idCase = t.rf_idCase
							INNER JOIN dbo.t_ONK_SL ss ON
			o.rf_idCase=ss.rf_idCase                          
WHERE NOT EXISTS(SELECT 1 FROM dbo.t_ONK_USL u WHERE rf_idCase=t.rf_idCase )
ORDER BY DS1_T			                

*/
----смотрим, есть ли двойные случаи
SELECT cc.rf_idRecordCasePatient
FROM #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
				INNER JOIN dbo.t_Case cc ON
		c.rf_idCase=cc.id              
				INNER JOIN dbo.t_Case ccc ON
		cc.rf_idRecordCasePatient=ccc.rf_idRecordCasePatient
WHERE m.MES='st19.038' AND AmountPay>0
GROUP BY cc.rf_idRecordCasePatient
HAVING COUNT(*)>1


SELECT COUNT(DISTINCT CASE WHEN ReportYear=2018 then ENP ELSE NULL end) AS Col1
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 then ENP ELSE NULL end) AS Col2
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2018 then rf_idCase ELSE NULL end) AS Col3
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 then rf_idCase ELSE NULL end) AS Col4
	   ,cast(sum(CASE WHEN ReportYear=2018 then AmountPay ELSE 0.0 end) as money) AS Col5
	   ,cast(sum(CASE WHEN ReportYear=2019 then AmountPay ELSE 0.0 end) as money) AS Col6
	   ------------------------------2----------------------------------------------
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2018 AND USL_TIP=2 then ENP ELSE NULL end) AS Col7
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 AND USL_TIP=2 then ENP ELSE NULL end) AS Col8
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2018 AND USL_TIP=2 then rf_idCase ELSE NULL end) AS Col9
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 AND USL_TIP=2 then rf_idCase ELSE NULL end) AS Col10
	   ,cast(sum(CASE WHEN ReportYear=2018 AND USL_TIP=2 then AmountPay ELSE 0.0 end) as money) AS Col11
	   ,cast(sum(CASE WHEN ReportYear=2019 AND USL_TIP=2 then AmountPay ELSE 0.0 end) as money) AS Col12
	   ------------------------------3----------------------------------------------
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2018 AND USL_TIP=3 then ENP ELSE NULL end) AS Col13
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 AND USL_TIP=3 then ENP ELSE NULL end) AS Col14
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2018 AND USL_TIP=3 then rf_idCase ELSE NULL end) AS Col15
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 AND USL_TIP=3 then rf_idCase ELSE NULL end) AS Col16
	   ,cast(sum(CASE WHEN ReportYear=2018 AND USL_TIP=3 then AmountPay ELSE 0.0 end) as money) AS Col17
	   ,cast(sum(CASE WHEN ReportYear=2019 AND USL_TIP=3 then AmountPay ELSE 0.0 end) as money) AS Col18
	   ------------------------------4----------------------------------------------
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2018 AND USL_TIP=1 then ENP ELSE NULL end) AS Col19
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 AND USL_TIP=1 then ENP ELSE NULL end) AS Col20
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2018 AND USL_TIP=1 then rf_idCase ELSE NULL end) AS Col21
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 AND USL_TIP=1 then rf_idCase ELSE NULL end) AS Col22
	   ,cast(sum(CASE WHEN ReportYear=2018 AND USL_TIP=1 then AmountPay ELSE 0.0 end) as money) AS Col23
	   ,cast(sum(CASE WHEN ReportYear=2019 AND USL_TIP=1 then AmountPay ELSE 0.0 end) as money) AS Col24
	   ------------------------------5----------------------------------------------
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 AND USL_TIP=4 then ENP ELSE NULL end) AS Col25
	   ,COUNT(DISTINCT CASE WHEN ReportYear=2019 AND USL_TIP=4 then rf_idCase ELSE NULL end) AS Col26
	   ,cast(sum(CASE WHEN ReportYear=2019 AND USL_TIP=4 then AmountPay ELSE 0.0 end) as money) AS Col27s
FROM #tCases
WHERE AmountPay>0

go

DROP TABLE #tCases
DROP TABLE #tD
--DROP TABLE #t260
--DROP TABLE #tt