USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200401',
		@dateEnd DATETIME='20201031',
		@dateEndPay DATETIME='20201031'
---обратить внимание на возраст
CREATE TABLE #csg(code varchar(10), typeHardCase TINYINT,PeriodUse TINYINT,crit VARCHAR(5))
INSERT #csg(code,typeHardCase,PeriodUse) VALUES('st12.008.1',1,1),('st12.009.1',1,1),('st23.004.1',2,1),('st12.013.2',3,1),('st12.013.1',4,1)

INSERT #csg(code,typeHardCase,PeriodUse,crit) VALUES('st12.008.1',1,2,null),('st12.009.1',1,2,null),('st23.004.1',1,2,'cr8')
,('st12.013.2',2,2,'cr4'),('st12.013.1',3,2,'cr5'),('st12.013.1',4,2,'cr6')

CREATE TABLE #tTotal( Col1 INT NOT NULL DEFAULT(0),Col2 INT NOT NULL DEFAULT(0),Col3 INT NOT NULL DEFAULT(0),Col4 INT NOT NULL DEFAULT(0),Col5 INT NOT NULL DEFAULT(0)
,Col6 INT NOT NULL DEFAULT(0),Col7 INT NOT NULL DEFAULT(0),Col8 INT NOT NULL DEFAULT(0),Col9 INT NOT NULL DEFAULT(0),Col10 INT NOT NULL DEFAULT(0),Col11 INT NOT NULL DEFAULT(0)
,Col12 INT NOT NULL DEFAULT(0),Col13 INT NOT NULL DEFAULT(0),Col14 INT NOT NULL DEFAULT(0),Col15 INT NOT NULL DEFAULT(0),Col16 INT NOT NULL DEFAULT(0),Col17 INT NOT NULL DEFAULT(0)
,Col18 INT NOT NULL DEFAULT(0),Col19 INT NOT NULL DEFAULT(0),Col20 INT NOT NULL DEFAULT(0),Col21 INT NOT NULL DEFAULT(0),Col22 INT NOT NULL DEFAULT(0),Col23 INT NOT NULL DEFAULT(0)
,Col24 INT NOT NULL DEFAULT(0),Col25 INT NOT NULL DEFAULT(0),Col26 INT NOT NULL DEFAULT(0),Col27 INT NOT NULL DEFAULT(0),Col28 INT NOT NULL DEFAULT(0),Col29 INT NOT NULL DEFAULT(0)
)
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest,cc.id AS rf_idCompletedCasse,cc.DateBegin,cc.DateEnd,a.ReportMonth,
		CASE WHEN c.rf_idV009 IN(105,106) THEN c.rf_idV009 ELSE NULL END RSLT,DATEDIFF(DAY,cc.DateBegin,cc.DateEnd) as DiffDate,ps.ENP
INTO #tCases
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
			AND cc.DateEnd>='20200401'									
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>3 AND a.ReportMonth<10 AND c.rf_idV006=1
	AND d.TypeDiagnosis IN(1,3) AND d.DiagnosisCode IN('U07.1','U07.2') AND a.rf_idSMO<>'34' AND c.Age BETWEEN 18 AND 65

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
						   FROM dbo.t_PaymentAcceptedCase2 c
						   WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
						   GROUP BY c.rf_idCase
						 ) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE AmountPayment=0
--1 - легкая, 2-средняя, 3-тяжелая, 4-крайне тяжелая
ALTER TABLE #tCases ADD IsTypeHardCase TINYINT NOT NULL DEFAULT(0)

UPDATE c SET c.IsTypeHardCase=cc.typeHardCase
FROM #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
				INNER JOIN #csg cc ON
        m.MES=cc.code
WHERE c.ReportMonth<9 AND cc.PeriodUse=1

UPDATE c SET c.IsTypeHardCase=cc.typeHardCase
FROM #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
				INNER JOIN dbo.t_AdditionalCriterion a ON
        c.rf_idCase=a.rf_idCase
				INNER JOIN #csg cc ON
        m.MES=cc.code
		AND a.rf_idAddCretiria=cc.crit
WHERE c.ReportMonth>=9 AND cc.PeriodUse=2 AND cc.crit IS NOT NULL

UPDATE c SET c.IsTypeHardCase=cc.typeHardCase
FROM #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase
				INNER JOIN #csg cc ON
        m.MES=cc.code
