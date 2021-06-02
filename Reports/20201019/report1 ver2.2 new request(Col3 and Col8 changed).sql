USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20201011',
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME=GETDATE(),
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=10

declare @firstDayNextMonth date
SET @firstDayNextMonth=DATEADD(MONTH,1,'2020'+RIGHT('0'+CAST(@reportMonth-1 AS VARCHAR(2)),2)+'01')

-----------------------только терапия. С.Б.Никитенко переписала несколько групп.Делаем все терапевтические
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,c.rf_idV006 AS USL_OK,c.rf_idRecordCasePatient,pp.rf_idV005 AS Sex, d.flag,f.TypeFile,@firstDayNextMonth AS dd, 1 AS TypeDs
	,@reportYear AS ReportYear
INTO #t
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
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN oms_nsi.dbo.tmp_DS2report202007 d ON
             dd.DiagnosisCode=d.КОД					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<@reportMonth  AND  a.rf_idSMO<>'34'  AND dd.TypeDiagnosis=1 AND d.flag<28

--CREATE UNIQUE NONCLUSTERED INDEX IXCase ON #t(rf_idCase,flag,ENP) WITH IGNORE_DUP_KEY

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,c.rf_idV006 AS USL_OK,c.rf_idRecordCasePatient,pp.rf_idV005 AS Sex, d.flag,f.TypeFile,@firstDayNextMonth AS dd,2
		,@reportYear AS ReportYear
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
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase																
					INNER JOIN oms_nsi.dbo.tmp_DS2report202007 d ON
			dd.DiagnosisCode=d.КОД
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<@reportMonth AND  a.rf_idSMO<>'34' AND f.TypeFile='F' AND dd.TypeDiagnosis<>1 AND d.flag<28


INSERT #t
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age,c.rf_idV006 AS USL_OK,c.rf_idRecordCasePatient,pp.rf_idV005 AS Sex, d.flag,f.TypeFile,@firstDayNextMonth AS dd,2
		,@reportYear AS ReportYear
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
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase					
					INNER JOIN oms_nsi.dbo.tmp_DS2report202007 d ON
             dd.DiagnosisCode=d.КОД											
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<@reportMonth AND  a.rf_idSMO<>'34' AND f.TypeFile='F' AND d.flag<28

DELETE FROM #t WHERE Age<18
--------------------------------------Last year--------------------------------------------------------------------------------------------------------
INSERT #t
SELECT rf_idCase,AmountPayment,CodeM,ENP,Age,USL_OK,rf_idRecordCasePatient,Sex,flag,TypeFile,@firstDayNextMonth ,TypeDs,ReportYear
FROM t_CaseDN_2019 WHERE flag<28


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
-----------------------------определение страховой принадлежности--------------------
ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

UPDATE e SET PID=p.PID
FROM #t e INNER JOIN PolicyRegister.dbo.HISTENP p ON
		e.enp=p.ENP
WHERE e.pid IS null


EXEC Utility.dbo.sp_GetIdPolisLPU

