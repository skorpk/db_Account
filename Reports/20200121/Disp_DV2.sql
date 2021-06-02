USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20200121',
		@reportYear SMALLINT=2019

SELECT c.id AS rf_idCase, ps.ENP,c.AmountPayment,f.CodeM,a.Account,f.DateRegistration,c.DateEnd,c.idRecordCase,a.DateRegister
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient				
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_DispInfo d ON
            c.id=d.rf_idCase
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND a.Letter='O'
	AND d.TypeDisp ='ДВ2'
		


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCase2 c
							WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEnd
							GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

--общее количество случаев по ДВ2 принятых к оплате
SELECT COUNT(DISTINCT rf_idCase) FROM #tCases WHERE AmountPayment>0

;WITH cteDouble
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY ENP ORDER BY DateRegistration,DateEnd) AS IdRow,enp
	FROM #tCases
	WHERE AmountPayment>0
)
SELECT l.CodeM+' - '+l.NAMES AS LPU,cc.Account,cc.DateRegister,cc.idRecordCase,cc.ENP
FROM cteDouble c INNER JOIN #tCases cc ON
        cc.ENP = c.ENP
				INNER JOIN dbo.vw_sprT001 l ON
		cc.CodeM=l.CodeM				
WHERE c.IdRow>1 AND cc.AmountPayment>0.0
ORDER BY ENP,LPU
GO
DROP TABLE #tCases