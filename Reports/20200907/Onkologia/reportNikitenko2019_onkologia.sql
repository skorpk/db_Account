USE AccountOMS
go
SELECT DiagnosisCode ,MainDS INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #tDiag SELECT DiagnosisCode ,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D48'

SELECT DiagnosisCode ,MainDS INTO #tDiag2 FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #tDiag2 SELECT DiagnosisCode ,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'


CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tDiag(DiagnosisCode)
CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tDiag2(DiagnosisCode)
/*
------------------------------01------------------------------------
DECLARE @month TINYINT=1,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, ReportMonth, ReportYear, IdTypeCol12,@dd AS dd INTO #t  FROM dbo.tmpOnkologia2019 WHERE ReportYear=@year AND ReportMonth=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year, CASE WHEN rubrikDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12,@dd FROM dbo.DNPersons1920_ZNO WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

SELECT * INTO #t2 FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
------------------------------2------------------------------------
DECLARE @month TINYINT=2,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, ReportMonth, ReportYear, IdTypeCol12,@dd AS dd INTO #t  FROM dbo.tmpOnkologia2019 WHERE ReportYear=@year AND ReportMonth=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year, CASE WHEN rubrikDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12,@dd FROM dbo.DNPersons1920_ZNO WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU
INSERT #t2 SELECT *  FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
------------------------------3------------------------------------
DECLARE @month TINYINT=3,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, ReportMonth, ReportYear, IdTypeCol12,@dd AS dd INTO #t  FROM dbo.tmpOnkologia2019 WHERE ReportYear=@year AND ReportMonth=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year, CASE WHEN rubrikDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12,@dd FROM dbo.DNPersons1920_ZNO WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

INSERT #t2 SELECT *  FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
------------------------------4------------------------------------
DECLARE @month TINYINT=4,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, ReportMonth, ReportYear, IdTypeCol12,@dd AS dd INTO #t  FROM dbo.tmpOnkologia2019 WHERE ReportYear=@year AND ReportMonth=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year, CASE WHEN rubrikDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12,@dd FROM dbo.DNPersons1920_ZNO WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

INSERT #t2 SELECT *  FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
------------------------------5------------------------------------
DECLARE @month TINYINT=5,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, ReportMonth, ReportYear, IdTypeCol12,@dd AS dd INTO #t  FROM dbo.tmpOnkologia2019 WHERE ReportYear=@year AND ReportMonth=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year, CASE WHEN rubrikDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12,@dd FROM dbo.DNPersons1920_ZNO WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

INSERT #t2 SELECT *  FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
------------------------------6------------------------------------
DECLARE @month TINYINT=6,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, ReportMonth, ReportYear, IdTypeCol12,@dd AS dd INTO #t  FROM dbo.tmpOnkologia2019 WHERE ReportYear=@year AND ReportMonth=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year, CASE WHEN rubrikDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12,@dd FROM dbo.DNPersons1920_ZNO WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

INSERT #t2 SELECT *  FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
------------------------------7------------------------------------
DECLARE @month TINYINT=7,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, ReportMonth, ReportYear, IdTypeCol12,@dd AS dd INTO #t  FROM dbo.tmpOnkologia2019 WHERE ReportYear=@year AND ReportMonth=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year, CASE WHEN rubrikDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12,@dd FROM dbo.DNPersons1920_ZNO WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

INSERT #t2 SELECT *  FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
------------------------------8------------------------------------
DECLARE @month TINYINT=8,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, ReportMonth, ReportYear, IdTypeCol12,@dd AS dd INTO #t  FROM dbo.tmpOnkologia2019 WHERE ReportYear=@year AND ReportMonth=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year, CASE WHEN rubrikDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12,@dd FROM dbo.DNPersons1920_ZNO WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

INSERT #t2 SELECT *  FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
------------------------------9------------------------------------
DECLARE @month TINYINT=9,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, ReportMonth, ReportYear, IdTypeCol12,@dd AS dd INTO #t  FROM dbo.tmpOnkologia2019 WHERE ReportYear=@year AND ReportMonth=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year, CASE WHEN rubrikDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12,@dd FROM dbo.DNPersons1920_ZNO WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

INSERT #t2 SELECT *  FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
------------------------------10------------------------------------
DECLARE @month TINYINT=10,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, ReportMonth, ReportYear, IdTypeCol12,@dd AS dd INTO #t  FROM dbo.tmpOnkologia2019 WHERE ReportYear=@year AND ReportMonth=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year, CASE WHEN rubrikDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12,@dd FROM dbo.DNPersons1920_ZNO WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

INSERT #t2 SELECT *  FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
------------------------------11------------------------------------
DECLARE @month TINYINT=11,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, ReportMonth, ReportYear, IdTypeCol12,@dd AS dd INTO #t  FROM dbo.tmpOnkologia2019 WHERE ReportYear=@year AND ReportMonth=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year, CASE WHEN rubrikDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12,@dd FROM dbo.DNPersons1920_ZNO WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

INSERT #t2 SELECT *  FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
------------------------------12------------------------------------
DECLARE @month TINYINT=12,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, ReportMonth, ReportYear, IdTypeCol12,@dd AS dd INTO #t  FROM dbo.tmpOnkologia2019 WHERE ReportYear=@year AND ReportMonth=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year, CASE WHEN rubrikDS BETWEEN 'D10' AND 'D48' THEN 1 ELSE 0 END AS IdTypeCol12,@dd FROM dbo.DNPersons1920_ZNO WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

INSERT #t2 SELECT *  FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO

SELECT *  INTO tmpOnkologia2019_GOOD FROM #t2 
GO
*/
-------------------------------------------------------------------
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME='20200125',
		@year int=2019

