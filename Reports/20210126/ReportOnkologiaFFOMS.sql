USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20210116',
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME='20210119',
		@reportYear SMALLINT=2020

CREATE TABLE #tDiag(id TINYINT,DiagnosisCode VARCHAR(10))
CREATE TABLE #tMuSur(id SMALLINT, MUSurgery VARCHAR(15))

INSERT #tDiag VALUES(0,'Z03.1')
insert #tDiag SELECT 1 AS id,  DiagnosisCode FROM dbo.vw_sprMKB10 WHERE  MainDS BETWEEN 'C00' AND 'C14' 
insert #tDiag SELECT 2 AS id,  DiagnosisCode FROM dbo.vw_sprMKB10 WHERE  MainDS between 'C15' and 'C26' 
insert #tDiag SELECT 3 AS id,  DiagnosisCode FROM dbo.vw_sprMKB10 WHERE  MainDS between 'C30' and 'C39' 	
insert #tDiag SELECT 4 AS id,  DiagnosisCode FROM dbo.vw_sprMKB10 WHERE  MainDS between 'C40' and 'C41' 
insert #tDiag SELECT 5 AS id,  DiagnosisCode FROM dbo.vw_sprMKB10 WHERE  MainDS between 'C43' and 'C44' 
insert #tDiag SELECT 6 AS id,  DiagnosisCode FROM dbo.vw_sprMKB10 WHERE  MainDS between 'C45' and 'C49' 
insert #tDiag SELECT 7 AS id,  DiagnosisCode FROM dbo.vw_sprMKB10 WHERE  MainDS ='C50'
insert #tDiag SELECT 8 AS id,  DiagnosisCode FROM dbo.vw_sprMKB10 WHERE  MainDS between 'C51' and 'C58' 
insert #tDiag SELECT 9 AS id,  DiagnosisCode FROM dbo.vw_sprMKB10 WHERE  MainDS between 'C60' and 'C63' 
insert #tDiag SELECT 10 AS id, DiagnosisCode FROM dbo.vw_sprMKB10 WHERE  MainDS between 'C64' and 'C68' 
insert #tDiag SELECT 11 AS id, DiagnosisCode FROM dbo.vw_sprMKB10 WHERE  MainDS between 'C69' and 'C72' 
insert #tDiag SELECT 12 AS id, DiagnosisCode FROM dbo.vw_sprMKB10 WHERE  MainDS between 'C76' and 'C80' 	
insert #tDiag SELECT 13 AS id, DiagnosisCode FROM dbo.vw_sprMKB10 WHERE  MainDS between 'C81' and 'C96' 
insert #tDiag SELECT 15 AS id, DiagnosisCode FROM dbo.vw_sprMKB10 WHERE  MainDS between 'D00' and 'D09' 
insert #tDiag SELECT 14 AS id, DiagnosisCode FROM dbo.vw_sprMKB10 WHERE  MainDS ='C97'


