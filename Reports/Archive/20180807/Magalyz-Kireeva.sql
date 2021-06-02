USE AccountOMS
GO
DECLARE @dtStart DATETIME='20180101',
		@dtEnd DATETIME='20180527',
		@dtEndRAK DATETIME='20180529',
		@reportMM TINYINT=8,
		@reportYear SMALLINT=2018

SELECT a.ReportMonth, c.id,d.DS1, c.rf_idV006, a.rf_idSMO,c.AmountPayment, c.AmountPayment AS AmountPaymentAcc
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient							
			INNER JOIN (VALUES(105),(106),(205),(206),(313),(405),(406),(411)) v(rf_idV009) ON--RSLT=411 не брать
			c.rf_idV009=v.rf_idV009 
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase																
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth>=1 AND a.ReportMonth<@reportMM
		AND c.DateEnd>='20180101' AND c.DateEnd<'20180801' AND a.rf_idSMO<>'34'

SELECT p.id, r.CodeReason,c.idAkt
INTO #tmpEKMP
FROM dbo.t_PaymentAcceptedCase2 c INNER JOIN #tmpPeople p ON
			c.rf_idCase=p.id
					LEFT JOIN dbo.t_ReasonDenialPayment r ON
			c.rf_idCase=r.rf_idCase
			AND c.idAkt=r.idAkt                  
WHERE c.DateRegistration>=@dtStart AND c.DateRegistration<@dtEndRAK And c.TypeCheckup=3
							

  ----------------------Наши-----------------------
SELECT Ds1--,ReportMonth
	--------------------Амбулаторка------------------------------------
	,COUNT(DISTINCT CASE WHEN rf_idV006=3 THEN p.id ELSE NULL END) AS Stacionar
	,COUNT(DISTINCT CASE WHEN rf_idV006=3  AND e.CodeReason IS NOT null THEN p.id ELSE NULL END) AS Stacionar2
	,COUNT(CASE WHEN rf_idV006=3  AND e.CodeReason IS NOT null THEN p.id ELSE NULL END) AS Stacionar3
	,COUNT(DISTINCT CASE WHEN rf_idV006=3  AND ISNULL(e.CodeReason,99) IN (24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42 ) THEN p.id ELSE NULL END) AS Stacionar4
	--------------------Стационар------------------------------------
	,COUNT(DISTINCT CASE WHEN rf_idV006=1 THEN p.id ELSE NULL END) AS Stacionar
	,COUNT(DISTINCT CASE WHEN rf_idV006=1  AND e.CodeReason IS NOT null THEN p.id ELSE NULL END) AS Stacionar2
	,COUNT(CASE WHEN rf_idV006=1  AND e.CodeReason IS NOT null THEN p.id ELSE NULL END) AS Stacionar3
	,COUNT(DISTINCT CASE WHEN rf_idV006=1  AND ISNULL(e.CodeReason,99) IN (24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42 ) THEN p.id ELSE NULL END) AS Stacionar4
	--------------------Дневной Стационар------------------------------------
	,COUNT(DISTINCT CASE WHEN rf_idV006=2 THEN p.id ELSE NULL END) AS DnStacionar
	,COUNT(DISTINCT CASE WHEN rf_idV006=2  AND e.CodeReason IS NOT null THEN p.id ELSE NULL END) AS DnStacionar2
	,COUNT(CASE WHEN rf_idV006=2  AND e.CodeReason IS NOT null THEN p.id ELSE NULL END) AS DnStacionar3
	,COUNT(DISTINCT CASE WHEN rf_idV006=2  AND ISNULL(e.CodeReason,99) IN (24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42 ) THEN p.id ELSE NULL END) AS DnStacionar4
	--------------------Скорая------------------------------------
	,COUNT(DISTINCT CASE WHEN rf_idV006=4 THEN p.id ELSE NULL END) AS Skorya
	,COUNT(DISTINCT CASE WHEN rf_idV006=4 AND e.CodeReason IS NOT null THEN p.id ELSE NULL END) AS Skorya2
	,COUNT(CASE WHEN rf_idV006=4  AND e.CodeReason IS NOT null THEN p.id ELSE NULL END) AS Skorya3
	,COUNT(DISTINCT CASE WHEN rf_idV006=4  AND ISNULL(e.CodeReason,99) IN (24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42 ) THEN p.id ELSE NULL END) AS Skorya4	
	--------------------Всего------------------------------------
	,COUNT(DISTINCT p.id ) AS AllCase
	,COUNT(DISTINCT CASE WHEN e.CodeReason IS NOT null THEN p.id ELSE NULL END) AS AllCase2
	,COUNT(CASE WHEN e.CodeReason IS NOT null THEN p.id ELSE NULL END) AS AllCase3
	,COUNT(DISTINCT CASE WHEN ISNULL(e.CodeReason,99) IN (24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42 ) THEN p.id ELSE NULL END) AS AllCase4	
FROM #tmpPeople p INNER JOIN #tmpEKMP e ON
		p.id=e.id	
--WHERE (CASE WHEN AmountPayment>0 AND AmountPaymentAcc>0 THEN 1 WHEN AmountPayment=0 and AmountPaymentAcc=0 THEN 1 ELSE 0 END)=1
GROUP BY Ds1--,ReportMonth
ORDER BY DS1

go

DROP TABLE #tmpPeople
DROP TABLE #tmpEKMP