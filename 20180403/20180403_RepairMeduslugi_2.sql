USE AccountOMS
GO

DECLARE @idCase BIGINT=7000000,
		@idCase2 BIGINT=10000000

		

INSERT t_Meduslugi( rf_idCase ,id ,GUID_MU ,rf_idMO ,rf_idSubMO ,rf_idDepartmentMO ,rf_idV002 ,IsChildTariff ,DateHelpBegin ,DateHelpEnd ,
									DiagnosisCode ,MUGroupCode ,MUUnGroupCode ,MUCode ,Quantity ,Price ,TotalPrice ,rf_idV004 ,rf_idDoctor ,Comments ,
									MUSurgery )
SELECT m.rf_idCase ,m.id ,m.GUID_MU ,m.rf_idMO ,m.rf_idSubMO ,m.rf_idDepartmentMO ,m.rf_idV002 ,m.IsChildTariff ,m.DateHelpBegin ,m.DateHelpEnd ,
		m.DiagnosisCode ,m.MUGroupCode,m.MUUnGroupCode,m.MUCode,m.Quantity ,m.Price ,m.TotalPrice ,m.rf_idV004 ,m.rf_idDoctor ,m.Comments ,
		m.MUSurgery 
FROM dbo.MURepair m
WHERE rf_idCase>@idCase	AND  rf_idCase<=@idCase2

