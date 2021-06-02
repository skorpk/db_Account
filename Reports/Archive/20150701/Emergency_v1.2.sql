USE AccountOMS
GO
DECLARE @dateEnd DATETIME='20140124', -- конечна€ дата регистрации счетов
		@reportYear smallint=2013,--отчетный год
		@dateEndPay DATETIME='20140128',
		@endMonth TINYINT=12, --конечный отчетный мес€ц
		@iter tinyint=1 
		
declare	@dateStart DATETIME=CAST(@reportYear AS CHAR(4))+'0101'

CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  DS1 varCHAR(6),
					  AmountPayment DECIMAL(11,2),					
					  DSTotal AS LEFT(DS1,3)
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
		AND a.rf_idSMO<>'34' AND c.rf_idV006=4
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


INSERT @Total 
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0)) from #tPeople p WHERE AmountPayment>=0 
SET @iter+=1
---Empty Rows
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1


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

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='A00' AND DSTotal<='B99' 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='B18'
SET @iter+=1
			   
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal>='C00' AND DSTotal<='D48' 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p          
WHERE AmountPayment>=0 AND DSTotal>='C00' AND DSTotal<='D97'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='C81' AND DSTotal<='C96'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C50'
SET @iter+=1

---Empty Rows
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1
----------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p          
WHERE AmountPayment>=0 AND DSTotal='C34'
SET @iter+=1
---Empty Rows
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1
----------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C18'
SET @iter+=1
---Empty Rows
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1
----------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C16'
SET @iter+=1
---Empty Rows
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1
----------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='C61'
SET @iter+=1
---Empty Rows
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1
----------------------

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

---Empty Rows
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1
----------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='D50' AND DSTotal<='D89' 
SET @iter+=1
				
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='E00' AND DSTotal<='E90'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='E10' AND DSTotal<='E14'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p         
WHERE AmountPayment>=0 AND DSTotal='E10' 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal='E11'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='G00' AND DSTotal<='G99' 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='G00' AND DSTotal<='G09'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='G35' AND DSTotal<='G37'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='H00' AND DSTotal<='H59' 
SET @iter+=1

--SELECT @iter

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='H60' AND DSTotal<='H95' 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p        
WHERE AmountPayment>=0 AND DSTotal>='I00' AND DSTotal<='I99'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='I20' AND DSTotal<='I25'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I20' 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1='I20.0' 
SET @iter+=1
---Empty Rows
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1
------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I21' 

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I22'
SET @iter+=1
---Empty Rows
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1
------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I26'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='I60' AND DSTotal<='I69'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I60'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I61'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I62'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I63'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='I64'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='J00' AND DSTotal<='J99'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='J09' AND DSTotal<='J11'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='J12' AND DSTotal<='J16'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='J18'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='K00' AND DSTotal<='K93'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='K56'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='K25' AND DSTotal<='K26'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('K25.0','K25.4','K26.0','K26.4')
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('K25.1','K25.5','K26.1','K26.5')
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('K25.2','K25.6','K26.2','K26.6')
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='K65'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('K70.3','K71.7')

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='K74'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('K80.0','K81.0')
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='K85'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1='K92.2'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='L00' AND DSTotal<='L99'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='M00' AND DSTotal<='M99'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='N00' AND DSTotal<='N99'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='O00' AND DSTotal<='O99'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='O00'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='O67'

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='O72'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DS1 IN ('O71.0','O71.1')
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='O85'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='P00' AND DSTotal<='P96'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='P07'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='P10'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='P23'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal='P36'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='Q00' AND DSTotal<='Q99'
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(isnull(AmountPayment,0))
from #tPeople p 
WHERE AmountPayment>=0 AND DSTotal>='S00' AND DSTotal<='T98'
SET @iter+=1

SELECT t.rowID, SUM(t.CountCase),CAST(SUM(ISNULL(t.AmountPayment,0)) AS MONEY)
from @Total t
GROUP BY t.rowID
ORDER BY t.rowID
GO
DROP TABLE #tPeople