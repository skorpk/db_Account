USE PlanDD
GO
alter PROCEDURE usp_173N_Table1
		@dateStartReg DATETIME,
		@dateEndReg DATETIME,
		@dateStartRegRAK DATETIME,
		@dateEndRegRAK DATETIME,
		@reportYear SMALLINT,
		@reportMonth TINYINT
as
DECLARE @firstDayNextMonth DATE
SET @firstDayNextMonth=(CASE WHEN @reportMonth>1 THEN DATEADD(MONTH,1,'2021'+RIGHT('0'+CAST(@reportMonth AS VARCHAR(2)),2)+'01') ELSE '20210201' END) 

CREATE TABLE #tDiagI(idrow TINYINT,DiagnosisCode VARCHAR(6))
INSERT #tDiagI(idrow,DiagnosisCode)
VALUES(1,'I10'),(2,'I11'),(3,'I11.0'),(4,'I11.9'),(5,'I12'),(6,'I12.0'),(7,'I12.9'),(8,'I13'),(9,'I13.0'),(10,'I13.1'),(11,'I13.2'),(12,'I13.9'),
(13,'I15'),(14,'I15.0'),(15,'I15.1'),(16,'I15.2'),(17,'I15.8'),(18,'I15.9'),(19,'I20.1'),(20,'I20.8'),(21,'I20.9'),(22,'I25.0'),(23,'I25.1'),
(24,'I25.2'),(25,'I25.5'),(26,'I25.6'),(27,'I25.8'),(28,'I25.9'),(29,'I47'),(30,'I47.0'),(31,'I47.1'),(32,'I47.2'),(33,'I47.9'),(34,'I48'),
(35,'I48.0'),(36,'I48.1'),(37,'I48.2'),(38,'I48.3'),(39,'I48.4'),(40,'I48.9'),(41,'I50'),(42,'I50.0'),(43,'I50.1'),(44,'I50.9'),(45,'I67.8 '),
(46,'I65.2'),(47,'I69'),(48,'I69.0'),(49,'I69.1'),(50,'I69.2'),(51,'I69.3'),(52,'I69.4'),(53,'I69.8')

--берем только те ЛПУ у которых есть прикрепление взрослого населения
CREATE TABLE #LPU(CodeM CHAR(6))
INSERT #LPU(CodeM) VALUES('114504'),('124528'),('124530'),('134505'),('141016'),('141022'),('141023'),('141024'),('154602'),('161007'),('161015'),('174601'),('184603'),('251001'),
('251002'),('251003'),('254505'),('301001'),('311001'),('321001'),('331001'),('341001'),('351001'),('361001'),('371001'),('381001'),('391001'),('391002'),('401001'),('411001'),
('421001'),('431001'),('441001'),('451001'),('461001'),('471001'),('481001'),('491001'),('501001'),('511001'),('521001'),('531001'),('541001'),('551001'),('561001'),('571001'),
('581001'),('591001'),('601001'),('611001'),('621001'),('711001')

SELECT DISTINCT rf_idCase, c.AmountPayment,c.CodeM,c.ENP,c.rf_idRecordCasePatient,c.ReportMonth,c.DateEnd
INTO #tCases
FROM dbo.t_173N_First c 
WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg  AND c.ReportYear=@reportYear AND c.ReportMonth<=@reportMonth

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
PRINT('Query 4 -'+ CAST(@@ROWCOUNT AS VARCHAR(20)))

DELETE FROM #tCases WHERE AmountPayment=0.0

;WITH cteR
as
(
	SELECT ROW_NUMBER() OVER(PARTITION BY enp,d.Codem ORDER BY d.DateRegistration desc) AS idRow, ENP,@firstDayNextMonth AS dd,0 AS IsListOfDN,12 as ReportMonth, 0 AS TypeQ,d.CODEM
	FROM dbo.DN173N_First d INNER JOIN #tDiagI i ON
				d.DS=i.DiagnosisCode
				JOIN #LPU l ON
            d.CodeM=l.CodeM
	WHERE d.ReportYear=@reportYear
)
SELECT cteR.ENP,cteR.dd,cteR.IsListOfDN,cteR.ReportMonth,cteR.TypeQ,cteR.CODEM
INTO #t
FROM cteR WHERE cteR.idRow=1

PRINT('Insert 1 -'+ CAST(@@ROWCOUNT AS VARCHAR(20)))

ALTER TABLE #t ADD LPU CHAR(6)
ALTER TABLE #t ADD Q CHAR(5)
ALTER TABLE #t ADD PID INT
ALTER TABLE #t ADD [sid] INT
ALTER TABLE #t ADD [lid] INT

CREATE UNIQUE NONCLUSTERED INDEX IX_1 ON #t(ENP) INCLUDE(PID) WITH IGNORE_DUP_KEY

;WITH cteI
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY enp,CodeM ORDER BY DateEnd DESC,rf_idCase desc) AS idRow,ENP,@firstDayNextMonth AS dd,1 AS IsListOfDN, ReportMonth,CodeM FROM #tCases 
	)
INSERT #t(enp,dd,IsListOfDN,ReportMonth,TypeQ,CODEM) 
SELECT i.ENP,i.dd,i.IsListOfDN,i.ReportMonth,1,i.CodeM
FROM cteI i WHERE i.idRow=1

PRINT('Insert 2 -'+ CAST(@@ROWCOUNT AS VARCHAR(20)))

UPDATE e SET PID=p.Id
FROM #t e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP
CREATE NONCLUSTERED INDEX IX_2 ON #t(Pid) INCLUDE(dd,sid,lid,lpu,Q,ReportMonth)


EXEC Utility.dbo.sp_GetIdPolisLPU


SELECT t.COdeM, l.NAMES,COUNT(DISTINCT ENP) AS col1 
FROM #t t JOIN dbo.vw_sprT001 l ON
		t.CODEM=l.CodeM
WHERE [sid] IS NOT NULL	
GROUP BY t.COdeM, l.NAMES
ORDER BY t.CodeM

DROP TABLE #t
DROP TABLE #tCases
DROP TABLE #tDiagI
DROP TABLE #LPU
go