USE AccountOMSReports
GO
SET STATISTICS TIME ON 
DECLARE @dateStartReg DATETIME='20210101',
		@dateEndReg DATETIME=GETDATE(),
		@reportYear SMALLINT=2021,
		@reportMonth TINYINT=3

SELECT DISTINCT f.rf_idCase, f.AmountPayment,f.CodeM,f.ENP,f.rf_idCompletedCase,f.ReportMonth,f.AmountPaymentLPU,USL_OK
INTO #tCases
FROM t_CaseReportOblKomIT f		
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND f.ReportYear>=@reportYear AND f.ReportMonth<=@reportMonth
PRINT('------------------------------Query1-----------------------------')

CREATE NONCLUSTERED INDEX IX_1 ON #tCases(rf_idCase) INCLUDE(AmountPayment,[CodeM],[rf_idCompletedCase],[ReportMonth],USL_OK,ENP)
CREATE NONCLUSTERED INDEX IX_2 ON #tCases([USL_OK]) INCLUDE ([CodeM],[rf_idCompletedCase],[ReportMonth])

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM #tCases cc join dbo.t_PaymentAcceptedCase2 c ON
										cc.rf_idCase=c.rf_idCase
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
PRINT('------------------------------Query2-----------------------------')
DELETE FROM #tCases WHERE (CASE WHEN AmountPaymentLPU>0.0 AND AmountPayment=0.0 THEN 1 
								WHEN AmountPaymentLPU=0.0 AND AmountPayment<0.0 THEN 1 ELSE 0 END)=1
PRINT('------------------------------Query3-----------------------------')
CREATE TABLE #t(CodeM CHAR(6), Col1 INT NOT NULL DEFAULT (0), Col2 INT NOT NULL DEFAULT (0), Col3 INT NOT NULL DEFAULT (0), Col4 INT NOT NULL DEFAULT (0)
			,Col1_Y INT NOT NULL DEFAULT (0), Col2_Y INT NOT NULL DEFAULT (0), Col3_Y INT NOT NULL DEFAULT (0), Col4_Y INT NOT NULL DEFAULT (0))

----------------------------------------------------------Col1------------------------------------------
INSERT #t(CodeM,Col1,Col1_Y)
SELECT c.CodeM,SUM(CASE WHEN c.ReportMonth=@reportMonth then cv.Qunatity ELSE 0 end),SUM (cv.Qunatity)
FROM #tCases c JOIN dbo.t_Case_UnitCode_V006 cv ON
		c.rf_idCase=cv.rf_idCase
GROUP BY c.CodeM
PRINT('------------------------------Query4-----------------------------')
----------------------------------------------------------Col2------------------------------------------
INSERT #t(CodeM,Col2,Col2_Y)
SELECT c.CodeM,COUNT(DISTINCT CASE WHEN c.ReportMonth=@reportMonth then c.rf_idCompletedCase ELSE null end),COUNT(DISTINCT c.rf_idCompletedCase)
FROM #tCases c 
WHERE c.USL_OK=4
GROUP BY c.CodeM
PRINT('------------------------------Query5-----------------------------')
----------------------------------------------------------Col3------------------------------------------
INSERT #t(CodeM,Col3,Col3_Y)
SELECT c.CodeM,COUNT(DISTINCT CASE WHEN c.ReportMonth=@reportMonth then c.rf_idCompletedCase ELSE null end),COUNT(DISTINCT c.rf_idCompletedCase)
FROM #tCases c 
WHERE c.USL_OK IN(1,2,3)
GROUP BY c.CodeM
PRINT('------------------------------Query6-----------------------------')
----------------------------------------------------------Col4------------------------------------------
INSERT #t(CodeM,Col4,Col4_Y)
SELECT c.CodeM,COUNT(DISTINCT CASE WHEN c.ReportMonth=@reportMonth then ENP ELSE null end),COUNT(DISTINCT c.ENP)
FROM #tCases c 
GROUP BY c.CodeM
PRINT('------------------------------Query7-----------------------------')

SELECT l.CodeM,l.NAMES,SUM(Col1),SUM(Col2),SUM(Col3),SUM(Col4),SUM(Col1_Y),SUM(Col2_Y),SUM(Col3_Y),SUM(Col4_Y)
FROM #t t JOIN dbo.vw_sprT001 l ON
	t.CodeM=l.CodeM
GROUP BY l.CodeM,l.NAMES
ORDER BY l.CodeM
PRINT('------------------------------Query8-----------------------------')
GO
SET STATISTICS TIME OFF
GO
DROP TABLE #t
GO
DROP TABLE #tCases