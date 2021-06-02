USE AccountOMS
GO
SELECT  t.CodeM ,l.NAMES ,v019.IDHVID ,t.rf_idV019 ,v019.Name ,COUNT(t.id) AS countCase,CAST(SUM(t.AmountPayment) AS MONEY) AS AmountCase,CAST(SUM(t.Quantity) AS int) AS Quatity
from (
SELECT f.CodeM,c.rf_idV019,c.id,c.AmountPayment,SUM(m.Quantity) AS Quantity
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
				INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
							
			  INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
			  INNER JOIN (VALUES('1.11.1'),('55.1.5')) v(MU) ON
			 m.MU=v.MU
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20150127 23:59:59' AND a.ReportYear=2014 AND a.ReportMonth>=1 AND a.ReportMonth<=12 AND a.Letter='H'
GROUP BY f.CodeM,c.rf_idV019,c.id,c.AmountPayment
	)   t INNER JOIN dbo.vw_sprT001 l ON
			t.CodeM=l.CodeM
			INNER JOIN (SELECT v19.Code AS IDHM,v19.NAME,v18.Code AS IDHVID,v18.Name AS Name1
							FROM OMS_NSI.dbo.sprV019 v19 INNER JOIN OMS_NSI.dbo.sprV018 v18 ON
										v19.rf_sprV018Id=v18.SprV018Id) v019 ON
			t.rf_idV019=v019.IDHM	
GROUP BY t.CodeM ,l.NAMES ,v019.IDHVID ,t.rf_idV019 ,v019.Name
ORDER BY CodeM,IDHVID