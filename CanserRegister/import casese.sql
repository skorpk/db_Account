USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',	--всегда с начало года
		@dateEnd DATETIME=GETDATE(),
		@dateEndRAK DATETIME=GETDATE(),
		@reportYear SMALLINT=2019


SELECT distinct DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'	


------берем с диагнозом из списка
-- 1 по диагнозу и 2 по DS_ONK
SELECT c.id AS rf_idCase,c.AmountPayment, ENP, f.CodeM,a.Account,a.DateRegister,c.DateBegin, c.rf_idV009, 1 AS TypeSearch, c.DateEnd, r.id AS rf_idRecordCasePatient
, CAST(NULL AS VARCHAR(10)) AS DiagnosisCode
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND dd.DS_ONK=1 AND f.TypeFile='H'	 AND c.rf_idv006<4
	AND a.rf_idSMO<>'34'

CREATE UNIQUE NONCLUSTERED INDEX QU_IXCase ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY

INSERT #tCases
SELECT c.id AS rf_idCase,c.AmountPayment, ENP, f.CodeM,a.Account,a.DateRegister,c.DateBegin, c.rf_idV009,2, c.DateEnd, r.id AS rf_idRecordCasePatient
, CAST(NULL AS VARCHAR(10)) AS DiagnosisCode
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND dd.IsOnko=1 AND f.TypeFile='F'	AND c.rf_idv006<4
	AND a.rf_idSMO<>'34'
--основной диагноз
INSERT #tCases
SELECT c.id AS rf_idCase,c.AmountPayment, ENP, f.CodeM,a.Account,a.DateRegister,c.DateBegin, c.rf_idV009,1, c.DateEnd, r.id AS rf_idRecordCasePatient, d.DiagnosisCode
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND d.TypeDiagnosis IN(1,3) AND c.rf_idv006<4
	  AND a.rf_idSMO<>'34'

INSERT #tCases
SELECT c.id AS rf_idCase,c.AmountPayment, ENP, f.CodeM,a.Account,a.DateRegister,c.DateBegin, c.rf_idV009,1 , c.DateEnd, r.id AS rf_idRecordCasePatient, dd.DiagnosisCode
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND f.TypeFile='F'	AND c.rf_idv006<4
	  AND a.rf_idSMO<>'34'
--добавить выборку сведений по диспансеризации и профосмотру по пациенту включенному в КанцерРегистр.

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.TypeCheckup=1 and c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT distinct c.ENP,p.FAM,p.IM,p.OT,p.BirthDay,Sex,c.TypeSearch
INTO tmp_PeopleENP
FROM #tCases c INNER JOIN dbo.t_RegisterPatient p ON
		c.rf_idRecordCasePatient=p.rf_idRecordCase
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
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear and c.rf_idv006<4	AND dd.DS_ONK=1
			AND NOT EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=ce.ENP)
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
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear and c.rf_idv006<4	AND d.TypeDiagnosis IN(1,3)
			AND NOT EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=ce.ENP)
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
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear and  c.rf_idv006<4	AND NOT EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=ce.ENP)
), cteFirst
AS
(
	SELECT ROW_NUMBER() OVER(PARTITION BY enp ORDER BY DateEnd) AS idRow, rf_idCase ,ENP ,DateEnd ,DS_ONK FROM cte_DS_ONK
)
SELECT  rf_idCase ,ENP ,DateEnd ,DS_ONK 
INTO #tDS_ONK
FROM cteFirst WHERE idRow=1 AND DS_ONK=1


SELECT * FROM #tDS_ONK
--Направление на биопсию
SELECT ps.ENP,MIN(dm.DirectionDate) as DirectionDate ,'Биопсия'
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
						INNER JOIN dbo.t_DirectionMU dm ON
				c.id=dm.rf_idCase   						
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear and c.rf_idv006<4	AND dm.TypeDirection=2
GROUP BY ps.ENP



