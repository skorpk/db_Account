USE AccountOMS
GO
ALTER PROC usp_ReportAmbulance_20150702
		@dateEnd DATETIME, -- конечна€ дата регистрации счетов
		@reportYear smallint,--отчетный год
		@dateEndPay DATETIME,
		@endMonth TINYINT --конечный отчетный мес€ц
AS
DECLARE @iter tinyint=1 
		
declare	@dateStart DATETIME=CAST(@reportYear AS CHAR(4))+'0101'

CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  DS1 varCHAR(6),
					  AmountPayment DECIMAL(11,2),					
					  DSTotal AS LEFT(DS1,3) ,
					  TypeCol TINYINT
					  )	 

INSERT #tPeople( rf_idCase,DS1,AmountPayment)
SELECT DISTINCT c.id,RTRIM(d.DS1),c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles																
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient																									
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=@endMonth AND a.ReportYear=@reportYear
		AND a.rf_idSMO<>'34' AND c.rf_idV006=3
-------------------------------Type 5----------------------------------------------------------------		
UPDATE p SET  p.TypeCol=5 --ставим 1 т.к 5 колонка
FROM #tPeople p INNER JOIN dbo.t_Meduslugi m ON
	p.rf_idCase=m.rf_idCase
WHERE m.MUGroupCode=2 AND m.MUUnGroupCode IN (81,88)
-------------------------------Type 7----------------------------------------------------------------
;WITH cteMUHave AS
(
SELECT DISTINCT rf_idCase
FROM dbo.t_Meduslugi m INNER JOIN (SELECT MU
								FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode IN(78,89)
								UNION ALL
								SELECT v.MU
								FROM (VALUES('57.1.4'), ('57.1.32'), ('57.1.33'),('57.1.51'), ('57.1.52')) v(MU)
								UNION ALL
								SELECT MU
								FROM dbo.vw_sprMU WHERE MUGroupCode=57 AND MUUnGroupCode=1 AND MUCode IN (35,36,37,38,39,40,41,42,43,44,45,46,57,58,59,60,61)
								UNION ALL
								SELECT MU
								FROM dbo.vw_sprMU WHERE MUGroupCode=57 AND MUUnGroupCode=4 AND MUCode IN (38,39,40,41)
								) v ON
					m.MU=v.MU                                
),
cteMUNotHave AS
(
SELECT DISTINCT rf_idCase
FROM dbo.t_Meduslugi m INNER JOIN (SELECT MU
									FROM dbo.vw_sprMU WHERE MUGroupCode=57 AND MUUnGroupCode=1 AND MUCode IN (47,48,49,50,53,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81)
									UNION ALL
									SELECT v.MU
									FROM (VALUES('57.5.1'), ('57.5.2')) v(MU)
								) v ON
					m.MU=v.MU       
)
UPDATE p SET p.TypeCol=7
from cteMUHave c INNER JOIN #tPeople p ON
		c.rf_idCase=p.rf_idCase
WHERE NOT EXISTS(SELECT * FROM cteMUNotHave WHERE rf_idCase=c.rf_idCase)
-------------------------------Type 9----------------------------------------------------------------
;WITH cteMUHave AS
(
SELECT DISTINCT rf_idCase
FROM dbo.t_Meduslugi m INNER JOIN (SELECT MU
									FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode IN(80,82)
									UNION ALL
									SELECT MU
									FROM dbo.vw_sprMU WHERE MUGroupCode=57 AND MUUnGroupCode=1 AND MUCode IN (47,48,49,50,53,72,73,74,75,76,77,78,79,80,81)
								) v ON
					m.MU=v.MU                                
),
cteMUNotHave AS
(
SELECT DISTINCT rf_idCase
FROM dbo.t_Meduslugi m INNER JOIN (SELECT MU
									FROM dbo.vw_sprMU WHERE MUGroupCode=57 AND MUUnGroupCode=1 AND MUCode IN (4,32,33,35,36,37,38,39,40,41,42,43,44,45,46,52,54,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71)
									UNION ALL
									SELECT MU
									FROM dbo.vw_sprMU WHERE MUGroupCode=57 AND MUUnGroupCode=5 AND MUCode IN (1,2)
									UNION ALL
									SELECT MU
									FROM dbo.vw_sprMU WHERE MUGroupCode=57 AND MUUnGroupCode=4 AND MUCode>37 AND MUCode<42
								) v ON
					m.MU=v.MU       
)
UPDATE p SET p.TypeCol=9
from cteMUHave c INNER JOIN #tPeople p ON
		c.rf_idCase=p.rf_idCase
