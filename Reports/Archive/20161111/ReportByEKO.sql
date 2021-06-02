USE RegisterCases
GO
SELECT f.DateRegistration,a.NumberRegister,a.ReportMonth,a.ReportYear,p.Fam,p.im,e.ErrorNumber
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
					INNER JOIN dbo.t_RefRegisterPatientRecordCase rp ON
			r.id=rp.rf_idRecordCase
					INNER JOIN dbo.t_RegisterPatient p ON
			rp.rf_idRegisterPatient=p.id
			AND f.id=p.rf_idFiles
					INNER JOIN (VALUES('Мамаева','Наталия',32015),('Тарабарова','Юлия',30407),('Трофимова','Анна',32642)) v(FAM,IM,DR) ON
			p.fam=v.fam
			AND p.Im=v.IM
			AND p.Birthday=DATEADD(DAY,-2,CAST(cast(v.DR AS datetime) AS DATE)) 
					INNER JOIN dbo.t_ErrorProcessControl e ON
			f.id=e.rf_idFile
			AND c.id=e.rf_idCase            
WHERE f.DateRegistration>'20160101' AND f.CodeM='801934' 