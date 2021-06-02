USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20200326',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=2


SELECT code,name 
INTO #csg
FROM dbo.vw_sprCSG WHERE code IN('st12.008','st12.009','st12.013','st23.004') AND dateBeg>='20200101'

SELECT c.id AS rf_idCase, c.AmountPayment,c.rf_idv008,f.CodeM,c.rf_idRecordCasePatient,cs.code,cs.name
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase	
					INNER JOIN #csg cs ON
            m.MES=cs.code
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND a.ReportMonth<=@reportMonth

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT l.CodeM+' - '+l.NAMES AS LPU,c.code+' - '+c.name AS CSG,RTRIM(d.DS1)+' - '+mkb.Diagnosis AS DS1,COUNT(c.rf_idRecordCasePatient) AS CountCases,CAST(SUM(c.AmountPayment) AS MONEY) AS SumPay
FROM #tCases c INNER JOIN dbo.vw_Diagnosis d ON
		c.rf_idCase=d.rf_idCase
				INNER JOIN dbo.vw_sprT001 l ON
       c.CodeM=l.CodeM
				INNER JOIN dbo.vw_sprMKB10 mkb ON
       d.DS1=mkb.DiagnosisCode
WHERE c.AmountPayment>0
GROUP BY l.CodeM+' - '+l.NAMES ,c.code+' - '+c.name ,RTRIM(d.DS1)+' - '+mkb.Diagnosis
ORDER BY LPU,DS1,csg
GO
DROP TABLE #csg
GO
DROP TABLE #tCases