WHERE NOT EXISTS(SELECT * FROM cteMUNotHave WHERE rf_idCase=c.rf_idCase)
---------------------------------------------------------------------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(c.AmountMEK) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
													a.id=c.rf_idCheckedAccount 														
							WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEndPay AND d.TypeExamination=0
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DECLARE @Total AS TABLE (rowID smallint, AmountPayment decimal(15,2),CountCase5 int, AmountPayment5 decimal(15,2),CountCase7 int, AmountPayment7 decimal(15,2),
					CountCase9 int, AmountPayment9 decimal(15,2))

----------------------------1-----------------------------
INSERT @Total
SELECT @iter,SUM(isnull(AmountPayment,0)),0 AS Col5,0 AS Col6,0 AS Col7,0 AS Col8,0 AS Col9,0 AS Col10
from #tPeople p	 WHERE p.AmountPayment>=0	 SET @iter+=1
----------------------------2-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------3-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------4-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------5-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1

----------------------------6-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p	 WHERE p.AmountPayment>=0	AND p.DSTotal>='A00' AND p.Dstotal<='E90'

INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p WHERE p.AmountPayment>=0	AND p.DSTotal>='G00' AND p.Dstotal<='Q99'

INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p WHERE p.AmountPayment>=0	AND p.DSTotal>='S00' AND p.Dstotal<='T98'
SET @iter+=1
----------------------------7-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='A00' AND DSTotal<='B99' 
SET @iter+=1
----------------------------8-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='B18'
SET @iter+=1
----------------------------9-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal>='C00' AND DSTotal<='D48' 
SET @iter+=1
----------------------------10-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p          
WHERE AmountPayment>=0 AND DSTotal>='C00' AND DSTotal<='D97'
SET @iter+=1
----------------------------11-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='C81' AND DSTotal<='C96'
SET @iter+=1
----------------------------12-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C50'
SET @iter+=1
----------------------------13-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------14-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1

----------------------------15-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1

----------------------------16-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p          
WHERE AmountPayment>=0 AND DSTotal='C34'
SET @iter+=1											  
----------------------------17-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------18-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------19-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------20-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C18'
SET @iter+=1
----------------------------21-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------22-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------23-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------24-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C16'
SET @iter+=1
----------------------------25-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------26-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------27-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------28-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C61'
SET @iter+=1
----------------------------29-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------30-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------31-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------32-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C00' AND DSTotal<='C15'

INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal='C17' 

INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C19' AND DSTotal<='C33'

INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C35' AND DSTotal<='C49'

INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C51' AND DSTotal<='C60'

INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C62' AND DSTotal<='C80'

INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal='C97' 
SET @iter+=1
----------------------------33-----------------------------
---Empty Rows
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------34-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------35-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------36-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='D50' AND DSTotal<='D89' 
SET @iter+=1
----------------------------37-----------------------------				
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='E00' AND DSTotal<='E90'
SET @iter+=1
----------------------------38-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='E10' AND DSTotal<='E14'
SET @iter+=1
----------------------------39-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='E10' 
SET @iter+=1
----------------------------40-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal='E11'
SET @iter+=1
----------------------------41-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='G00' AND DSTotal<='G99' 
SET @iter+=1
----------------------------42-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='G00' AND DSTotal<='G09'
SET @iter+=1
----------------------------43-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='G35' AND DSTotal<='G37'
SET @iter+=1
----------------------------44-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='H00' AND DSTotal<='H59' 
SET @iter+=1
----------------------------45-----------------------------

INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='H60' AND DSTotal<='H95' 
SET @iter+=1
----------------------------46-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='I00' AND DSTotal<='I99'
SET @iter+=1
----------------------------47-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='I20' AND DSTotal<='I25'
SET @iter+=1
----------------------------48-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I20' 
SET @iter+=1
----------------------------49-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DS1='I20.0' 
SET @iter+=1
----------------------------50----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------51-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I21' 

INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I22'
SET @iter+=1
----------------------------52-----------------------------
---Empty Rows
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------53-----------------------------
INSERT @Total VALUES(@iter,0.0,0,0.0,0,0.0,0,0.0) SET @iter+=1
----------------------------54-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I26'
SET @iter+=1
----------------------------55-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='I60' AND DSTotal<='I69'
SET @iter+=1
----------------------------56-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I60'
SET @iter+=1
----------------------------57-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I61'

INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I62'
SET @iter+=1
----------------------------58-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I63'
SET @iter+=1
----------------------------59-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I64'
SET @iter+=1
----------------------------60-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='J00' AND DSTotal<='J99'
SET @iter+=1
----------------------------61-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='J09' AND DSTotal<='J11'
SET @iter+=1
----------------------------62-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='J12' AND DSTotal<='J16'

INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='J18'
SET @iter+=1
----------------------------63-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='K00' AND DSTotal<='K93'
SET @iter+=1
----------------------------64-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='K56'
SET @iter+=1
----------------------------65-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='K25' AND DSTotal<='K26'
SET @iter+=1
----------------------------66-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('K25.0','K25.4','K26.0','K26.4')
SET @iter+=1
----------------------------67-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('K25.1','K25.5','K26.1','K26.5')
SET @iter+=1
----------------------------68-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('K25.2','K25.6','K26.2','K26.6')
SET @iter+=1
----------------------------69-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='K65'
SET @iter+=1
----------------------------70-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('K70.3','K71.7')

INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='K74'
SET @iter+=1
----------------------------71-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('K80.0','K81.0')
SET @iter+=1
----------------------------72-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='K85'
SET @iter+=1
----------------------------73-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DS1='K92.2'
SET @iter+=1
----------------------------74-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='L00' AND DSTotal<='L99'
SET @iter+=1
----------------------------75-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='M00' AND DSTotal<='M99'
SET @iter+=1
----------------------------76-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='N00' AND DSTotal<='N99'
SET @iter+=1
----------------------------77-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='O00' AND DSTotal<='O99'
SET @iter+=1
----------------------------76-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='O00'
SET @iter+=1
----------------------------79-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='O67'

INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='O72'
SET @iter+=1
----------------------------80-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('O71.0','O71.1')
SET @iter+=1
----------------------------81-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='O85'
SET @iter+=1
----------------------------82-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='P00' AND DSTotal<='P96'
SET @iter+=1
----------------------------83-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='P07'
SET @iter+=1
----------------------------84-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='P10'
SET @iter+=1
----------------------------85-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='P23'
SET @iter+=1
----------------------------86-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='P36'
SET @iter+=1
----------------------------87-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='Q00' AND DSTotal<='Q99'
SET @iter+=1
----------------------------88-----------------------------
INSERT @Total
SELECT @iter, SUM(isnull(AmountPayment,0)),
		COUNT(CASE WHEN TypeCol=5 THEN rf_idCase ELSE NULL END) AS Col5,
		SUM(CASE WHEN TypeCol=5 THEN AmountPayment ELSE 0 END) AS Col6,
		COUNT(CASE WHEN TypeCol=7 THEN rf_idCase ELSE NULL END) AS Col7,
		SUM(CASE WHEN TypeCol=7 THEN AmountPayment ELSE 0 END) AS Col8,
		COUNT(CASE WHEN TypeCol=9 THEN rf_idCase ELSE NULL END) AS Col9,
		SUM(CASE WHEN TypeCol=9 THEN AmountPayment ELSE 0 END) AS Col10
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='S00' AND DSTotal<='T98'


SELECT t.rowID, CAST(SUM(ISNULL(t.AmountPayment,0)) AS MONEY),
		 SUM(t.CountCase5),CAST(SUM(ISNULL(t.AmountPayment5,0)) AS MONEY),
		 SUM(t.CountCase7),CAST(SUM(ISNULL(t.AmountPayment7,0)) AS MONEY),
		 SUM(t.CountCase9),CAST(SUM(ISNULL(t.AmountPayment9,0)) AS MONEY)
from @Total t
GROUP BY t.rowID
ORDER BY t.rowID

DROP TABLE #tPeople

GO
