USE AccountOMS
GO
SELECT *
INTO #t
FROM dbo.t_PaymentAcceptedCase2 p
WHERE DateRegistration>='20190101' AND NOT EXISTS(SELECT * FROM [SRV-CNT-DB3].AccountOMSReports.dbo.t_PaymentAcceptedCase2 pp WHERE pp.rf_idCase=p.rf_idCase AND pp.idAkt=p.idAkt)

SELECT * FROM #t

BEGIN TRANSACTION
DELETE FROM dbo.t_PaymentAcceptedCase2
FROM dbo.t_PaymentAcceptedCase2 p INNER JOIN #t t ON
		p.rf_idCase=t.rf_idCase
		AND t.idAkt = p.idAkt

commit