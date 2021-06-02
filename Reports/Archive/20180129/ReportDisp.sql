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
--íàøè
UPDATE c SET c.AmountPaymentAccepted=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c INNER JOIN #tmpCases cc ON
										c.rf_idCase=cc.rf_idCase																							
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase    
--èíîãîðîäíèå
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
WHERE d1.TypeDisp='ÄÂ1' AND NOT EXISTS(SELECT * FROM #tmpDD d2 WHERE d2.ENP =d1.ENP AND d2.TypeDisp='ÄÂ2')

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

;WITH cteDDW 
AS(
SELECT CodeSMO
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>17 and Age<55 AND RSLT IN(317,318,355,356) THEN ENP ELSE NULL END) AS Column4
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>17 and Age<55 AND RSLT=317 THEN ENP ELSE NULL END) AS Column5
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>17 and Age<55 AND RSLT=318 THEN ENP ELSE NULL END) AS Column6
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>17 and Age<55 AND RSLT=355 THEN ENP ELSE NULL END) AS Column7
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>17 and Age<55 AND RSLT=356 THEN ENP ELSE NULL END) AS Column8
		--//////////////////////////////////////////////////////////////////////////////////-----------------
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>54 and Age<66 AND RSLT IN(317,318,355,356) THEN ENP ELSE NULL END) AS Column9
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>54 and Age<66 AND RSLT=317 THEN ENP ELSE NULL END) AS Column10
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>54 and Age<66 AND RSLT=318 THEN ENP ELSE NULL END) AS Column11
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>54 and Age<66 AND RSLT=355 THEN ENP ELSE NULL END) AS Column12
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>54 and Age<66 AND RSLT=356 THEN ENP ELSE NULL END) AS Column13
		--//////////////////////////////////////////////////////////////////////////////////-----------------
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>65 AND RSLT IN(317,318,355,356) THEN ENP ELSE NULL END) AS Column14
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>65 AND RSLT=317 THEN ENP ELSE NULL END) AS Column15
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>65 AND RSLT=318 THEN ENP ELSE NULL END) AS Column16
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>65 AND RSLT=355 THEN ENP ELSE NULL END) AS Column17
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>65 AND RSLT=356 THEN ENP ELSE NULL END) AS Column18
		,0 AS Column19,0 AS COLUMN20,0 AS COLUMN21,0 AS COLUMN22
FROM #tmpDD WHERE Sex='Æ' GROUP BY CodeSMO
UNION ALL
SELECT CodeSMO
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>17 and Age<55 AND RSLT IN(317,318,355,356,352,353,357,358) THEN ENP ELSE NULL END) AS Column4
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>17 and Age<55 AND RSLT in(317,352) THEN ENP ELSE NULL END) AS Column5
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>17 and Age<55 AND RSLT in(318,353) THEN ENP ELSE NULL END) AS Column6
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>17 and Age<55 AND RSLT in(355,357) THEN ENP ELSE NULL END) AS Column7
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>17 and Age<55 AND RSLT in(356,358) THEN ENP ELSE NULL END) AS Column8
		--//////////////////////////////////////////////////////////////////////////////////-----------------
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>54 and Age<66 AND RSLT IN(317,318,355,356,352,353,357,358) THEN ENP ELSE NULL END) AS Column9
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>54 and Age<66 AND RSLT in(317,352) THEN ENP ELSE NULL END) AS Column10
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>54 and Age<66 AND RSLT in(318,353) THEN ENP ELSE NULL END) AS Column11
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>54 and Age<66 AND RSLT in(355,357) THEN ENP ELSE NULL END) AS Column12
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>54 and Age<66 AND RSLT in(356,358) THEN ENP ELSE NULL END) AS Column13
		--//////////////////////////////////////////////////////////////////////////////////-----------------
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>65 AND RSLT IN(317,318,355,356,352,353,357,358) THEN ENP ELSE NULL END) AS Column14
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>65 AND RSLT in(317,352) THEN ENP ELSE NULL END) AS Column15
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>65 AND RSLT in(318,353) THEN ENP ELSE NULL END) AS Column16
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>65 AND RSLT in(355,357) THEN ENP ELSE NULL END) AS Column17
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>65 AND RSLT in(356,357) THEN ENP ELSE NULL END) AS Column18
		,0 AS Column19,0 AS COLUMN20,0 AS COLUMN21,0 AS COLUMN22
FROM #tmpDD	WHERE Sex='Æ' GROUP BY CodeSMO
UNION ALL
SELECT CodeSMO,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		,COUNT( DISTINCT CASE WHEN TypeDisp='ÄÂ2' AND RSLT IN(318,355,356) and Age>17 THEN enp ELSE NULL END) AS col19
		,COUNT( DISTINCT CASE WHEN TypeDisp='ÄÂ2' AND RSLT IN(318,355,356) and Age>17 and Age<55 THEN enp ELSE NULL END) AS col20
		,COUNT( DISTINCT CASE WHEN TypeDisp='ÄÂ2' AND RSLT IN(318,355,356) and Age>54 and Age<66 THEN enp ELSE NULL END) AS col21
		,COUNT( DISTINCT CASE WHEN TypeDisp='ÄÂ2' AND RSLT IN(318,355,356) and Age>65 THEN enp ELSE NULL END) AS col22
