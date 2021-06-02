USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20200713',
		@reportYear SMALLINT=2020,
		@codeSMO VARCHAR(5)='34002'



CREATE TABLE #tCase
(ReportYear SMALLINT,CodeM CHAR(6),Col3 INT NOT NULL DEFAULT 0,Col4 INT NOT NULL DEFAULT 0,Col5 INT NOT NULL DEFAULT 0,Col6 INT NOT NULL DEFAULT 0,Col7 INT NOT NULL DEFAULT 0,
Col8 INT NOT NULL DEFAULT 0,Col9 INT NOT NULL DEFAULT 0,Col10 INT NOT NULL DEFAULT 0,Col11 INT NOT NULL DEFAULT 0,Col12 INT NOT NULL DEFAULT 0,Col13 INT NOT NULL DEFAULT 0,Col14 INT NOT NULL DEFAULT 0,
Col15 INT NOT NULL DEFAULT 0,Col16 INT NOT NULL DEFAULT 0,Col17 INT NOT NULL DEFAULT 0,Col18 INT NOT NULL DEFAULT 0,Col19 INT NOT NULL DEFAULT 0)


SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.ReportYear,f.CodeM,c.DateEnd, c.rf_idV006 AS USL_OK,c.Age
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.t_MES m ON
            c.id=m.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<7 AND m.MES='ds02.005' AND a.rf_idSMO=@codeSMO

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<'20200716'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT DiagnosisCode,MainDS INTO #tDiag FROM vw_sprMKB10 WHERE MainDS BETWEEN 'O20' AND 'O48'
INSERT #tDiag SELECT DiagnosisCode, MainDS FROM vw_sprMKB10 WHERE MainDS BETWEEN 'Z34' AND 'Z36'
INSERT #tDiag SELECT DiagnosisCode, MainDS FROM vw_sprMKB10 WHERE MainDS ='O99'
INSERT #tDiag SELECT DiagnosisCode, MainDS FROM vw_sprMKB10 WHERE DiagnosisCode BETWEEN 'O98.4' AND 'O98.99'

INSERT #tCase(ReportYear,CodeM,Col3)
SELECT ReportYear,#t.CodeM,COUNT(DISTINCT rf_idCase) FROM #t WHERE AmountPayment>0 GROUP BY ReportYear,CodeM
PRINT 'Col3'

INSERT #tCase(ReportYear,CodeM,Col4)
SELECT ReportYear,CodeM,COUNT(DISTINCT t.rf_idCase) 
FROM #t t INNER JOIN dbo.t_Coefficient cc ON
		t.rf_idCase=cc.rf_idCase
			INNER JOIN dbo.t_Meduslugi m ON
        t.rf_idCase=m.rf_idCase
WHERE cc.Code_SL=15 AND m.MUSurgery='A11.20.025.001' AND AmountPayment>0
AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.rf_idCase=t.rf_idCase AND mm.MUSurgery NOT IN('A11.20.025.001','A11.20.17') AND m.MUSurgery IS NOT null)
GROUP BY ReportYear,CodeM
PRINT 'Col4'
/*
SELECT DISTINCT t.rf_idCase,4 colName
INTO #Col
FROM #t t INNER JOIN dbo.t_Coefficient cc ON
		t.rf_idCase=cc.rf_idCase
			INNER JOIN dbo.t_Meduslugi m ON
        t.rf_idCase=m.rf_idCase
WHERE cc.Code_SL=15 AND m.MUSurgery='A11.20.025.001' AND AmountPayment>0
AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.rf_idCase=t.rf_idCase AND mm.MUSurgery NOT IN('A11.20.025.001','A11.20.17') AND m.MUSurgery IS NOT null)
INSERT #Col
SELECT DISTINCT t.rf_idCase,5 colName
FROM #t t INNER JOIN dbo.t_Meduslugi m ON
        t.rf_idCase=m.rf_idCase
WHERE m.MUSurgery IN( 'A11.20.028','A11.20.036' ) AND EXISTS(SELECT 1 FROM dbo.t_Coefficient cc WHERE cc.rf_idCase=t.rf_idCase AND cc.Code_SL=15) AND AmountPayment>0

INSERT #Col
SELECT DISTINCT t.rf_idCase,6 colName
FROM #t t INNER JOIN dbo.t_Meduslugi m ON
        t.rf_idCase=m.rf_idCase
WHERE NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient cc WHERE cc.rf_idCase=t.rf_idCase) AND AmountPayment>0	

INSERT #Col
SELECT DISTINCT t.rf_idCase,7 colName
FROM #t t INNER JOIN dbo.t_Coefficient cc ON
		t.rf_idCase=cc.rf_idCase
			INNER JOIN dbo.t_Meduslugi m ON
        t.rf_idCase=m.rf_idCase
WHERE cc.Code_SL=16 AND AmountPayment>0

INSERT #Col
SELECT DISTINCT t.rf_idCase,8 colName
FROM #t t INNER JOIN dbo.t_Coefficient cc ON
		t.rf_idCase=cc.rf_idCase
			INNER JOIN dbo.t_Meduslugi m ON
        t.rf_idCase=m.rf_idCase
WHERE cc.Code_SL=17 AND m.MUSurgery='A11.20.030.001' AND AmountPayment>0

;WITH cteRow
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY rf_idCase ORDER BY ColName) AS IdRow,rf_idCase,colName FROM #col
)
SELECT r.*
FROM cteRow r ORDER BY r.rf_idCase, r.IdRow

DROP TABLE #col
*/
INSERT #tCase(ReportYear,CodeM,Col5)
SELECT ReportYear,CodeM,COUNT(DISTINCT t.rf_idCase) 
FROM #t t INNER JOIN dbo.t_Meduslugi m ON
        t.rf_idCase=m.rf_idCase
