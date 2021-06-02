USE AccountOMSReports
GO
DECLARE @dtStart DATETIME='20160101',
		@dtEnd DATETIME='20170120',
		@reportYear SMALLINT=2016,
		@dtEndRAK DATETIME='20170120'

CREATE TABLE #tDiagnosis(DS1 VARCHAR(10), TypeCol TINYINT)

INSERT #tDiagnosis( DS1, TypeCol )
VALUES  ('C81.0',1),('C81.1',1),('C81.2',1),('C81.3',1),('C81.4',1),('C81.7',1),('C81.9',1),('C83.7',2),('C84.0',5),('C84.1',5),('C84.2',5),('C84.3',5),('C84.4',5),('C84.5',5),('C84.6',3),
		('C84.7',3),('C84.8',4),('C84.9',5),('C85.0',6),('C85.1',7),('C85.2',8),('C85.7',10),('C85.9',10),('C86.6',9)

CREATE TABLE #tName(id tinyint,NAME VARCHAR(250), DS VARCHAR(25))

INSERT #tName( id, NAME, DS )
VALUES  (1,'Лимфома Ходжкина (лимфогрануломатоз)','C81.0 - C81.9'),
(2,'Лимфома Беркитта','C83.7'),
(3,'Системная апластическая крупноклеточная лимфома (ALK-позитивная, ALK-отрицательная)','C84.6, C84.7'),
(4,'Кожная Т-клеточная лимфома','C84.8'),
(5,'Периферические и кожные Т-клеточные лимфомы','C84.0 - C84.9'),
(6,'Лимфосаркома','C85.0'),
(7,'В-клеточная лимфома неуточненная','C85.1'),
(8,'Медиастинальная (тимусная) большая В-клеточная лимфома','C85.2'),
(9,'Первичные кожные CD30-положительные пролиферации Т-клеток','C86.6')



SELECT c.id,a.rf_idSMO, m.MES, c.AmountPayment, c.AmountPayment AS AmountPaymentAcc,c.rf_idV008, CASE WHEN c.Age<18 THEN 1 ELSE 2 END AS Age, d1.TypeCol
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient				
				INNER JOIN t_Mes m ON
		c.id=m.rf_idCase              
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase												
				INNER JOIN #tDiagnosis d1 ON
		d.DS1=d1.DS1		              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND a.rf_idSMO<>'34'--a.rf_idSMO='34'

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase c
								WHERE c.DateRegistration>=@dtStart AND c.DateRegistration<@dtEndRAK
								GROUP BY c.rf_idCase
							) r ON
			p.id=r.rf_idCase
-------------------------Adults---------------------------
SELECT TypeCol, n.NAME,n.DS,COUNT(p.id) AS Col3,CAST(SUM(AmountPayment) AS MONEY) AS Col5, COUNT(CASE WHEN MES IN('1010137', '1020137', '1000140') THEN p.id ELSE NULL END) AS col7,
		COUNT(CASE WHEN rf_idV008=32 THEN p.id ELSE NULL END) AS Col9, 
		CAST(sum(CASE WHEN rf_idV008=32 THEN AmountPayment ELSE 0 END)  AS MONEY) AS Col11
FROM #tmpPeople	p INNER JOIN #tName n ON
			p.TypeCol=n.id
WHERE AmountPayment>0 AND Age=2
GROUP BY TypeCol, NAME,n.DS
ORDER BY TypeCol
--------------------------children--------------------------------
SELECT TypeCol, n.NAME, n.DS,COUNT(p.id) AS Col3,CAST(SUM(AmountPayment) AS MONEY) AS Col5, COUNT(CASE WHEN MES IN('1010032', '1020032') THEN p.id ELSE NULL END) AS col7,
		COUNT(CASE WHEN rf_idV008=32 THEN p.id ELSE NULL END) AS Col9, 
		CAST(sum(CASE WHEN rf_idV008=32 THEN AmountPayment ELSE 0 END)  AS MONEY) AS Col11
FROM #tmpPeople	p INNER JOIN #tName n ON
			p.TypeCol=n.id
WHERE AmountPayment>0 AND Age=1
GROUP BY TypeCol,NAME,n.DS
ORDER BY TypeCol
go

DROP TABLE #tDiagnosis
DROP TABLE #tmpPeople
DROP TABLE #tName
		
