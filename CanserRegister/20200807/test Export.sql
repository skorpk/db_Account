USE [AccountOMS]
GO
DECLARE @dateStart DATETIME='20190101',	--всегда с начало года
		@dateEnd DATETIME=GETDATE(),
		@dateEndRAK DATETIME=GETDATE(),
		@reportYear SMALLINT=2019


SELECT distinct DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'	


------берем с диагнозом из списка
-- 1 по диагнозу и 2 по DS_ONK
SELECT c.id AS rf_idCase,c.AmountPayment AS Payment, CAST(0.0 AS DECIMAL(15,2)) AS AmountPayment, ENP, f.CodeM,a.Account,a.DateRegister,c.DateBegin, c.rf_idV009, 1 AS TypeSearch, c.DateEnd, r.id AS rf_idRecordCasePatient
, CAST(NULL AS VARCHAR(10)) AS DiagnosisCode,a.rf_idSMO AS CodeSMO,1 AS TypeQ
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient					  										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
					INNER JOIN t_DS_ONK_REAB dd ON
			c.id=dd.rf_idCase																   					  					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear>=@reportYear AND dd.DS_ONK=1 AND f.TypeFile='H'	 AND c.rf_idv006<4
	AND a.rf_idSMO<>'34' AND ps.ENP='1351430846000422'

CREATE UNIQUE NONCLUSTERED INDEX QU_IXCase ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY
--CREATE UNIQUE NONCLUSTERED INDEX QU_IXENP ON #tCases(ENP) WITH IGNORE_DUP_KEY


INSERT #tCases
SELECT c.id AS rf_idCase,c.AmountPayment AS Payment, CAST(0.0 AS DECIMAL(15,2)) AS AmountPayment, ENP, f.CodeM,a.Account,a.DateRegister,c.DateBegin, c.rf_idV009,2, c.DateEnd, r.id AS rf_idRecordCasePatient
, CAST(NULL AS VARCHAR(10)) AS DiagnosisCode,a.rf_idSMO AS CodeSMO,2 AS TypeQ
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient					  										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
					INNER JOIN dbo.t_DispInfo dd ON
			c.id=dd.rf_idCase																   					  					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear>=@reportYear AND dd.IsOnko=1 AND f.TypeFile='F'	AND c.rf_idv006<4
	AND a.rf_idSMO<>'34' AND ps.ENP='1351430846000422'
--основной диагноз
INSERT #tCases
SELECT c.id AS rf_idCase,c.AmountPayment AS Payment, CAST(0.0 AS DECIMAL(15,2)) AS AmountPayment, ENP, f.CodeM,a.Account,a.DateRegister,c.DateBegin, 
c.rf_idV009,1, c.DateEnd, r.id AS rf_idRecordCasePatient, d.DiagnosisCode,a.rf_idSMO AS CodeSMO,3 AS TypeQ
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient					  										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase																   					  					      
					INNER JOIN #tD td ON
			d.DiagnosisCode=td.DiagnosisCode                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear>=@reportYear AND d.TypeDiagnosis IN(1,3) AND c.rf_idv006<4
	  AND a.rf_idSMO<>'34' AND ps.ENP='1351430846000422'
---------летальность 
-----------------------07.08.2020---------------
INSERT #tCases
SELECT c.id AS rf_idCase,c.AmountPayment AS Payment, CAST(0.0 AS DECIMAL(15,2)) AS AmountPayment, ENP, f.CodeM,a.Account,a.DateRegister,c.DateBegin, 
c.rf_idV009,1, c.DateEnd, r.id AS rf_idRecordCasePatient, d.DiagnosisCode,a.rf_idSMO AS CodeSMO,3 AS TypeQ
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient					  
					INNER JOIN (VALUES(105),(106),(205),(206),(313),(405),(406),(411)) v(rf_idV009) ON
			c.rf_idV009=v.rf_idV009										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase																   					  					      					               
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear>=@reportYear AND c.rf_idv006<4
	  AND a.rf_idSMO<>'34' AND ps.ENP='1351430846000422'

INSERT #tCases
SELECT c.id AS rf_idCase,c.AmountPayment AS Payment, CAST(0.0 AS DECIMAL(15,2)) AS AmountPayment, ENP, f.CodeM,a.Account,a.DateRegister,c.DateBegin
, c.rf_idV009,1 , c.DateEnd, r.id AS rf_idRecordCasePatient, dd.DiagnosisCode,a.rf_idSMO AS CodeSMO,4 AS TypeQ
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient					  										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase			
					INNER JOIN #tD td ON
			dd.DiagnosisCode=td.DiagnosisCode 													   					  					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear>=@reportYear AND f.TypeFile='F'	AND c.rf_idv006<4
	  AND a.rf_idSMO<>'34' AND ps.ENP='1351430846000422'
