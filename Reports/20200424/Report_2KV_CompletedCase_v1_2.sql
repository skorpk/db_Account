USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200307',
		@dateEndReg DATETIME='20200408',
		@dateStartRegRAK DATETIME='20200311',
		@dateEndRegRAK DATETIME='20200409',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=3


SELECT 1 AS TypeDiag,DiagnosisCode INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J12' AND 'J18'

SELECT DiagnosisCode INTO #tDiagOnk FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C81' AND 'C96'

INSERT #tDiag(TypeDiag,DiagnosisCode) VALUES(1,'Z03.8'),(1,'Z22.8'),(1,'Z20.8'),(1,'Z11.5'),(1,'B34.2'),(1,'B33.8'),(1,'U07.1'),(1,'U07.2')
			,(2,'Z20.8'),(2,'B34.2'),(2,'U07.1'),(2,'U07.2')

SELECT l.mcod,l.mcod+' - '+l.LPU_Mcode AS LPU,v.id,v.ColB,v.ColV
INTO #tCol
FROM dbo.vw_sprT001 l CROSS join (VALUES (1,'Всего на медицинскую помощь, из них:','х'),
(2,'Медицинская помощь в условиях круглосуточного стаицонара, всего,в том числе:','случай госпитализации'),
(21,'по профилю "онкология"','случай госпитализации'),
(22,'госпитализации в экстренной форме (без учета профиля "онкология"','случай госпитализации'),
(23,'госпитализации в плановой форме (без учета профиля "онкология"','случай госпитализации'),
(30,'Медицинская помощь в условиях дневного стаицонара, всего,в том числе:','случай лечения'),
(31,'по профилю "онкология"','случай лечения'),
(32,'ЭКО','случай лечения'),
(33,'гемодиализ','случай лечения'),
(34,'иные профили','случай лечения')) v(id,ColB,ColV)




SELECT DISTINCT cc.id,c.id AS rf_idCase,cc.AmountPayment,c.rf_idv008,f.CodeM,c.rf_idV006 AS USL_OK, c.rf_idV002, c.rf_idV014 AS FOR_POM, NULL AS Col_60_3, 3 AS ReportMonth, NULL as IsOnk
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase						
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.AmountPayment>0  AND a.ReportMonth=@reportMonth 
		AND NOT EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DS1 AND d.TypeDiag=1
						UNION ALL
                        SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DS2 AND d.TypeDiag=2
						) AND a.rf_idSMO<>'34' 
						
--CREATE UNIQUE NONCLUSTERED INDEX IX_1 ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY

------------------------------------------------------------------------------------------------------
--считаем случаи по КОВИДу СМП
SELECT DISTINCT c.id AS rf_idCase, 2428.6 AmountPayment,f.CodeM,c.rf_idV006 AS USL_OK
INTO #tCovid
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.AmountPayment=0.0 AND c.rf_idV006=4 AND a.ReportMonth=@reportMonth 
		AND dd.TypeDiagnosis IN(1,3) AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND dd.TypeDiagnosis=REPLACE(d.TypeDiag,2,3)) AND a.rf_idSMO<>'34'		

----------------------------Before March-----------------------------------------------
----------------------------December----------------------------
INSERT #tCases
SELECT DISTINCT cc.id, c.id AS rf_idCase, cc.AmountPayment,c.rf_idv008,f.CodeM,c.rf_idV006 AS USL_OK, c.rf_idV002, c.rf_idV014 AS FOR_POM, NULL AS Col_60_3, a.ReportMonth, NULL as IsOnk
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient
WHERE f.DateRegistration>='20191205' AND f.DateRegistration<'20200120'  AND a.ReportYear=2019 AND a.ReportMonth=12 AND a.rf_idSMO<>'34' 
----------------------------2020 January and February----------------------------
INSERT #tCases
SELECT DISTINCT cc.id,c.id AS rf_idCase, cc.AmountPayment,c.rf_idv008,f.CodeM,c.rf_idV006 AS USL_OK, c.rf_idV002, c.rf_idV014 AS FOR_POM, NULL AS Col_60_3, a.ReportMonth, NULL as IsOnk
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient				
WHERE f.DateRegistration>='20200118' AND f.DateRegistration<'20200311'  AND a.ReportYear=2020 AND a.ReportMonth<3  AND a.rf_idSMO<>'34' 
-----------------------------------------------------------------------------------------------------
----------------------------December 2020 January and February COVID----------------------------
SELECT DISTINCT cc.id,c.id AS rf_idCase, CASE WHEN c.rf_idV006=4 AND cc.AmountPayment=0.0 THEN 2314.0 ELSE cc.AmountPayment END AS AmountPayment,c.rf_idv008,f.CodeM,c.rf_idV006 AS USL_OK, c.rf_idV002, c.rf_idV014 AS FOR_POM, NULL AS Col_60_3, a.ReportMonth, NULL as IsOnk
INTO #tCasesCovid
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
WHERE f.DateRegistration>='20191205' AND f.DateRegistration<'20200120'  AND a.ReportYear=2019  AND a.ReportMonth=12 AND dd.TypeDiagnosis IN(1,3) 
		AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND dd.TypeDiagnosis=REPLACE(d.TypeDiag,2,3)) AND a.rf_idSMO<>'34'

