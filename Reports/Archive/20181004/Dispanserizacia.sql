USE AccountOMS
GO
DECLARE @dtStart DATETIME='20180101',
		@dtEnd DATETIME='20181004',
		@dtEndRAK DATETIME='20181004',
		@reportMM TINYINT=10,
		@reportYear SMALLINT=2018

SELECT a.ReportMonth, c.id,c.AmountPayment, c.AmountPayment AS AmountPaymentAccepted,a.Account, a.DateRegister,c.rf_idV009,f.CodeM,a.rf_idSMO, c.GUID_Case, 1 AS Col1,c.idRecordCase
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient													
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMM AND a.Letter='O'
		AND c.DateEnd>='20180101' AND c.DateEnd<'20181101' AND a.rf_idSMO<>'34' AND c.rf_idV009>354 AND c.rf_idV009<357	AND ISNULL(c.IsNeedDisp,0) NOT IN (1,2)
		AND NOT EXISTS(SELECT 1 FROM dbo.t_DS2_Info WHERE rf_idCase=c.id AND IsNeedDisp IN(1,2) )

CREATE UNIQUE NONCLUSTERED INDEX UQ_temp ON #tmpPeople(id) WITH IGNORE_DUP_KEY

INSERT #tmpPeople (ReportMonth,id,AmountPayment,AmountPaymentAccepted,Account,DateRegister,rf_idV009,CodeM,rf_idSMO,GUID_Case, Col1,idRecordCase) 
SELECT DISTINCT a.ReportMonth, c.id,c.AmountPayment, c.AmountPayment AS AmountPaymentAccepted,a.Account, a.DateRegister,c.rf_idV009,f.CodeM,a.rf_idSMO, c.GUID_Case,2,c.idRecordCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient													
				INNER JOIN t_DS2_Info dd ON
		c.id=dd.rf_idCase              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMM AND a.Letter='O'
		AND c.DateEnd>='20180101' AND c.DateEnd<'20181101' AND a.rf_idSMO<>'34' AND c.rf_idV009>354 AND c.rf_idV009<357	AND (ISNULL(dd.IsNeedDisp,0) NOT IN (1,2) )
		AND NOT EXISTS(SELECT 1 FROM dbo.t_DS2_Info WHERE rf_idCase=c.id AND IsNeedDisp IN(1,2) 
					   UNION ALL
					   SELECT 1 FROM t_Case WHERE id=c.id AND IsNeedDisp IN(1,2)
					  ) 

UPDATE p SET p.AmountPaymentAccepted=p.AmountPaymentAccepted-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dtStart AND c.DateRegistration<@dtEndRAK
								GROUP BY c.rf_idCase
							) r ON
			p.id=r.rf_idCase

--SELECT * FROM #tmpPeople WHERE col1=2

SELECT p.rf_idSMO,s.sNameS, p.CodeM,l.NAMES, p.Account, p.DateRegister,p.idRecordCase,p.GUID_Case,p.AmountPaymentAccepted,v9.id,v9.name
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