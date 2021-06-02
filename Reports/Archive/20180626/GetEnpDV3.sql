USE RegisterCases
GO
DROP TABLE PeopleAttach.dbo.t_ENPDV3

SELECT distinct f.CodeM AS LPU, p.ENP, NULL AS LPU_P
INTO PeopleAttach.dbo.t_ENPDV3
FROM dbo.t_FileBack f INNER JOIN dbo.t_RegisterCaseBack a ON
			f.id=a.rf_idFilesBack
					INNER JOIN dbo.t_RecordCaseBack r ON
			a.id=r.rf_idRegisterCaseBack
					INNER JOIN dbo.t_CaseBack c ON
			r.id=c.rf_idRecordCaseBack
					INNER JOIN dbo.t_PatientBack p ON
			r.id=p.rf_idRecordCaseBack
					INNER JOIN dbo.t_DispInfo d ON
			r.rf_idCase=d.rf_idCase
WHERE f.DateCreate>'20180101' AND a.ReportYear=2018 AND c.TypePay=1 AND d.TypeDisp='ÄÂ3'			                    