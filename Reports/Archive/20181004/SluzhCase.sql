USE AccountOMS
GO
DECLARE @dtStart DATETIME='20180101',
		@dtEnd DATETIME='20181004',
		@dtEndRAK DATETIME='20181004',
		@reportMM TINYINT=10,
		@reportYear SMALLINT=2018

SELECT a.ReportMonth, c.id,c.AmountPayment, c.AmountPayment AS AmountPaymentAccepted,a.Account, a.DateRegister,c.rf_idV009,f.CodeM,a.rf_idSMO, c.GUID_Case,c.idRecordCase
		,p.ENp, c.DateEnd, CAST(ss.DateSluzh AS DATE) AS DateSluzh
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient              
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient
				INNER JOIN dbo.tmpSluzhPeople2018 ss ON
		p.ENP=ss.ENP													
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMM 
		AND c.DateEnd>='20180101' AND c.DateEnd<'20181101' AND a.rf_idSMO<>'34' AND ss.DateSluzh<c.DateEnd


UPDATE p SET p.AmountPaymentAccepted=p.AmountPaymentAccepted-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dtStart AND c.DateRegistration<@dtEndRAK
								GROUP BY c.rf_idCase
							) r ON
			p.id=r.rf_idCase

SELECT p.rf_idSMO,s.sNameS, p.CodeM,l.NAMES, p.Account, p.DateRegister,p.idRecordCase,p.GUID_Case,CAST(p.AmountPaymentAccepted AS MONEY) AS AmountPaymentAccepted,ENP, p.DateEnd,p.DateSluzh 
FROM #tmpPeople p INNER JOIN dbo.vw_sprSMO s ON
			p.rf_idSMO=s.smocod
				INNER JOIN dbo.vw_sprT001 l ON
			p.CodeM=l.CodeM
				INNER JOIN RegisterCases.dbo.vw_sprV009 v9 ON
			p.rf_idV009=v9.id              
WHERE p.AmountPaymentAccepted>0
ORDER BY rf_idSMO, codem

GO
DROP TABLE #tmpPeople