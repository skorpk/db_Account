USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20160101',	
		@dtEndReg DATETIME='20170119 23:59:59',
		@dtEndAmb DATETIME='20180120',
		@dtEnd DATE='20161231',
		@reportYear SMALLINT=2016,
		@reportMonth TINYINT=12
				
SELECT TOP 1 WITH TIES c.id AS rf_idCase,c.AmountPayment,c.DateEnd,ce.pid,ce.ENP,f.CodeM
INTO #tmpEKO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase  										
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase 
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<=@dtEnd AND c.rf_idV002=137 	AND c.rf_idV006=2
	AND m.MES LIKE '2__4005'
ORDER BY ROW_NUMBER() OVER(PARTITION BY ce.PID ORDER BY c.DateBegin desc)		

INSERT #tmpEKO (rf_idCase,AmountPayment,DateEnd,PID,ENP,CodeM)
SELECT TOP 1 WITH TIES c.id AS rf_idCase,c.AmountPayment,c.DateEnd,ce.pid,ce.ENP,f.CodeM
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase  										
					inner JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase 
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<=@dtEnd AND c.rf_idV002=137 	AND c.rf_idV006=2
	AND m.MES LIKE '2__4005' AND ce.PID IS NULL
ORDER BY ROW_NUMBER() OVER(PARTITION BY ce.ENP ORDER BY c.DateBegin desc)		



UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpEKO c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 

INSERT #tmpEKO (rf_idCase,AmountPayment,DateEnd,PID,ENP) 
SELECT 0,100,DATEADD(DAY,-2,CAST(cast(v.DateEnd AS datetime) AS DATE)),v.PID,v.ENP
FROM (VALUES (2016,1309745,'3456310887000020',42670),(2016,1324640,'3457810872000389',42482),(2016,1400424,'3450510869000346',42629),(2016,1426083,'3454910891000536',42412),
			(2016,1441298,'3448510876000292',42444),(2016,1480957,'3448020878000167',42426),(2016,1530783,'3449910897000116',42474),(2016,1534582,'3447410896000201',42600),
			(2016,1551311,'3454110883000046',42514),(2016,1561426,'3458900884000185',42429),(2016,1574280,'7758310884004047',42457),(2016,1669620,'3452710889000700',42494),
			(2016,1684850,'3453810883000265',42434),(2016,1691443,'3458020874000663',42566),(2016,1696066,'3455810876000486',42425),(2016,1704462,'3454310873000317',42639),
			(2016,1726943,'3458700890000066',42443),(2016,1748042,'3456510873000385',42591),(2016,1748163,'3453710889000428',42427),(2016,1754377,'3452120898000057',42550),
			(2016,1755580,'3457110889000799',42468),(2016,1775268,'3457020873000624',42417),(2016,1857668,'3458410871000826',42430),(2016,1858857,'3449310889000184',42520),
			(2016,1862682,'3456410873000479',42616),(2016,1875359,'3448810883000677',42474),(2016,1875483,'3453910878001029',42454),(2016,1945650,'3458220886000566',42532),
			(2016,1952400,'3458720892000146',42469),(2016,1954797,'3453020883000568',42609),(2016,1973029,'3448910892000187',42447),(2016,2015872,'3449410869000400',42570),
			(2016,2017519,'3454810877000494',42654),(2016,2089862,'3456610868000034',42403),(2016,2093179,'3456210887000410',42441),(2016,2093663,'3458020873000235',42506),
			(2016,2141949,'3457910886000704',42510),(2016,2171990,'3448210887000148',42453),(2016,2195061,'3448010898000313',42618),(2016,2206196,'3454810884000735',42457),
			(2016,2213589,'3458910885000043',42429),(2016,2273924,'3454320892000032',42579),(2016,2281070,'3453610881000816',42482),(2016,2328666,'3447910870000077',42539),
			(2016,2341937,'3451410890000697',42448),(2016,2380635,'3447120870000123',42420),(2016,2400010,'3451110894000384',42429),(2016,2447581,'3453910887000616',42490),
			(2016,2463466,'3455810885000501',42453),(2016,2522433,'3454010873000297',42591),(2016,2524560,'7748710885003794',42649),(2016,2550109,'3455110883000615',42503),
			(2016,2556329,'1147310898000455',42426),(2016,2650318,'3450410873000970',42478)) v(ReportYear,PID,ENP,DateEnd)



UPDATE c SET c.ENP=p.ENP
FROM #tmpEKO c INNER JOIN PolicyRegister.dbo.PEOPLE p ON
			c.pid=p.id
WHERE c.ENP IS null


SELECT c.id AS rf_idCase,c.AmountPayment,d.DS1,c.DateBegin,c.DateEnd,ce.pid,ce.ENP,e.rf_idCase AS rf_idCaseEKO, c.Comments
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase  
					INNER JOIN #tmpEKO e ON
			ce.ENP=e.ENP					                  
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<@dtEndAmb AND c.rf_idV002=136 AND c.rf_idV006=3 AND c.DateBegin>=e.DateEnd AND a.ReportYearMonth<=201712
		AND e.AmountPayment>0

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c INNER JOIN #tmpCases cc ON
														c.rf_idCase=cc.rf_idCase																							
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<@dtEndAmb
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 

   
SELECT e.ENP,e.DateEnd, l.NAMES,'Волгоградская область',c.DateBegin,c.DateEnd,c.DS1,m.Diagnosis, c.Comments
FROM #tmpEKO e INNER JOIN #tmpCases c ON
		e.ENP=c.ENP
				INNER JOIN dbo.vw_sprMKB10 m ON
		c.DS1=m.DiagnosisCode 
				INNER JOIN dbo.vw_sprT001 l ON
		e.CodeM=l.CodeM      
WHERE m.MainDS IN('O10','O11','O12','O13','O14','O15','O16','O20','O21','O22','O23','O24','O25','O26','O28','O30','O31','O32','O33','O36','O40','O41','O43','O44','O45','O46','O47','O98','O99'
				,'Z33','Z34','Z35','Z36')		            
		AND c.AmountPayment>0
--ORDER BY c.DateEnd desc

DROP TABLE dbo.tmpEKO34

SELECT 	rf_idCase ,DateEnd ,pid ,ENP
INTO tmpEKO34
FROM #tmpEKO e 
WHERE AmountPayment>0

GO
DROP TABLE #tmpCases
DROP TABLE #tmpEKO