CREATE NONCLUSTERED INDEX IX_Temp1
ON #t ([USL_OK],[TypeFile],[TypeDs],[AmountPayment],[sid])
INCLUDE ([rf_idCase],[ENP],[Age],[Sex],[flag])

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #tCase
(Col1 INT NOT NULL DEFAULT 0,Col3 INT NOT NULL DEFAULT 0,Col4 INT NOT NULL DEFAULT 0,Col5 INT NOT NULL DEFAULT 0,Col6 INT NOT NULL DEFAULT 0,Col7 INT NOT NULL DEFAULT 0,
Col8 INT NOT NULL DEFAULT 0,Col9 INT NOT NULL DEFAULT 0,Col10 INT NOT NULL DEFAULT 0,Col11 INT NOT NULL DEFAULT 0,Col12 INT NOT NULL DEFAULT 0,Col13 INT NOT NULL DEFAULT 0,Col14 INT NOT NULL DEFAULT 0,
Col15 INT NOT NULL DEFAULT 0,Col16 INT NOT NULL DEFAULT 0,Col17 INT NOT NULL DEFAULT 0,Col18 INT NOT NULL DEFAULT 0,Col19 INT NOT NULL DEFAULT 0,Col20 INT NOT NULL DEFAULT 0,Col21 INT NOT NULL DEFAULT 0,
Col22 INT NOT NULL DEFAULT 0,Col23 INT NOT NULL DEFAULT 0,Col24 INT NOT NULL DEFAULT 0,Col25 INT NOT NULL DEFAULT 0,Col26 INT NOT NULL DEFAULT 0,Col27 INT NOT NULL DEFAULT 0,Col28 INT NOT NULL DEFAULT 0,
Col29 INT NOT NULL DEFAULT 0,Col30 INT NOT NULL DEFAULT 0,Col31 INT NOT NULL DEFAULT 0,Col32 INT NOT NULL DEFAULT 0,Col33 INT NOT NULL DEFAULT 0,Col34 INT NOT NULL DEFAULT 0,Col35 INT NOT NULL DEFAULT 0,
Col36 INT NOT NULL DEFAULT 0,Col37 INT NOT NULL DEFAULT 0,Col38 INT NOT NULL DEFAULT 0,Col39 INT NOT NULL DEFAULT 0,Col40 INT NOT NULL DEFAULT 0,Col41 INT NOT NULL DEFAULT 0,Col42 INT NOT NULL DEFAULT 0,
Col43 INT NOT NULL DEFAULT 0,Col44 INT NOT NULL DEFAULT 0,Col45 INT NOT NULL DEFAULT 0,Col46 INT NOT NULL DEFAULT 0,Col47 INT NOT NULL DEFAULT 0,Col48 INT NOT NULL DEFAULT 0,Col49 INT NOT NULL DEFAULT 0,
Col50 INT NOT NULL DEFAULT 0,Col51 INT NOT NULL DEFAULT 0,Col52 INT NOT NULL DEFAULT 0,Col53 INT NOT NULL DEFAULT 0,Col54 INT NOT NULL DEFAULT 0,Col55 INT NOT NULL DEFAULT 0,Col56 INT NOT NULL DEFAULT 0,
Col57 INT NOT NULL DEFAULT 0,Col58 INT NOT NULL DEFAULT 0,Col59 INT NOT NULL DEFAULT 0,Col60 INT NOT NULL DEFAULT 0,Col61 INT NOT NULL DEFAULT 0,Col62 INT NOT NULL DEFAULT 0,Col63 INT NOT NULL DEFAULT 0,
Col64 INT NOT NULL DEFAULT 0,Col65 INT NOT NULL DEFAULT 0,Col66 INT NOT NULL DEFAULT 0,Col67 INT NOT NULL DEFAULT 0)

PRINT('create #tCase')
-------------------------------------3----------------
;WITH cteCol4
AS(
SELECT DISTINCT d.ENP,d.flag,d.Age,d.sex_ENP AS Sex
FROM dbo.DNPersons202007 d 
WHERE NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.PEOPLE p WHERE p.ENP=d.enp AND ISNULL(p.DS,'22220101')<@firstDayNextMonth ) AND d.flag<28
UNION ALL
SELECT DISTINCT enp,flag,t.Age,sex
FROM #t t 
WHERE t.sid IS NOT NULL AND t.AmountPayment>0 AND t.USL_OK<4 
)
INSERT #tCase(Col1, Col3,col4,col5,col6,col7)
SELECT flag,COUNT(DISTINCT enp) AS Col3
		,COUNT(distinct CASE WHEN c.Sex=1 AND age<65 THEN c.ENP ELSE NULL end) AS Col4
		,COUNT(distinct CASE WHEN c.Sex=1 AND age>=65 THEN c.ENP ELSE NULL end) AS Col5
		-------distinct ---Женщины--------------------------------------------------
		,COUNT(distinct CASE WHEN c.Sex=2 AND age< 60 THEN c.ENP ELSE NULL end) AS Col6
		,COUNT(distinct CASE WHEN c.Sex=2 AND age>=60 THEN c.ENP ELSE NULL end) AS Col7
FROM cteCol4 c GROUP BY flag
--------------------------9-12-----------------Edited 24/08/2020