FROM #tmpDD dd INNER JOIN #tDS ds ON
		dd.rf_idCase=ds.id
WHERE Sex='Æ' GROUP BY CodeSMO
UNION ALL
SELECT CodeSMO,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		,COUNT( DISTINCT CASE WHEN TypeDisp='ÄÂ1' and DV1=1 AND RSLT IN(318,355,356,352,353,357,358) and Age>17 THEN enp ELSE NULL END) AS col19
		,COUNT( DISTINCT CASE WHEN TypeDisp='ÄÂ1' and DV1=1 AND RSLT IN(318,355,356,352,353,357,358) and Age>17 and Age<55 THEN enp ELSE NULL END) AS col20
		,COUNT( DISTINCT CASE WHEN TypeDisp='ÄÂ1' and DV1=1 AND RSLT IN(318,355,356,352,353,357,358) and Age>54 and Age<66 THEN enp ELSE NULL END) AS col21
		,COUNT( DISTINCT CASE WHEN TypeDisp='ÄÂ1' and DV1=1 AND RSLT IN(318,355,356,352,353,357,358) and Age>65 THEN enp ELSE NULL END) AS col22
FROM #tmpDD dd INNER JOIN #tDS ds ON
		dd.rf_idCase=ds.id
WHERE Sex='Æ' GROUP BY CodeSMO																  
)
SELECT s.sNameS,CodeSMO, SUM(column4+column9+column14) AS TotalPeople
		, SUM(column4) AS Col4,SUM(column5) AS Col5,SUM(column6) AS Col6,SUM(column7) AS Col7,SUM(column8) AS Col8
		, SUM(column9) AS Col9,SUM(column10) AS Col10,SUM(column11) AS Col11,SUM(column12) AS Col12,SUM(column13) AS Col13
		, SUM(column14) AS Col14,SUM(column15) AS Col15,SUM(column16) AS Col16,SUM(column17) AS Col17,SUM(column18) AS Col18
		, SUM(column19) AS Col19,SUM(column20) AS Col20,SUM(column21) AS Col21,SUM(column22) AS Col22
FROM cteDDW d INNER JOIN dbo.vw_sprSMO s ON
		d.codeSMO=s.smocod
GROUP BY snames,CodeSMO


;WITH cteDDM 
AS(
SELECT CodeSMO
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>17 and Age<55 AND RSLT IN(317,318,355,356) THEN ENP ELSE NULL END) AS Column4
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>17 and Age<55 AND RSLT=317 THEN ENP ELSE NULL END) AS Column5
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>17 and Age<55 AND RSLT=318 THEN ENP ELSE NULL END) AS Column6
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>17 and Age<55 AND RSLT=355 THEN ENP ELSE NULL END) AS Column7
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>17 and Age<55 AND RSLT=356 THEN ENP ELSE NULL END) AS Column8
		--//////////////////////////////////////////////////////////////////////////////////-----------------
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>54 and Age<66 AND RSLT IN(317,318,355,356) THEN ENP ELSE NULL END) AS Column9
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>54 and Age<66 AND RSLT=317 THEN ENP ELSE NULL END) AS Column10
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>54 and Age<66 AND RSLT=318 THEN ENP ELSE NULL END) AS Column11
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>54 and Age<66 AND RSLT=355 THEN ENP ELSE NULL END) AS Column12
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>54 and Age<66 AND RSLT=356 THEN ENP ELSE NULL END) AS Column13
		--//////////////////////////////////////////////////////////////////////////////////-----------------
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>65 AND RSLT IN(317,318,355,356) THEN ENP ELSE NULL END) AS Column14
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>65 AND RSLT=317 THEN ENP ELSE NULL END) AS Column15
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>65 AND RSLT=318 THEN ENP ELSE NULL END) AS Column16
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>65 AND RSLT=355 THEN ENP ELSE NULL END) AS Column17
		,count(CASE WHEN TypeDisp='ÄÂ2' and Age>65 AND RSLT=356 THEN ENP ELSE NULL END) AS Column18
		,0 AS Column19,0 AS COLUMN20,0 AS COLUMN21,0 AS COLUMN22
