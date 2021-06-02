USE RegisterCases
GO
SELECT f.id
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
		f.id=a.rf_idFiles
WHERE f.DateRegistration>='20151001' and f.DateRegistration<'20160120' AND a.ReportYear=2015


UPDATE p SET Fam=null, IM=NULL, Ot=NULL, BirthDay=NULL, BirthPlace=NULL
FROM  dbo.t_RegisterPatient p INNER JOIN #t t ON
		p.rf_idFiles=t.id

UPDATE pa SET Fam=null, IM=NULL, Ot=NULL, BirthDay=NULL
FROM  dbo.t_RegisterPatient p INNER JOIN #t t ON
		p.rf_idFiles=t.id
						INNER JOIN dbo.t_RegisterPatientAttendant pa ON
		p.id=pa.rf_idRegisterPatient                      

UPDATE pa SET SeriaDocument=NULL, NumberDocument=NULL, SNILS=NULL
FROM  dbo.t_RegisterPatient p INNER JOIN #t t ON
		p.rf_idFiles=t.id
						INNER JOIN dbo.t_RegisterPatientDocument pa ON
		p.id=pa.rf_idRegisterPatient

UPDATE r SET r.SeriaPolis=NULL, r.NumberPolis='' 
FROM dbo.t_RegistersCase a INNER JOIN dbo.t_RecordCase r ON
		a.id=r.rf_idRegistersCase		
							INNER JOIN #t t ON
		a.rf_idFiles=t.id                          

go
DROP TABLE #t
go
-----------------------------------------------------------------------
USE AccountOMS
GO
SELECT f.id
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
WHERE f.DateRegistration>='20150101' and f.DateRegistration<'20161201' AND a.ReportYear=2015

UPDATE p SET Fam=null, IM=NULL, Ot=NULL, BirthDay=NULL, BirthPlace=NULL
FROM  dbo.t_RegisterPatient p INNER JOIN #t t ON
		p.rf_idFiles=t.id

UPDATE pa SET Fam=null, IM=NULL, Ot=NULL, BirthDay=NULL
FROM  dbo.t_RegisterPatient p INNER JOIN #t t ON
		p.rf_idFiles=t.id
						INNER JOIN dbo.t_RegisterPatientAttendant pa ON
		p.id=pa.rf_idRegisterPatient                      

UPDATE pa SET SeriaDocument=NULL, NumberDocument=NULL, SNILS=NULL
FROM  dbo.t_RegisterPatient p INNER JOIN #t t ON
		p.rf_idFiles=t.id
						INNER JOIN dbo.t_RegisterPatientDocument pa ON
		p.id=pa.rf_idRegisterPatient

UPDATE r SET r.SeriaPolis=NULL, r.NumberPolis=NULL 
FROM dbo.t_RegistersAccounts a INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts							
							INNER JOIN #t t ON
		a.rf_idFiles=t.id     
		                     

go
DROP TABLE #t
go
-----------------------------------------------------------------------
