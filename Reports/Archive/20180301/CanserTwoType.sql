USE AccountOMS
GO
DECLARE @dateBegReg DATETIME='20170101',
		@dateEndReg datetime ='20180221',
		@reportYear smallint=2017,
		@dateBegRegOld DATETIME='20150101', 
		@dateEndRegOld DATETIME='20180101'

CREATE TABLE #tPeople(ENP VARCHAR(20),PID INT ,DiagnosisCode VARCHAR(10),TypeQuery TINYINT,FIO VARCHAR(50), DR DATE, DateRegister NVARCHAR(10), DateUnRegister NVARCHAR(10))
INSERT #tPeople( ENP, PID, DiagnosisCode, TypeQuery, FIO,DR, DateRegister, DateUnRegister ) SELECT Enp,PID,CODE_DIAG,1,FIO,DR,DATE_REG,DATE_UNREG 
FROM [PeopleAttach].[dbo].[CR_pj_tmp] WHERE ENP IS NOT null 
INSERT #tPeople( ENP, PID, DiagnosisCode, TypeQuery, FIO,DR, DateRegister, DateUnRegister ) SELECT Enp,PID,CODE_DIAG,2,FIO,DR,DATE_REG,DATE_UNREG 
FROM [PeopleAttach].[dbo].[CR_rp_tmp] WHERE ENP IS NOT null 

;WITH cte
AS(
SELECT TOP 1 WITH TIES p.*,c.id AS rf_idCase,c.DateBegin, c.AmountPayment,a.rf_idSMO AS CodeSMO,DS1
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_PatientSMO s ON
			r.id=s.rf_idRecordCasePatient           					       
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase   
					INNER JOIN dbo.vw_sprMKB10 mkb ON
			d.DS1=mkb.DiagnosisCode               
					inner JOIN #tPeople p on
			s.ENP=p.ENP								
WHERE f.DateRegistration>=@dateBegReg AND f.DateRegistration<@dateEndReg AND ReportYear=@reportYear AND f.CodeM='103001' 
		AND TypeQuery=1 AND mkb.MainDS IN('C15','C16','C17','C18', 'C19', 'C20','C21','C22','C23','C24','C25','C26')
ORDER BY ROW_NUMBER() OVER(PARTITION BY p.enp ORDER BY c.DateBegin,f.DateRegistration)
UNION all
SELECT TOP 1 WITH TIES p.*,c.id AS rf_idCase,c.DateBegin, c.AmountPayment,a.rf_idSMO,DS1
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_PatientSMO s ON
			r.id=s.rf_idRecordCasePatient           					    
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase   
					INNER JOIN dbo.vw_sprMKB10 mkb ON
			d.DS1=mkb.DiagnosisCode               
					inner JOIN #tPeople p on
			s.ENP=p.ENP								
WHERE f.DateRegistration>=@dateBegReg AND f.DateRegistration<@dateEndReg AND ReportYear=@reportYear AND f.CodeM='103001' 
		AND TypeQuery=2 AND mkb.MainDS IN('C00','C01', 'C02', 'C03', 'C04', 'C05','C06','C07','C08','C09','C10','C11','C12','C13','C14')				 
ORDER BY ROW_NUMBER() OVER(PARTITION BY p.enp ORDER BY c.DateBegin,f.DateRegistration)
)
SELECT * INTO #tmpCases FROM cte ORDER BY enp

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c INNER JOIN #tmpCases cc ON
										c.rf_idCase=cc.rf_idCase																							
								WHERE c.DateRegistration>=@dateBegReg AND c.DateRegistration<=GETDATE()	AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase  


DELETE FROM #tmpCases WHERE AmountPayment=0 

SELECT TOP 1 WITH TIES p.*,c.id AS rf_idCaseNew, c.AmountPayment AS AmountPayment2,f.CodeM
INTO #tmpCasesOther
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts													      
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient											
					INNER JOIN dbo.t_Case_PID_ENP pe ON
			c.id=pe.rf_idCase                  
					inner JOIN #tmpCases p on
			pe.PID = p.PID				
WHERE f.DateRegistration>=@dateBegRegOld AND f.DateRegistration<@dateEndRegOld AND f.CodeM<>'103001' AND c.DateEnd<=p.DateBegin	AND a.Letter<>'K'
ORDER BY ROW_NUMBER() OVER(PARTITION BY p.enp ORDER BY c.DateBegin desc,f.DateRegistration DESC)

