USE AccountOMS
GO
DECLARE @dateStart DATETIME='20150101',
		@dateEnd DATETIME='20151230 23:59:59',
		@dateEndPay DATETIME='20151230  23:59:59'
		
CREATE TABLE #tPeople(rf_idCase BIGINT,
					  CodeM CHAR(6),
					  CodeSMO CHAR(5),
					  AmountPayment DECIMAL(11,2),
					  DS VARCHAR(10),
					  Ds2 VARCHAR(10),
					  Surgery VARCHAR(16),
					  Age INT,
					  Duration tinyint,
					  Sex CHAR(1),
					  DurationCase CHAR(1)
					  )

CREATE TABLE #tCaseCSG(rf_idCase BIGINT,idCSG smallint)

CREATE UNIQUE NONCLUSTERED INDEX UQ_Case ON #tCaseCSG(rf_idCase) WITH IGNORE_DUP_KEY
-------------------------взрослые причисляются к одной группе 5
INSERT #tPeople( rf_idCase ,CodeM ,CodeSMO ,AmountPayment,Age,Duration,Sex)
SELECT c.id,f.CodeM,a.rf_idSMO,c.AmountPayment,5,CASE WHEN DATEDIFF(DAY,c.DateBegin,c.DateEnd)>2 THEN 1 ELSE NULL END,p.Sex
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase	
					INNER JOIN (SELECT  code FROM dbo.vw_sprCSG WHERE SUBSTRING(code,3,1)='2')	csg ON
			m.MES=csg.code                  
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles				
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=12 AND a.ReportYear=2015-- AND c.rf_idV006<>32		
		AND c.Age>18 AND c.rf_idV006=2
----------------разбивка детей по группам--------------------		
INSERT #tPeople( rf_idCase ,CodeM ,CodeSMO ,AmountPayment,Age,Duration,Sex)
SELECT c.id,f.CodeM,a.rf_idSMO,c.AmountPayment,v.ageGroup,CASE WHEN DATEDIFF(DAY,c.DateBegin,c.DateEnd)>2 THEN 1 ELSE NULL END,p.Sex
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase	
					INNER JOIN (SELECT  code FROM dbo.vw_sprCSG WHERE SUBSTRING(code,3,1)='2') csg ON
			m.MES=csg.code  																	
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles	
					INNER join (VALUES(1,28),(2,90),(3,365),(4,6571) ) v(ageGroup,dayYear) ON
			DATEDIFF(DAY,p.BirthDay,c.DateBegin)<v.dayYear			
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=12 AND a.ReportYear=2015-- AND c.rf_idV006<>32		
		AND c.Age<18 AND c.rf_idV006=2
		
		
UPDATE p SET DS=d.DS1
from #tPeople p INNER JOIN dbo.vw_Diagnosis d ON
		p.rf_idCase=d.rf_idCase

UPDATE p SET Surgery=m.MUSurgery
from #tPeople p INNER JOIN dbo.t_Meduslugi m ON
		p.rf_idCase=m.rf_idCase
WHERE m.MUSurgery IS NOT NULL
-------------т.к. DS2 может быть представленн несколькими записями
UPDATE p SET DS2=d.DS2
from #tPeople p INNER JOIN dbo.vw_Diagnosis d ON
		p.rf_idCase=d.rf_idCase
				INNER JOIN dbo.tmp_CSG2016 cd ON
		d.DS2=cd.DS2
WHERE cd.DS2 IS NOT null		              
--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction 
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase a 
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay 
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
			
			
			
-------------Step 1---------------
/*
INSERT #tCaseCSG( rf_idCase, idCSG )
SELECT DISTINCT p.rf_idCase,c.id
FROM #tPeople p INNER JOIN dbo.tmp_CSG2016 c ON
		p.DS=c.DS1
WHERE c.Step=1 AND p.AmountPayment>0  AND c.CSG>299 AND c.CSG<309 AND c.rf_idV006=1
*/
-------------Step 2---------------
INSERT #tCaseCSG( rf_idCase, idCSG )
SELECT DISTINCT p.rf_idCase,c.id
FROM #tPeople p INNER JOIN dbo.tmp_CSG2016 c ON
		p.Surgery=c.Sur
WHERE c.Step=2 AND p.AmountPayment>0  AND c.CSG>299 AND c.CSG<309 AND c.rf_idV006=1
-------------Step 3---------------
/*
INSERT #tCaseCSG( rf_idCase, idCSG )
SELECT DISTINCT p.rf_idCase,c.id
FROM #tPeople p INNER JOIN dbo.tmp_CSG2016 c ON
		p.DS=c.DS1		
		AND p.Surgery=c.Sur
WHERE c.Step=3 AND p.AmountPayment>0  AND c.CSG>299 AND c.CSG<309 AND c.rf_idV006=1
-------------Step 4---------------
INSERT #tCaseCSG( rf_idCase, idCSG )
SELECT DISTINCT p.rf_idCase,c.id
FROM #tPeople p INNER JOIN dbo.tmp_CSG2016 c ON
		p.DS=c.DS1
		AND p.Surgery=c.Sur		
		AND p.Age=c.Age
WHERE c.Step=4 AND p.AmountPayment>0  AND c.CSG>299 AND c.CSG<309 AND c.rf_idV006=1
-------------Step 7---------------
INSERT #tCaseCSG( rf_idCase, idCSG )
SELECT DISTINCT p.rf_idCase,c.id
FROM #tPeople p INNER JOIN dbo.tmp_CSG2016 c ON
		p.DS=c.DS1		
		AND p.Age=c.age
WHERE c.Step=7 AND p.AmountPayment>0  AND c.CSG>299 AND c.CSG<309 AND c.rf_idV006=1		
-------------Step 8---------------
INSERT #tCaseCSG( rf_idCase, idCSG )
SELECT DISTINCT p.rf_idCase,c.id
FROM #tPeople p INNER JOIN dbo.tmp_CSG2016 c ON
		p.DS=c.DS1		
		AND p.Sex=c.Sex
WHERE c.Step=8   AND p.AmountPayment>0  AND c.CSG>299 AND c.CSG<309 AND c.rf_idV006=1
-------------Step 9---------------
INSERT #tCaseCSG( rf_idCase, idCSG )
SELECT DISTINCT p.rf_idCase,c.id
FROM #tPeople p INNER JOIN dbo.tmp_CSG2016 c ON
		p.DS=c.DS1
		AND p.Surgery=c.Sur		
		AND p.Duration=c.los
WHERE c.Step=9 AND p.AmountPayment>0  AND c.CSG>299 AND c.CSG<309 AND c.rf_idV006=1
*/
-------------Step 10 ---------------
INSERT #tCaseCSG( rf_idCase, idCSG )
SELECT DISTINCT p.rf_idCase,c.id
FROM #tPeople p INNER JOIN dbo.tmp_CSG2016 c ON
		p.Age=c.Age
		AND p.Surgery=c.Sur
 WHERE c.Step=10	AND p.AmountPayment>0  AND c.CSG>299 AND c.CSG<309 AND c.rf_idV006=1