WHERE c.ReportMonth>=9 AND cc.PeriodUse=2 AND cc.crit IS null
--удаляем случаи у которых не удалось определить степень тяжести
DELETE FROM #tCases WHERE IsTypeHardCase=0
-------------------------------------------Амбулаторная помощь-------------------------------------
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, c.AmountPayment,c.DateBegin,c.DateEnd,a.ReportMonth,ps.ENP,c.rf_idV002 AS Profil
INTO #tCasesAmb
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN #tCases s ON
            ps.ENP=s.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient							
			AND c.DateEnd>='20200401'									
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>2 AND a.ReportMonth<10 AND c.rf_idV006=3 AND a.rf_idSMO<>'34' AND c.rf_idV002 IN(28, 57, 58, 65, 75, 97, 151,160)

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCasesAmb p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
						   FROM dbo.t_PaymentAcceptedCase2 c
						   WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
						   GROUP BY c.rf_idCase
						 ) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCasesAmb WHERE AmountPayment=0
----------------------------------------------------------------

----------------Всего госпитализаций--------------------------
INSERT #tTotal(Col1) SELECT COUNT(DISTINCT rf_idCompletedCasse) FROM #tCases 
----------------Легкое течение--------------------------
INSERT #tTotal(Col2) SELECT COUNT(DISTINCT rf_idCompletedCasse) FROM #tCases WHERE IsTypeHardCase=1
----------------Среднее течение--------------------------
INSERT #tTotal(Col3) SELECT COUNT(DISTINCT rf_idCompletedCasse) FROM #tCases WHERE IsTypeHardCase=2
INSERT #tTotal(Col4) SELECT COUNT(DISTINCT rf_idCompletedCasse) FROM #tCases WHERE IsTypeHardCase=2 AND DiffDate<=10
INSERT #tTotal(Col7) SELECT COUNT(DISTINCT rf_idCompletedCasse) FROM #tCases WHERE IsTypeHardCase=2 AND DiffDate>10
----------------Тяжелое течение--------------------------
INSERT #tTotal(Col10) SELECT COUNT(DISTINCT rf_idCompletedCasse) FROM #tCases WHERE IsTypeHardCase=3
INSERT #tTotal(Col11) SELECT COUNT(DISTINCT rf_idCompletedCasse) FROM #tCases WHERE IsTypeHardCase=3 AND DiffDate<=10
INSERT #tTotal(Col14) SELECT COUNT(DISTINCT rf_idCompletedCasse) FROM #tCases WHERE IsTypeHardCase=3 AND DiffDate>10

----------------Крайне Тяжелое течение--------------------------
INSERT #tTotal(Col17) SELECT COUNT(DISTINCT rf_idCompletedCasse) FROM #tCases WHERE IsTypeHardCase=4
INSERT #tTotal(Col18) SELECT COUNT(DISTINCT rf_idCompletedCasse) FROM #tCases WHERE IsTypeHardCase=4 AND DiffDate<=10
INSERT #tTotal(Col21) SELECT COUNT(DISTINCT rf_idCompletedCasse) FROM #tCases WHERE IsTypeHardCase=4 AND DiffDate>10
----------------Случаи со смертельным исходом---------------------
INSERT #tTotal(Col25) SELECT COUNT(DISTINCT rf_idCompletedCasse) FROM #tCases WHERE IsTypeHardCase=2 AND RSLT IS NOT NULL
INSERT #tTotal(Col27) SELECT COUNT(DISTINCT rf_idCompletedCasse) FROM #tCases WHERE IsTypeHardCase=3 AND RSLT IS NOT NULL
INSERT #tTotal(Col29) SELECT COUNT(DISTINCT rf_idCompletedCasse) FROM #tCases WHERE IsTypeHardCase=4 AND RSLT IS NOT NULL
---------------------Амбулаторная помощь----------------
------------госпитализация в день обращения за амбулаторно-поликлинической помощью ---------------
----------------cсредне тяжелое-------------
;WITH dRecord
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY c.ENP ORDER BY a.DateEnd) AS idRow,c.*,a.Profil,a.rf_idCase AS rf_idCaseA,a.CodeM AS CodeMA
FROM #tCases c INNER JOIN #tCasesAmb a ON
		c.enp=a.ENP
		AND c.DateBegin=a.DateEnd
