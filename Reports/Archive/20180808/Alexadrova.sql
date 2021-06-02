USE AccountOMS
GO
DECLARE @dtStart DATETIME='20180601',
		@dtEnd DATETIME='20180808',
		@dtEndRAK DATETIME='20180808',
		@reportMM TINYINT=6,
		@reportYear SMALLINT=2018

SELECT a.ReportMonth, c.id,c.AmountPayment, c.AmountPayment AS AmountPaymentAccepted, d.MES,k.rf_idKiro , cc.name
	,CASE WHEN DATEDIFF(DAY,c.DateBegin, c.DateEnd)=0 THEN 1 ELSE DATEDIFF(DAY,c.DateBegin, c.DateEnd) END  AS KoikoDay
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient									
				INNER JOIN dbo.t_MES d ON
		c.id=d.rf_idCase	
				INNER JOIN dbo.vw_sprCSG cc ON
		d.MES=cc.code              
				LEFT JOIN dbo.t_Kiro k ON
		c.id=k.rf_idCase															
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMM
		AND c.DateEnd>='20180601' AND c.DateEnd<'20180701' AND a.rf_idSMO<>'34' AND f.CodeM='121125' AND c.rf_idV002=84	AND c.rf_idV006=1

UPDATE p SET p.AmountPaymentAccepted=p.AmountPaymentAccepted-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dtStart AND c.DateRegistration<@dtEndRAK
								GROUP BY c.rf_idCase
							) r ON
			p.id=r.rf_idCase
							
SELECT MES, Name, COUNT(id) AS AllCases,SUM(KoikoDay) AS KoikoAll, SUM(AmountPayment) AS SumAll
		,COUNT(CASE WHEN rf_idKiro=1 THEN id ELSE NULL END) AS Kiro1Cases
		,sum(CASE WHEN rf_idKiro=1 THEN KoikoDay ELSE 0 END) AS Kiro1Koiko
		,sum(CASE WHEN rf_idKiro=1 then	AmountPayment ELSE 0 END) AS Kiro1Sum
		,COUNT(CASE WHEN rf_idKiro=2 THEN id ELSE NULL END) AS Kiro2Cases
		,sum(CASE WHEN rf_idKiro=2 THEN KoikoDay ELSE 0 END) AS Kiro2Koiko
		,sum(CASE WHEN rf_idKiro=2 then	AmountPayment ELSE 0 END) AS Kiro2Sum
from #tmpPeople
WHERE (CASE WHEN AmountPayment>0 AND AmountPaymentAccepted>0 THEN 1 WHEN AmountPayment=0 and AmountPaymentAccepted=0 THEN 1 ELSE 0 END)=1
GROUP BY MES, Name
ORDER BY MES
go

DROP TABLE #tmpPeople