--добавить выборку сведений по диспансеризации и профосмотру по пациенту включенному в КанцерРегистр.
SELECT * FROM #tCases
UPDATE p SET p.AmountPayment=p.Payment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.TypeCheckup=1 and c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT distinct c.ENP,p.FAM,p.IM,p.OT,p.DR,CASE WHEN p.W=2 THEN 'Ж' ELSE 'М' END AS Sex,0
FROM #tCases c INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		c.ENP=p.ENP
WHERE AmountPayment>0 


---расчитываем DS_ONK и Дату признака подозрения на ЗНО
;WITH cte_DS_ONK
AS
(
	SELECT c.id AS rf_idCase,ps.ENP,cc.DateEnd,DS_ONK
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts					
						INNER JOIN dbo.t_Case c  ON
				r.id=c.rf_idRecordCasePatient					  										     
						INNER JOIN dbo.t_CompletedCase cc  ON
				r.id=cc.rf_idRecordCasePatient						
						INNER JOIN dbo.t_PatientSMO ps ON
				r.id=ps.rf_idRecordCasePatient	
						INNER JOIN #tCases ce ON
				ps.ENP=ce.ENP
						INNER JOIN dbo.vw_DS_ONK dd ON
				c.id=dd.rf_idCase								
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear>=@reportYear and c.rf_idv006<4	AND dd.DS_ONK=1
			AND NOT EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=ce.ENP)	AND ce.AmountPayment>0
	UNION ALL
	SELECT c.id AS rf_idCase, ps.ENP,cc.DateEnd,0
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts					
							INNER JOIN dbo.t_Case c  ON
					r.id=c.rf_idRecordCasePatient					  										     
							INNER JOIN dbo.t_CompletedCase cc  ON
					r.id=cc.rf_idRecordCasePatient
							INNER JOIN dbo.t_PatientSMO ps ON
					r.id=ps.rf_idRecordCasePatient	
							INNER JOIN #tCases ce ON
					ps.ENP=ce.ENP
							INNER JOIN dbo.t_Diagnosis d ON
				c.id=d.rf_idCase																   					  					      
						INNER JOIN #tD td ON
				d.DiagnosisCode=td.DiagnosisCode								
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear>=@reportYear and c.rf_idv006<4	AND d.TypeDiagnosis IN(1,3)
			AND NOT EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=ce.ENP)	AND ce.AmountPayment>0
	UNION ALL
	SELECT c.id AS rf_idCase, ps.ENP,cc.DateEnd,0
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts					
						INNER JOIN dbo.t_Case c  ON
				r.id=c.rf_idRecordCasePatient					  										     
						INNER JOIN dbo.t_CompletedCase cc  ON
				r.id=cc.rf_idRecordCasePatient
						INNER JOIN dbo.t_PatientSMO ps ON
				r.id=ps.rf_idRecordCasePatient	
						INNER JOIN #tCases ce ON
				ps.ENP=ce.ENP
						INNER JOIN dbo.t_DS2_Info d ON
			c.id=d.rf_idCase																   					  					      
					INNER JOIN #tD td ON
			d.DiagnosisCode=td.DiagnosisCode								
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear>=@reportYear AND ce.AmountPayment>0 AND c.rf_idv006<4	
		AND NOT EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=ce.ENP)
), cteFirst
AS
(
	SELECT ROW_NUMBER() OVER(PARTITION BY enp ORDER BY DateEnd) AS idRow, rf_idCase ,ENP ,DateEnd ,DS_ONK FROM cte_DS_ONK
)
SELECT  rf_idCase ,ENP ,DateEnd ,DS_ONK 
INTO #tDS_ONK
FROM cteFirst WHERE idRow=1 AND DS_ONK=1

SELECT distinct ENP ,DateEnd ,DS_ONK,rf_idCase FROM #tDS_ONK

--Направление на биопсию