WHERE m.MUSurgery ='A11.20.017' AND EXISTS(SELECT 1 FROM dbo.t_Coefficient cc WHERE cc.rf_idCase=t.rf_idCase AND cc.Code_SL=15) AND AmountPayment>0
AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.rf_idCase=t.rf_idCase AND ((mm.MUSurgery ='A11.20.025.001' AND mm.MUSurgery='A11.20.036')  
					OR (mm.MUSurgery ='A11.20.028' AND mm.MUSurgery='A11.20.031') or (mm.MUSurgery ='A11.20.025.001' AND mm.MUSurgery='A11.20.028') ) 
			)
GROUP BY ReportYear,CodeM
PRINT 'Col5'

-----------------------------------------------------------------------------
INSERT #tCase(ReportYear,CodeM,Col6)
SELECT ReportYear,CodeM,COUNT(DISTINCT t.rf_idCase) 
FROM #t t INNER JOIN dbo.t_Meduslugi m ON
        t.rf_idCase=m.rf_idCase
WHERE NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient cc WHERE cc.rf_idCase=t.rf_idCase) AND AmountPayment>0	
GROUP BY ReportYear,CodeM
PRINT 'Col6'

INSERT #tCase(ReportYear,CodeM,Col7)
SELECT ReportYear,CodeM,COUNT(DISTINCT t.rf_idCase) 
FROM #t t INNER JOIN dbo.t_Coefficient cc ON
		t.rf_idCase=cc.rf_idCase
			INNER JOIN dbo.t_Meduslugi m ON
        t.rf_idCase=m.rf_idCase
WHERE cc.Code_SL=16 AND AmountPayment>0
GROUP BY ReportYear,CodeM
PRINT 'Col7'

INSERT #tCase(ReportYear,CodeM,Col8)
SELECT ReportYear,CodeM,COUNT(DISTINCT t.rf_idCase) 
FROM #t t INNER JOIN dbo.t_Coefficient cc ON
		t.rf_idCase=cc.rf_idCase
			INNER JOIN dbo.t_Meduslugi m ON
        t.rf_idCase=m.rf_idCase
WHERE cc.Code_SL=17 AND m.MUSurgery='A11.20.030.001' AND AmountPayment>0
GROUP BY ReportYear,CodeM
PRINT 'Col8'



INSERT #tCase(ReportYear,CodeM,Col9)
SELECT ReportYear,#t.CodeM,COUNT(DISTINCT ENP) FROM #t WHERE AmountPayment>0 GROUP BY ReportYear,CodeM
PRINT 'Col9'
------------------------------------------Люди для колонок 10-12
SELECT ENP,t.DateEnd,t.rf_idCase,Age,t.CodeM
INTO #tEnp
FROM #t t 
WHERE AmountPayment>0


INSERT #tCase(ReportYear,CodeM,Col10)
SELECT @reportYear,e.CodeM,COUNT(DISTINCT p.ENP)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN #tEnp e ON
            p.enp=e.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN dbo.vw_Diagnosis d ON
            c.id=d.rf_idCase
					INNER JOIN #tDiag dd ON
            d.DS1=dd.DiagnosisCode
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<GETDATE()  AND a.ReportYear>=@reportYear AND c.rf_idV006=3 --AND c.rf_idV002=137
AND c.DateBegin>e.DateEnd
GROUP BY e.CodeM
PRINT 'Col10'

INSERT #tCase(ReportYear,CodeM,Col11)
SELECT @reportYear,e.CodeM,COUNT(DISTINCT p.ENP)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN #tEnp e ON
            p.enp=e.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN dbo.vw_Diagnosis d ON
            c.id=d.rf_idCase
					INNER JOIN #tDiag dd ON
            d.DS1=dd.DiagnosisCode
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<GETDATE() AND a.ReportYear>=@reportYear AND c.rf_idV006=3-- AND c.rf_idV002=137
AND c.DateBegin>e.DateEnd AND dd.MainDS IN('O30','O31')
GROUP BY e.CodeM
PRINT 'Col11'

