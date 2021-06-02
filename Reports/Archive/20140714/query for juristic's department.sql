USE RegisterCases
GO
SELECT f.DateRegistration,a.NumberRegister,e.ErrorNumber,c.GUID_Case,V002.name
FROM t_File f INNER JOIN dbo.t_RegistersCase a ON
		f.id=a.rf_idFiles
				INNER JOIN dbo.t_RecordCase r ON
		a.id=r.rf_idRegistersCase
				INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCase
				INNER JOIN dbo.t_RefRegisterPatientRecordCase r1 ON
		r.id=r1.rf_idRecordCase
				INNER JOIN dbo.t_RegisterPatient p ON
		r1.rf_idRegisterPatient=p.id
		AND f.id=p.rf_idFiles
				inner JOIN dbo.t_ErrorProcessControl e ON			
		c.id=e.rf_idCase
				INNER JOIN dbo.vw_sprV002 v002 ON
		c.rf_idV002=v002.id
WHERE f.DateRegistration>'20131201' AND f.DateRegistration<'20140201' AND a.ReportMonth=12 AND a.ReportYear=2013
		AND c.DateEnd>='20131201' AND c.DateEnd<'20140101'
		AND p.Fam='Брызгунова' AND p.Im='Галина' AND p.BirthDay='19420707' AND f.CodeM='151012'	AND c.rf_idV006=1