;WITH cteCol9
AS(
SELECT DISTINCT enp,flag,t.Age,sex
FROM #t t 
WHERE t.sid IS NOT NULL AND t.USL_OK<4 AND t.AmountPayment>0 AND t.ReportYear=@reportYear
		AND NOT EXISTS(SELECT 1 FROM dbo.DNPersons202007 d WHERE d.enp=t.ENP AND d.flag=t.flag
						UNION ALL 
						SELECT 1 FROM #t d WHERE ReportYear=(@reportYear-1) AND d.ENP=t.ENP AND d.flag=t.flag
					   ) 
)
INSERT #tCase(Col1, Col8,col9,col10,col11,col12)
SELECT flag,COUNT(DISTINCT enp) AS Col8
		,COUNT(distinct CASE WHEN c.Sex=1 AND age<65 THEN c.ENP ELSE NULL end) AS Col9
		,COUNT(distinct CASE WHEN c.Sex=1 AND age>=65 THEN c.ENP ELSE NULL end) AS Col10
		----------Женщины--------------------------------------------------
		,COUNT(distinct CASE WHEN c.Sex=2 AND age< 60 THEN c.ENP ELSE NULL end) AS Col11
		,COUNT(distinct CASE WHEN c.Sex=2 AND age>=60 THEN c.ENP ELSE NULL end) AS Col12
FROM cteCol9 c GROUP BY flag


-------------------------------------8----------------
;WITH cteCol4
AS(
SELECT DISTINCT d.ENP,d.flag,d.Age,d.sex_ENP AS Sex
FROM dbo.DNPersons202007 d 
WHERE NOT EXISTS(SELECT 1 FROM PolicyRegister.dbo.PEOPLE p WHERE p.ENP=d.enp AND ISNULL(p.DS,'22220101')<@firstDayNextMonth ) AND d.flag<28
UNION ALL
SELECT DISTINCT enp,flag,t.Age,sex
FROM #t t INNER JOIN dbo.t_PurposeOfVisit p on
		t.rf_idCase=p.rf_idCase
WHERE t.sid IS NOT NULL AND t.TypeFile='H' AND p.rf_idV025='1.3' AND t.USL_OK=3 AND p.DN IN(1,2) AND t.AmountPayment>0 AND t.ReportYear=@reportYear
UNION ALL
SELECT DISTINCT enp,flag,t.Age,t.Sex
FROM #t t INNER JOIN dbo.t_Case p on
		t.rf_idCase=p.id
WHERE t.sid IS NOT NULL AND t.TypeFile='F' AND t.USL_OK=3 AND p.IsNeedDisp IN(1,2) AND t.TypeDs=1 AND t.AmountPayment>0 AND t.ReportYear=@reportYear
UNION ALL
SELECT DISTINCT enp,t.flag,t.Age,t.Sex
FROM  dbo.t_DS2_Info p 	INNER JOIN oms_nsi.dbo.tmp_DS2report202007 d ON
             p.DiagnosisCode=d.КОД	
			 INNER JOIN #t t ON
           p.rf_idCase=t.rf_idCase
		   AND d.flag=t.flag
WHERE t.sid IS NOT NULL AND t.TypeFile='F' AND t.USL_OK=3 AND p.IsNeedDisp IN(1,2) AND t.TypeDs=2 AND t.AmountPayment>0 AND t.ReportYear=@reportYear
)
INSERT #tCase(Col1, Col18,col19,col20,col21,col22)
SELECT flag,COUNT(DISTINCT enp) AS Col3
		,COUNT(distinct CASE WHEN c.Sex=1 AND age<65 THEN c.ENP ELSE NULL end) AS Col4
		,COUNT(distinct CASE WHEN c.Sex=1 AND age>=65 THEN c.ENP ELSE NULL end) AS Col5
		-------distinct ---Женщины--------------------------------------------------
		,COUNT(distinct CASE WHEN c.Sex=2 AND age< 60 THEN c.ENP ELSE NULL end) AS Col6
		,COUNT(distinct CASE WHEN c.Sex=2 AND age>=60 THEN c.ENP ELSE NULL end) AS Col7