CREATE UNIQUE NONCLUSTERED INDEX IX_3 ON #tCasesCovid(rf_idCase) WITH IGNORE_DUP_KEY

INSERT #tCasesCovid
SELECT DISTINCT cc.id,c.id AS rf_idCase, CASE WHEN c.rf_idV006=4 AND cc.AmountPayment=0.0 THEN 2428.6 ELSE cc.AmountPayment END AS AmountPayment,c.rf_idv008,f.CodeM,c.rf_idV006 AS USL_OK, c.rf_idV002, c.rf_idV014 AS FOR_POM, NULL AS Col_60_3, a.ReportMonth, NULL as IsOnk
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
WHERE f.DateRegistration>='20200118' AND f.DateRegistration<'20200311'  AND a.ReportYear=2020 AND a.ReportMonth<3 AND dd.TypeDiagnosis IN(1,3) 
		AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode AND dd.TypeDiagnosis=REPLACE(d.TypeDiag,2,3)) AND a.rf_idSMO<>'34'
---в онкологию берем гематологию по профилю 12 с диагнозами из C81-C96
UPDATE c SET c.IsOnk=1
FROM #tCases c INNER JOIN dbo.vw_Diagnosis m ON
		c.rf_idCase=m.rf_idCase
				INNER JOIN #tDiagOnk d ON
        m.DS1=d.DiagnosisCode
WHERE c.rf_idV002=12

UPDATE c SET c.IsOnk=1
FROM #tCasesCovid c INNER JOIN dbo.vw_Diagnosis m ON
		c.rf_idCase=m.rf_idCase
				INNER JOIN #tDiagOnk d ON
        m.DS1=d.DiagnosisCode
WHERE c.rf_idV002=12


---простовляем случаю, является ли он гемодиализным
UPDATE c SET c.Col_60_3=1
FROM #tCases c INNER JOIN dbo.t_Meduslugi m ON
		c.rf_idCase=m.rf_idCase
WHERE m.MUGroupCode=60 AND m.MUUnGroupCode=3

UPDATE c SET c.Col_60_3=1
FROM #tCasesCovid c INNER JOIN dbo.t_Meduslugi m ON
		c.rf_idCase=m.rf_idCase
WHERE m.MUGroupCode=60 AND m.MUUnGroupCode=3

-------------------March-------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c 											
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE p.ReportMonth=3
-------------------December-------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>='20191205' AND c.DateRegistration<'20200121'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE p.ReportMonth=12

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCasesCovid p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>='20191205' AND c.DateRegistration<'20200121'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE p.ReportMonth=12
-------------------January and February-------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>='20200118' AND c.DateRegistration<'20200311'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE p.ReportMonth IN(1,2)

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCasesCovid p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>='20200118' AND c.DateRegistration<'20200311'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE p.ReportMonth IN(1,2)

