USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20200116',
		@reportYear SMALLINT=2019

SELECT c.id AS rf_idCase, c.AmountPayment,r.AttachLPU , f.CodeM, c.rf_idV006,m.MES,c.DateEnd
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient				
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase             
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND a.rf_idSMO<>'34' 
		AND c.rf_idV008=31 AND c.rf_idV010=33 AND f.CodeM='141022' AND m.TypeMES=2

INSERT #tCases
SELECT c.id AS rf_idCase, c.AmountPayment,r.AttachLPU , f.CodeM, c.rf_idV006,m.MES,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient				
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase             
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND c.rf_idV006=2 AND a.rf_idSMO<>'34' 
		AND c.rf_idV010=43 AND f.CodeM='141022' AND m.TypeMES=2

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCase2 c
							WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEnd
							GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT csg.code,csg.name,
		count(CASE WHEN c.CodeM=c.AttachLPU THEN c.rf_idCase ELSE NULL END) AS CountPeopleAttach,
		CAST(ISNULL(SUM(CASE WHEN c.CodeM=c.AttachLPU THEN c.AmountPayment ELSE NULL END),0.0) AS MONEY) AS SumPeopleAttach,
		------------------------------------------------------------------------------------------
		count(CASE WHEN c.CodeM<>c.AttachLPU THEN c.rf_idCase ELSE NULL END) AS CountPeopleNotAttach,
		CAST(ISNULL(SUM(CASE WHEN c.CodeM<>c.AttachLPU THEN c.AmountPayment ELSE NULL END),0.0) AS MONEY) AS SumPeopleNotAttach
FROM #tCases c INNER JOIN dbo.vw_sprCSG csg ON
		c.MES=csg.code		
WHERE c.rf_idV006=1 AND c.AmountPayment>0 AND c.DateEnd BETWEEN csg.dateBeg AND csg.dateEnd
GROUP BY csg.code,csg.name
ORDER BY csg.code

SELECT l.CodeM+' - '+l.NAMES AS LPU,csg.code,csg.name,
		count(CASE WHEN c.CodeM<>c.AttachLPU THEN c.rf_idCase ELSE NULL END) AS CountPeopleNotAttach,
		CAST(ISNULL(SUM(CASE WHEN c.CodeM<>c.AttachLPU THEN c.AmountPayment ELSE NULL END),0.0) AS MONEY) AS SumPeopleNotAttach
FROM #tCases c INNER JOIN dbo.vw_sprCSG csg ON
		c.MES=csg.code		
				INNER JOIN dbo.vw_sprT001 l ON
        c.AttachLPU=l.CodeM
WHERE c.rf_idV006=1 AND c.AmountPayment>0 AND c.DateEnd BETWEEN csg.dateBeg AND csg.dateEnd AND c.CodeM<>c.AttachLPU
GROUP BY l.CodeM+' - '+l.NAMES ,csg.code,csg.name
ORDER BY LPU,csg.code


--------------------------DnevnoiStacionar-------------------------------------
SELECT csg.code,csg.name,
		count(CASE WHEN c.CodeM=c.AttachLPU THEN c.rf_idCase ELSE NULL END) AS CountPeopleAttach,
		CAST(ISNULL(SUM(CASE WHEN c.CodeM=c.AttachLPU THEN c.AmountPayment ELSE NULL END),0.0) AS MONEY) AS SumPeopleAttach,
		------------------------------------------------------------------------------------------
		count(CASE WHEN c.CodeM<>c.AttachLPU THEN c.rf_idCase ELSE NULL END) AS CountPeopleNotAttach,
		CAST(ISNULL(SUM(CASE WHEN c.CodeM<>c.AttachLPU THEN c.AmountPayment ELSE NULL END),0.0) AS MONEY) AS SumPeopleNotAttach
FROM #tCases c INNER JOIN dbo.vw_sprCSG csg ON
		c.MES=csg.code		
WHERE c.rf_idV006=2 AND c.AmountPayment>0 AND c.DateEnd BETWEEN csg.dateBeg AND csg.dateEnd
GROUP BY csg.code,csg.name
ORDER BY csg.code

SELECT l.CodeM+' - '+l.NAMES AS LPU,csg.code,csg.name,
		count(CASE WHEN c.CodeM<>c.AttachLPU THEN c.rf_idCase ELSE NULL END) AS CountPeopleNotAttach,
		CAST(ISNULL(SUM(CASE WHEN c.CodeM<>c.AttachLPU THEN c.AmountPayment ELSE NULL END),0.0) AS MONEY) AS SumPeopleNotAttach
FROM #tCases c INNER JOIN dbo.vw_sprCSG csg ON
		c.MES=csg.code		
				INNER JOIN dbo.vw_sprT001 l ON
        c.AttachLPU=l.CodeM
WHERE c.rf_idV006=2 AND c.AmountPayment>0 AND c.DateEnd BETWEEN csg.dateBeg AND csg.dateEnd AND c.CodeM<>c.AttachLPU
GROUP BY l.CodeM+' - '+l.NAMES ,csg.code,csg.name
ORDER BY LPU,csg.code
GO

DROP TABLE #tCases