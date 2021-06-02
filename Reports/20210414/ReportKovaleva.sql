USE AccountOMS
go
DECLARE @dateStartReg DATETIME='20210101',
		@dateEndReg DATETIME=GETDATE(),
		@reportYear SMALLINT=2021,
		@reportMonth TINYINT=3

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,cc.id AS rf_idCompletedCase,a.ReportMonth,cc.AmountPayment AS AmountPaymentLPU,c.rf_idV006 AS USL_OK
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear>=@reportYear AND a.ReportMonth<=@reportMonth

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM #tCases cc join dbo.t_PaymentAcceptedCase2 c ON
										cc.rf_idCase=c.rf_idCase
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE (CASE WHEN AmountPaymentLPU>0.0 AND AmountPayment=0.0 THEN 1 
								WHEN AmountPaymentLPU=0.0 AND AmountPayment<0.0 THEN 1 ELSE 0 END)=1
CREATE TABLE #t(CodeM CHAR(6), Col1 INT NOT NULL DEFAULT (0), Col2 INT NOT NULL DEFAULT (0), Col3 INT NOT NULL DEFAULT (0), Col4 INT NOT NULL DEFAULT (0)
			,Col1_Y INT NOT NULL DEFAULT (0), Col2_Y INT NOT NULL DEFAULT (0), Col3_Y INT NOT NULL DEFAULT (0), Col4_Y INT NOT NULL DEFAULT (0))

----------------------------------------------------------Col1------------------------------------------
INSERT #t(CodeM,Col1,Col1_Y)
SELECT c.CodeM,SUM(CASE WHEN c.ReportMonth=@reportMonth then cv.Qunatity ELSE 0 end),SUM (cv.Qunatity)
FROM #tCases c JOIN dbo.t_Case_UnitCode_V006 cv ON
		c.rf_idCase=cv.rf_idCase
GROUP BY c.CodeM
----------------------------------------------------------Col2------------------------------------------
INSERT #t(CodeM,Col2,Col2_Y)
SELECT c.CodeM,COUNT(DISTINCT CASE WHEN c.ReportMonth=@reportMonth then c.rf_idCompletedCase ELSE null end),COUNT(DISTINCT c.rf_idCompletedCase)
FROM #tCases c 
WHERE c.USL_OK=4
GROUP BY c.CodeM
----------------------------------------------------------Col3------------------------------------------
INSERT #t(CodeM,Col3,Col3_Y)
SELECT c.CodeM,COUNT(DISTINCT CASE WHEN c.ReportMonth=@reportMonth then c.rf_idCompletedCase ELSE null end),COUNT(DISTINCT c.rf_idCompletedCase)
FROM #tCases c 
WHERE c.USL_OK<4
GROUP BY c.CodeM
----------------------------------------------------------Col4------------------------------------------
INSERT #t(CodeM,Col4,Col4_Y)
SELECT c.CodeM,COUNT(DISTINCT CASE WHEN c.ReportMonth=@reportMonth then ENP ELSE null end),COUNT(DISTINCT c.ENP)
FROM #tCases c 
WHERE c.USL_OK<4
GROUP BY c.CodeM

SELECT l.CodeM,l.NAMES,SUM(Col1),SUM(Col2),SUM(Col3),SUM(Col4),SUM(Col1_Y),SUM(Col2_Y),SUM(Col3_Y),SUM(Col4_Y)
FROM #t t JOIN dbo.vw_sprT001 l ON
	t.CodeM=l.CodeM
GROUP BY l.CodeM,l.NAMES
ORDER BY l.CodeM
GO
DROP TABLE #t
GO
DROP TABLE #tCases