;WITH cteBiopsy
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY ps.ENP ORDER BY dm.DirectionDate) AS idRow, ps.ENP,dm.DirectionDate as DirectionDate,c.id AS rf_idCase 
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts					
						INNER JOIN dbo.t_Case c  ON
				r.id=c.rf_idRecordCasePatient					  										     						
						INNER JOIN dbo.t_PatientSMO ps ON
				r.id=ps.rf_idRecordCasePatient	
						INNER JOIN #tDS_ONK ce ON
				ps.ENP=ce.ENP	
						INNER JOIN #tCases ce1 ON
				c.id=ce1.rf_idcase
						INNER JOIN dbo.t_DirectionMU dm ON
				c.id=dm.rf_idCase   						
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear>=@reportYear and c.rf_idv006<4	AND dm.TypeDirection=2 
		AND ce1.AmountPayment>0
)
SELECT ENP,DirectionDate,rf_idCase FROM cteBiopsy WHERE idRow=1

---расчитываем диагноз ЗНО и Дату постановки диагноза
;WITH cte_Diag
AS
(
	SELECT ce.ENP,cc.DateEnd,ce.DiagnosisCode,c.id AS rf_idCase
	FROM #tCases ce INNER JOIN dbo.t_Case c ON
				ce.rf_idCase=c.id	
					INNER JOIN dbo.t_CompletedCase cc ON
				c.rf_idRecordCasePatient = cc.rf_idRecordCasePatient                  
	WHERE ce.DiagnosisCode IS NOT NULL AND ce.AmountPayment>0
	UNION ALL
	SELECT ce.enp,c.DateEnd,d.DiagnosisCode, c.id AS rf_idCase  
	FROM #tCases ce INNER JOIN  dbo.t_CasesOnkologia2018 c2018 ON
				ce.ENP=c2018.ENP  
					INNER JOIN dbo.t_Case c ON
				c2018.rf_idCase=c.id						                  
					INNER JOIN dbo.t_Diagnosis d ON
				c.id = d.rf_idCase
					INNER JOIN #tD dd ON
				d.DiagnosisCode=dd.DiagnosisCode
	WHERE d.TypeDiagnosis IN(1,3) AND ce.AmountPayment>0
),
cteTotal
AS
(
	SELECT ROW_NUMBER() OVER(PARTITION BY enp ORDER BY DateEnd) AS idRow,ENP,DateEnd,DiagnosisCode,rf_idCase FROM cte_Diag
)
SELECT ENP,DiagnosisCode,DateEnd,rf_idCase INTO #tDiagnosis FROM cteTotal WHERE idRow=1

SELECT '#tDiagnosis',* FROM #tDiagnosis

------Стадия----------
SELECT ENP,o.rf_idN002 AS STAD,d.rf_idCase
FROM #tDiagnosis d INNER JOIN dbo.t_ONK_SL o ON
		d.rf_idCase=o.rf_idCase
WHERE o.rf_idN002 IS NOT null
---расчитываем проведение диспансерного наблюдения
;WITH cte_PCEL
AS
(
	SELECT ROW_NUMBER() OVER(PARTITION BY ps.enp ORDER BY cc.DateEnd desc) AS idRow, ps.ENP,cc.DateEnd, c.id AS rf_idCase
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts					
							INNER JOIN dbo.t_Case c  ON
					r.id=c.rf_idRecordCasePatient					  										     
							INNER JOIN dbo.t_CompletedCase cc  ON
					r.id=cc.rf_idRecordCasePatient
							INNER JOIN dbo.t_PatientSMO ps ON
					r.id=ps.rf_idRecordCasePatient	
							INNER JOIN #tCases ce ON
					ps.ENP=ce.ENP
							INNER JOIN dbo.t_Diagnosis d ON
				c.id=d.rf_idCase																   					  					      
						INNER JOIN #tD td ON
				d.DiagnosisCode=td.DiagnosisCode								
						INNER JOIN dbo.t_PurposeOfVisit pv ON
				c.id=pv.rf_idCase                      
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear>=@reportYear and c.rf_idv006=3	AND d.TypeDiagnosis =1 
			AND pv.rf_idV025='1.3' AND ce.AmountPayment>0	
)
SELECT ENP,DateEnd,rf_idCase FROM cte_PCEL WHERE idRow=1

--лечение по поводу ЗНО

