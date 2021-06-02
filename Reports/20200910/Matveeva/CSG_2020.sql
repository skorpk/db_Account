USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20200708',
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME='20200710',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=7

CREATE TABLE #tCSG(CSG VARCHAR(10),TypeCol TINYINT)
INSERT #tCSG(CSG,TypeCol)
VALUES('st01.001',7),('st02.001',7),('st02.002',7),('st02.003',7),('st02.005',7),('st02.007',7),('st02.008',7),('st02.009',7),('st02.010',7),('st02.011',7),('st03.002',7),
('st04.001',7),('st04.003',7),('st04.005',7),('st05.001',7),('st06.002',7),('st06.003',7),('st09.001',7),('st10.003',7),('st10.004',7),('st10.005',7),('st12.001',7),
('st12.002',7),('st12.010',7),('st12.011',7),('st12.012',7),('st14.001',7),('st15.001',7),('st15.003',7),('st15.005',7),('st15.010',7),('st15.011',7),('st15.017',7),
('st16.001',7),('st16.003',7),('st16.005',7),('st20.001',7),('st20.002',7),('st20.003',7),('st20.004',7),('st20.005',7),('st20.006',7),('st21.001',7),('st21.002',7),
('st21.007',7),('st21.008',7),('st22.002',7),('st23.001',7),('st23.003',7),('st24.003',7),('st25.001',7),('st26.001',7),('st27.001',7),('st27.002',7),('st27.003',7),
('st27.004',7),('st27.005',7),('st27.006',7),('st27.008',7),('st27.010',7),('st27.011',7),('st27.012',7),('st27.014',7),('st29.001',7),('st29.003',7),('st29.004',7),
('st29.005',7),('st29.009',7),('st29.010',7),('st30.001',7),('st30.002',7),('st30.003',7),('st30.004',7),('st30.005',7),('st31.001',7),('st31.002',7),('st31.003',7),
('st31.011',7),('st31.012',7),('st31.016',7),('st31.017',7),('st31.018',7),('st32.011',7),('st32.012',7),('st32.013',7),('st34.001',7),('st34.002',7),('st35.006',7),
('st36.004',7),('st36.005',7),('st36.012',7),('st37.011',7),('st37.012',7),('st12.009.2',7)
-------------------Covid
,('st12.009',7),('st12.008',8),('st12.013',9),('st23.004',8)
INSERT #tCSG(CSG,TypeCol)
VALUES('st02.004',8),('st02.012',8),('st02.013',8),('st04.002',8),('st04.004',8),('st05.004',8),('st05.008',8),('st06.001',8),('st07.001',8),('st09.002',8),('st09.003',8),('st09.005',8),
('st09.006',8),('st09.007',8),('st09.008',8),('st09.009',8),('st10.006',8),('st10.007',8),('st11.001',8),('st11.002',8),('st11.003',8),('st12.003',8),('st12.004',8),('st12.014',8),
('st13.001',8),('st13.004',8),('st13.005',8),('st13.006',8),('st13.007',8),('st14.002',8),('st14.003',8),('st15.002',8),('st15.004',8),('st15.018',8),('st15.007',8),('st15.008',8),
('st15.009',8),('st15.012',8),('st16.002',8),('st16.004',8),('st16.006',8),('st16.009',8),('st16.010',8),('st16.011',8),('st16.012',8),('st17.004',8),('st17.005',8),('st17.006',8),
('st18.001',8),('st18.002',8),('st18.003',8),('st20.007',8),('st20.008',8),('st20.009',8),('st21.003',8),('st21.004',8),('st21.005',8),('st21.006',8),('st22.001',8),('st22.003',8),
('st22.004',8),('st23.002',8),('st23.005',8),('st23.006',8),('st24.001',8),('st24.002',8),('st24.004',8),('st25.002',8),('st25.003',8),('st25.004',8),('st25.005',8),('st25.008',8),
('st25.009',8),('st27.007',8),('st27.009',8),('st28.001',8),('st28.002',8),('st28.003',8),('st29.002',8),('st29.006',8),('st29.011',8),('st29.012',8),('st30.006',8),('st30.007',8),
('st30.008',8),('st30.010',8),('st30.011',8),('st30.012',8),('st30.013',8),('st30.014',8),('st31.004',8),('st31.005',8),('st31.006',8),('st31.007',8),('st31.008',8),('st31.009',8),
('st31.013',8),('st31.019',8),('st32.001',8),('st32.002',8),('st32.005',8),('st32.008',8),('st32.009',8),('st32.010',8),('st32.014',8),('st32.015',8),('st32.016',8),('st32.017',8),
('st32.018',8),('st33.001',8),('st33.003',8),('st33.004',8),('st34.003',8),('st34.004',8),('st34.005',8),('st35.001',8),('st35.002',8),('st35.003',8),('st35.004',8),('st35.007',8),
('st35.008',8),('st36.007',8),('st36.009',8),('st37.001',8),('st37.002',8),('st37.005',8),('st37.006',8),('st37.008',8),('st37.009',8),('st37.010',8),('st37.013',8),('st37.014',8),
('st37.015',8),('st37.018',8),('st38.001',8),('st12.008.1',8),('st12.008.2',8),('st12.009.1',8),('st23.004.2',8)

