USE AccountOMS
go
DECLARE @dateStartReg DATETIME='20170101',
		@dateEndReg DATETIME='20190125',
		@dateStartRegRAK DATETIME='20170101',
		@dateEndRegRAK DATETIME=GETDATE()
		

SELECT DiagnosisCode ,MainDS INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'I00' AND 'I99'

CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tDiag(DiagnosisCode)
---------------------------------------------------2018-------------------------------------------------
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportMonth,a.ReportYear,c.Age
		,DATEADD(MONTH,1,(CAST(a.ReportYearMonth AS VARCHAR(6))+'01')) AS dd, d.MainDS
INTO #t
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
					INNER JOIN #tDiag d ON
             dd.DS1=d.DiagnosisCode
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=2018 AND f.TypeFile='H' AND c.rf_idV006 =3 AND c.Age>16 AND a.rf_idSMO<>'34'

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportMonth,a.ReportYear,c.age
		,DATEADD(MONTH,1,(CAST(a.ReportYearMonth AS VARCHAR(6))+'01')) AS dd,d.MainDS
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient							
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear =2018  AND f.TypeFile='F'
	 AND c.rf_idV006 =3  AND c.Age>16 AND a.rf_idSMO<>'34'

INSERT #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportMonth,a.ReportYear,c.Age
		,DATEADD(MONTH,1,(CAST(a.ReportYearMonth AS VARCHAR(6))+'01')) AS dd,d.MainDS
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient						
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear =2018 AND f.TypeFile='F' AND c.rf_idV006 =3  AND c.Age>16 AND a.rf_idSMO<>'34'

-------------------------------------------2017-----------------------------------------
INSERT #t
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,p.ENP,a.ReportMonth,a.ReportYear,c.Age
		,DATEADD(MONTH,1,(CAST(a.ReportYearMonth AS VARCHAR(6))+'01')) AS dd,d.MainDS
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP p ON
            c.id=p.rf_idCase
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DS1=d.DiagnosisCode					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=2017 AND f.TypeFile='H' AND c.rf_idV006 <4 AND c.Age>16 AND a.rf_idSMO<>'34'
	AND p.enp IS NOT NULL

DELETE FROM #t WHERE Age<18

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) 

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP
WHERE e.AmountPayment>0

CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q)


EXEC Utility.dbo.sp_GetIdPolisLPU

;WITH cteTotal
AS(
SELECT DISTINCT ReportMonth, t.enp AS Col1
		--,RTRIM(enp)+t.MainDS AS Col1a
		,null AS Col2
FROM #t t
WHERE AmountPayment>0 AND t.sid IS NOT NULL
UNION all
SELECT DISTINCT t.ReportMonth,null,t.enp AS Col2		
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
WHERE a.ReportYear=t.ReportYear AND t.ReportMonth=a.ReportMonth AND f.TypeFile='H'AND c.rf_idV006 =3 AND pv.rf_idV025='1.3' AND t.sid IS NOT NULL AND t.AmountPayment>0 AND c.rf_idV002 IN(29,42,53,57,97)
)
SELECT c.ReportMonth,c.Col1 AS Col3,c.Col2 AS Col6
INTO #Total
FROM cteTotal c 

;WITH cte
AS(
SELECT a.ReportMonth, COUNT(DISTINCT a.Col3) AS Col3, COUNT(DISTINCT CASE WHEN a.ReportMonth=1 THEN a.Col6 ELSE NULL END) AS Col6
from #Total a WHERE a.ReportMonth=1
group by a.ReportMonth
UNION ALL
SELECT 2, COUNT(DISTINCT a.Col3) AS Col3, COUNT(DISTINCT CASE WHEN a.ReportMonth=2 THEN a.Col6 ELSE NULL END) AS Col6
from #Total a WHERE a.ReportMonth<=2
-----------------------------------------
UNION ALL
SELECT 3, COUNT(DISTINCT a.Col3) AS Col3, COUNT(DISTINCT CASE WHEN a.ReportMonth=3 THEN a.Col6 ELSE NULL END) AS Col6
from #Total a WHERE a.ReportMonth<=3
-----------------------------------------
UNION ALL
SELECT 4, COUNT(DISTINCT a.Col3) AS Col3, COUNT(DISTINCT CASE WHEN a.ReportMonth=4 THEN a.Col6 ELSE NULL END) AS Col6
from #Total a WHERE a.ReportMonth<=4
-----------------------------------------
UNION ALL
SELECT 5, COUNT(DISTINCT a.Col3) AS Col3, COUNT(DISTINCT CASE WHEN a.ReportMonth=5 THEN a.Col6 ELSE NULL END) AS Col6
from #Total a WHERE a.ReportMonth<=5
-----------------------------------------
UNION ALL
SELECT 6, COUNT(DISTINCT a.Col3) AS Col3, COUNT(DISTINCT CASE WHEN a.ReportMonth=6 THEN a.Col6 ELSE NULL END) AS Col6
from #Total a WHERE a.ReportMonth<=6
-----------------------------------------
UNION ALL
SELECT 7, COUNT(DISTINCT a.Col3) AS Col3, COUNT(DISTINCT CASE WHEN a.ReportMonth=7 THEN a.Col6 ELSE NULL END) AS Col6
from #Total a WHERE a.ReportMonth<=7
-----------------------------------------
UNION ALL
SELECT 8, COUNT(DISTINCT a.Col3) AS Col3, COUNT(DISTINCT CASE WHEN a.ReportMonth=8 THEN a.Col6 ELSE NULL END) AS Col6
from #Total a WHERE a.ReportMonth<=8
-----------------------------------------
UNION ALL
SELECT 9, COUNT(DISTINCT a.Col3) AS Col3, COUNT(DISTINCT CASE WHEN a.ReportMonth=9 THEN a.Col6 ELSE NULL END) AS Col6
from #Total a WHERE a.ReportMonth<=9
-----------------------------------------
UNION ALL
SELECT 10, COUNT(DISTINCT a.Col3) AS Col3, COUNT(DISTINCT CASE WHEN a.ReportMonth=10 THEN a.Col6 ELSE NULL END) AS Col6
from #Total a WHERE a.ReportMonth<=10
----------------------------------------------------------
UNION ALL
SELECT 11, COUNT(DISTINCT a.Col3) AS Col3, COUNT(DISTINCT CASE WHEN a.ReportMonth=11 THEN a.Col6 ELSE NULL END) AS Col6
from #Total a WHERE a.ReportMonth<=11
----------------------------------------------------------
UNION ALL
SELECT 12, COUNT(DISTINCT a.Col3) AS Col3, COUNT(DISTINCT CASE WHEN a.ReportMonth=12 THEN a.Col6 ELSE NULL END) AS Col6
from #Total a WHERE a.ReportMonth<=12
)
SELECT DISTINCT cte.ReportMonth,
       (cte.Col3),
       MAX(cte.Col6)
FROM cte
GROUP BY cte.ReportMonth,cte.Col3
ORDER BY cte.ReportMonth

go
--DROP TABLE #t
--GO
--DROP TABLE #tDiag
--GO
--DROP TABLE #Total