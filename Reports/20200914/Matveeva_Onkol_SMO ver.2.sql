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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear>=@reportYear AND  c.rf_idV006=2 AND a.rf_idSMO<>'34'
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

;WITH cte
AS(
SELECT CodeM,DiagnosisCode ,COUNT(DISTINCT rf_idRecordCasePatient) AS Col3,a.rf_idAddCretiria AS Col4,CASE WHEN a.rf_idAddCretiria IN('sh903','sh904') THEN d.MNN ELSE null END AS Col5
FROM #t t left JOIN dbo.t_AdditionalCriterion a ON
		t.rf_idCase=a.rf_idCase
			left JOIN (
					SELECT distinct d.rf_idCase,d.rf_idV024,
					MNN=REPLACE((SELECT DISTINCT ISNULL(n20.MNN,'') AS 'data()'
					 FROM dbo.t_DrugTherapy dd LEFT JOIN oms_nsi.dbo.sprN020 n20 ON
					 		  dd.rf_idV020=n20.ID_LEKP
					 WHERE dd.rf_idCase=d.rf_idCase AND dd.rf_idV024=d.rf_idV024
					 for xml path('')
					  ),' ',',')
					FROM t_DrugTherapy d
			) d ON
          t.rf_idCase=d.rf_idCase
		  AND a.rf_idAddCretiria=d.rf_idV024
GROUP BY t.rf_idCase,CodeM,DiagnosisCode ,a.rf_idAddCretiria,CASE WHEN a.rf_idAddCretiria IN('sh903','sh904') THEN d.MNN ELSE null END
)
SELECT c1.CodeM+' - '+l.NAMES AS LPU,RTRIM(c1.DiagnosisCode)+' - '+m10.Diagnosis AS DiagnosisCode,SUM(col3) AS Col3,c1.Col4,c1.col5
FROM cte c1 INNER JOIN dbo.vw_sprT001 l ON
		c1.CodeM=l.CodeM
			INNER JOIN dbo.vw_sprMKB10 m10 ON
		m10.DiagnosisCode = c1.DiagnosisCode 
GROUP BY c1.CodeM+' - '+l.NAMES,RTRIM(c1.DiagnosisCode)+' - '+m10.Diagnosis ,col4,col5
ORDER BY lpu, DiagnosisCode,c1.Col4,col5


GO 
DROP TABLE #tDiag
GO
DROP TABLE #t
GO
DROP TABLE #tLPU