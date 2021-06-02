USE AccountOMS
GO
drop TABLE t_People_Case;
 
INSERT dbo.t_People_Case
        ( IDPeople, rf_idCase )
SELECT        DENSE_RANK() OVER (ORDER BY t .ID) AS ID, rf_idCase
FROM            (
				 SELECT  CAST(PID AS varchar(20)) AS ID, rf_idCase FROM  dbo.t_Case_PID_ENP WHERE PID IS NOT NULL
                 UNION ALL
                 SELECT ENP AS ID, rf_idCase FROM  dbo.t_Case_PID_ENP WHERE  PID IS NULL AND ENP IS NOT null
                  UNION 
                 SELECT        rp.Fam + rp.Im + rp.Ot + CONVERT(VARCHAR(10), rp.BirthDay, 104), c.id
                 FROM            dbo.t_Case c INNER JOIN dbo.t_RecordCasePatient r ON 
										c.rf_idRecordCasePatient = r.id 
												INNER JOIN dbo.t_RegistersAccounts a ON 
										r.rf_idRegistersAccounts = a.id 
												INNER JOIN dbo.t_File f ON 
										a.rf_idFiles = f.id 
												INNER JOIN dbo.t_RegisterPatient rp ON 
										r.id = rp.rf_idRecordCase
												LEFT JOIN dbo.t_Case_PID_ENP pid ON
										c.id=pid.rf_idCase
                 WHERE pid.rf_idCase IS NULL AND c.DateEnd>'20130101'
                 ) t
 