USE AccountOMS
GO
DECLARE @dateEnd DATETIME='20140124', -- конечна€ дата регистрации счетов
		@reportYear smallint=2013,--отчетный год
		@dateEndPay DATETIME='20140127',
		@endMonth TINYINT=12, --конечный отчетный мес€ц
		@iter tinyint=1 
		
declare	@dateStart DATETIME=CAST(@reportYear AS CHAR(4))+'0101'

CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  DS1 varCHAR(6),
					  AmountPayment DECIMAL(11,2),					
					  DSTotal AS LEFT(DS1,3) ,
					  MES VARCHAR(20),
					  Surgery VARCHAR(16),
					  TypeMes TINYINT,
					  LastCSG AS CAST(CASE WHEN TypeMes=2 THEN RIGHT(RTRIM(MES),3) ELSE 0 END AS INT)
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
		AND a.rf_idSMO<>'34' AND c.rf_idV006=1
---------------------------------------------------------------------------------------		
UPDATE p SET p.Mes=m.MES, p.TypeMes=spr.typeMes
FROM #tPeople p INNER JOIN dbo.t_MES m ON
			p.rf_idCase=m.rf_idCase
				INNER JOIN (SELECT MU,1 AS typeMes FROM dbo.vw_sprMUCompletedCase UNION ALL SELECT code,2 FROM vw_sprCSG) spr on		                 
			m.MES=spr.MU
---------------------------------------------------------------------------------------
UPDATE p SET p.surgery=m.MUSurgery
FROM #tPeople p INNER JOIN dbo.t_Meduslugi m ON
	p.rf_idCase=m.rf_idCase
WHERE m.MUSurgery IS NOT null
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

DECLARE @Total AS TABLE (rowID smallint,CountCase int, AmountPayment decimal(15,2))

----------------------------1-----------------------------
INSERT @Total 
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0)) from #tPeople p WHERE AmountPayment>=0 
SET @iter+=1
----------------------------2-----------------------------
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1
----------------------------3-----------------------------
INSERT @Total values(@iter,0,0.0) SET @iter+=1
----------------------------4-----------------------------
INSERT @Total values(@iter,0,0.0) SET @iter+=1
----------------------------5-----------------------------
INSERT @Total values(@iter,0,0.0) SET @iter+=1

----------------------------6-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p	 WHERE p.AmountPayment>=0	AND p.DSTotal>='A00' AND p.Dstotal<='E90'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p WHERE p.AmountPayment>=0	AND p.DSTotal>='G00' AND p.Dstotal<='Q99'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p WHERE p.AmountPayment>=0	AND p.DSTotal>='S00' AND p.Dstotal<='T98'
SET @iter+=1
----------------------------7-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='A00' AND DSTotal<='B99' 
SET @iter+=1
----------------------------8-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='B18'
SET @iter+=1
----------------------------9-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal>='C00' AND DSTotal<='D48' 
SET @iter+=1
----------------------------10-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p          
WHERE AmountPayment>=0 AND DSTotal>='C00' AND DSTotal<='D97'
SET @iter+=1
----------------------------11-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='C81' AND DSTotal<='C96'
SET @iter+=1
----------------------------12-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C50'
SET @iter+=1
----------------------------13-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C50' AND p.Surgery LIKE 'A16.%'
SET @iter+=1
----------------------------14-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C50' AND p.TypeMes=2 AND LastCSG IN (77,78,79, 111,112,113)
SET @iter+=1

----------------------------15-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C50' AND p.TypeMes=2 AND LastCSG IN (31,74,75,76 , 107,108,109, 110)
SET @iter+=1


