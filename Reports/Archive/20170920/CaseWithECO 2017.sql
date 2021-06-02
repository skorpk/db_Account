USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATE='20170831',
		@dtEnd DATETIME='20170920 23:59:59',
		@dtEndAmb DATETIME='20171121',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=10
				
SELECT TOP 1 WITH TIES c.id AS rf_idCase,c.AmountPayment,c.DateEnd,ce.pid,ce.ENP,f.CodeM
INTO #tmpEKO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase  
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase            
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<=@dtEndReg AND c.rf_idV002=137 AND c.rf_idV006=2
	AND m.MES LIKE '2__40005' AND ce.PID IS NULL
ORDER BY ROW_NUMBER() OVER(PARTITION BY ce.ENP ORDER BY c.DateEnd desc)		

INSERT #tmpEKO (rf_idCase,AmountPayment,DateEnd,PID,ENP,CodeM)
SELECT TOP 1 WITH TIES c.id AS rf_idCase,c.AmountPayment,c.DateEnd,ce.pid,ce.ENP,f.CodeM
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Case_PID_ENP ce ON
			c.id=ce.rf_idCase  
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase            
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<=@dtEndReg AND c.rf_idV002=137 AND c.rf_idV006=2
	AND m.MES LIKE '2__40005' AND ce.PID IS NOT NULL
ORDER BY ROW_NUMBER() OVER(PARTITION BY ce.PID ORDER BY c.DateEnd desc)

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpEKO c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase	c
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEnd
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 


--INSERT #tmpEKO (rf_idCase,AmountPayment,DateEnd,PID,ENP) 
--SELECT 0,100,v.DateEnd,0,v.ENP
--FROM tmp_Eko_Victor	v	   
--определяем людей из БД Калиничева. Их присылает мне Александрова.
INSERT #tmpEKO (rf_idCase,AmountPayment,DateEnd,PID,ENP) 
SELECT 0,100,CONVERT(DATE,c.DATE_2,120) AS DateEnd,0,p.ENP
FROM ACCOTFOMS2011.dbo.t_FilesR f INNER JOIN ACCOTFOMS2011.dbo.t_Accounts a ON
			f.id=a.id_FileR
				 INNER JOIN ACCOTFOMS2011.dbo.t_Pacients p ON
			a.id=p.id_Account
				INNER JOIN ACCOTFOMS2011.dbo.t_Cases c ON
			p.id=c.id_Pacient              
				 INNER JOIN (VALUES ('40000','2000',27,'780079'), ('40000','1692',8,'780035'),('40000','1753',120,'780486'),('40000','2305',9,'780264'),('45000','431',90,'774781'),
									('45000','431',282,'774795'),('45000','431',1482,'774795'),('45000','592',1023,'774781'),('45000','752',56,'774864'),('45000','752',205,'774781'),
									('45000','752',910,'774781'),('45000','752',2159,'774781'),('45000','752',2162,'774781'),('45000','914',165,'775039'),('45000','914',461,'774781'),
									('45000','914',702,'774781'),('45000','914',916,'774781'),('45000','1076',125,'774781'),('45000','1076',1548,'774781'),
									('45000','1076',1561,'774781'),('45000','1076',1635,'774781'),('45000','1076',1672,'774781'),('45000','1076',1761,'774781'),
									('45000','1236',123,'774781'),('45000','1236',293,'774781'),('45000','1236',551,'775039'),('45000','1236',596,'774781'),
									('45000','1236',642,'774781'),('45000','1236',697,'774781'),('45000','1236',904,'774781'),('45000','1236',1000,'774781'),
									('45000','1236',1237,'774781'),('45000','1396',29,'774781'),('45000','1396',230,'774781'),('45000','1396',553,'774781'),
									('45000','1396',644,'774781'),('45000','1396',721,'774781'),('45000','1396',729,'774781'),('45000','1396',872,'774781'),
									('45000','1396',1464,'774781'),('45000','1552',239,'774781'),('45000','1715',163,'774781'),('45000','1715',391,'774781'),
									('45000','1715',430,'774781'),('45000','1715',1534,'774781'),('45000','1715',1567,'774781'),('63000','70134',143,'640971'),('63000','70434',274,'640971'))v(OKATO,Account,N_ZAP,CodeM) ON
			a.C_OKATO1=v.OKATO
			AND a.NSCHET=v.account
			AND p.N_ZAP=v.n_zap
WHERE a.YEAR=2017


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
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<@dtEndAmb AND c.rf_idV002=136 AND c.rf_idV006=3 AND c.DateBegin>=e.DateEnd AND a.ReportYearMonth<=201710 AND e.AmountPayment>0

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase c INNER JOIN #tmpCases cc ON
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

INSERT dbo.tmpEKO34
        ( rf_idCase, DateEnd, pid, ENP )
SELECT 	rf_idCase ,DateEnd ,pid ,ENP
FROM #tmpEKO e 
WHERE AmountPayment>0

GO
DROP TABLE #tmpCases
DROP TABLE #tmpEKO