WHERE IsTypeHardCase=2 AND DiffDate<=10
)
INSERT #tTotal(Col5) SELECT count(DISTINCT dRecord.rf_idCompletedCasse) FROM dRecord WHERE idRow=1
--------------тяжелое-----------------
;WITH dRecord
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY c.ENP ORDER BY a.DateEnd) AS idRow,c.*,a.Profil,a.rf_idCase AS rf_idCaseA,a.CodeM AS CodeMA
FROM #tCases c INNER JOIN #tCasesAmb a ON
		c.enp=a.ENP
		AND c.DateBegin=a.DateEnd
WHERE IsTypeHardCase=3 AND DiffDate<=10
)
INSERT #tTotal(Col12) SELECT count(DISTINCT dRecord.rf_idCompletedCasse) FROM dRecord WHERE idRow=1
--------------крайне тяжелое-----------------
;WITH dRecord
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY c.ENP ORDER BY a.DateEnd) AS idRow,c.*,a.Profil,a.rf_idCase AS rf_idCaseA,a.CodeM AS CodeMA
FROM #tCases c INNER JOIN #tCasesAmb a ON
		c.enp=a.ENP
		AND c.DateBegin=a.DateEnd
WHERE IsTypeHardCase=4 AND DiffDate<=10
)
INSERT #tTotal(Col12) SELECT count(DISTINCT dRecord.rf_idCompletedCasse) FROM dRecord WHERE idRow=1
---------------------------Для слуаев госпитализации больше 10 дней---------------------
----------------средне тяжелое-------------
;WITH dRecord
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY c.ENP ORDER BY a.DateEnd) AS idRow,c.*,a.Profil,a.rf_idCase AS rf_idCaseA,a.CodeM AS CodeMA
FROM #tCases c INNER JOIN #tCasesAmb a ON
		c.enp=a.ENP
		AND c.DateBegin=a.DateEnd
WHERE IsTypeHardCase=2 AND DiffDate>10
)
INSERT #tTotal(Col8) SELECT count(DISTINCT dRecord.rf_idCompletedCasse) FROM dRecord WHERE idRow=1
--------------тяжелое-----------------
;WITH dRecord
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY c.ENP ORDER BY a.DateEnd) AS idRow,c.*,a.Profil,a.rf_idCase AS rf_idCaseA,a.CodeM AS CodeMA
FROM #tCases c INNER JOIN #tCasesAmb a ON
		c.enp=a.ENP
		AND c.DateBegin=a.DateEnd
WHERE IsTypeHardCase=3 AND DiffDate>10
)
INSERT #tTotal(Col15) SELECT count(DISTINCT dRecord.rf_idCompletedCasse) FROM dRecord WHERE idRow=1
--------------крайне тяжелое-----------------
;WITH dRecord
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY c.ENP ORDER BY a.DateEnd) AS idRow,c.*,a.Profil,a.rf_idCase AS rf_idCaseA,a.CodeM AS CodeMA
FROM #tCases c INNER JOIN #tCasesAmb a ON
		c.enp=a.ENP
		AND c.DateBegin=a.DateEnd
WHERE IsTypeHardCase=4 AND DiffDate>10
)
INSERT #tTotal(Col22) SELECT count(DISTINCT dRecord.rf_idCompletedCasse) FROM dRecord WHERE idRow=1
------------------------Госпитализация в течении недели после амбулаторной помощи для пациентов с длительностью <=10----------------------
-----------------------------------------------------средне тяжелое--------------------------------------------
;WITH dRecord
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY c.ENP ORDER BY a.DateEnd) AS idRow,c.*,a.Profil,DATEDIFF(DAY,a.DateEnd,c.DateBegin) AS DiffD,a.DateEnd AS DateA
FROM #tCases c INNER JOIN #tCasesAmb a ON
		c.enp=a.ENP
WHERE IsTypeHardCase=2 AND DiffDate<=10
)
INSERT #tTotal(Col6) SELECT COUNT(DISTINCT dRecord.rf_idCompletedCasse) FROM dRecord WHERE  dRecord.DiffD>=1 AND dRecord.DiffD<8 AND idRow=1
--------------------------------------------тяжелое-----------------------------------
;WITH dRecord
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY c.ENP ORDER BY a.DateEnd) AS idRow,c.*,a.Profil,DATEDIFF(DAY,a.DateEnd,c.DateBegin) AS DiffD,a.DateEnd AS DateA
FROM #tCases c INNER JOIN #tCasesAmb a ON
		c.enp=a.ENP
