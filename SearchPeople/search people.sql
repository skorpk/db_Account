USE AccountOMS
GO
;WITH cteENP
AS(
SELECT *
FROM dbo.t_Case_PID_ENP ce
WHERE ce.ReportYear=2016 AND ce.PID IS NULL AND NOT EXISTS(SELECT PID FROM PolicyRegister.dbo.PEOPLE WHERE ENP=ce.ENP
															UNION ALL
															SELECT PID FROM PolicyRegister.dbo.HISTENP WHERE ENP=ce.ENP
															) 
)
SELECT DISTINCT p.Fam,p.Im,p.Ot,p.BirthDay,ENP,pd.rf_idDocumentType,pd.SeriaDocument ,pd.NumberDocument ,pd.SNILS 
FROM cteENP e INNER JOIN dbo.t_Case c ON
		e.rf_idCase=c.id
				INNER JOIN dbo.t_RegisterPatient p ON
		c.rf_idRecordCasePatient=p.rf_idRecordCase 
				LEFT JOIN dbo.t_RegisterPatientDocument pd ON
		p.id=pd.rf_idRegisterPatient               