USE AccountOMS
GO
DECLARE @dateEnd DATETIME='20140124', -- конечная дата регистрации счетов
		@reportYear smallint=2013,--отчетный год
		@endMonth TINYINT=12, --конечный отчетный месяц
		@iter tinyint=1 
		
declare	@dateStart DATETIME=CAST(@reportYear AS CHAR(4))+'0101'

CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  DS1 CHAR(6),
					  AmountPayment DECIMAL(11,2)					
					  LEFT(DS1,3)
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
							WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd AND d.TypeCheckup=0
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
DECLARE @Total AS TABLE (rowID smallint,CountCase int, AmountPayment decimal(15,2))

INSERT @Total SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment) from #tPeople p WHERE AmountPayment>0 
SET @iter+=1
---Empty Rows
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='A00' AND h1.DiagnosisCodeE<='E90'
							UNION ALL
							SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='G00' AND h1.DiagnosisCodeE<='Q99'  
							UNION ALL
							SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='S00' AND h1.DiagnosisCodeE<='T98'                          
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='A00' AND h1.DiagnosisCodeE<='B99'						                 
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE m.DiagnosisCode='B18'
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1


INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='C00' AND h1.DiagnosisCodeE<='D48'						                 
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h.DiagnosisCodeB>='C00' AND h.DiagnosisCodeE<='C97'						                 
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h.DiagnosisCodeB>='C81' AND h.DiagnosisCodeE<='C96'						                 
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h.DiagnosisCodeB='C50'
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

---Empty Rows
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1
----------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE m.DiagnosisCode='C34'
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1
---Empty Rows
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1
----------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB='C18'
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1
---Empty Rows
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1
----------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB='C16'
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1
---Empty Rows
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1
----------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB='C61'
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1
---Empty Rows
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1
----------------------

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='C00' AND h1.DiagnosisCodeE<='C15'
							UNION ALL
							SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB='C17'
							UNION ALL
							SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='С19' AND h1.DiagnosisCodeE<='С33'
							UNION ALL
							SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='С35' AND h1.DiagnosisCodeE<='С49'
							UNION ALL
							SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='С51' AND h1.DiagnosisCodeE<='С60'                          
							UNION ALL
							SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='С62' AND h1.DiagnosisCodeE<='С80'
							UNION ALL
							SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB='C97'
							
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

---Empty Rows
INSERT @Total VALUES(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1

INSERT @Total values(@iter,0,0.0) SET @iter+=1
----------------------
INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='D50' AND h1.DiagnosisCodeE<='D89'							
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1


INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='E00' AND h1.DiagnosisCodeE<='E90'							
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='E10' AND h1.DiagnosisCodeE<='E14'							
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB='E10'
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB='E11'
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='G00' AND h1.DiagnosisCodeE<='G99'							
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='G00' AND h1.DiagnosisCodeE<='G09'							
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='G35' AND h1.DiagnosisCodeE<='G37'							
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='H00' AND h1.DiagnosisCodeE<='H59'							
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='H60' AND h1.DiagnosisCodeE<='H95'							
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='I00' AND h1.DiagnosisCodeE<='I99'							
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB>='I20' AND h1.DiagnosisCodeE<='I25'							
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1

INSERT @Total
SELECT @iter,COUNT(rf_idCase), SUM(AmountPayment)
from #tPeople p INNER JOIN (SELECT m.DiagnosisCode
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId
							WHERE h1.DiagnosisCodeB='I20' 
						 ) d ON
               p.DS1=d.DiagnosisCode          
WHERE AmountPayment>0 
SET @iter+=1