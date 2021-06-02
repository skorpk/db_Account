USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',	--всегда с начало года
		@dateEnd DATETIME=GETDATE(),
		@dateEndRAK DATETIME=GETDATE(),
		@reportYear SMALLINT=2019


SELECT distinct DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'	


------берем с диагнозом из списка
-- 1 по диагнозу и 2 по DS_ONK
SELECT c.id AS rf_idCase,c.AmountPayment AS Payment, CAST(0.0 AS DECIMAL(15,2)) AS AmountPayment, ENP, f.CodeM,a.Account,a.DateRegister,c.DateBegin, c.rf_idV009, 1 AS TypeSearch, c.DateEnd, r.id AS rf_idRecordCasePatient
, CAST(NULL AS VARCHAR(10)) AS DiagnosisCode,a.rf_idSMO AS CodeSMO
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
--CREATE UNIQUE NONCLUSTERED INDEX QU_IXENP ON #tCases(ENP) WITH IGNORE_DUP_KEY


INSERT #tCases
SELECT c.id AS rf_idCase,c.AmountPayment AS Payment, CAST(0.0 AS DECIMAL(15,2)) AS AmountPayment, ENP, f.CodeM,a.Account,a.DateRegister,c.DateBegin, c.rf_idV009,2, c.DateEnd, r.id AS rf_idRecordCasePatient
, CAST(NULL AS VARCHAR(10)) AS DiagnosisCode,a.rf_idSMO AS CodeSMO
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
SELECT c.id AS rf_idCase,c.AmountPayment AS Payment, CAST(0.0 AS DECIMAL(15,2)) AS AmountPayment, ENP, f.CodeM,a.Account,a.DateRegister,c.DateBegin, c.rf_idV009,1, c.DateEnd, r.id AS rf_idRecordCasePatient, d.DiagnosisCode,a.rf_idSMO AS CodeSMO
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
SELECT c.id AS rf_idCase,c.AmountPayment AS Payment, CAST(0.0 AS DECIMAL(15,2)) AS AmountPayment, ENP, f.CodeM,a.Account,a.DateRegister,c.DateBegin, c.rf_idV009,1 , c.DateEnd, r.id AS rf_idRecordCasePatient, dd.DiagnosisCode,a.rf_idSMO AS CodeSMO
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

UPDATE p SET p.AmountPayment=p.Payment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.TypeCheckup=1 and c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

--лечение по поводу ЗНО
SELECT * FROM #tCases WHERE rf_idCase IN(106289004,106289486)
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
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear and c.rf_idv006<4	AND d.TypeDiagnosis IN(1,3)
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
	WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND ce.AmountPayment>0 AND c.rf_idv006<4	
		AND NOT EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=ce.ENP)
), cteFirst
AS
(
	SELECT ROW_NUMBER() OVER(PARTITION BY enp ORDER BY DateEnd) AS idRow, rf_idCase ,ENP ,DateEnd ,DS_ONK FROM cte_DS_ONK
)
SELECT  rf_idCase ,ENP ,DateEnd ,DS_ONK 
INTO #tDS_ONK
FROM cteFirst WHERE idRow=1 AND DS_ONK=1

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
				c.id=ce1.rf_idCase
						INNER JOIN dbo.t_DirectionMU dm ON
				c.id=dm.rf_idCase   						
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear and c.rf_idv006<4	AND dm.TypeDirection=2 
		AND ce1.AmountPayment>0
)
SELECT ENP,DirectionDate,rf_idCase FROM cteBiopsy WHERE idRow=1 AND rf_idCase=106289004
GO 
DROP TABLE #tCases
GO
DROP TABLE #tD
GO
DROP TABLE #tDS_ONK