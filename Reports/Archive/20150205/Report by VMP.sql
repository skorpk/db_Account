USE AccountOMS
GO
SELECT  t.CodeM ,t.NAMES ,t.IDHVID ,t.rf_idV019 ,t.Name ,COUNT(t.id) AS countCase,CAST(SUM(t.AmountPayment) AS MONEY) AS AmountCase
from (
SELECT f.CodeM,l.NAMES,v019.IDHVID,c.rf_idV019,v019.NAME,c.id,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
				INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
				INNER JOIN (SELECT v19.Code AS IDHM,v19.NAME,m.DiagnosisCode,v18.Code AS IDHVID,v18.Name AS Name1
							FROM OMS_NSI.dbo.sprV019 v19 INNER JOIN OMS_NSI.dbo.sprV019MKB m ON
										v19.SprV019Id=m.rf_sprV019Id
														INNER JOIN OMS_NSI.dbo.sprV018 v18 ON
										v19.rf_sprV018Id=v18.SprV018Id) v019 ON
			c.rf_idV019=v019.IDHM
				INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM			
				LEFT JOIN (SELECT rf_idCase,SUM(p.AmountDeduction) AS AmountDeduction
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase p 
							WHERE DateRegistration>'20140101' AND DateRegistration<'20150127 23:59:59' AND Letter IN ('H','S')
							GROUP BY rf_idCase) p ON
				c.id=p.rf_idCase				
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20150127 23:59:59' AND a.ReportYear=2014 AND a.ReportMonth>=1 AND a.ReportMonth<=12 
			AND c.rf_idV006=1 AND c.rf_idV008=32 AND c.AmountPayment-ISNULL(p.AmountDeduction,0)>0
	
GROUP BY f.CodeM,l.NAMES,v019.IDHVID,c.rf_idV019,v019.NAME,c.id,c.AmountPayment
	)   t
GROUP BY t.CodeM ,t.NAMES ,t.IDHVID ,t.rf_idV019 ,t.Name
ORDER BY CodeM,IDHVID