----------------------------16-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p          
WHERE AmountPayment>=0 AND DSTotal='C34'
SET @iter+=1											  
----------------------------17-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p          
WHERE AmountPayment>=0 AND DSTotal='C34' AND p.Surgery LIKE 'A16.%'
SET @iter+=1	
----------------------------18-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C34' AND p.TypeMes=2 AND LastCSG IN (77,78,79, 111,112,113)
SET @iter+=1
----------------------------19-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C34' AND p.TypeMes=2 AND LastCSG IN (31,74,75,76 , 107,108,109, 110)
SET @iter+=1
----------------------------20-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C18'
SET @iter+=1
----------------------------21-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p          
WHERE AmountPayment>=0 AND DSTotal='C18' AND p.Surgery LIKE 'A16.%'
SET @iter+=1	
----------------------------22-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C18' AND p.TypeMes=2 AND LastCSG IN (77,78,79, 111,112,113)
SET @iter+=1
----------------------------23-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C18' AND p.TypeMes=2 AND LastCSG IN (31,74,75,76 , 107,108,109, 110)
SET @iter+=1
----------------------------24-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C16'
SET @iter+=1
----------------------------25-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p          
WHERE AmountPayment>=0 AND DSTotal='C16' AND p.Surgery LIKE 'A16.%'
SET @iter+=1
----------------------------26-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C16' AND p.TypeMes=2 AND LastCSG IN (77,78,79, 111,112,113)
SET @iter+=1
----------------------------27-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C16' AND p.TypeMes=2 AND LastCSG IN (31,74,75,76 , 107,108,109, 110)
SET @iter+=1
----------------------------28-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C61'
SET @iter+=1
----------------------------29-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p          
WHERE AmountPayment>=0 AND DSTotal='C61' AND p.Surgery LIKE 'A16.%'
SET @iter+=1
----------------------------30-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C61' AND p.TypeMes=2 AND LastCSG IN (77,78,79, 111,112,113)
SET @iter+=1
----------------------------31-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C61' AND p.TypeMes=2 AND LastCSG IN (31,74,75,76 , 107,108,109, 110)
SET @iter+=1
----------------------------32-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C00' AND DSTotal<='C15'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal='C17' 

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C19' AND DSTotal<='C33'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C35' AND DSTotal<='C49'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C51' AND DSTotal<='C60'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C62' AND DSTotal<='C80'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal='C97' 
SET @iter+=1
----------------------------33-----------------------------
---Empty Rows
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C00' AND DSTotal<='C15' AND p.Surgery LIKE 'A16.%'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal='C17' AND p.Surgery LIKE 'A16.%'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C19' AND DSTotal<='C33' AND p.Surgery LIKE 'A16.%'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C35' AND DSTotal<='C49' AND p.Surgery LIKE 'A16.%'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C51' AND DSTotal<='C60' AND p.Surgery LIKE 'A16.%'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C62' AND DSTotal<='C80' AND p.Surgery LIKE 'A16.%'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal='C97' AND p.Surgery LIKE 'A16.%' 
SET @iter+=1
----------------------------34-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C00' AND DSTotal<='C15' AND LastCSG IN (77,78,79, 111,112,113)

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal='C17' AND LastCSG IN (77,78,79, 111,112,113)

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C19' AND DSTotal<='C33' AND LastCSG IN (77,78,79, 111,112,113)

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C35' AND DSTotal<='C49' AND LastCSG IN (77,78,79, 111,112,113)

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C51' AND DSTotal<='C60' AND LastCSG IN (77,78,79, 111,112,113)

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C62' AND DSTotal<='C80' AND LastCSG IN (77,78,79, 111,112,113)

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal='C97' AND LastCSG IN (77,78,79, 111,112,113)
SET @iter+=1
----------------------------35-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C00' AND DSTotal<='C15' AND LastCSG IN (31,74,75,76 ,107,108,109, 110)

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal='C17' AND LastCSG IN (31,74,75,76 ,107,108,109, 110)

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C19' AND DSTotal<='C33' AND LastCSG IN (31,74,75,76 ,107,108,109, 110)

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C35' AND DSTotal<='C49' AND LastCSG IN (31,74,75,76 ,107,108,109, 110)

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C51' AND DSTotal<='C60' AND LastCSG IN (31,74,75,76 ,107,108,109, 110)

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal>='C62' AND DSTotal<='C80' AND LastCSG IN (31,74,75,76 ,107,108,109, 110)

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p           
WHERE AmountPayment>=0 AND DSTotal='C97' AND LastCSG IN (31,74,75,76 ,107,108,109, 110)
SET @iter+=1
----------------------------36-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='D50' AND DSTotal<='D89' 
SET @iter+=1
----------------------------37-----------------------------				
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='E00' AND DSTotal<='E90'
SET @iter+=1
----------------------------38-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='E10' AND DSTotal<='E14'
SET @iter+=1
----------------------------39-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='E10' 
SET @iter+=1
----------------------------40-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal='E11'
SET @iter+=1
----------------------------41-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='G00' AND DSTotal<='G99' 
SET @iter+=1
----------------------------42-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='G00' AND DSTotal<='G09'
SET @iter+=1
----------------------------43-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='G35' AND DSTotal<='G37'
SET @iter+=1
----------------------------44-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='H00' AND DSTotal<='H59' 
SET @iter+=1
----------------------------45-----------------------------

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='H60' AND DSTotal<='H95' 
SET @iter+=1
----------------------------46-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='I00' AND DSTotal<='I99'
SET @iter+=1
----------------------------47-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='I20' AND DSTotal<='I25'
SET @iter+=1
----------------------------48-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I20' 
SET @iter+=1
----------------------------49-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1='I20.0' 
SET @iter+=1
----------------------------50----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1='I20.0' AND MES IN ('1.12.408','1218109','1.9.50')
SET @iter+=1
----------------------------51-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I21' 

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I22'
SET @iter+=1
----------------------------52-----------------------------
---Empty Rows
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I21' AND p.Surgery='A11.12.003.002'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I22' AND p.Surgery='A11.12.003.002'
SET @iter+=1
----------------------------53-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I21' AND MES IN ('1.12.408','1218109','1.9.50') 

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I22' AND MES IN ('1.12.408','1218109','1.9.50')
SET @iter+=1
----------------------------54-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I26'
SET @iter+=1
----------------------------55-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='I60' AND DSTotal<='I69'
SET @iter+=1
----------------------------56-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I60'
SET @iter+=1
----------------------------57-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I61'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I62'
SET @iter+=1
----------------------------58-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I63'
SET @iter+=1
----------------------------59-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I64'
SET @iter+=1
----------------------------60-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='J00' AND DSTotal<='J99'
SET @iter+=1
----------------------------61-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='J09' AND DSTotal<='J11'
SET @iter+=1
----------------------------62-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='J12' AND DSTotal<='J16'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='J18'
SET @iter+=1
----------------------------63-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='K00' AND DSTotal<='K93'
SET @iter+=1
----------------------------64-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='K56'
SET @iter+=1
----------------------------65-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='K25' AND DSTotal<='K26'
SET @iter+=1
----------------------------66-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('K25.0','K25.4','K26.0','K26.4')
SET @iter+=1
----------------------------67-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('K25.1','K25.5','K26.1','K26.5')
SET @iter+=1
----------------------------68-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('K25.2','K25.6','K26.2','K26.6')
SET @iter+=1
----------------------------69-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='K65'
SET @iter+=1
----------------------------70-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('K70.3','K71.7')

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='K74'
SET @iter+=1
----------------------------71-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('K80.0','K81.0')
SET @iter+=1
----------------------------72-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='K85'
SET @iter+=1
----------------------------73-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1='K92.2'
SET @iter+=1
----------------------------74-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='L00' AND DSTotal<='L99'
SET @iter+=1
----------------------------75-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='M00' AND DSTotal<='M99'
SET @iter+=1
----------------------------76-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='N00' AND DSTotal<='N99'
SET @iter+=1
----------------------------77-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='O00' AND DSTotal<='O99'
SET @iter+=1
----------------------------76-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='O00'
SET @iter+=1
----------------------------79-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='O67'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='O72'
SET @iter+=1
----------------------------80-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('O71.0','O71.1')
SET @iter+=1
----------------------------81-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='O85'
SET @iter+=1
----------------------------82-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='P00' AND DSTotal<='P96'
SET @iter+=1
----------------------------83-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='P07'
SET @iter+=1
----------------------------84-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='P10'
SET @iter+=1
----------------------------85-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='P23'
SET @iter+=1
----------------------------86-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='P36'
SET @iter+=1
----------------------------87-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='Q00' AND DSTotal<='Q99'
SET @iter+=1
----------------------------88-----------------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='S00' AND DSTotal<='T98'


SELECT t.rowID, SUM(t.CountCase),CAST(SUM(ISNULL(t.AmountPayment,0)) AS MONEY)
from @Total t
GROUP BY t.rowID
ORDER BY t.rowID
GO
DROP TABLE #tPeople