UPDATE c SET c.AmountPayment2=c.AmountPayment2-p.AmountDeduction
from #tmpCasesOther c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c INNER JOIN #tmpCasesOther cc ON
										c.rf_idCase=cc.rf_idCaseNew																							
								WHERE c.DateRegistration>=@dateBegRegOld AND c.DateRegistration<=GETDATE()	AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCaseNew=p.rf_idCase  


DELETE FROM #tmpCasesOther WHERE AmountPayment=0 

SELECT DISTINCT t.rf_idCaseNew,c.TypeCheckup,c.AmountDeduction,r.CodeReason
INTO #tAkt
FROM dbo.t_PaymentAcceptedCase2 c INNER JOIN #tmpCasesOther t ON
				c.rf_idCase=t.rf_idCaseNew		
							LEFT JOIN vw_sprReasonDenialPayment r ON
				c.rf_idCase=r.rf_idCase
				AND c.idAkt=r.idAkt																					
WHERE c.DateRegistration>=@dateBegRegOld AND c.DateRegistration<=GETDATE() AND c.TypeCheckup IN(2,3)

SELECT pp.ENP,pp.FIO,pp.DR,c.DateBegin,c.DateEnd,cc.CodeSMO,cc.DS1
		,l.NAMES AS LPU,a.rf_idSMO,c1.DateBegin,c1.DateEnd,c.Age,ISNULL(r.SeriaPolis,'')+r.NumberPolis AS Policy
		,CAST(f.DateRegistration AS DATE) AS DateRegistration,a.Account,a.DateRegister,
		c1.idRecordCase,d.DS1, mkb.Diagnosis,c1.AmountPayment,v2.name AS Profil, v6.name AS USL_OK,c1.NumberHistoryCase,v9.name AS RSLT, v12.name AS ISHOD, v4.name AS PRVS,
		c1.DateBegin,c1.DateEnd,		
		CASE WHEN aa.TypeCheckup=2 THEN aa.CodeReason ELSE NULL END AS CodeMEE,
		CASE WHEN aa.TypeCheckup=2 THEN CAST(ISNULL(aa.AmountDeduction,0.0) AS MONEY) else null end AS DeductionMEE,
		----------------------------------------------------------
		CASE WHEN aa.TypeCheckup=3 THEN aa.CodeReason ELSE NULL END AS CodeEKMP,
		CASE WHEN aa.TypeCheckup=3 THEN CAST(ISNULL(aa.AmountDeduction,0.0) AS MONEY) else null end AS DeductionEKMP		
FROM #tmpCasesOther cc INNER JOIN dbo.t_Case c ON
		cc.rf_idCase=c.id
						INNER JOIN dbo.t_Case c1 ON
		cc.rf_idCaseNew=c1.id
						INNER JOIN dbo.t_RecordCasePatient r ON
		c1.rf_idRecordCasePatient=r.id
						INNER JOIN dbo.t_RegistersAccounts a ON
		r.rf_idRegistersAccounts=a.id
						INNER JOIN dbo.t_File f ON
		a.rf_idFiles=f.id                      
						INNER JOIN dbo.vw_Diagnosis d ON
		c1.id=d.rf_idCase   
						INNER JOIN dbo.vw_sprMKB10 mkb ON
		d.DS1=mkb.DiagnosisCode                   
				INNER JOIN AccountOMS.dbo.vw_sprT001 l ON
		f.CodeM=l.CodeM
				INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
		c1.rf_idV002=v2.id   
				INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
		c1.rf_idV006=v6.id
				INNER JOIN RegisterCases.dbo.vw_sprV009 v9 ON
		c1.rf_idV009=v9.id 
				INNER JOIN RegisterCases.dbo.vw_sprV012 v12 ON
		c1.rf_idV012=v12.id 
				INNER JOIN RegisterCases.dbo.vw_sprV004 v4 ON
		c1.rf_idV004=v4.id  
		AND c1.DateEnd>=v4.DateBeg AND c1.DateEnd<v4.DateEnd
				LEFT JOIN #tAkt aa ON
		c1.id=aa.rf_idCaseNew  
				right JOIN #tPeople pp ON
		cc.PID=pp.PID
WHERE pp.TypeQuery=2

go
DROP TABLE #tPeople
DROP TABLE #tmpCases
DROP TABLE #tmpCasesOther
DROP TABLE #tAkt