WHERE IsTypeHardCase=3 AND DiffDate<=10
)
INSERT #tTotal(Col13) SELECT COUNT(DISTINCT dRecord.rf_idCompletedCasse) FROM dRecord WHERE  dRecord.DiffD>=1 AND dRecord.DiffD<8 AND idRow=1
-------------------------------------крайнее тяжелое-----------------------------------------------
;WITH dRecord
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY c.ENP ORDER BY a.DateEnd) AS idRow,c.*,a.Profil,DATEDIFF(DAY,a.DateEnd,c.DateBegin) AS DiffD,a.DateEnd AS DateA
FROM #tCases c INNER JOIN #tCasesAmb a ON
		c.enp=a.ENP
WHERE IsTypeHardCase=4 AND DiffDate<=10
)
INSERT #tTotal(Col20) SELECT COUNT(DISTINCT dRecord.rf_idCompletedCasse) FROM dRecord WHERE  dRecord.DiffD>=1 AND dRecord.DiffD<8 AND idRow=1

------------------------Госпитализация в течении недели после амбулаторной помощи для пациентов с длительностью >10----------------------
--------------------------------------средне тяжелое-----------------------------------------
;WITH dRecord
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY c.ENP ORDER BY a.DateEnd) AS idRow,c.*,a.Profil,DATEDIFF(DAY,a.DateEnd,c.DateBegin) AS DiffD,a.DateEnd AS DateA
FROM #tCases c INNER JOIN #tCasesAmb a ON
		c.enp=a.ENP
WHERE IsTypeHardCase=2 AND DiffDate>10
)
INSERT #tTotal(Col9) SELECT COUNT(DISTINCT dRecord.rf_idCompletedCasse) FROM dRecord WHERE  dRecord.DiffD>=1 AND dRecord.DiffD<8 AND idRow=1
-----------------------------------------тяжелое-------------------------------------------------
;WITH dRecord
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY c.ENP ORDER BY a.DateEnd) AS idRow,c.*,a.Profil,DATEDIFF(DAY,a.DateEnd,c.DateBegin) AS DiffD,a.DateEnd AS DateA
FROM #tCases c INNER JOIN #tCasesAmb a ON
		c.enp=a.ENP
WHERE IsTypeHardCase=3 AND DiffDate>10
)
INSERT #tTotal(Col16) SELECT COUNT(DISTINCT dRecord.rf_idCompletedCasse) FROM dRecord WHERE  dRecord.DiffD>=1 AND dRecord.DiffD<8 AND idRow=1
-------------------------------------------крайнее тяжелое-------------------------------------------
;WITH dRecord
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY c.ENP ORDER BY a.DateEnd) AS idRow,c.*,a.Profil,DATEDIFF(DAY,a.DateEnd,c.DateBegin) AS DiffD,a.DateEnd AS DateA
FROM #tCases c INNER JOIN #tCasesAmb a ON
		c.enp=a.ENP
WHERE IsTypeHardCase=4 AND DiffDate>10
)
INSERT #tTotal(Col23) SELECT COUNT(DISTINCT dRecord.rf_idCompletedCasse) FROM dRecord WHERE  dRecord.DiffD>=1 AND dRecord.DiffD<8 AND idRow=1

------------------------------------Вывод итоговых данных возрастная группа 18-65---------------------
SELECT sum(Col1)  as Col1,sum(Col2)  as Col2,sum(Col3)  as Col3,sum(Col4)  as Col4,sum(Col5)  as Col5,sum(Col6)  as Col6,sum(Col7)  as Col7,sum(Col8)  as Col8,sum(Col9)  as Col9,sum(Col10) as Col10,
       sum(Col11) as Col11,sum(Col12) as Col12,sum(Col13) as Col13,sum(Col14) as Col14,sum(Col15) as Col15,sum(Col16) as Col16       
FROM #tTotal

SELECT sum(Col17) as Col17,sum(Col18) as Col18,sum(Col19) as Col19,sum(Col20) as Col20,sum(Col21) as Col21,sum(Col22) as Col22,sum(Col23) as Col23,sum(Col24) as Col24,sum(Col25) as Col25,sum(Col26) as Col26,
       sum(Col27) as Col27,sum(Col28) as Col28,sum(Col29) as Col29
FROM #tTotal


GO
DROP TABLE #tCases
GO
DROP TABLE #csg
GO 
DROP table #tTotal
GO
DROP TABLE #tCasesAmb