FROM #tmpDD WHERE Sex='Ì' GROUP BY CodeSMO
UNION ALL
SELECT CodeSMO
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>17 and Age<55 AND RSLT IN(317,318,355,356,352,353,357,358) THEN ENP ELSE NULL END) AS Column4
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>17 and Age<55 AND RSLT in(317,352) THEN ENP ELSE NULL END) AS Column5
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>17 and Age<55 AND RSLT in(318,353) THEN ENP ELSE NULL END) AS Column6
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>17 and Age<55 AND RSLT in(355,357) THEN ENP ELSE NULL END) AS Column7
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>17 and Age<55 AND RSLT in(356,358) THEN ENP ELSE NULL END) AS Column8
		--//////////////////////////////////////////////////////////////////////////////////-----------------
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>54 and Age<66 AND RSLT IN(317,318,355,356,352,353,357,358) THEN ENP ELSE NULL END) AS Column9
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>54 and Age<66 AND RSLT in(317,352) THEN ENP ELSE NULL END) AS Column10
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>54 and Age<66 AND RSLT in(318,353) THEN ENP ELSE NULL END) AS Column11
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>54 and Age<66 AND RSLT in(355,357) THEN ENP ELSE NULL END) AS Column12
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>54 and Age<66 AND RSLT in(356,358) THEN ENP ELSE NULL END) AS Column13
		--//////////////////////////////////////////////////////////////////////////////////-----------------
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>65 AND RSLT IN(317,318,355,356,352,353,357,358) THEN ENP ELSE NULL END) AS Column14
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>65 AND RSLT in(317,352) THEN ENP ELSE NULL END) AS Column15
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>65 AND RSLT in(318,353) THEN ENP ELSE NULL END) AS Column16
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>65 AND RSLT in(355,357) THEN ENP ELSE NULL END) AS Column17
		,count(CASE WHEN TypeDisp='ÄÂ1' and DV1=1 and Age>65 AND RSLT in(356,357) THEN ENP ELSE NULL END) AS Column18
		,0 AS Column19,0 AS COLUMN20,0 AS COLUMN21,0 AS COLUMN22
FROM #tmpDD	WHERE Sex='Ì' GROUP BY CodeSMO
UNION ALL
SELECT CodeSMO,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		,COUNT( DISTINCT CASE WHEN TypeDisp='ÄÂ2' AND RSLT IN(318,355,356) and Age>17 THEN enp ELSE NULL END) AS col19
		,COUNT( DISTINCT CASE WHEN TypeDisp='ÄÂ2' AND RSLT IN(318,355,356) and Age>17 and Age<55 THEN enp ELSE NULL END) AS col20
		,COUNT( DISTINCT CASE WHEN TypeDisp='ÄÂ2' AND RSLT IN(318,355,356) and Age>54 and Age<66 THEN enp ELSE NULL END) AS col21
		,COUNT( DISTINCT CASE WHEN TypeDisp='ÄÂ2' AND RSLT IN(318,355,356) and Age>65 THEN enp ELSE NULL END) AS col22
FROM #tmpDD dd INNER JOIN #tDS ds ON
		dd.rf_idCase=ds.id
WHERE Sex='Ì' GROUP BY CodeSMO
UNION ALL
SELECT CodeSMO,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		,COUNT(DISTINCT CASE WHEN TypeDisp='ÄÂ1' and DV1=1 AND RSLT IN(318,355,356,352,353,357,358) and Age>17 THEN enp ELSE NULL END) AS col19
		,COUNT(DISTINCT CASE WHEN TypeDisp='ÄÂ1' and DV1=1 AND RSLT IN(318,355,356,352,353,357,358) and Age>17 and Age<55 THEN enp ELSE NULL END) AS col20
		,COUNT(DISTINCT CASE WHEN TypeDisp='ÄÂ1' and DV1=1 AND RSLT IN(318,355,356,352,353,357,358) and Age>54 and Age<66 THEN enp ELSE NULL END) AS col21
		,COUNT(DISTINCT CASE WHEN TypeDisp='ÄÂ1' and DV1=1 AND RSLT IN(318,355,356,352,353,357,358) and Age>65 THEN enp ELSE NULL END) AS col22
FROM #tmpDD dd INNER JOIN #tDS ds ON
		dd.rf_idCase=ds.id
WHERE Sex='Ì' GROUP BY CodeSMO
)
SELECT s.sNameS,CodeSMO, SUM(column4+column9+column14) AS TotalPeople
		, SUM(column4) AS Col4,SUM(column5) AS Col5,SUM(column6) AS Col6,SUM(column7) AS Col7,SUM(column8) AS Col8
		, SUM(column9) AS Col9,SUM(column10) AS Col10,SUM(column11) AS Col11,SUM(column12) AS Col12,SUM(column13) AS Col13
		, SUM(column14) AS Col14,SUM(column15) AS Col15,SUM(column16) AS Col16,SUM(column17) AS Col17,SUM(column18) AS Col18
		, SUM(column19) AS Col19,SUM(column20) AS Col20,SUM(column21) AS Col21,SUM(column22) AS Col22
FROM cteDDM d INNER JOIN dbo.vw_sprSMO s ON
		d.codeSMO=s.smocod
GROUP BY snames,CodeSMO

GO
DROP TABLE #tmpCases
DROP TABLE #tmpDD
DROP TABLE #tDS