---расчитываем диагноз ЗНО и Дату постановки диагноза
;WITH cte_Diag
AS
(
	SELECT ce.ENP,cc.DateEnd,ce.DiagnosisCode, c.id AS rf_idCase
	FROM #tCases ce INNER JOIN dbo.t_Case c ON
				ce.rf_idCase=c.id	
					INNER JOIN dbo.t_CompletedCase cc ON
				c.rf_idRecordCasePatient = cc.rf_idRecordCasePatient                  
	WHERE ce.DiagnosisCode IS NOT null
	UNION ALL
	SELECT ce.enp,c.DateEnd,d.DiagnosisCode , c.id AS rf_idCase 
	FROM #tCases ce INNER JOIN  dbo.t_CasesOnkologia2018 c2018 ON
				ce.ENP=c2018.ENP  
					INNER JOIN dbo.t_Case c ON
				c2018.rf_idCase=c.id						                  
					INNER JOIN dbo.t_Diagnosis d ON
				c.id = d.rf_idCase
					INNER JOIN #tD dd ON
				d.DiagnosisCode=dd.DiagnosisCode
	WHERE d.TypeDiagnosis IN(1,3)                 		
),
cteTotal
AS
(
	SELECT ROW_NUMBER() OVER(PARTITION BY enp ORDER BY DateEnd) AS idRow,ENP,DateEnd,DiagnosisCode,rf_idCase FROM cte_Diag
)
SELECT ENP,DateEnd,DiagnosisCode,rf_idCase INTO #tmpDIag from cteTotal WHERE idRow=1

SELECT ENP,DateEnd,DiagnosisCode,'Диагноз' FROM #tmpDIag
------Стадия----------
SELECT ENP,d.rf_idCase,o.rf_idN002 AS STAD,'Стадия'
FROM #tmpDIag d INNER JOIN dbo.t_ONK_SL o ON
		d.rf_idCase=o.rf_idCase
WHERE o.rf_idN002 IS NOT null
---расчитываем проведение диспансерного наблюдения
;WITH cte_PCEL
AS
(
	SELECT ROW_NUMBER() OVER(PARTITION BY ps.enp ORDER BY cc.DateEnd desc) AS idRow, ps.ENP,cc.DateEnd, c.id
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
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear and c.rf_idv006=3	AND d.TypeDiagnosis =1 AND pv.rf_idV025='1.3'	
)
SELECT ENP,id AS rf_idCase,DateEnd,'Диспансерное наблюдение' FROM cte_PCEL WHERE idRow=1

--лечение по поводу ЗНО
SELECT ps.ENP,MAX(c.DateEnd) AS DateEND, u.rf_idN013 AS usl_tip
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear and c.rf_idv006<3 AND u.rf_idN013<5
GROUP BY ps.ENP,u.rf_idN013
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
WHERE d.TypeDirection=3			              
)
SELECT id ,DirectionDate ,MethodStudy,'Направление'
from cteNAPR WHERE idRow=1
---------------------Закрытие ИИ с ЗНО--------------
;WITH ctePeople
AS(
select row_number()over(partition by p.id order by s.id DESC) AS idRow,
		 p.ENP,s.id,ISNULL(s.DSTOP,s.DEND) AS DSTOP
from PolicyRegister.dbo.polis s join PolicyRegister.dbo.people p ON 
						s.pid=p.id 
								inner join #tCases t ON 
						p.ENP=t.ENP
where /*isnull(s.st, 0) <> 2 and ISNULL(s.dstop,s.DEND) < GETDATE() and (left(s.okato,2)='18')
	and (s.poltp in (1,2) or isnull(s.dend,'21000101')<GETDATE()) 
	and (s.poltp in(2,3,4,5 ) or (s.poltp=1 and (isnull(s.dend,'21000101')>'20101231')))  
	and */s.dbeg <= GETDATE() AND p.DS IS NULL
)
 SELECT  ENP,DSTOP,1
 FROM ctePeople	 WHERE idRow=1 AND DSTOP<=GETDATE()
 UNION all
 SELECT c.ENP,p.DS,2
 FROM #tCases c INNER JOIN PolicyRegister.dbo.PEOPLE p ON
 		c.ENP=p.ENP
 WHERE p.DS IS NOT null
 

GO
DROP TABLE #tCases
GO
DROP TABLE #tD
GO
DROP TABLE dbo.tmp_PeopleENP
GO
DROP TABLE #tDS_ONK
GO
DROP TABLE #tmpDIag