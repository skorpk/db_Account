USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20200623',--'20200516',--'20200516',-- за апрель
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME=GETDATE(),--'20200516',--'20200516',--20200516 за апрель
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=5,
		@firstDayNextMonth DATE='20200601' --дата актуализации на РС ЗС 20200501 за апрель


SELECT DiagnosisCode ,MainDS INTO #tDiag 
FROM dbo.vw_sprMKB10 WHERE DiagnosisCode IN('I00','I01.0','I01.1','I01.8','I01.9','I02.9','I05.0','I05.1','I05.2','I05.8','I05.9','I06.0','I06.1','I06.2','I06.8','I06.9',
											'I07.2','I07.8','I07.9','I08.0','I08.1','I08.3','I08.9','I09.0','I09.8','I09.9','I10','I11.0','I11.9','I12.0','I12.9','I13.0',
											'I13.1','I13.2','I13.9','I15.0','I15.1','I15.2','I15.8','I15.9','I20.0','I20.1','I20.8','I20.9','I25.0','I25.1','I25.2','I25.3',
											'I25.4','I25.5','I25.6','I25.8','I25.9','I31.0','I31.1','I31.9','I34.0','I34.1','I34.2','I34.8','I34.9','I35.0','I35.1','I35.2',
											'I35.8','I35.9','I36.0','I36.1','I37.0','I37.2','I37.8','I38','I42.0','I42.1','I42.2','I42.5','I42.6','I42.7','I42.8','I42.9',
											'I44.0','I44.1','I44.2','I44.3','I44.4','I44.6','I44.7','I45.0','I45.1','I45.3','I45.5','I45.6','I45.8','I45.9','I47.0','I47.1',
											'I47.2','I47.9','I48.0','I48.1','I48.2','I48.3','I48.4','I48.9','I49.0','I49.1','I49.2','I49.3','I49.4','I49.5','I49.8','I49.9',
											'I50.0','I50.1','I50.9','I51.0','I51.4','I51.5','I51.9','I65.2','I67.0','I67.1','I67.2','I67.3','I67.4','I67.5','I67.7','I67.8','I67.9',
											'I69.0','I69.1','I69.2','I69.3','I69.4','I69.8','I70.0','I70.1','I70.2','I70.8','I70.9','I95.0','I95.1','I95.8','I95.9','I97.0',
											'I97.1')

CREATE TABLE #tDiagI(idrow TINYINT,Diagnosis VARCHAR(6), TypeDiag TINYINT)
INSERT #tDiagI(idrow,Diagnosis,TypeDiag)
VALUES(1,'I20.1',1),(2,'I20.8',1),(3,'I20.9',1),(4,'I25.0',1),(5,'I25.1',1),(6,'I25.2',1),(7,'I25.5',1),(8,'I25.6',1),(9,'I25.8',1),(10,'I25.9',1),
(11,'I10',2),(12,'I11',2),(13,'I12',2),(14,'I13',2),(15,'I15',2),(16,'I50.0',1),(17,'I50.1',1),(18,'I50.9',1),(19,'I48',2),(20,'I47',2),(21,'I65.2',1),
(22,'I69.0',1),(23,'I69.1',1),(24,'I69.2',1),(25,'I69.3',1),(26,'I69.4',1),(27,'I67.8',1)


CREATE UNIQUE NONCLUSTERED INDEX ix_1 ON #tDiag(DiagnosisCode)

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,dd.DS1,c.rf_idRecordCasePatient,f.DateRegistration,a.ReportMonth,pv.DN,d.MainDS
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
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DS1=d.DiagnosisCode
					inner JOIN t_PurposeOfVisit pv ON
             c.id=pv.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND f.TypeFile='H'
	 AND c.rf_idV006 =3 AND pv.rf_idV025='1.3' AND pv.DN IN (1,2) AND c.Age>17

PRINT('Query 1 -'+ CAST(@@ROWCOUNT AS VARCHAR(20)))

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,dd.DiagnosisCode,c.rf_idRecordCasePatient,f.DateRegistration,a.ReportMonth,c.IsNeedDisp,d.MainDS
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
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND f.TypeFile='F'
	 AND c.rf_idV006 =3 AND c.IsNeedDisp IN(1,2) AND c.Age>17