SELECT * INTO #t2 FROM tmpOnkologia2019_GOOD

CREATE TABLE #tTotal(
					idRow INT
                    , Col1   varchar(16) null
					, Col2   varchar(16) null
					, Col3	 varchar(16) null
					, Col4	 varchar(16) null
					, Col5	 varchar(16) null
					, Col6	 varchar(16) null
					, Col7	 varchar(16) null
					, Col8	 varchar(16) null
					, Col9	 varchar(16) null
					, Col10	 varchar(16) null
					, Col11	 varchar(16) null
					, Col12	 varchar(16) NULL
					,Col13  varchar(16) NULL
)			

INSERT #tTotal(idRow,Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9,Col10,Col11,Col12)
SELECT 1 , CASE WHEN t.ReportMonth= 1 THEN t.ENP ELSE NULL END
		, CASE WHEN t.ReportMonth= 2 THEN t.ENP ELSE NULL END
		, CASE WHEN t.ReportMonth= 3 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 4 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 5 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 6 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 7 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 8 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 9 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 10 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 11 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 12 THEN t.ENP ELSE NULL END	
FROM #t2 t

SELECT p.ENP,c.DateEnd
INTO #tENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN #t2 t ON
            p.enp=t.enp
					INNER JOIN dbo.t_Meduslugi m ON
            c.id=m.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@year AND a.Letter='K' AND m.MUGroupCode=60 AND m.MUUnGroupCode IN(4,5,7,8,9) 
UNION ALL
SELECT p.ENP,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN #t2 t ON
            p.enp=t.enp
					INNER JOIN dbo.vw_Diagnosis dd ON
            c.id=dd.rf_idCase
					INNER JOIN #tDiag d ON
             dd.DS1=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@year AND a.Letter IN('Z','S','H') 


INSERT #tTotal(idRow,Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9,Col10,Col11,Col12,Col13)
SELECT 2 ,CASE WHEN a.ReportMonth= 1 THEN t.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 2 THEN t.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 3 THEN t.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 4 THEN t.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 5 THEN t.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 6 THEN t.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 7 THEN t.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 8 THEN t.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 9 THEN t.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 10 THEN t.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 11 THEN t.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 12 THEN t.ENP ELSE NULL END	
		,t.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN #tENP t ON
            p.enp=t.enp
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@year  AND c.rf_idV002 IN(18,60) AND c.DateEnd<t.DateEnd

INSERT #tTotal(idRow,Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9,Col10,Col11,Col12,col13)
SELECT 3 ,CASE WHEN a.ReportMonth= 1 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 2 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 3 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 4 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 5 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 6 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 7 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 8 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 9 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 10 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 11 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 12 THEN p.ENP ELSE NULL END	
		,p.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Meduslugi m ON
            c.id=m.rf_idCase
					INNER JOIN dbo.vw_Diagnosis dd ON
            c.id=dd.rf_idCase
					INNER JOIN #tDiag2 d ON
             dd.DS1=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@year AND a.Letter='K' AND m.MUGroupCode=60 AND m.MUUnGroupCode IN(2,4,5,7,8,9) 