/*
-------------Step 11---------------
INSERT #tCaseCSG( rf_idCase, idCSG )
SELECT DISTINCT p.rf_idCase,c.id
FROM #tPeople p INNER JOIN dbo.tmp_CSG2016 c ON
		p.DS=c.DS1
		AND p.DS2=c.DS2
WHERE c.Step=11 AND p.AmountPayment>0  AND c.CSG>299 AND c.CSG<309 AND c.rf_idV006=1
-------------Step 12---------------
INSERT #tCaseCSG( rf_idCase, idCSG )
SELECT DISTINCT p.rf_idCase,c.id
FROM #tPeople p INNER JOIN dbo.tmp_CSG2016 c ON
		p.Surgery=c.Sur		
		AND p.Sex=c.Sex
WHERE c.Step=12 AND p.AmountPayment>0  AND c.CSG>299 AND c.CSG<309 AND c.rf_idV006=1		
-------------Step 13--------------
INSERT #tCaseCSG( rf_idCase, idCSG )
SELECT DISTINCT p.rf_idCase,c.id
FROM #tPeople p INNER JOIN dbo.tmp_CSG2016 c ON
		p.Surgery=c.Sur		
		AND p.Duration=c.LOS	
WHERE c.Step=13 AND p.AmountPayment>0  AND c.CSG>299 AND c.CSG<309 AND c.rf_idV006=1
-------------Step 14--------------
INSERT #tCaseCSG( rf_idCase, idCSG )
SELECT DISTINCT p.rf_idCase,c.id
FROM #tPeople p INNER JOIN dbo.tmp_CSG2016 c ON
		p.DS2=c.DS2
		AND p.Surgery=c.Sur		
		AND p.Age=c.age
WHERE c.Step=14 AND p.AmountPayment>0  AND c.CSG>299 AND c.CSG<309 AND c.rf_idV006=1		
*/	

INSERT #tCaseCSG( rf_idCase, idCSG )
SELECT DISTINCT p.rf_idCase,null
FROM #tPeople p
WHERE NOT EXISTS(SELECT * FROM #tCaseCSG WHERE rf_idCase=p.rf_idCase)

-------------witout smo
SELECT l.filialName,p.CodeM,l.NAMES AS LPU, sCSG.CSG ,sCSG.NameCSG,COUNT( DISTINCT c.rf_idCase) AS CountCaseCSG,p.DurationCase
FROM #tPeople p INNER JOIN #tCaseCSG c ON
		p.rf_idCase=c.rf_idCase
				INNER JOIN dbo.vw_sprT001 l ON
		p.CodeM=l.CodeM
				INNER JOIN tmp_CSG2016 sCSG ON
		c.idCSG=sCSG.id
GROUP BY l.filialName,p.CodeM,l.NAMES, sCSG.CSG ,sCSG.NameCSG,p.DurationCase
ORDER BY p.Codem


SELECT l.filialName,p.CodeM,l.NAMES AS LPU,COUNT(c.rf_idCase) AS CountCaseCSG,p.DS+' '+mkb.Diagnosis,/*ISNULL(p.DS2+' '+mkb1.Diagnosis,''),*/ISNULL(p.Surgery,''),ISNULL(v.RBNAME,'')	
FROM #tPeople p INNER JOIN #tCaseCSG c ON
		p.rf_idCase=c.rf_idCase
				INNER JOIN dbo.vw_sprT001 l ON
		p.CodeM=l.CodeM	
				INNER JOIN dbo.vw_sprMKB10 mkb ON
		p.DS=mkb.DiagnosisCode		
				LEFT JOIN OMS_NSI.dbo.V001 v ON
		p.surgery=v.IDRB	
				LEFT JOIN dbo.vw_sprMKB10 mkb1 ON
		p.DS2=mkb1.DiagnosisCode	
WHERE c.idCSG IS NULL AND p.AmountPayment>0			
GROUP BY l.filialName,p.CodeM,l.NAMES,p.DS+' '+mkb.Diagnosis,ISNULL(p.DS2+' '+mkb1.Diagnosis,''),ISNULL(p.Surgery,''),ISNULL(v.RBNAME,'')
ORDER BY p.Codem			
GO

DROP TABLE #tPeople			
DROP TABLE #tCaseCSG