INSERT #tMuSur(id,MUSurgery)VALUES(6,'A06.03.002'),(7,'A06.03.002.005'),(8,'A06.03.021.001'),(9,'A06.03.021.002'),(10,'A06.03.036.001'),(11,'A06.03.036.002'),(12,'A06.03.058'),(13,'A06.03.058.003'),
(14,'A06.03.062'),(15,'A06.03.069'),(16,'A06.04.017'),(17,'A06.04.020'),(18,'A06.07.013'),(19,'A06.08.007'),(20,'A06.08.007.001'),(21,'A06.08.007.002'),(22,'A06.08.007.004'),(23,'A06.08.009'),
(24,'A06.08.009.001'),(25,'A06.08.009.002'),(26,'A06.09.005'),(27,'A06.09.005.002'),(28,'A06.09.008.001'),(29,'A06.09.011'),(30,'A06.11.004'),(31,'A06.11.004.001'),(32,'A06.17.007'),(33,'A06.17.007.001'),
(34,'A06.18.004.002'),(35,'A06.18.004.003'),(36,'A06.20.002'),(37,'A06.20.002.001'),(38,'A06.20.002.002'),(39,'A06.20.002.003'),(40,'A06.20.004'),(41,'A06.21.003'),(42,'A06.21.003.001'),(43,'A06.21.003.002'),
(44,'A06.21.003.003'),(45,'A06.22.002'),(46,'A06.22.002.001'),(47,'A06.23.004'),(48,'A06.23.004.002'),(49,'A06.23.004.006'),(50,'A06.23.004.007'),(51,'A06.25.003'),(52,'A06.25.003.002'),(53,'A06.26.006'),
(54,'A06.26.006.001'),(55,'A06.28.009'),(56,'A06.28.009.001'),(57,'A06.28.009.002'),(58,'A06.30.005'),(59,'A06.30.005.001'),(60,'A06.30.005.002'),(61,'A06.30.005.003'),(62,'A06.30.005.005'),(63,'A06.30.007'),
(64,'A06.30.007.002'),(65,'A05.02.002'),(66,'A05.03.001'),(67,'A05.03.002'),(68,'A05.03.002.001'),(69,'A05.03.003'),(70,'A05.03.004'),(71,'A05.03.004.001'),(72,'A05.04.001'),(73,'A05.04.001.001'),
(74,'A05.08.002'),(75,'A05.08.003'),(76,'A05.08.004'),(77,'A05.09.001'),(78,'A05.11.001'),(79,'A05.15.001'),(80,'A05.17.001'),(81,'A05.17.001.001'),(82,'A05.18.001'),(83,'A05.18.001.001'),(84,'A05.20.003'),
(85,'A05.20.003.001'),(86,'A05.21.001'),(87,'A05.21.001.001'),(88,'A05.22.001'),(89,'A05.22.001.001'),(90,'A05.22.002'),(91,'A05.22.002.001'),(92,'A05.23.009'),(93,'A05.23.009.001'),(94,'A05.23.009.010'),
(95,'A05.23.009.011'),(96,'A05.26.008'),(97,'A05.26.008.001'),(98,'A05.28.002'),(99,'A05.28.002.001'),(100,'A05.30.004'),(101,'A05.30.004.001'),(102,'A05.30.005'),(103,'A05.30.005.001'),(104,'A05.30.006'),(105,'A05.30.006.001'),
(106,'A05.30.007'),(107,'A05.30.007.001'),(108,'A05.30.008'),(109,'A05.30.008.001'),(110,'A05.30.010'),(111,'A05.30.010.001'),(112,'A05.30.011'),(113,'A05.30.011.001'),(114,'A05.30.011.002'),
(115,'A05.30.012'),(116,'A05.30.012.001'),(117,'A05.30.012.002'),(118,'A06.30.002.002'),(119,'A06.30.002.003'),(120,'A06.30.002.004'),(121,'A06.30.002.005'),(122,'A06.30.002.006'),
(123,'A07.30.001'),(124,'A07.30.001.001'),(125,'A08.30.046'),(126,'A08.30.046.001'),(127,'A08.30.046.002'),(128,'A08.30.046.003'),(129,'A08.30.046.004'),(130,'A08.30.046.005'),(131,'A08.30.046.006'),
(132,'A08.30.046.007'),(133,'A08.30.046.008'),(134,'A08.30.046.009'),(135,'A08.30.046.010'),(136,'A08.30.046.011'),(137,'A08.30.046.012'),(138,'A08.30.046.013'),(139,'A08.30.046.014'),(140,'A08.30.046.015'),
(141,'A08.01.001'),(142,'A08.01.001.001'),(143,'A08.01.001.002'),(144,'A08.01.002'),(145,'A08.01.004'),(146,'A08.01.005'),(147,'A08.01.006'),(148,'A08.02.001'),(149,'A08.02.001.001'),(150,'A08.02.001.002'),
(151,'A08.02.001.003'),(152,'A08.02.002'),(153,'A08.03.001'),(154,'A08.03.002'),(155,'A08.03.002.001'),(156,'A08.03.002.002'),(157,'A08.03.004'),(158,'A08.05.001'),(159,'A08.05.002'),(160,'A08.05.002.001'),
(161,'A08.05.002.002'),(162,'A08.05.012'),(163,'A08.06.001'),(164,'A08.06.002'),(165,'A08.06.002.001'),(166,'A08.06.002.002'),(167,'A08.06.003'),(168,'A08.06.003.001'),(169,'A08.06.003.002'),(170,'A08.06.004'),
(171,'A08.06.005'),(172,'A08.06.006'),(173,'A08.06.007'),(174,'A08.07.001'),(175,'A08.07.002'),(176,'A08.07.002.001'),(177,'A08.07.002.002'),(178,'A08.07.003'),(179,'A08.07.004'),(180,'A08.07.004.001'),
(181,'A08.07.004.002'),(182,'A08.07.005'),(183,'A08.07.005.001'),(184,'A08.07.005.002'),(185,'A08.07.006'),(186,'A08.07.007'),(187,'A08.07.007.001'),(188,'A08.07.007.002'),(189,'A08.07.008'),(190,'A08.07.009'),
(191,'A08.07.009.001'),(192,'A08.07.009.002'),(193,'A08.07.010'),(194,'A08.07.011'),(195,'A08.08.001'),(196,'A08.08.001.001'),(197,'A08.08.001.002'),(198,'A08.08.001.003'),(199,'A08.08.002'),(200,'A08.08.003'),
(201,'A08.08.004'),(202,'A08.08.005'),(203,'A08.08.006'),(204,'A08.09.001'),(205,'A08.09.001.001'),(206,'A08.09.001.002'),(207,'A08.09.001.003'),(208,'A08.09.002'),(209,'A08.09.002.001'),(210,'A08.09.002.002'),
(211,'A08.09.002.003'),(212,'A08.09.003'),(213,'A08.09.004'),(214,'A08.09.005'),(215,'A08.09.005.001'),(216,'A08.09.005.002'),(217,'A08.09.006'),(218,'A08.09.007'),(219,'A08.09.008'),(220,'A08.09.009'),
(221,'A08.11.001'),(222,'A08.11.003'),(223,'A08.12.001'),(224,'A08.14.001'),(225,'A08.14.001.001'),(226,'A08.14.001.002'),(227,'A08.14.001.003'),(228,'A08.14.004'),(229,'A08.14.004.001'),(230,'A08.14.005'),
(231,'A08.15.001'),(232,'A08.15.002'),(233,'A08.16.001'),(234,'A08.16.001.001'),(235,'A08.16.001.002'),(236,'A08.16.002'),(237,'A08.16.002.001'),(238,'A08.16.002.002'),(239,'A08.16.003'),(240,'A08.16.003.001'),
(241,'A08.16.003.002'),(242,'A08.17.001'),(243,'A08.17.001.001'),(244,'A08.17.001.002'),(245,'A08.17.001.003'),(246,'A08.17.002'),(247,'A08.18.001'),(248,'A08.18.001.001'),(249,'A08.18.001.002'),(250,'A08.18.001.003'),
(251,'A08.18.002'),(252,'A08.18.003'),(253,'A08.18.003.001'),(254,'A08.19.001'),(255,'A08.19.001.001'),(256,'A08.19.001.002'),(257,'A08.19.002'),(258,'A08.19.002.001'),(259,'A08.19.002.002'),(260,'A08.20.001'),
(261,'A08.20.001.001'),(262,'A08.20.001.002'),(263,'A08.20.002'),(264,'A08.20.002.001'),(265,'A08.20.002.002'),(266,'A08.20.003'),(267,'A08.20.003.001'),(268,'A08.20.003.002'),(269,'A08.20.005'),
(270,'A08.20.005.001'),(271,'A08.20.005.002'),(272,'A08.20.006'),(273,'A08.20.006.001'),(274,'A08.20.006.002'),(275,'A08.20.007'),(276,'A08.20.007.001'),(277,'A08.20.008'),(278,'A08.20.008.001'),
(279,'A08.20.009'),(280,'A08.20.009.001'),(281,'A08.20.009.002'),(282,'A08.20.011'),(283,'A08.20.016'),(284,'A08.21.001'),(285,'A08.21.001.001'),(286,'A08.21.001.002'),(287,'A08.21.001.003'),
(288,'A08.21.002'),(289,'A08.21.002.001'),(290,'A08.21.002.002'),(291,'A08.21.002.003'),(292,'A08.21.003'),(293,'A08.21.003.001'),(294,'A08.21.003.002'),(295,'A08.21.004'),(296,'A08.21.004.001'),
(297,'A08.22.002'),(298,'A08.22.002.001'),(299,'A08.22.002.002'),(300,'A08.22.003'),(301,'A08.22.003.001'),(302,'A08.22.003.002'),(303,'A08.22.006'),(304,'A08.22.006.001'),(305,'A08.22.006.002'),
(306,'A08.22.007'),(307,'A08.22.007.001'),(308,'A08.22.007.002'),(309,'A08.22.008'),(310,'A08.23.001'),(311,'A08.23.002'),(312,'A08.23.002.001'),(313,'A08.23.002.002'),(314,'A08.23.002.003'),
(315,'A08.24.001'),(316,'A08.24.001.001'),(317,'A08.24.001.002'),(318,'A08.26.004'),(319,'A08.26.004.001'),(320,'A08.26.004.002'),(321,'A08.26.004.003'),(322,'A08.28.004'),(323,'A08.28.004.001'),
(324,'A08.28.005'),(325,'A08.28.005.001'),(326,'A08.28.005.002'),(327,'A08.28.005.003'),(328,'A08.28.009'),(329,'A08.28.009.001'),(330,'A08.28.009.002'),(331,'A08.28.009.003'),(332,'A08.30.002'),
(333,'A08.30.012'),(334,'A08.30.012.001'),(335,'A08.30.012.002'),(336,'A08.30.013'),(337,'A08.30.013.001'),(338,'A08.30.014'),(339,'A08.30.015'),(340,'A08.30.032'),(341,'A08.30.033'),(342,'A08.30.034'),
(343,'A08.30.036'),(344,'A08.30.037'),(345,'A08.30.038'),(346,'A08.30.039'),(347,'A08.30.040'),(348,'A08.30.041'),(349,'A08.30.042'),(350,'A08.30.043'),(351,'A08.30.044'),(352,'A08.30.045'),(353,'A27.05.040'),
(354,'A27.05.041'),(355,'A27.05.042'),(356,'A27.05.046'),(357,'A27.05.049 '),(358,'A27.05.050'),(359,'A27.05.051'),(360,'A27.05.052'),(361,'A27.30.001'),(362,'A27.30.002'),(363,'A27.30.006'),(364,'A27.30.007'),
(365,'A27.30.008'),(366,'A27.30.009'),(367,'A27.30.010'),(368,'A27.30.011'),(369,'A27.30.012'),(370,'A27.30.013'),(371,'A27.30.014'),(372,'A27.30.015'),(373,'A27.30.016'),(374,'A27.30.017'),
(375,'A27.30.018'),(376,'A27.30.019'),(377,'A27.30.020'),(378,'A27.30.022'),(379,'A27.30.023'),(380,'A27.30.047'),(381,'A27.30.059'),(382,'A27.30.061'),(383,'A27.3 0.064'),(384,'A27.30.065'),
(385,'A27.30.078'),(386,'A27.30.079'),(387,'A27.30.083'),(388,'A27.30.084')