INSERT #tCSG(CSG,TypeCol)
VALUES ('st02.006',9),('st03.001',9),('st04.006',9),('st05.002',9),('st05.003',9),('st05.005',9),('st09.004',9),('st09.010',9),('st10.001',9),('st10.002',9),('st11.004',9),('st12.005',9)
,('st12.006',9),('st12.007',9),('st13.002',9),('st13.003',9),('st15.019',9),('st15.020',9),('st15.013',9),('st15.014',9),('st15.015',9),('st15.016',9),('st16.007',9),('st16.008',9)
,('st17.001',9),('st17.002',9),('st17.003',9),('st17.007',9),('st20.010',9),('st25.006',9),('st25.007',9),('st25.010',9),('st25.011',9),('st25.012',9),('st27.013',9),('st28.004',9)
,('st28.005',9),('st29.007',9),('st29.008',9),('st29.013',9),('st30.009',9),('st30.015',9),('st31.010',9),('st31.014',9),('st31.015',9),('st32.003',9),('st32.004',9),('st32.006',9)
,('st32.007',9),('st33.002',9),('st33.005',9),('st33.006',9),('st33.007',9),('st33.008',9),('st35.005',9),('st35.009',9),('st36.001',9),('st36.002',9),('st36.003',9),('st36.006',9)
,('st36.008',9),('st36.010',9),('st36.011',9),('st37.003',9),('st37.004',9),('st37.007',9),('st37.016',9),('st37.017',9),('st12.013.1',9),('st12.013.2',9),('st12.013.3',9),('st23.004.1',9)

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,c.AmountPayment AS amountCase,mes,cs.TypeCol,c.rf_idRecordCasePatient,cc.AmountPayment AS Amm
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN dbo.t_CompletedCase cc ON
			cc.rf_idRecordCasePatient = r.id				
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
					INNER JOIN t_Mes m ON
			c.id=m.rf_idCase
					INNER JOIN #tCSG cs ON
			m.MES=cs.CSG			
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND  c.rf_idV006=1 AND c.rf_idV008=31 AND a.ReportMonth<@reportMonth AND a.rf_idSMO<>'34'

--UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
--FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
--								FROM dbo.t_PaymentAcceptedCase2 c
--								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK 
--								GROUP BY c.rf_idCase
--							) r ON
--			p.rf_idCase=r.rf_idCase

SELECT * FROM #t WHERE AmountPayment<=0

ALTER TABLE #t ADD IsAmount TINYINT

update #t SET IsAmount=1
WHERE AmountPayment>0 AND Amm<>AmountPayment AND amountCase<>Amm

update t SET IsAmount=2
FROM #t t INNER JOIN dbo.t_Meduslugi m ON
			t.rf_idCase=m.rf_idCase
WHERE AmountPayment>0 AND m.MUGroupCode=60 AND m.MUUnGroupCode=3

SELECT 2019,SUM(CASE WHEN IsAmount IS not NULL THEN t.amountCase else  t.AmountPayment  END )AS Col2
	,SUM(CASE WHEN t.TypeCol=7 AND IsAmount IS NULL THEN t.AmountPayment WHEN t.TypeCol=7 AND IsAmount IS NOT NULL THEN t.amountCase ELSE 0.0 END ) AS Col3
	,SUM(CASE WHEN t.TypeCol=8 AND IsAmount IS NULL THEN t.AmountPayment WHEN t.TypeCol=8 AND IsAmount IS NOT NULL THEN t.amountCase ELSE 0.0 END )AS Col4
	,SUM(CASE WHEN t.TypeCol=9 AND IsAmount IS NULL THEN t.AmountPayment WHEN t.TypeCol=9 AND IsAmount IS NOT NULL THEN t.amountCase ELSE 0.0 END )AS Col5
	,COUNT(DISTINCT t.rf_idCase) AS Col6
	,Count(CASE WHEN t.TypeCol=7 THEN t.rf_idCase ELSE null END ) AS Col7
	,Count(CASE WHEN t.TypeCol=8 THEN t.rf_idCase ELSE null END ) AS Col4
	,Count(CASE WHEN t.TypeCol=9 THEN t.rf_idCase ELSE null END ) AS Col5
FROM #t t
WHERE t.AmountPayment>0
GO
DROP TABLE #t
GO
DROP TABLE #tCSG