FROM cteCol4 c GROUP BY flag
-------------------------------19-----------------------------------------

-----------------------------------------------------23-27--------------------------------------------------------------------------
----пересчет по новому-------

;WITH cteCol9
AS(
SELECT DISTINCT enp,flag,t.Age,sex
FROM #t t INNER JOIN dbo.t_PurposeOfVisit p on
		t.rf_idCase=p.rf_idCase
WHERE t.sid IS NOT NULL AND t.TypeFile='H' AND p.rf_idV025='1.3' AND t.USL_OK=3 AND p.DN =2 AND NOT EXISTS(SELECT 1 FROM dbo.DNPersons202007 d WHERE d.enp=t.ENP AND d.flag=t.flag) AND t.AmountPayment>0 AND t.ReportYear=@reportYear
UNION ALL
SELECT DISTINCT enp,flag,t.Age,t.Sex
FROM #t t INNER JOIN dbo.t_Case p on
		t.rf_idCase=p.id
WHERE t.sid IS NOT NULL AND t.TypeFile='F' AND t.USL_OK=3 AND p.IsNeedDisp=2 AND t.TypeDs=1 AND NOT EXISTS(SELECT 1 FROM dbo.DNPersons202007 d WHERE d.enp=t.ENP AND d.flag=t.flag) AND t.AmountPayment>0 AND t.ReportYear=@reportYear
UNION ALL
SELECT DISTINCT enp,t.flag,t.Age,t.Sex
FROM  dbo.t_DS2_Info p 	INNER JOIN oms_nsi.dbo.tmp_DS2report202007 d ON
             p.DiagnosisCode=d.КОД	
			 INNER JOIN #t t ON
           p.rf_idCase=t.rf_idCase
		   AND d.flag=t.flag
WHERE t.sid IS NOT NULL AND t.TypeFile='F' AND t.USL_OK=3 AND p.IsNeedDisp=2 AND t.TypeDs=2 AND NOT EXISTS(SELECT 1 FROM dbo.DNPersons202007 d WHERE d.enp=t.ENP AND d.flag=t.flag) AND t.AmountPayment>0 AND t.ReportYear=@reportYear AND d.flag<28
)
INSERT #tCase(Col1, Col23,col24,col25,col26,col27)
SELECT flag,COUNT(DISTINCT enp) AS Col8
		,COUNT(distinct CASE WHEN c.Sex=1 AND age<65 THEN c.ENP ELSE NULL end) AS Col9
		,COUNT(distinct CASE WHEN c.Sex=1 AND age>=65 THEN c.ENP ELSE NULL end) AS Col10
		----------Женщины--------------------------------------------------
		,COUNT(distinct CASE WHEN c.Sex=2 AND age< 60 THEN c.ENP ELSE NULL end) AS Col11
		,COUNT(distinct CASE WHEN c.Sex=2 AND age>=60 THEN c.ENP ELSE NULL end) AS Col12
FROM cteCol9 c GROUP BY flag
----------------------------------24------------------------------
--INSERT #tCase(Col1, Col23,col24,col25,col26,col27)
--SELECT Col1, SUM(Col8),SUM(col9),SUM(col10),SUM(col11),SUM(col12) FROM #tCase GROUP BY Col1

--------------------------------------------------------13-----------------------------------------------------------------------
INSERT #tCase(Col1, Col13,col14,col15,col16,col17)
SELECT flag,COUNT(DISTINCT enp) AS Col8
		,COUNT(distinct CASE WHEN c.Sex=1 AND age<65 THEN c.ENP ELSE NULL end) AS Col9
		,COUNT(distinct CASE WHEN c.Sex=1 AND age>=65 THEN c.ENP ELSE NULL end) AS Col10
		----------Женщины------2-------------------------------------------
		,COUNT(distinct CASE WHEN c.Sex=2 AND age< 60 THEN c.ENP ELSE NULL end) AS Col11
		,COUNT(distinct CASE WHEN c.Sex=2 AND age>=60 THEN c.ENP ELSE NULL end) AS Col12
