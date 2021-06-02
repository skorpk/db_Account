USE AccountOMS
GO
SELECT l.filialName,t.CodeM,l.NameS,t.GroupID, g.Name,CAST(SUM(AmountPayment) AS MONEY) AS AmountPayment,CAST(SUM(Quantity) AS MONEY) AS SumQuantity, CAST(COUNT(id) AS MONEY) AS CountIDCase
FROM (
		SELECT f.CodeM,spr.GroupID,c.AmountPayment,c.id,SUM(m.Quantity) AS Quantity
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
						  INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						 INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient
						INNER JOIN dbo.vw_Diagnosis d ON
				c.id=d.rf_idCase
						INNER JOIN sprDiagnosisKSG spr ON
				d.DS1=spr.Diagnosis
						INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
		WHERE f.DateRegistration>'20121001' AND f.DateRegistration<'20131001' AND c.rf_idV006=1
		GROUP BY f.CodeM,spr.GroupID,c.AmountPayment,c.id
		) t INNER JOIN dbo.sprGroupKSG g ON
			t.GroupID=g.GroupID
			INNER JOIN vw_sprT001 l ON
		t.CodeM=l.CodeM
GROUP BY l.filialName,t.CodeM,l.NameS,t.GroupID, g.Name
ORDER BY filialName,t.CodeM,GroupID