----------------------------------

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCovid p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
----------------March-----------------
;WITH cte
AS(
SELECT CodeM,AmountPayment FROM dbo.t_AdditionalAccounts202003 WHERE ReportMonth=@reportMonth AND ReportYear=@reportYear
UNION ALL
SELECT CodeM,AmountPayment FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth FROM  #tCases where ReportMonth=@reportMonth) t 
UNION ALL
SELECT CodeM,-AmountPayment FROM #tCovid 
)
SELECT 1 AS idRow,cte.CodeM,SUM(cte.AmountPayment) as Col2 ,3 AS ReportMonth,CAST(0.0 AS decimal(15,2)) AS Col1,CAST(0.0 AS decimal(15,2)) AS Col1_1
INTO #total 
FROM cte GROUP BY cte.CodeM
----------------December-----------------
;WITH cte
AS(
SELECT CodeM,AmountPayment FROM dbo.t_AdditionalAccounts202003 WHERE ReportMonth<@reportMonth AND ReportYear=@reportYear
UNION ALL
SELECT CodeM,AmountPayment FROM dbo.t_AdditionalAccounts202003 WHERE ReportMonth=12 AND ReportYear=2019
UNION ALL
SELECT CodeM,AmountPayment FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth FROM  #tCases  WHERE ReportMonth<>@reportMonth) t
)
INSERT #total SELECT 1 AS idRow,cte.CodeM,0.0 AS Col2 ,1,SUM(cte.AmountPayment) AS Col1,0.0 AS Col1_1 FROM cte GROUP BY cte.CodeM

-------------------------COVID------------------------------------
---2 - ReportMont is number of column
INSERT #total SELECT 1 AS idRow,CodeM,0.0 as Col2, 2,0.0 AS Col1,SUM(AmountPayment) AS Col1_1 FROM #tCasesCovid GROUP BY CodeM

-------------------------------------------------March-------------------------------------------
INSERT #total SELECT 2 ,CodeM,SUM(AmountPayment) AS Col2 ,ReportMonth ,0.0 AS Col1,0.0 AS Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM FROM  #tCases) t WHERE ReportMonth=@reportMonth and USL_OK=1  GROUP BY CodeM,ReportMonth
INSERT #total SELECT 21,CodeM,SUM(AmountPayment) AS Col2, ReportMonth ,0.0 AS Col1,0.0 AS Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCases) t WHERE ReportMonth=@reportMonth and USL_OK=1  AND (rf_idV002 IN(18,60,76) OR IsOnk=1 ) GROUP BY CodeM,ReportMonth
INSERT #total SELECT 22,CodeM,SUM(AmountPayment) AS Col2, ReportMonth ,0.0 AS Col1,0.0 AS Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCases) t WHERE ReportMonth=@reportMonth and USL_OK=1  AND (rf_idV002 not IN(18,60,76) And IsOnk IS NULL) AND FOR_POM=1 GROUP BY CodeM,ReportMonth
INSERT #total SELECT 23,CodeM,SUM(AmountPayment) AS Col2, ReportMonth ,0.0 AS Col1,0.0 AS Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCases) t WHERE ReportMonth=@reportMonth and USL_OK=1  AND (rf_idV002 not IN(18,60,76) And IsOnk IS NULL) AND FOR_POM=3 GROUP BY CodeM,ReportMonth
INSERT #total SELECT 30,CodeM,SUM(AmountPayment) AS Col2, ReportMonth ,0.0 AS Col1,0.0 AS Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCases) t WHERE ReportMonth=@reportMonth and USL_OK=2  GROUP BY CodeM,ReportMonth
INSERT #total SELECT 31,CodeM,SUM(AmountPayment) AS Col2, ReportMonth ,0.0 AS Col1,0.0 AS Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM, IsOnk FROM  #tCases) t WHERE ReportMonth=@reportMonth and USL_OK=2  AND (rf_idV002 IN(18,60,76) OR t.IsOnk=1 ) GROUP BY CodeM,ReportMonth
INSERT #total SELECT 32,CodeM,SUM(AmountPayment) AS Col2, ReportMonth ,0.0 AS Col1,0.0 AS Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCases) t WHERE ReportMonth=@reportMonth and USL_OK=2  AND rf_idV002 =137 GROUP BY CodeM,ReportMonth
INSERT #total SELECT 33,CodeM,SUM(AmountPayment) AS Col2, ReportMonth ,0.0 AS Col1,0.0 AS Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCases) t WHERE ReportMonth=@reportMonth and USL_OK=2  AND Col_60_3=1 GROUP BY CodeM,ReportMonth

