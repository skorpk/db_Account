USE AccountOMS
GO
alter PROCEDURE usp_GetData_173N_First
as
DECLARE @dateStartReg DATETIME='20210101',
		@dateEndReg DATETIME=GETDATE(),
		@dateStartRegRAK DATETIME='20210101',
		@dateEndRegRAK DATETIME=GETDATE(),
		@reportYear SMALLINT=2021,
		@reportMonth TINYINT=12


--берем только те ЛПУ у которых есть прикрепление взрослого населения
CREATE TABLE #LPU(CodeM CHAR(6))
INSERT #LPU(CodeM) VALUES('114504'),('124528'),('124530'),('134505'),('141016'),('141022'),('141023'),('141024'),('154602'),('161007'),('161015'),('174601'),('184603'),('251001'),
('251002'),('251003'),('254505'),('301001'),('311001'),('321001'),('331001'),('341001'),('351001'),('361001'),('371001'),('381001'),('391001'),('391002'),('401001'),('411001'),
('421001'),('431001'),('441001'),('451001'),('461001'),('471001'),('481001'),('491001'),('501001'),('511001'),('521001'),('531001'),('541001'),('551001'),('561001'),('571001'),
('581001'),('591001'),('601001'),('611001'),('621001'),('711001')


CREATE TABLE #tDiagI(idrow TINYINT,DiagnosisCode VARCHAR(6))
INSERT #tDiagI(idrow,DiagnosisCode)
VALUES(1,'I10'),(2,'I11'),(3,'I11.0'),(4,'I11.9'),(5,'I12'),(6,'I12.0'),(7,'I12.9'),(8,'I13'),(9,'I13.0'),(10,'I13.1'),(11,'I13.2'),(12,'I13.9'),
(13,'I15'),(14,'I15.0'),(15,'I15.1'),(16,'I15.2'),(17,'I15.8'),(18,'I15.9'),(19,'I20.1'),(20,'I20.8'),(21,'I20.9'),(22,'I25.0'),(23,'I25.1'),
(24,'I25.2'),(25,'I25.5'),(26,'I25.6'),(27,'I25.8'),(28,'I25.9'),(29,'I47'),(30,'I47.0'),(31,'I47.1'),(32,'I47.2'),(33,'I47.9'),(34,'I48'),
(35,'I48.0'),(36,'I48.1'),(37,'I48.2'),(38,'I48.3'),(39,'I48.4'),(40,'I48.9'),(41,'I50'),(42,'I50.0'),(43,'I50.1'),(44,'I50.9'),(45,'I67.8 '),
(46,'I65.2'),(47,'I69'),(48,'I69.0'),(49,'I69.1'),(50,'I69.2'),(51,'I69.3'),(52,'I69.4'),(53,'I69.8')

SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,f.CodeM,p.ENP,c.rf_idRecordCasePatient,a.ReportMonth,1 AS TypeQ,c.DateEnd
,a.ReportYear,f.DateRegistration
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					JOIN #LPU l ON
            f.CodeM=l.CodeM
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiagI d ON
             dd.DS1=d.DiagnosisCode
					inner JOIN t_PurposeOfVisit pv ON
             c.id=pv.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear>=@reportYear AND f.TypeFile='H' AND a.ReportMonth<=@reportMonth
	 AND c.rf_idV006 =3  AND pv.DN IN (1,2) AND c.Age>17 AND a.rf_idSMO<>'34'

PRINT('Query 1 -'+ CAST(@@ROWCOUNT AS VARCHAR(20)))
INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,f.CodeM,p.ENP,c.rf_idRecordCasePatient,a.ReportMonth,2,c.DateEnd,a.ReportYear,f.DateRegistration
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					JOIN #LPU l ON
            f.CodeM=l.CodeM
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiagI d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND f.TypeFile='F' AND a.ReportMonth<=@reportMonth
	 AND c.rf_idV006 =3 AND c.IsNeedDisp IN(1,2) AND c.Age>17 AND a.rf_idSMO<>'34'
PRINT('Query 2 -'+ CAST(@@ROWCOUNT AS VARCHAR(20)))
INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,f.CodeM,p.ENP,c.rf_idRecordCasePatient,a.ReportMonth,3,c.DateEnd,a.ReportYear,f.DateRegistration
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					JOIN #LPU l ON
            f.CodeM=l.CodeM
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient							
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase						
					INNER JOIN #tDiagI d ON
             dd.DiagnosisCode=d.DiagnosisCode	
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear  AND f.TypeFile='F' AND a.ReportMonth<=@reportMonth
	 AND c.rf_idV006 =3 AND dd.IsNeedDisp IN(1,2) AND c.Age>17 AND a.rf_idSMO<>'34'
PRINT('Query 3 -'+ CAST(@@ROWCOUNT AS VARCHAR(20)))

SELECT rf_idCase,AmountPayment,CodeM,ENP,rf_idRecordCasePatient,ReportMonth,DateEnd,ReportYear,DateRegistration INTO tmp_173N_First FROM #tCases

DROP TABLE #tCases
DROP TABLE #tDiagI
DROP TABLE #LPU
go