;WITH cteN13
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY ps.ENP,  u.rf_idN013 ORDER BY cc.DateEnd desc) AS idRow, ps.ENP,cc.DateEnd, u.rf_idN013 AS usl_tip ,c.id AS rf_idCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts					
						INNER JOIN dbo.t_Case c  ON
				r.id=c.rf_idRecordCasePatient					  										     
						INNER JOIN dbo.t_CompletedCase cc  ON
				r.id=cc.rf_idRecordCasePatient
						INNER JOIN dbo.t_PatientSMO ps ON
				r.id=ps.rf_idRecordCasePatient	
						INNER JOIN #tCases ce ON
				ps.ENP=ce.ENP		
						INNER JOIN dbo.t_ONK_USL u ON
				c.id=u.rf_idCase				                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear>=@reportYear and c.rf_idv006<3 AND u.rf_idN013<5 AND ce.AmountPayment>0
)
SELECT ENP,DateEnd ,USL_TIP,rf_idCase from cteN13 WHERE idRow=1
--код СМО
PRINT('tmp_PeopleSMO')
;WITH cteLastSMO
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY ce.ENP ORDER BY cc.DateEnd desc) AS idRow, ce.ENP,cc.DateEnd, ce.CodeSMO,c.id	AS rf_idCase
FROM #tCases ce INNER JOIN dbo.t_Case c  ON
				ce.rf_idCase=c.id
						INNER JOIN dbo.t_CompletedCase cc  ON
				c.rf_idRecordCasePatient=cc.rf_idRecordCasePatient
WHERE ce.AmountPayment>0
)
SELECT  ENP ,CodeSMO,rf_idCase FROM cteLastSMO WHERE idRow=1

PRINT('tmp_PeopleNAPR')
--направление на дообследование
;WITH cteNAPR
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY ce.ENP ORDER BY d.DirectionDate) AS idRow,c.id,ce.ENP,d.DirectionDate,d.MethodStudy
FROM #tCases ce INNER JOIN dbo.t_Case c ON
			ce.rf_idCase=c.id	
				INNER JOIN dbo.t_CompletedCase cc ON
			c.rf_idRecordCasePatient = cc.rf_idRecordCasePatient
				INNER JOIN dbo.t_DirectionMU d ON
			c.id=d.rf_idCase
WHERE d.TypeDirection=3	AND ce.AmountPayment>0		              
)
SELECT ENP,DirectionDate ,id ,MethodStudy
from cteNAPR WHERE idRow=1

---------------------Закрытие ИИ с ЗНО--------------
PRINT('tmp_PeopleEND')
;WITH ctePeople
AS(
select row_number()over(partition by p.id order by s.id DESC) AS idRow,
		 p.ENP,s.id,ISNULL(s.DSTOP,s.DEND) AS DSTOP
from PolicyRegister.dbo.polis s join PolicyRegister.dbo.people p ON 
						s.pid=p.id 
								inner join #tCases t ON 
						p.ENP=t.ENP
where s.dbeg <= GETDATE() AND p.DS IS NULL AND t.AmountPayment>0
)
 SELECT  ENP,DSTOP,1
 FROM ctePeople	 WHERE idRow=1 AND DSTOP<=GETDATE()
 UNION all
 SELECT c.ENP,p.DS,2
 FROM #tCases c INNER JOIN PolicyRegister.dbo.PEOPLE p ON
 		c.ENP=p.ENP
 WHERE p.DS IS NOT null
-------------------Выводим всю историю по онко больному-----------------
-----------------------07.08.2020---------------
PRINT('tmp_PeopleCase')
SELECT c.ENP, cc.id,c.Account,c.DateRegister, c.CodeM, cc.idRecordCase AS NumberCase, d.DS1,d.DS2,cc.DateBegin,cc.DateEnd,dd.DS_ONK,cc.rf_idV006 AS USL_OK, cc.rf_idv008,cc.rf_idV009
		,CASE WHEN cc.rf_idV006=3 THEN pv.rf_idV025 ELSE NULL END AS P_CEL, pv.DN
from #tCases c INNER JOIN dbo.t_Case cc ON
		c.rf_idCase=cc.id
				INNER JOIN dbo.vw_Diagnosis d ON
		cc.id=d.rf_idCase      
				LEFT JOIN t_DS_ONK_REAB dd ON
			cc.id=dd.rf_idCase        
				LEFT JOIN dbo.t_PurposeOfVisit pv ON
			cc.id=pv.rf_idCase
WHERE c.AmountPayment>0 
ORDER BY c.ENP, cc.DateBegin, cc.DateEnd		             

PRINT('tmp_PeopleMES')

SELECT c.Enp,m.rf_idCase,m.MES,m.TypeMES
from #tCases c INNER JOIN dbo.t_MES m ON
		c.rf_idCase=m.rf_idCase            
WHERE c.AmountPayment>0 		        
ORDER BY c.ENP     
go
DROP TABLE #tCases
go
DROP TABLE #tD
go
DROP TABLE #tDS_ONK
GO
DROP TABLE #tDiagnosis