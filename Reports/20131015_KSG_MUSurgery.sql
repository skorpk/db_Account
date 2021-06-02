USE AccountOMS
GO
SELECT t.MUSurgery,t.SurgeryName,CAST(SUM(AmountPayment) AS MONEY) AS AmountPayment,CAST(SUM(Quantity)  AS MONEY) AS SumQuantity, cast(COUNT(id) AS MONEY) AS CountIDCase
FROM (
		SELECT m1.MUSurgery,m1.SurgeryName,c.AmountPayment,c.id,SUM(m.Quantity) AS Quantity
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
						  INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						 INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient												
						INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
						INNER JOIN (SELECT DISTINCT m.rf_idCase, spr.MUSurgery,spr.SurgeryName
									FROM dbo.t_Meduslugi m inner join dbo.sprMUSurgeryKSG spr ON
										m.MUSurgery=spr.MUSurgery
									) m1 ON
				m.rf_idCase=m1.rf_idCase
		WHERE f.DateRegistration>'20121001' AND f.DateRegistration<'20131001' AND c.rf_idV006=1 AND m.MUGroupCode=1
		GROUP BY m1.MUSurgery,m1.SurgeryName,c.AmountPayment,c.id
		) t 
GROUP BY t.MUSurgery,t.SurgeryName