FROM (SELECT distinct flag,ENP,Age,sex FROM dbo.T_inform202007 WHERE sex IS NOT NULL AND flag<28) c
GROUP BY flag
-------------------------------------28 and 38-----------------------------------
;WITH cte
AS
(
select flag,t.rf_idCase,age,t.Sex,t.enp
FROM #t t INNER JOIN dbo.t_PurposeOfVisit p on
		t.rf_idCase=p.rf_idCase
			INNER JOIN dbo.t_Meduslugi m ON
		t.rf_idCase=m.rf_idCase
WHERE p.rf_idV025='1.3' AND m.MUGroupCode=2 AND  m.MUUnGroupCode=88 AND rf_idDepartmentMO IS NULL AND t.TypeFile='H' AND t.AmountPayment>0 AND t.ReportYear=@reportYear
)
INSERT #tCase(Col1, Col28,col29,col30,col31,col32,Col38,Col39,Col40,Col41,Col42)
SELECT flag,COUNT(DISTINCT c.rf_idCase) AS Col8
		,COUNT(distinct CASE WHEN c.Sex=1 AND age<65 THEN c.rf_idCase ELSE NULL end) AS Col9
		,COUNT(distinct CASE WHEN c.Sex=1 AND age>=65 THEN c.rf_idCase ELSE NULL end) AS Col10
		------- ---Женщины--------------------------------------------------
		,COUNT(distinct CASE WHEN c.Sex=2 AND age< 60 THEN c.rf_idCase ELSE NULL end) AS Col11
		,COUNT(distinct CASE WHEN c.Sex=2 AND age>=60 THEN c.rf_idCase ELSE NULL end) AS Col12
		------- --------Люди-----------------------------
		,COUNT(DISTINCT c.ENP) AS Col38
		,COUNT(distinct CASE WHEN c.Sex=1 AND age<65  THEN c.ENP ELSE NULL end) AS Col39
		,COUNT(distinct CASE WHEN c.Sex=1 AND age>=65 THEN c.ENP ELSE NULL end) AS Col40
		------- ---Женщины--------------------------------------------------
		,COUNT(distinct CASE WHEN c.Sex=2 AND age< 60 THEN c.ENP ELSE NULL end) AS Col41
		,COUNT(distinct CASE WHEN c.Sex=2 AND age>=60 THEN c.ENP ELSE NULL end) AS Col42
FROM cte c
GROUP BY flag
-------------------------------------33 and 43-----------------------------------
;WITH cte
AS
(
select flag,enp,age,t.Sex,t.rf_idCase
FROM #t t INNER JOIN dbo.t_PurposeOfVisit p on
		t.rf_idCase=p.rf_idCase
			INNER JOIN dbo.t_Meduslugi m ON
		t.rf_idCase=m.rf_idCase
WHERE  p.rf_idV025='1.3' AND m.MUGroupCode=2 AND  m.MUUnGroupCode=88 AND rf_idDepartmentMO=0 AND t.TypeFile='H' AND t.AmountPayment>0 AND t.ReportYear=@reportYear
)
INSERT #tCase(Col1, Col33,col34,col35,col36,col37,Col43,Col44,Col45,Col46,Col47)
SELECT flag,COUNT(DISTINCT rf_idCase) AS Col8
		,COUNT(distinct CASE WHEN c.Sex=1 AND age<65 THEN c.rf_idCase ELSE NULL end) AS Col9
		,COUNT(distinct CASE WHEN c.Sex=1 AND age>=65 THEN c.rf_idCase ELSE NULL end) AS Col10
		-------distinct ---Женщины--------------------------------------------------
		,COUNT(distinct CASE WHEN c.Sex=2 AND age< 60 THEN c.rf_idCase ELSE NULL end) AS Col11
		,COUNT(distinct CASE WHEN c.Sex=2 AND age>=60 THEN c.rf_idCase ELSE NULL end) AS Col12
		------- --------Люди-----------------------------
		,COUNT(DISTINCT c.ENP) AS Col43
		,COUNT(distinct CASE WHEN c.Sex=1 AND age<65  THEN c.ENP ELSE NULL end) AS Col44
		,COUNT(distinct CASE WHEN c.Sex=1 AND age>=65 THEN c.ENP ELSE NULL end) AS Col45
		------- ---Женщины--------------------------------------------------
		,COUNT(distinct CASE WHEN c.Sex=2 AND age< 60 THEN c.ENP ELSE NULL end) AS Col46
		,COUNT(distinct CASE WHEN c.Sex=2 AND age>=60 THEN c.ENP ELSE NULL end) AS Col47