INSERT #tTotal(idRow,Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9,Col10,Col11,Col12,col13)
SELECT 3 ,CASE WHEN a.ReportMonth= 1 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 2 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 3 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 4 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 5 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 6 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 7 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 8 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 9 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 10 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 11 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 12 THEN p.ENP ELSE NULL END	
		,p.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Meduslugi m ON
            c.id=m.rf_idCase
					INNER JOIN dbo.vw_Diagnosis dd ON
            c.id=dd.rf_idCase
					INNER JOIN #tDiag2 d ON
             dd.DS2=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@year AND a.Letter='K' AND m.MUGroupCode=60 AND m.MUUnGroupCode IN(2,4,5,7,8,9) 

INSERT #tTotal(idRow,Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9,Col10,Col11,Col12,Col13)
SELECT 4 ,CASE WHEN a.ReportMonth= 1 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 2 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 3 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 4 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 5 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 6 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 7 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 8 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 9 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 10 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 11 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 12 THEN p.ENP ELSE NULL END	
		,p.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient								
					INNER JOIN dbo.vw_Diagnosis dd ON
            c.id=dd.rf_idCase
					INNER JOIN #tDiag2 d ON
             dd.DS1=d.DiagnosisCode	
					INNER JOIN t_MES m ON
             c.id=m.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@year AND c.rf_idV008 IN(12,13) AND a.Letter='Z' AND m.MES IN('ds19.029','ds19.033')

INSERT #tTotal(idRow,Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9,Col10,Col11,Col12,Col13)
SELECT 5 ,CASE WHEN a.ReportMonth= 1 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 2 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 3 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 4 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 5 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 6 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 7 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 8 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 9 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 10 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 11 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 12 THEN p.ENP ELSE NULL END	
		,p.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient								
					INNER JOIN dbo.vw_Diagnosis dd ON
            c.id=dd.rf_idCase
					INNER JOIN #tDiag2 d ON
             dd.DS1=d.DiagnosisCode	
					INNER JOIN t_MES m ON
             c.id=m.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@year AND c.rf_idV008 =31 AND a.Letter='Z' AND m.MES IN('ds19.029','ds19.033')

INSERT #tTotal(idRow,Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9,Col10,Col11,Col12,Col13)
SELECT 6 ,CASE WHEN a.ReportMonth= 1 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 2 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 3 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 4 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 5 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 6 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 7 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 8 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 9 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 10 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 11 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 12 THEN p.ENP ELSE NULL END	
		,p.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient								
					INNER JOIN dbo.vw_Diagnosis dd ON
            c.id=dd.rf_idCase
					INNER JOIN #tDiag2 d ON
             dd.DS1=d.DiagnosisCode	
					INNER JOIN t_MES m ON
             c.id=m.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@year AND c.rf_idV008=31 AND a.Letter='S' AND m.MES='st27.014' AND c.rf_idV006=1

INSERT #tTotal(idRow,Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9,Col10,Col11,Col12,Col13)
SELECT 7 ,CASE WHEN a.ReportMonth= 1 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 2 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 3 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 4 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 5 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 6 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 7 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 8 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 9 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 10 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 11 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 12 THEN p.ENP ELSE NULL END	
		,p.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient								
					INNER JOIN dbo.vw_Diagnosis dd ON
            c.id=dd.rf_idCase
					INNER JOIN #tDiag2 d ON
             dd.DS1=d.DiagnosisCode	
					INNER JOIN dbo.t_PurposeOfVisit pp ON
             c.id=pp.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@year AND pp.rf_idV025='1.3' AND c.rf_idV002 IN(18,60)

INSERT #tTotal(idRow,Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9,Col10,Col11,Col12,Col13)
SELECT 8 ,CASE WHEN a.ReportMonth= 1 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 2 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 3 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 4 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 5 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 6 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 7 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 8 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 9 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 10 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 11 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 12 THEN p.ENP ELSE NULL END	
		,p.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient								
					INNER JOIN dbo.vw_Diagnosis dd ON
            c.id=dd.rf_idCase
					INNER JOIN #tDiag2 d ON
             dd.DS1=d.DiagnosisCode	
					INNER JOIN t_MES m ON
             c.id=m.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@year AND c.rf_idV008 IN(12,13) AND a.Letter='Z' AND m.MES not IN('ds19.029','ds19.033') AND c.rf_idV006=2
AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL o WHERE o.rf_idCase=c.id AND o.DS1_T=6 )

INSERT #tTotal(idRow,Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9,Col10,Col11,Col12,Col13)
SELECT 9 ,CASE WHEN a.ReportMonth= 1 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 2 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 3 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 4 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 5 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 6 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 7 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 8 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 9 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 10 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 11 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 12 THEN p.ENP ELSE NULL END	
		,p.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient								
					INNER JOIN dbo.vw_Diagnosis dd ON
            c.id=dd.rf_idCase
					INNER JOIN #tDiag2 d ON
             dd.DS1=d.DiagnosisCode	
					INNER JOIN t_MES m ON
             c.id=m.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@year AND c.rf_idV008 =31 AND a.Letter='Z' AND m.MES not IN('ds19.029','ds19.033') AND c.rf_idV006=2
AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL o WHERE o.rf_idCase=c.id AND o.DS1_T=6 )


INSERT #tTotal(idRow,Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9,Col10,Col11,Col12,Col13)
SELECT 10 ,CASE WHEN a.ReportMonth= 1 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 2 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 3 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 4 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 5 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 6 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 7 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 8 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 9 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 10 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 11 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 12 THEN p.ENP ELSE NULL END	
		,p.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient								
					INNER JOIN dbo.vw_Diagnosis dd ON
            c.id=dd.rf_idCase
					INNER JOIN #tDiag2 d ON
             dd.DS1=d.DiagnosisCode	
					INNER JOIN t_MES m ON
             c.id=m.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@year AND c.rf_idV008 =31 AND a.Letter='S' AND m.MES ='st27.014' AND c.rf_idV006=1
AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL o WHERE o.rf_idCase=c.id AND o.DS1_T=6 )

INSERT #tTotal(idRow,Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9,Col10,Col11,Col12,Col13)
SELECT 11 ,CASE WHEN a.ReportMonth= 1 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 2 THEN p.ENP ELSE NULL END
		, CASE WHEN a.ReportMonth= 3 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 4 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 5 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 6 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 7 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 8 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 9 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 10 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 11 THEN p.ENP ELSE NULL END	
		, CASE WHEN a.ReportMonth= 12 THEN p.ENP ELSE NULL END	
		,p.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts										
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
					INNER JOIN dbo.vw_Diagnosis dd ON
            c.id=dd.rf_idCase
					INNER JOIN #tDiag2 d ON
             dd.DS1=d.DiagnosisCode					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@year AND c.rf_idV002 IN(18,60) AND a.Letter='H' AND c.rf_idV006=1

INSERT #tTotal(idRow,Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9,Col10,Col11,Col12)
SELECT 12 , CASE WHEN t.ReportMonth= 1 THEN t.ENP ELSE NULL END
		, CASE WHEN t.ReportMonth= 2 THEN t.ENP ELSE NULL END
		, CASE WHEN t.ReportMonth= 3 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 4 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 5 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 6 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 7 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 8 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 9 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 10 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 11 THEN t.ENP ELSE NULL END	
		, CASE WHEN t.ReportMonth= 12 THEN t.ENP ELSE NULL END	
FROM #t2 t
WHERE t.sid IS NOT NULL AND t.IdTypeCol12=0

SELECT idRow
,COUNT(DISTINCT Col1) AS Col1
,COUNT(DISTINCT Col2) as Col2
,COUNT(DISTINCT Col3) as Col3
,COUNT(DISTINCT Col4) as Col4
,COUNT(DISTINCT Col5) as Col5
,COUNT(DISTINCT Col6) as Col6
,COUNT(DISTINCT Col7) as Col7
,COUNT(DISTINCT Col8) as Col8
,COUNT(DISTINCT Col9) as Col9
,COUNT(DISTINCT Col10) as Col10
,COUNT(DISTINCT Col11) as Col11
,COUNT(DISTINCT Col12) as Col12
,COUNT(DISTINCT Col13) as Col13
FROM #tTotal
GROUP BY idRow
ORDER BY idRow
GO 
DROP TABLE #tTotal
go
--DROP TABLE #t
GO
DROP TABLE #t2
GO
DROP TABLE #tDiag
GO
DROP TABLE #tDiag2
GO
DROP TABLE #tENP