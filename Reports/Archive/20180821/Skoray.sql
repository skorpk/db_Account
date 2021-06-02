USE AccountOMS
GO
DECLARE @dtStart DATETIME='20170101',
		@dtEnd DATETIME='20180119',
		@dtEndRAK DATETIME='20180120',
		@reportMM TINYINT=12,
		@reportYear SMALLINT=2017,
		@idV006 TINYINT=1


SELECT c.id,c.AmountPayment, c.AmountPayment AS AmountPaymentAccepted,r.AttachLPU, SUM(m.Quantity) AS Quatity
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase							
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMM
		AND c.DateEnd>='20170101' AND c.DateEnd<'20180101' AND a.rf_idSMO<>'34'	AND m.MUGroupCode=71
GROUP BY c.id,c.AmountPayment, c.AmountPayment ,r.AttachLPU

UPDATE p SET p.AmountPaymentAccepted=p.AmountPaymentAccepted-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dtStart AND c.DateRegistration<@dtEndRAK
								GROUP BY c.rf_idCase
							) r ON
			p.id=r.rf_idCase

SELECT ISNULL(l.CodeM +' - '+l.NAMES,'Неприкрепленные') AS LPU,COUNT(Quatity)
from #tmpPeople	p left JOIN dbo.vw_sprT001 l ON
		p.AttachLPU=l.CodeM
WHERE (CASE WHEN AmountPayment>0 AND AmountPaymentAccepted>0 THEN 1 WHEN AmountPayment=0 and AmountPaymentAccepted=0 THEN 1 ELSE 0 END)=1
GROUP BY l.CodeM +' - '+l.NAMES 
ORDER BY LPU
GO
DROP TABLE #tmpPeople