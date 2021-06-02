USE AccountOMS
GO
BEGIN TRANSACTION
INSERT dbo.t_Meduslugi( rf_idCase ,id ,GUID_MU ,rf_idMO ,rf_idDepartmentMO ,rf_idV002 ,IsChildTariff ,DateHelpBegin ,DateHelpEnd ,DiagnosisCode ,MUGroupCode ,MUUnGroupCode ,
						MUCode ,Quantity ,Price ,TotalPrice ,rf_idV004 ,rf_idDoctor ,Comments ,MUSurgery,rf_idSubMO)
SELECT distinct c.id AS rf_idCase ,m.id ,m.GUID_MU ,m.rf_idMO ,m.rf_idDepartmentMO ,m.rf_idV002 ,m.IsChildTariff ,m.DateHelpBegin ,m.DateHelpEnd ,m.DiagnosisCode ,0,0,0,
				        m.Quantity ,m.Price ,m.TotalPrice ,m.rf_idV004 ,m.rf_idDoctor ,m.Comments ,m.MUSurgery ,m.rf_idSubMO 
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN RegisterCases.dbo.t_Case c1 ON
			c.GUID_Case=c1.GUID_Case
			AND c1.DateEnd>='20160801'			
					INNER JOIN RegisterCases.dbo.t_Meduslugi m ON
			c1.id=m.rf_idCase    
WHERE NOT EXISTS(SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=c.id) AND f.DateRegistration>='20160801' AND a.ReportYear=2016 AND c.DateEnd>='20160801'
COMMIT
--SELECT *
--FROM RegisterCases.dbo.t_Case WHERE GUID_Case='0A19B4FE-B274-110D-1ACE-7FFE52082443'

--SELECT *
--FROM RegisterCases.dbo.t_Meduslugi WHERE rf_idCase=65245251