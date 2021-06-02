USE AccountOMS
GO
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATETIME='20170629 23:59:59',
		@dtEndRegRAK DATETIME='20170630 23:59:59',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=5

SELECT *
INTO #csg
FROM (
		SELECT 1 AS rf_idV006, code,name
		FROM dbo.vw_sprCSG WHERE code LIKE '_____14[7-9]'		
		-----Дневной стационар---------------
		UNION ALL
		SELECT 2,code,name
		FROM dbo.vw_sprCSG WHERE code LIKE '_____04[4-6]'		
	) t	

SELECT f.CodeM,c.id AS rf_idCase, r.id AS rf_idRecordCasePatient, f.id AS rf_idFile,c.AmountPayment,c.rf_idV006,pid, DateBegin,DateEnd,MES,cs.name AS CSGName,enp
INTO #tmp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts							
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase		
					INNER JOIN #csg cs  ON
			m.MES=cs.code                  
			AND cs.rf_idV006=1
					inner JOIN dbo.t_Case_PID_ENP pc ON
			c.id=pc.rf_idCase       		          
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO IN('34007','34006','34002','34001') AND c.rf_idV006=1
UNION ALL
SELECT f.CodeM,c.id AS rf_idCase, r.id AS rf_idRecordCasePatient, f.id AS rf_idFile,c.AmountPayment,c.rf_idV006,pid,DateBegin, DateEnd,MES,cs.name AS CSGName,ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts							
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase		
					INNER JOIN #csg cs  ON
			m.MES=cs.code     
			AND cs.rf_idV006=2
					inner JOIN dbo.t_Case_PID_ENP pc ON
			c.id=pc.rf_idCase       			    
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO IN('34007','34006','34002','34001') 	 AND c.rf_idV006=2

UPDATE t SET t.ENP=p.ENP
FROM #tmp t INNER JOIN PolicyRegister.dbo.PEOPLE p on
		t.pid=p.id
WHERE t.ENP IS NULL

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmp c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
						 FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount
															INNER JOIN #tmp cc ON
														c.rf_idCase=cc.rf_idCase 																							
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndRegRAK
								GROUP BY c.rf_idCase 
							) p ON
			c.rf_idCase=p.rf_idCase 

;WITH cte 
AS
(
	SELECT  ROW_NUMBER() OVER(PARTITION BY ENP,rf_idV006 ORDER BY rf_idCase desc) AS id, rf_idCase,enp
	FROM #tmp WHERE AmountPayment>0
)
DELETE FROM cte WHERE id>1

SELECT l.NAMES AS LPU,p.FAM,p.Im,ISNULL(p.Ot,'') AS Ot,p.BirthDay,t.DateBegin,t.DateEnd,RTRIM(DS1)+' '+mkb.Diagnosis AS DS1,MES,CSGName,ISNULL(cr.STAGE,'')
FROM #tmp t INNER JOIN dbo.vw_Diagnosis d ON
		t.rf_idCase=d.rf_idCase
			INNER JOIN dbo.vw_sprMKB10 mkb ON
		d.DS1=mkb.DiagnosisCode
			INNER JOIN dbo.vw_RegisterPatient p ON
		t.rf_idRecordCasePatient=p.rf_idRecordCase
		AND t.rf_idFile=p.rf_idFiles	
			INNER JOIN dbo.vw_sprT001 l ON
		t.CodeM=l.CodeM		      
			LEFT JOIN PeopleAttach.dbo.CancerRegistr cr ON
		t.ENP=cr.ENP    
WHERE AmountPayment>0 AND rf_idV006=1 

SELECT l.NAMES AS LPU,p.FAM,p.Im,ISNULL(p.Ot,'') AS Ot,p.BirthDay,t.DateBegin,t.DateEnd,RTRIM(DS1)+' '+mkb.Diagnosis AS DS1,MES,CSGName,ISNULL(cr.STAGE,'')
FROM #tmp t INNER JOIN dbo.vw_Diagnosis d ON
		t.rf_idCase=d.rf_idCase
			INNER JOIN dbo.vw_sprMKB10 mkb ON
		d.DS1=mkb.DiagnosisCode
			INNER JOIN dbo.vw_RegisterPatient p ON
		t.rf_idRecordCasePatient=p.rf_idRecordCase
		AND t.rf_idFile=p.rf_idFiles			          
			INNER JOIN dbo.vw_sprT001 l ON
		t.CodeM=l.CodeM
				LEFT JOIN PeopleAttach.dbo.CancerRegistr cr ON
		t.ENP=cr.ENP   
WHERE AmountPayment>0 AND rf_idV006=2
go
DROP TABLE #csg
DROP TABLE #tmp
