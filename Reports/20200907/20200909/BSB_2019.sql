USE AccountOMS
GO
--DROP TABLE tmpBSB2018
----------------------------------------1
DECLARE @month TINYINT=1,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, @month AS ReportMonth, ReportYear, @dd AS dd,PID INTO #t  FROM dbo.tmpDSB2019 WHERE ReportYear=@year AND ReportMonth=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year ,@dd ,pid FROM dbo.DNPersons1920_NEW WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
--ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

SELECT * INTO #t2 FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
-------------------------------------2
DECLARE @month TINYINT=2,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, @month AS ReportMonth, ReportYear, @dd AS dd ,pid INTO #t  FROM dbo.tmpDSB2019 WHERE ReportYear=@year AND ReportMonth<=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year ,@dd,pid FROM dbo.DNPersons1920_NEW WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
--ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

insert #t2 SELECT * FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
-------------------------------------3
DECLARE @month TINYINT=3,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')


SELECT rf_idCase, AmountPayment, ENP, @month AS ReportMonth, ReportYear, @dd AS dd ,pid INTO #t  FROM dbo.tmpDSB2019 WHERE ReportYear=@year AND ReportMonth<=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year ,@dd ,pid FROM dbo.DNPersons1920_NEW WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
--ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

insert #t2 SELECT * FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
-------------------------------------4
DECLARE @month TINYINT=4,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')


SELECT rf_idCase, AmountPayment, ENP, @month AS ReportMonth, ReportYear, @dd AS dd ,pid INTO #t  FROM dbo.tmpDSB2019 WHERE ReportYear=@year AND ReportMonth<=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year ,@dd, pid FROM dbo.DNPersons1920_NEW WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
--ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

insert #t2 SELECT * FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
-------------------------------------5
DECLARE @month TINYINT=5,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, @month AS ReportMonth, ReportYear, @dd AS dd ,pid INTO #t  FROM dbo.tmpDSB2019 WHERE ReportYear=@year AND ReportMonth<=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year ,@dd ,pid FROM dbo.DNPersons1920_NEW WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
--ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU
insert #t2 SELECT * FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
-------------------------------------6
DECLARE @month TINYINT=6,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, @month AS ReportMonth, ReportYear, @dd AS dd ,pid INTO #t  FROM dbo.tmpDSB2019 WHERE ReportYear=@year AND ReportMonth<=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year ,@dd ,pid FROM dbo.DNPersons1920_NEW WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
--ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

insert #t2 SELECT * FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
-------------------------------------7
DECLARE @month TINYINT=7,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, @month AS ReportMonth, ReportYear, @dd AS dd ,pid INTO #t  FROM dbo.tmpDSB2019 WHERE ReportYear=@year AND ReportMonth<=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year ,@dd ,pid FROM dbo.DNPersons1920_NEW WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
--ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

insert #t2 SELECT * FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
-------------------------------------8
DECLARE @month TINYINT=8,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, @month AS ReportMonth, ReportYear, @dd AS dd ,pid INTO #t  FROM dbo.tmpDSB2019 WHERE ReportYear=@year AND ReportMonth<=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year ,@dd ,pid FROM dbo.DNPersons1920_NEW WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
--ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

insert #t2 SELECT * FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
-------------------------------------9
DECLARE @month TINYINT=9,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, @month AS ReportMonth, ReportYear, @dd AS dd ,pid INTO #t  FROM dbo.tmpDSB2019 WHERE ReportYear=@year AND ReportMonth<=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year ,@dd ,pid FROM dbo.DNPersons1920_NEW WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
--ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

insert #t2 SELECT * FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
-------------------------------------10
DECLARE @month TINYINT=10,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, @month AS ReportMonth, ReportYear, @dd AS dd ,pid INTO #t  FROM dbo.tmpDSB2019 WHERE ReportYear=@year AND ReportMonth<=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year ,@dd ,pid FROM dbo.DNPersons1920_NEW WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
--ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU
insert #t2 SELECT * FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
-------------------------------------111
DECLARE @month TINYINT=11,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, @month AS ReportMonth, ReportYear, @dd AS dd ,pid INTO #t  FROM dbo.tmpDSB2019 WHERE ReportYear=@year AND ReportMonth<=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year ,@dd ,pid FROM dbo.DNPersons1920_NEW WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
--ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

insert #t2 SELECT * FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
-------------------------------------12
DECLARE @month TINYINT=12,
		@year SMALLINT=2019,
		@dd DATE
SET @dd=DATEADD(MONTH,1,'2019'+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01')

SELECT rf_idCase, AmountPayment, ENP, @month AS ReportMonth, ReportYear, @dd AS dd ,pid INTO #t  FROM dbo.tmpDSB2019 WHERE ReportYear=@year AND ReportMonth<=@month
UNION all
SELECT 1, 0.0, ENP, @month, @year ,@dd ,pid FROM dbo.DNPersons1920_NEW WHERE YEAR=@year

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
--ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)

EXEC Utility.dbo.sp_GetIdPolisLPU

insert #t2 SELECT * FROM #t  WHERE sid IS NOT NULL
GO
DROP TABLE #t
GO
--DROP TABLE tmpBSB2019
SELECT * INTO tmpBSB2019 FROM #t2 WHERE sid IS NOT NULL
GO
DROP TABLE #t2

---------------------------------------
DECLARE @year INT=2019

SELECT * INTO #t FROM tmpBSB2019

;WITH cteTotal
AS(
SELECT DISTINCT ReportMonth,t.enp AS Col3,NULL AS Col4
FROM #t t
WHERE t.ReportYear=@year
UNION all
SELECT DISTINCT t.ReportMonth,null, t.enp  AS Col4
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN #t t ON
			p.ENP=t.enp							
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					inner JOIN t_PurposeOfVisit pv ON
             c.id=pv.rf_idCase
WHERE a.ReportYear=t.ReportYear AND t.ReportMonth=a.ReportMonth AND f.TypeFile='H'AND c.rf_idV006 =3 AND pv.rf_idV025='1.3'  AND c.rf_idV002 IN(29,42,53,57,97)
)
SELECT c.ReportMonth,COUNT(DISTINCT c.Col3) AS Col3,COUNT(DISTINCT c.Col4) AS Col4
FROM cteTotal c GROUP BY c.ReportMonth ORDER BY c.ReportMonth

SELECT COUNT(DISTINCT t.ENP)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN #t t ON
			p.ENP=t.enp							
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					inner JOIN t_PurposeOfVisit pv ON
             c.id=pv.rf_idCase
WHERE a.ReportYear=t.ReportYear AND t.ReportMonth=a.ReportMonth AND f.TypeFile='H'AND c.rf_idV006 =3 AND pv.rf_idV025='1.3' AND t.sid IS NOT NULL  AND c.rf_idV002 IN(29,42,53,57,97)
GO
DROP TABLE #t