USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200101',
		@dateEnd DATETIME='20201010',
		@dateEndPay DATETIME='20201010'

CREATE TABLE #tDiag(DS1 VARCHAR(10))

INSERT #tDiag SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J12' AND 'J18'
INSERT #tDiag SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J90' AND 'J94'
INSERT #tDiag(DS1) VALUES('R09.1')

SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, cc.id AS rf_idCompletedCase,m.MES,a.ReportMonth,c.rf_idRecordCasePatient, 1 AS typeQuery
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_MES m ON
            c.id=m.rf_idCase
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>=1 AND a.ReportMonth<10 AND c.rf_idV006=1 AND d.TypeDiagnosis=1 AND d.DiagnosisCode ='U07.1' 

insert #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, cc.id AS rf_idCompletedCase,m.MES,a.ReportMonth,c.rf_idRecordCasePatient,2
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_MES m ON
            c.id=m.rf_idCase
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>=1 AND a.ReportMonth<10 AND c.rf_idV006=1 AND d.TypeDiagnosis=3 AND d.DiagnosisCode ='U07.1' 
	AND EXISTS(SELECT 1 FROM dbo.t_Diagnosis d INNER JOIN #tDiag dd ON d.DiagnosisCode=dd.DS1 WHERE d.rf_idCase=c.id AND d.TypeDiagnosis=1)
--------------------------------------------Двойные случаи---------------------------------------
;WITH cte
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY cc.rf_idRecordCasePatient ORDER BY c.rf_idCase) AS idrow,cc.rf_idRecordCasePatient
	FROM #tCases c INNER JOIN dbo.t_Case cc ON
			c.rf_idRecordCasePatient=cc.rf_idRecordCasePatient
	WHERE c.typeQuery=2
)
SELECT *
FROM cte WHERE cte.idrow>1
--------------------------------------------------------------------------------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

;WITH cte
AS
(
	SELECT DISTINCT ReportMonth,MES,rf_idCompletedCase,AmountPayment FROM #tCases WHERE AmountPayment>0
)
SELECT c.ReportMonth,MES,COUNT(c.rf_idCompletedCase),SUM(c.AmountPayment)
FROM cte c 
GROUP BY c.ReportMonth,MES
ORDER BY c.ReportMonth,c.MES
GO

DROP TABLE #tDiag
GO
DROP TABLE #tCases
---------------------------------------------------U07.2----------------------------------------------------
DECLARE @dateStart DATETIME='20200101',
		@dateEnd DATETIME='20201010',
		@dateEndPay DATETIME='20201010'

CREATE TABLE #tDiag(DS1 VARCHAR(10))

INSERT #tDiag SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J12' AND 'J18'
INSERT #tDiag SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J90' AND 'J94'
INSERT #tDiag(DS1) VALUES('R09.1')

SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, cc.id AS rf_idCompletedCase,m.MES,a.ReportMonth,c.rf_idRecordCasePatient, 1 AS typeQuery
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_MES m ON
            c.id=m.rf_idCase
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>=1 AND a.ReportMonth<10 AND c.rf_idV006=1 AND d.TypeDiagnosis=1 AND d.DiagnosisCode ='U07.2' 

insert #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,1 AS TypeRequest, cc.id AS rf_idCompletedCase,m.MES,a.ReportMonth,c.rf_idRecordCasePatient,2
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_MES m ON
            c.id=m.rf_idCase
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient										
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND a.ReportMonth>=1 AND a.ReportMonth<10 AND c.rf_idV006=1 AND d.TypeDiagnosis=3 AND d.DiagnosisCode ='U07.2' 
	AND EXISTS(SELECT 1 FROM dbo.t_Diagnosis d INNER JOIN #tDiag dd ON d.DiagnosisCode=dd.DS1 WHERE d.rf_idCase=c.id AND d.TypeDiagnosis=1)

--------------------------------------------Двойные случаи---------------------------------------
;WITH cte
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY cc.rf_idRecordCasePatient ORDER BY c.rf_idCase) AS idrow,cc.rf_idRecordCasePatient
	FROM #tCases c INNER JOIN dbo.t_Case cc ON
			c.rf_idRecordCasePatient=cc.rf_idRecordCasePatient
	WHERE c.typeQuery=2
)
SELECT *
FROM cte WHERE cte.idrow>1
--------------------------------------------------------------------------------------------------

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

;WITH cte
AS
(
	SELECT DISTINCT ReportMonth,MES,rf_idCompletedCase,AmountPayment FROM #tCases WHERE AmountPayment>0
)
SELECT c.ReportMonth,MES,COUNT(c.rf_idCompletedCase),SUM(c.AmountPayment)
FROM cte c 
GROUP BY c.ReportMonth,MES
ORDER BY c.ReportMonth,c.MES
GO

DROP TABLE #tDiag
GO
DROP TABLE #tCases