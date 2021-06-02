USE AccountOMS
GO
SELECT f.CodeM,l.NAMES,v019.IDHVID,c.rf_idV019,v019.NAME,COUNT( DISTINCT c.id)
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
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20140805 23:59:59' AND a.ReportYear=2014 AND a.ReportMonth>=1 AND a.ReportMonth<8 AND a.Letter='H'
GROUP BY f.CodeM,l.NAMES,v019.IDHVID,c.rf_idV019,v019.NAME
ORDER BY CodeM,IDHVID