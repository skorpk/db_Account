USE AccountOMS
GO

SELECT id
INTO #t
FROM dbo.t_File w
WHERE w.DateRegistration>'20190501'

BEGIN TRANSACTION


UPDATE r SET r.IsAttendant=2
FROM dbo.t_RegisterPatient p INNER JOIN dbo.t_ReliabilityPatient r ON
				p.id=r.rf_idRegisterPatient
						INNER JOIN #t t ON
                p.rf_idFiles=t.id
						INNER JOIN dbo.t_RegisterPatientAttendant pa ON
                pa.rf_idRegisterPatient=p.id
WHERE r.IsAttendant=1

SELECT *
FROM dbo.t_RegisterPatient p INNER JOIN dbo.t_ReliabilityPatient r ON
				p.id=r.rf_idRegisterPatient
						INNER JOIN #t t ON
                p.rf_idFiles=t.id
						INNER JOIN dbo.t_RegisterPatientAttendant pa ON
                pa.rf_idRegisterPatient=p.id

commit
GO
DROP TABLE #t