FROM cte c
GROUP BY flag

------------------------------------48---------------------
;WITH cteCol4
AS(
SELECT DISTINCT d.ENP,flag,age,d.sex_ENP AS Sex
FROM dbo.DNPersons202007 d WHERE flag<28
UNION ALL
SELECT DISTINCT enp,flag,age,sex
FROM #t t INNER JOIN dbo.t_PurposeOfVisit p on
		t.rf_idCase=p.rf_idCase
WHERE t.TypeFile='H' AND p.rf_idV025='1.3' AND t.USL_OK=3 AND p.DN IN(1,2) AND t.AmountPayment>0
UNION ALL
SELECT DISTINCT enp,flag,t.age,sex
FROM #t t INNER JOIN dbo.t_Case p on
		t.rf_idCase=p.id
WHERE t.TypeFile='F' AND t.USL_OK=3 AND p.IsNeedDisp IN(1,2) AND t.TypeDs=1 AND t.AmountPayment>0 AND t.ReportYear=@reportYear
UNION ALL
SELECT DISTINCT enp,t.flag,t.age,sex
FROM  dbo.t_DS2_Info p 	INNER JOIN oms_nsi.dbo.tmp_DS2report202007 d ON
             p.DiagnosisCode=d.КОД	
			 INNER JOIN #t t ON
           p.rf_idCase=t.rf_idCase
		   AND d.flag=t.flag
WHERE t.TypeFile='F' AND t.USL_OK=3 AND p.IsNeedDisp IN(1,2) AND t.TypeDs=2 AND t.AmountPayment>0 AND t.ReportYear=@reportYear
)
SELECT DISTINCT ENP,flag,Age,Sex INTO #tStacSkoray FROM cteCol4