PRINT('Query 2 -'+ CAST(@@ROWCOUNT AS VARCHAR(20)))
INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,dd.DiagnosisCode,c.rf_idRecordCasePatient,f.DateRegistration,a.ReportMonth,dd.IsNeedDisp,d.MainDS
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
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiag d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear  AND f.TypeFile='F'
	 AND c.rf_idV006 =3 AND dd.IsNeedDisp IN(1,2) AND c.Age>17
PRINT('Query 3 -'+ CAST(@@ROWCOUNT AS VARCHAR(20)))

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

PRINT('Query 4 -'+ CAST(@@ROWCOUNT AS VARCHAR(20)))
---дата актуализации на РЗ

SELECT DISTINCT ENP,@firstDayNextMonth AS dd, 1 AS IsListOfDN, 1 AS ReportMonth,DS AS DS1
	, CASE WHEN CHARINDEX('.',DS)>0 THEN SUBSTRING(DS,0,CHARINDEX('.',DS)) ELSE DS END AS MainDS 
INTO #t 
FROM dbo.DNPersons2020
UNION 
SELECT DISTINCT Enp,@firstDayNextMonth AS dd ,2, ReportMonth,DS1, MainDS FROM #tCases WHERE AmountPayment>0 and ReportMonth<=@reportMonth

PRINT(@@ROWCOUNT)

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

;WITH cte
AS(
SELECT DISTINCT DS1, ENP AS AllENP,NULL AS AprilENP,mainDS FROM #t WHERE [sid] IS NOT NULL
UNION ALL
SELECT DISTINCT d.DS1, NULL,d.ENP,d.MainDS
FROM #tCases d INNER JOIN #t e ON
			d.ENP=e.enp
WHERE e.[sid] IS NOT NULL AND d.ReportMonth=@reportMonth AND dn=2 
AND NOT EXISTS(SELECT 1 FROM #t tt WHERE tt.enp=e.ENP AND tt.ReportMonth<@reportMonth)
)
SELECT * INTO #tTotal FROM cte e 

--SELECT t.AllENP,t.AprilENP,d.idrow,d.Diagnosis
--FROM #tTotal t INNER JOIN #tDiagI d ON
--	t.DS1=d.Diagnosis
--WHERE d.TypeDiag=1 AND t.DS1='I67.8'

;WITH cte
AS(
	SELECT t.AllENP,t.AprilENP,d.idrow,d.Diagnosis
	FROM #tTotal t INNER JOIN #tDiagI d ON
		t.DS1=d.Diagnosis
	WHERE d.TypeDiag=1
	UNION ALL
	SELECT t.AllENP,t.AprilENP,d.idrow,d.Diagnosis
	FROM #tTotal t INNER JOIN #tDiagI d ON
		t.MainDS=d.Diagnosis
	WHERE d.TypeDiag=2
	UNION ALL
	SELECT t.AllENP,t.AprilENP,28,t.DS1
	FROM #tTotal t
	WHERE NOT EXISTS(SELECT 1 FROM #tDiagI d WHERE d.Diagnosis=t.MainDS OR d.Diagnosis=t.DS1)
	UNION ALL--добавляем диагнозы из отчета по которым нет сведений
    SELECT NULL,NULL,d.idrow,d.Diagnosis
	FROM #tDiagI d
	WHERE NOT EXISTS(SELECT 1 FROM #tTotal t WHERE d.Diagnosis=t.MainDS OR d.Diagnosis=t.DS1)
)
SELECT c.idrow,ROW_NUMBER() OVER(ORDER BY c.idrow,c.Diagnosis) AS IdRow2,m.Diagnosis,c.Diagnosis,COUNT(DISTINCT c.AllENP), COUNT(DISTINCT c.AprilENP)
FROM cte c INNER JOIN dbo.vw_sprMKB10 m ON
		c.Diagnosis=m.DiagnosisCode
GROUP BY c.idrow,c.Diagnosis,m.Diagnosis
ORDER BY c.idrow,c.Diagnosis		
go
DROP TABLE #tCases
go
DROP TABLE #tDiag
GO
DROP TABLE #tDiagI
GO
DROP TABLE #t
GO
DROP TABLE #tTotal