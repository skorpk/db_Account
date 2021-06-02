USE AccountOMS
GO
SELECT p.Fam,p.Im,p.Ot, p.BirthDay,LTRIM(ISNULL(r.SeriaPolis,''))+r.NumberPolis AS Policy
FROM dbo.t_Case_PID_ENP pid INNER JOIN dbo.t_Case c ON
			pid.rf_idCase=c.id
							INNER JOIN dbo.t_RecordCasePatient r ON
			c.rf_idRecordCasePatient=r.id
							INNER JOIN dbo.t_RegistersAccounts a on
			r.rf_idRegistersAccounts=a.id
							INNER JOIN dbo.t_File f ON
			a.rf_idFiles=f.id
							INNER JOIN dbo.t_RegisterPatient p ON
			f.id=p.rf_idFiles
			AND r.id=p.rf_idRecordCase
WHERE pid.ReportYear=2014 AND PID IS NULL
GROUP BY Fam,Im,Ot,BirthDay,LTRIM(ISNULL(r.SeriaPolis,''))+r.NumberPolis
ORDER By Fam,IM, BirthDay