;WITH cte
AS
(
	SELECT t.flag,t.Age,t.Sex,t.rf_idRecordCasePatient
	FROM #t t INNER JOIN #tStacSkoray s ON
			t.enp=s.ENP
			AND t.flag=s.flag
	WHERE t.USL_OK<3 AND t.ReportYear=@reportYear --AND t.AmountPayment>0
)
INSERT #tCase(Col1, Col48,col49,col50,col51,Col52)
SELECT flag,COUNT(DISTINCT c.rf_idRecordCasePatient ) AS Col8
		,COUNT(distinct CASE WHEN c.Sex=1 AND age<65  THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col9
		,COUNT(distinct CASE WHEN c.Sex=1 AND age>=65 THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col10
		------- ---Женщины--------------------------------------------------
		,COUNT(distinct CASE WHEN c.Sex=2 AND age< 60 THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col11
		,COUNT(distinct CASE WHEN c.Sex=2 AND age>=60 THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col12
FROM cte c GROUP BY flag
-----------------------------------------53-------------------
;WITH cte
AS(
SELECT DISTINCT t.flag,t.ENP,t.Age,t.sex
FROM #tStacSkoray tt INNER JOIN #t t ON
		tt.ENP=t.ENP
		AND tt.flag=t.flag
					INNER JOIN t_Case c ON
		t.rf_idCase=c.id
WHERE c.rf_idV009 IN(105,106,205,206,313,405,406,411) AND t.AmountPayment>0 AND t.TypeDs=1 AND t.ReportYear=@reportYear
)
INSERT #tCase(Col1, Col53,col54,col55,col56,col57)
SELECT flag,COUNT(DISTINCT enp) AS Col8
		,COUNT(distinct CASE WHEN c.Sex=1 AND age<65 THEN c.ENP ELSE NULL end) AS Col9
		,COUNT(distinct CASE WHEN c.Sex=1 AND age>=65 THEN c.ENP ELSE NULL end) AS Col10
		------- ---Женщины--------------------------------------------------
		,COUNT(distinct CASE WHEN c.Sex=2 AND age< 60 THEN c.ENP ELSE NULL end) AS Col11
		,COUNT(distinct CASE WHEN c.Sex=2 AND age>=60 THEN c.ENP ELSE NULL end) AS Col12
FROM cte c GROUP BY flag
-------------------------------------58--------------------------
;WITH cte
AS
(
	SELECT t.flag,t.Age,t.Sex,t.rf_idRecordCasePatient
	FROM #t t INNER JOIN #tStacSkoray s ON
			t.enp=s.ENP
			AND t.flag=s.flag
	WHERE t.USL_OK=4 AND t.ReportYear=@reportYear --AND t.AmountPayment>0
)
INSERT #tCase(Col1, Col58,col59,col60,col61,Col62)
SELECT flag,COUNT(DISTINCT c.rf_idRecordCasePatient ) AS Col8
		,COUNT(distinct CASE WHEN c.Sex=1 AND age<65  THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col9
		,COUNT(distinct CASE WHEN c.Sex=1 AND age>=65 THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col10
		------- ---Женщины--------------------------------------------------
		,COUNT(distinct CASE WHEN c.Sex=2 AND age< 60 THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col11
		,COUNT(distinct CASE WHEN c.Sex=2 AND age>=60 THEN c.rf_idRecordCasePatient ELSE NULL end) AS Col12
FROM cte c GROUP BY flag
------------------------63-----------------------------------
;WITH cte
AS
(
	SELECT DISTINCT s.flag,s.Age,s.Sex,s.ENP
	FROM dbo.t_Disability t INNER JOIN dbo.t_PatientSMO p ON
					t.rf_idRecordCasePatient=p.rf_idRecordCasePatient
							INNER JOIN oms_nsi.dbo.tmp_DS2report202007 d ON
					t.Diagnosis=d.Код
							INNER JOIN #tStacSkoray s ON						
			p.enp=s.ENP
			AND d.flag=s.flag	
)
INSERT #tCase(Col1, Col63,col64,col65,col66,Col67)
SELECT flag,COUNT(DISTINCT c.ENP) AS Col8
		,COUNT(distinct CASE WHEN c.Sex=1 AND age<65  THEN c.ENP ELSE NULL end) AS Col9
		,COUNT(distinct CASE WHEN c.Sex=1 AND age>=65 THEN c.ENP ELSE NULL end) AS Col10
		------- ---Женщины----------------------------
		,COUNT(distinct CASE WHEN c.Sex=2 AND age< 60 THEN c.ENP ELSE NULL end) AS Col11
		,COUNT(distinct CASE WHEN c.Sex=2 AND age>=60 THEN c.ENP ELSE NULL end) AS Col12
FROM cte c GROUP BY flag

SELECT  Col1,sum(Col3),sum(Col4),sum(Col5),sum(Col6),sum(Col7),sum(Col8),sum(Col9),sum(Col10),sum(Col11),sum(Col12),sum(Col13),sum(Col14),sum(Col15),
			SUM(Col16),sum(Col17),sum(Col18),sum(Col19),sum(Col20),sum(Col21),sum(Col22),sum(Col23),sum(Col24),sum(Col25),sum(Col26),sum(Col27),sum(Col28),
            sum(Col29),sum(Col30), sum(Col31),sum(Col32),sum(Col33),sum(Col34),sum(Col35),sum(Col36),sum(Col37),sum(Col38),sum(Col39),sum(Col40),sum(Col41),
            sum(Col42),sum(Col43),sum(Col44),sum(Col45),sum(Col46),sum(Col47),sum(Col48),sum(Col49),sum(Col50),sum(Col51),sum(Col52),sum(Col53),sum(Col54),
			SUM(Col55),sum(Col56),sum(Col57),sum(Col58),sum(Col59),sum(Col60),sum(Col61),sum(Col62),sum(Col63),sum(Col64),sum(Col65),sum(Col66),sum(Col67)
FROM #tCase
GROUP BY col1
ORDER BY col1
GO
DROP TABLE #t
GO
DROP TABLE #tCase
GO
DROP TABLE #tStacSkoray