INSERT #tCase(ReportYear,CodeM,Col12)
SELECT @reportYear,e.CodeM,COUNT(DISTINCT p.ENP)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN #tEnp e ON
            p.enp=e.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN dbo.vw_Diagnosis d ON
            c.id=d.rf_idCase
					INNER JOIN vw_sprMKB10 dd ON
            d.DS1=dd.DiagnosisCode
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<GETDATE()  AND a.ReportYear>=@reportYear AND c.rf_idV006=1 AND dd.MainDS BETWEEN 'O80' AND 'O84'
GROUP BY e.CodeM
PRINT 'Col12'
--------------------------Колонки 14-15-----------------------
INSERT #tCase(ReportYear,CodeM,Col14)
SELECT @reportYear,e.CodeM,COUNT(DISTINCT c.id)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN #tEnp e ON
            p.enp=e.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<GETDATE()  AND a.ReportYear>=@reportYear AND r.BirthWeight IS NOT null
GROUP BY e.CodeM
PRINT 'Col14'

INSERT #tCase(ReportYear,CodeM,Col15)
SELECT @reportYear,c.rf_idMO,COUNT(DISTINCT e.rf_idCase)
FROM dbo.t_Case c INNER JOIN #tEnp e ON
			c.id=e.rf_idCase								
WHERE c.rf_idV006=2 AND c.Age>35	
GROUP BY c.rf_idMO
PRINT 'Col15'
-------------------------Колонки 16-19
INSERT #tCase(ReportYear,CodeM,Col16)
SELECT @reportYear,e.CodeM,COUNT(DISTINCT p.ENP)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN #tEnp e ON
            p.enp=e.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN dbo.vw_Diagnosis d ON
            c.id=d.rf_idCase
					INNER JOIN #tDiag dd ON
            d.DS1=dd.DiagnosisCode
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<GETDATE()  AND a.ReportYear>=@reportYear AND c.rf_idV006=3 --AND c.rf_idV002=137
AND c.DateBegin>e.DateEnd AND e.Age>35
GROUP BY e.CodeM
PRINT 'Col16'

INSERT #tCase(ReportYear,CodeM,Col17)
SELECT @reportYear,e.CodeM,COUNT(DISTINCT p.ENP)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN #tEnp e ON
            p.enp=e.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN dbo.vw_Diagnosis d ON
            c.id=d.rf_idCase
					INNER JOIN #tDiag dd ON
            d.DS1=dd.DiagnosisCode
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<GETDATE() AND a.ReportYear>=@reportYear AND c.rf_idV006=3 --AND c.rf_idV002=137
AND c.DateBegin>e.DateEnd AND dd.MainDS IN('O30','O31') AND e.Age>35
GROUP BY e.CodeM
PRINT 'Col17'

SELECT DISTINCT ENP,e.rf_idCase,CodeM
INTO #tENP2
FROM dbo.t_Case c INNER JOIN #tEnp e ON
			c.id=e.rf_idCase								
WHERE c.rf_idV006=2 AND c.Age>35	


INSERT #tCase(ReportYear,CodeM,Col18)
SELECT @reportYear,e.CodeM,COUNT(DISTINCT p.ENP)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN #tEnp2 e ON
            p.enp=e.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN dbo.vw_Diagnosis d ON
            c.id=d.rf_idCase
					INNER JOIN vw_sprMKB10 dd ON
            d.DS1=dd.DiagnosisCode
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<GETDATE()  AND a.ReportYear>=@reportYear AND c.rf_idV006=1 AND dd.MainDS BETWEEN 'O80' AND 'O84' 
GROUP BY e.CodeM
PRINT 'Col18'

INSERT #tCase(ReportYear,CodeM,Col19)
SELECT @reportYear,e.CodeM,COUNT(DISTINCT c.id)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN #tEnp2 e ON
            p.enp=e.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<GETDATE()  AND a.ReportYear>=@reportYear AND r.BirthWeight IS NOT null
GROUP BY e.CodeM
PRINT 'Col19'

SELECT  ReportYear,l.CodeM+' - '+l.NAMES AS LPU
		,sum(Col3)  as Col3
		,sum(Col4)	as Col4
		,sum(Col5)	as Col5
		,sum(Col6)	as Col6
		,sum(Col7)	as Col7
		,sum(Col8)	as Col8
		,sum(Col9)	as Col9
		,sum(Col10)	as Col10
		,sum(Col11)	as Col11
		,sum(Col12)	as Col12
		,sum(Col13)	as Col13
		,sum(Col14)	as Col14
		,sum(Col15)	as Col15
		,SUM(Col16)	as Col16
		,sum(Col17)	as Col17
		,sum(Col18)	as Col18
		,sum(Col19)	as Col19
FROM #tCase c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
GROUP BY ReportYear,l.CodeM+' - '+l.NAMES 
ORDER BY ReportYear, LPU
GO
DROP TABLE #tEnp
GO
DROP TABLE #tENP2
GO
DROP TABLE #tDiag
GO
DROP TABLE #t
GO
DROP TABLE #tCase
GO 