INSERT #total
SELECT 34,t.CodeM,t.Col2-SUM(CASE WHEN t1.idRow>30 AND t1.idRow<34 then t1.Col2 ELSE 0.0 end),3,0.0 AS Col1,0.0 AS Col1_1
FROM #total t left JOIN #total t1 ON
		t.CodeM=ISNULL(t1.CodeM,t.CodeM)
		AND t.ReportMonth = ISNULL(t1.ReportMonth,t.ReportMonth)
WHERE t.idRow=30 AND t.ReportMonth=@reportMonth
GROUP BY t.CodeM,t.Col2

--------------------------------Before-----------------------------------------
INSERT #total SELECT 2 ,CodeM,0.0 AS Col2 ,1 as ReportMonth,SUM(AmountPayment) AS Col1,0.0 AS Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM FROM  #tCases) t WHERE ReportMonth<>@reportMonth and USL_OK=1 GROUP BY CodeM
INSERT #total SELECT 21,CodeM,0.0 AS Col2, 1 as ReportMonth,SUM(AmountPayment) AS Col1,0.0 AS Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCases) t WHERE ReportMonth<>@reportMonth and USL_OK=1 AND (rf_idV002 IN(18,60,76) OR t.IsOnk=1 ) GROUP BY CodeM
INSERT #total SELECT 22,CodeM,0.0 AS Col2, 1 as ReportMonth,SUM(AmountPayment) AS Col1,0.0 AS Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCases) t WHERE ReportMonth<>@reportMonth and USL_OK=1 AND (rf_idV002 not IN(18,60,76) And IsOnk IS NULL) AND FOR_POM=1 GROUP BY CodeM
INSERT #total SELECT 23,CodeM,0.0 AS Col2, 1 as ReportMonth,SUM(AmountPayment) AS Col1,0.0 AS Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCases) t WHERE ReportMonth<>@reportMonth and USL_OK=1 AND (rf_idV002 not IN(18,60,76) And IsOnk IS NULL) AND FOR_POM=3 GROUP BY CodeM
INSERT #total SELECT 30,CodeM,0.0 AS Col2, 1 as ReportMonth,SUM(AmountPayment) AS Col1,0.0 AS Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCases) t WHERE ReportMonth<>@reportMonth and USL_OK=2 GROUP BY CodeM
INSERT #total SELECT 31,CodeM,0.0 AS Col2, 1 as ReportMonth,SUM(AmountPayment) AS Col1,0.0 AS Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCases) t WHERE ReportMonth<>@reportMonth and USL_OK=2 AND (rf_idV002 IN(18,60,76) OR t.IsOnk=1) GROUP BY CodeM
INSERT #total SELECT 32,CodeM,0.0 AS Col2, 1 as ReportMonth,SUM(AmountPayment) AS Col1,0.0 AS Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCases) t WHERE ReportMonth<>@reportMonth and USL_OK=2 AND rf_idV002 =137 GROUP BY CodeM
INSERT #total SELECT 33,CodeM,0.0 AS Col2, 1 as ReportMonth,SUM(AmountPayment) AS Col1,0.0 AS Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCases) t WHERE ReportMonth<>@reportMonth and USL_OK=2 AND Col_60_3=1 GROUP BY CodeM

INSERT #total
SELECT 34,t.CodeM,0.0, 1, t.Col1-SUM(CASE WHEN t1.idRow>30 AND t1.idRow<34 then t1.Col1 ELSE 0.0 end) AS Col1,0.0 AS Col1_1
FROM #total t left JOIN #total t1 ON
		t.CodeM=ISNULL(t1.CodeM,t.CodeM)
		AND t.ReportMonth = ISNULL(t1.ReportMonth,t.ReportMonth)