SELECT c.id AS rf_idCase, c.AmountPayment,d.DiagnosisCode,dd.id AS rf_idDS1Group, mu.id AS rf_idMUSur,SUM(m.Quantity) AS Quantity
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles					
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase	
					INNER JOIN #tDiag dd ON
			d.DiagnosisCode	=dd.DiagnosisCode
					INNER JOIN dbo.t_Meduslugi m ON
            c.id=m.rf_idCase
					INNER JOIN #tMuSur mu ON
            m.MUSurgery=mu.MUSurgery
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND  c.rf_idV006=3  AND d.TypeDiagnosis=1
		AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.rf_idCase=c.id AND mm.MUGroupCode=60 AND mm.MUUnGroupCode IN(4,5,7,8,9))
GROUP BY c.id, c.AmountPayment,d.DiagnosisCode,f.CodeM,dd.id, mu.id

PRINT('All Cases')

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #t WHERE AmountPayment=0.0
PRINT('ÓäAëÿåì')

SELECT m.id,m.MUSurgery
		,cast(SUM(CASE WHEN rf_idDS1Group=0 THEN t.Quantity ELSE 0 END)  as int) AS Col2
		,cast(SUM(CASE WHEN rf_idDS1Group=1 THEN t.Quantity ELSE 0 END)  as int) AS Col3
		,cast(SUM(CASE WHEN rf_idDS1Group=2 THEN t.Quantity ELSE 0 END)  as int) AS Col4
		,cast(SUM(CASE WHEN rf_idDS1Group=3 THEN t.Quantity ELSE 0 END)  as int) AS Col5
		,cast(SUM(CASE WHEN rf_idDS1Group=4 THEN t.Quantity ELSE 0 END)  as int) AS Col6
		,cast(SUM(CASE WHEN rf_idDS1Group=5 THEN t.Quantity ELSE 0 END)  as int) AS Col7
		,cast(SUM(CASE WHEN rf_idDS1Group=6 THEN t.Quantity ELSE 0 END)  as int) AS Col8
		,cast(SUM(CASE WHEN rf_idDS1Group=7 THEN t.Quantity ELSE 0 END)  as int) AS Col9
		,cast(SUM(CASE WHEN rf_idDS1Group=8 THEN t.Quantity ELSE 0 END)  as int) AS Col10
		,cast(SUM(CASE WHEN rf_idDS1Group=9 THEN t.Quantity ELSE 0 END)  as int) AS Col11
		,cast(SUM(CASE WHEN rf_idDS1Group=10 THEN t.Quantity ELSE 0 END) as int)  AS Col12
		,cast(SUM(CASE WHEN rf_idDS1Group=11 THEN t.Quantity ELSE 0 END) as int)  AS Col13
		,cast(SUM(CASE WHEN rf_idDS1Group=12 THEN t.Quantity ELSE 0 END) as int)  AS Col14
		,cast(SUM(CASE WHEN rf_idDS1Group=13 THEN t.Quantity ELSE 0 END) as int)  AS Col15
		,cast(SUM(CASE WHEN rf_idDS1Group=14 THEN t.Quantity ELSE 0 END) as int)  AS Col16
		,cast(SUM(CASE WHEN rf_idDS1Group=15 THEN t.Quantity ELSE 0 END) as int)  AS Col17
FROM #tMuSur m LEFT JOIN #t t ON
		m.id=t.rf_idMUSur
GROUP BY m.id,m.MUSurgery
ORDER BY m.id

GO
DROP TABLE #tMuSur
GO
DROP TABLE #t
GO
DROP TABLE #tDiag