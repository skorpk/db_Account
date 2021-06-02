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

SELECT distinct c.ENP,p.FAM,p.IM,p.OT,p.DR,CASE WHEN p.W=2 THEN 'Ж' ELSE 'М' END AS Sex,0
FROM #tCases c INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		c.ENP=p.ENP
WHERE AmountPayment>0 



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
SELECT ENP,DiagnosisCode,DateEnd,rf_idCase FROM cteTotal WHERE idRow=1 AND enp='3451040842000030'

go

DROP TABLE #tCases

DROP TABLE #tD


