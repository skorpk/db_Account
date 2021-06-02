USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20190801',
		@dateEndReg DATETIME='20200901',
		@dateStartRegRAK DATETIME='20190801',
		@dateEndRegRAK DATETIME='20200915',
		@reportYear SMALLINT=2019


CREATE TABLE #tLPU(CodeM CHAR(6))

INSERT #tLPU(CodeM) VALUES('101001'),('141023'),('251001'),('391002'),('451001')

SELECT DiagnosisCode INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C00' AND 'C99'


SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,c.rf_idRecordCasePatient,d.DiagnosisCode,f.CodeM
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN #tLPU l ON
            f.CodeM=l.CodeM
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN dbo.t_CompletedCase cc ON
			cc.rf_idRecordCasePatient = r.id				
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase	
					INNER JOIN #tDiag dd ON
			d.DiagnosisCode	=dd.DiagnosisCode
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear>=@reportYear AND  c.rf_idV006=2 AND a.rf_idSMO='34'
		AND d.TypeDiagnosis=1

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #t WHERE AmountPayment=0.0
PRINT('Удаляем')

;WITH cte1
AS(
SELECT CodeM,DiagnosisCode ,COUNT(DISTINCT rf_idRecordCasePatient) AS Col3
FROM #t 
GROUP BY CodeM,DiagnosisCode 

),
cte2 AS(
	SELECT DISTINCT CodeM,DiagnosisCode ,d.rf_idV024 AS Col4,CASE WHEN d.rf_idV024 IN('sh903','sh904') THEN n20.MNN ELSE null END AS Col5 
	FROM #t t inner JOIN dbo.t_ONK_SL o ON
			t.rf_idCase=o.rf_idCase
				inner JOIN dbo.t_DrugTherapy d ON
	         o.rf_idCase=d.rf_idCase
			 AND d.rf_idN013=d.rf_idN013
				LEFT JOIN oms_nsi.dbo.sprN020 n20 ON
              d.rf_idV020=n20.ID_LEKP
	
)
SELECT c1.CodeM+' - '+l.NAMES AS LPU,RTRIM(c1.DiagnosisCode)+' - '+m10.Diagnosis AS DiagnosisCode,col3,c2.Col4,c2.col5
FROM cte1 c1 INNER JOIN dbo.vw_sprT001 l ON
		c1.CodeM=l.CodeM
			INNER JOIN dbo.vw_sprMKB10 m10 ON
		m10.DiagnosisCode = c1.DiagnosisCode 
			LEFT JOIN cte2 c2 ON
		c1.CodeM=c2.CodeM
		AND c1.DiagnosisCode=c2.DiagnosisCode
ORDER BY LPU,DiagnosisCode

GO 
DROP TABLE #tDiag
GO
DROP TABLE #t
GO
DROP TABLE #tLPU