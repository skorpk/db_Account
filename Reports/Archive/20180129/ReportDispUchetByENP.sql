USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATETIME='20180119',
		@dtEnd DATETIME='20180101',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=12
				
SELECT DISTINCT f.CodeM,RTRIM(a.rf_idSMO) AS CodeSMO,c.id AS rf_idCase,c.AmountPayment,CAST(0.0 AS DECIMAL(15,2)) AS AmountPaymentAccepted,c.Age,s.ENP,dd.TypeDisp,c.rf_idV009 AS RSLT,rp.Sex,c.IsNeedDisp AS PR_D_N,
		c.DateEnd,f.DateRegistration
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_PatientSMO s ON
			r.id=s.rf_idRecordCasePatient           
					INNER JOIN dbo.t_RegisterPatient rp ON
			r.id=rp.rf_idRecordCase
			AND f.id=rp.rf_idFiles       
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient								
					inner JOIN dbo.t_DispInfo dd ON
			c.id=dd.rf_idCase
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND c.DateEnd>=@dtBegin AND c.DateEnd<@dtEnd AND a.Letter='O'
--наши
UPDATE c SET c.AmountPaymentAccepted=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c INNER JOIN #tmpCases cc ON
										c.rf_idCase=cc.rf_idCase																							
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase    
--иногородние
UPDATE c SET c.AmountPaymentAccepted=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase34 c INNER JOIN #tmpCases cc ON
										c.rf_idCase=cc.rf_idCase																							
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase  

SELECT  CodeM ,CodeSMO,rf_idCase ,AmountPaymentAccepted ,Age ,ENP ,TypeDisp ,RSLT ,Sex ,PR_D_N ,DateEnd ,DateRegistration, 0 AS DV1
INTO #tmpDD
FROM #tmpCases 
WHERE AmountPaymentAccepted>0			
ORDER BY ROW_NUMBER() OVER(PARTITION BY enp,TypeDisp ORDER BY DateEnd,DateRegistration) 

UPDATE d1 SET DV1=1
FROM #tmpDD d1 
WHERE d1.TypeDisp='ДВ1' AND NOT EXISTS(SELECT * FROM #tmpDD d2 WHERE d2.ENP =d1.ENP AND d2.TypeDisp='ДВ2')

--SELECT COUNT( DISTINCT ENP) FROM #tmpDD WHERE CodeSMO='34' --GROUP BY TypeDisp

;WITH cteDS
AS(
SELECT c.id,ds.DS1
FROM #tmpDD dd INNER JOIN dbo.t_Case c ON
		dd.rf_idCase=c.id
				INNER JOIN dbo.vw_Diagnosis ds ON
		c.id=ds.rf_idCase              
				INNER JOIN dbo.tmpDS_Nikitenko n ON
		ds.DS1=n.DS
WHERE ISNULL(c.IsNeedDisp,0)<>0
UNION ALL
SELECT c.id,ds.DiagnosisCode
FROM #tmpDD dd INNER JOIN dbo.t_Case c ON
		dd.rf_idCase=c.id
				INNER JOIN dbo.t_DS2_Info ds ON
		c.id=ds.rf_idCase              
				INNER JOIN dbo.tmpDS_Nikitenko n ON
		ds.DiagnosisCode=n.DS
WHERE ISNULL(ds.IsNeedDisp,0)<>0
)
SELECT DISTINCT id INTO #tDS FROM cteDS

ALTER TABLE #tmpDD ADD isGood TINYINT



;WITH cteDDW 
AS(		
	SELECT ENP,rf_idCase,sex,TypeDisp
	FROM #tmpDD dd INNER JOIN #tDS ds ON
			dd.rf_idCase=ds.id
	WHERE TypeDisp='ДВ2' AND RSLT IN(318,355,356) and Age>17 
	UNION ALL
	SELECT ENP,rf_idCase,sex,TypeDisp
	FROM #tmpDD dd INNER JOIN #tDS ds ON
			dd.rf_idCase=ds.id
	WHERE TypeDisp='ДВ1' and DV1=1 AND RSLT IN(318,355,356,352,353,357,358) and Age>17 	
)
SELECT DISTINCT ENP,rf_idCase,sex,TypeDisp INTO tmpDisp
FROM cteDDW d 




GO
DROP TABLE #tmpCases
DROP TABLE #tmpDD
DROP TABLE #tDS