WHERE t.idRow=30  AND t.ReportMonth=1
GROUP BY t.CodeM,t.Col1
--------------------------------Covid-----------------------------------------
INSERT #total SELECT 2 ,CodeM,0.0 AS Col2 ,2 as ReportMonth,0.0 as Col1,SUM(AmountPayment) as Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM FROM  #tCasesCovid) t WHERE  USL_OK=1 GROUP BY CodeM
INSERT #total SELECT 21,CodeM,0.0 AS Col2, 2 as ReportMonth,0.0 as Col1,SUM(AmountPayment) as Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCasesCovid) t WHERE  USL_OK=1 AND (rf_idV002 IN(18,60,76) OR t.IsOnk=1 )GROUP BY CodeM
INSERT #total SELECT 22,CodeM,0.0 AS Col2, 2 as ReportMonth,0.0 as Col1,SUM(AmountPayment) as Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCasesCovid) t WHERE  USL_OK=1 AND (rf_idV002 not IN(18,60,76) And IsOnk IS NULL) AND FOR_POM=1 GROUP BY CodeM
INSERT #total SELECT 23,CodeM,0.0 AS Col2, 2 as ReportMonth,0.0 as Col1,SUM(AmountPayment) as Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCasesCovid) t WHERE  USL_OK=1 AND (rf_idV002 not IN(18,60,76) And IsOnk IS NULL) AND FOR_POM=3 GROUP BY CodeM
INSERT #total SELECT 30,CodeM,0.0 AS Col2, 2 as ReportMonth,0.0 as Col1,SUM(AmountPayment) as Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCasesCovid) t WHERE  USL_OK=2 GROUP BY CodeM
INSERT #total SELECT 31,CodeM,0.0 AS Col2, 2 as ReportMonth,0.0 as Col1,SUM(AmountPayment) as Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCasesCovid) t WHERE  USL_OK=2 AND (rf_idV002 IN(18,60,76) OR t.IsOnk=1) GROUP BY CodeM
INSERT #total SELECT 32,CodeM,0.0 AS Col2, 2 as ReportMonth,0.0 as Col1,SUM(AmountPayment) as Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCasesCovid) t WHERE  USL_OK=2 AND rf_idV002 =137 GROUP BY CodeM
INSERT #total SELECT 33,CodeM,0.0 AS Col2, 2 as ReportMonth,0.0 as Col1,SUM(AmountPayment) as Col1_1  FROM (SELECT DISTINCT id,CodeM,AmountPayment,ReportMonth,USL_OK,rf_idV002,Col_60_3,For_POM,IsOnk FROM  #tCasesCovid) t WHERE  USL_OK=2 AND Col_60_3=1 GROUP BY CodeM

INSERT #total
SELECT 34,t.CodeM, 0.0, 2 , 0.0, t.Col1_1-SUM(CASE WHEN t1.idRow>30 AND t1.idRow<34 then t1.Col1_1 ELSE 0.0 end)
FROM #total t left JOIN #total t1 ON
		t.CodeM=ISNULL(t1.CodeM,t.CodeM)
		AND t.ReportMonth = ISNULL(t1.ReportMonth,t.ReportMonth)
WHERE t.idRow=30 AND t.ReportMonth=2
GROUP BY t.CodeM,t.Col1_1



;WITH cteSum
AS(
SELECT l.mcod,t.idRow,CAST(0.0 AS Money) AS Col0
	,cast(SUM(CASE WHEN t.ReportMonth=1 THEN t.Col1 ELSE 0.0 END) AS MONEY) AS Col1
	,cast(SUM(CASE WHEN t.ReportMonth=2 THEN t.Col1_1 ELSE 0.0 END) AS MONEY) AS Col1_1
	,cast(SUM(CASE WHEN t.ReportMonth=3 THEN t.Col2 ELSE 0.0 END) AS MONEY) AS Col2
FROM #total t INNER JOIN dbo.vw_sprT001 l ON
        t.CodeM=l.CodeM
GROUP BY l.mcod,t.idRow
)
SELECT distinct c.mcod,c.LPU,c.ColB,c.ColV,c.id,ISNULL(s.Col0,0.0),ISNULL(s.Col1,0.0),ISNULL(s.Col1_1,0.0),ISNULL(s.Col2,0.0)
FROM #tCol c INNER JOIN cteSum ss ON
		c.mcod=ss.mcod 
			LEFT JOIN cteSum s on
		c.id=s.idRow
		AND c.mcod=s.mcod
ORDER BY c.mcod,c.id



GO
DROP TABLE #tCol
GO
DROP TABLE #tDiag
GO
DROP TABLE #tDiagOnk
GO
DROP TABLE #tCases
GO
DROP TABLE #total
GO
DROP TABLE #tCovid
GO 
DROP TABLE #tCasesCovid