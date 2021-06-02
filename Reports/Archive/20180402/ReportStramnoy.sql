USE AccountOMSReports
GO
DECLARE @dateRegStart DATETIME='20170101',
		@dateRegEnd DATETIME='20180201',
		@reportYear SMALLINT=2017

CREATE TABLE #tD(DS1 VARCHAR(10))
INSERT #tD( DS1 ) VALUES  ('S72.0'),('S72.00'),('S72.01'),('S72.1'),('S72.10'),('S72.2'),('S72.20')     
CREATE TABLE #tCSG(ReportYear SMALLINT, CSG VARCHAR(10))
INSERT #tCSG( ReportYear, CSG ) VALUES  (2016,'1000217'),(2016,'1000221'),(2016,'1000222'),(2017,'10000221'),(2017,'10000225'),(2017,'10000226')

SELECT c.id AS rf_idCase,f.CodeM,csg.CSG,c.AmountPayment, CASE WHEN c.age<18 THEN 1 ELSE 2 END AS IsChild, SUM(mm.Quantity) AS Quantity
INTO #tPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient p ON
		a.id=p.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
		p.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase
					INNER JOIN #tCSG csg ON
		m.mes=csg.CSG
		AND csg.ReportYear=@reportYear
					INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
					INNER JOIN #tD dd ON
		d.DS1=dd.DS1
					INNER JOIN dbo.t_Meduslugi mm ON
		c.id=mm.rf_idCase                  
WHERE f.DateRegistration>=@dateRegStart AND f.DateRegistration<@dateRegEnd AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND mm.MUGroupCode=1 AND mm.MUUnGroupCode=11 
GROUP BY c.id ,f.CodeM,csg.CSG,c.AmountPayment, CASE WHEN c.age<18 THEN 1 ELSE 2 END 

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCase p INNER  JOIN #tPeople t ON			
												p.rf_idCase=t.rf_idCase
							WHERE p.DateRegistration>=@dateRegStart AND p.DateRegistration<GETDATE()	 
							GROUP BY t.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
/*
SELECT *
FROM #tPeople p WHERE NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=p.rf_idCase AND m.MUGroupCode=1 AND MUUnGroupCode=11)

SELECT p.CodeM,l.NAMES AS LPU, csg.code, csg.name AS CSGName, 
		count(CASE WHEN p.IsChild=1 then p.rf_idCase else null END) AS CountCaseChild, 
		sum(CASE WHEN p.IsChild=1 THEN Quantity ELSE 0 END) AS QuantityChild,
		CAST(sum(CASE WHEN p.IsChild=1 THEN AmountPayment ELSE 0.0 END) AS MONEY) AS SumPaymentChild,
		---------------------Adult-----------------------
		count(CASE WHEN p.IsChild=2 then p.rf_idCase else null END) AS CountCaseAdult, 
		sum(CASE WHEN p.IsChild=2 THEN Quantity ELSE 0 END) AS QuantityAdult,
		cast(sum(CASE WHEN p.IsChild=2 THEN AmountPayment ELSE 0.0 END) AS MONEY) AS SumPaymentAdult,
		---------------------All---------------------------s
		count(p.rf_idCase) AS CountCase, 
		SUM(p.Quantity) AS Quantity,
		CAST(sum(AmountPayment) AS MONEY) AS SumPayment
FROM #tPeople P INNER JOIN dbo.vw_sprT001 L ON 
		p.CodeM=l.CodeM
				INNER JOIN dbo.vw_CSG csg ON
		p.CSG=csg.code
WHERE AmountPayment>0		                
GROUP BY p.CodeM,l.NAMES, csg.code, csg.name 
*/

SELECT p.CodeM,l.NAMES AS LPU, csg.code, csg.name AS CSGName, 		
		count(p.rf_idCase) AS CountCase, 
		CAST(SUM(p.Quantity) AS INT) AS Quantity,
		CAST(sum(AmountPayment) AS MONEY) AS SumPayment,
		CASE WHEN IsChild=1 THEN 'Дети' ELSE 'Взрослые' END IsAdult
FROM #tPeople P INNER JOIN dbo.vw_sprT001 L ON 
		p.CodeM=l.CodeM
				INNER JOIN dbo.vw_CSG csg ON
		p.CSG=csg.code
WHERE AmountPayment>0		                
GROUP BY p.CodeM,l.NAMES, csg.code, csg.name,CASE WHEN IsChild=1 THEN 'Дети' ELSE 'Взрослые' END 

GO
DROP TABLE #tCSG
DROP TABLE #tD
DROP TABLE #tPeople