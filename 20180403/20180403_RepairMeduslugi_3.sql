USE AccountOMS
GO
--SELECT COUNT(*)
--FROM dbo.t_Meduslugi m WHERE NOT EXISTS(SELECT 1 FROM MUOpenServer WHERE rf_idCase=m.rf_idCase AND GUID_MU=m.GUID_MU)

SELECT rf_idCase,Guid_MU
INTO #tMU
FROM dbo.MUOpenServer m WHERE NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=m.rf_idCase AND GUID_MU=m.GUID_MU)

SELECT cc.id,c.id AS rf_idCase,mm.Guid_MU
INTO #tCase
from AccountOMS.dbo.t_File f INNER JOIN AccountOMS.dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles				            
				inner JOIN AccountOMS.dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN AccountOMS.dbo.t_Case c ON
		r.id=c.rf_idRecordCasePatient
				INNER JOIN RegisterCases.dbo.t_Case cc ON
		c.GUID_Case=cc.GUID_Case
				INNER JOIN #tMU mm ON
		c.id=mm.rf_idCase              


INSERT AccountOMS.dbo.t_Meduslugi( rf_idCase ,id ,GUID_MU ,rf_idMO ,rf_idSubMO ,rf_idDepartmentMO ,rf_idV002 ,IsChildTariff ,DateHelpBegin ,DateHelpEnd ,
									DiagnosisCode ,MUGroupCode ,MUUnGroupCode ,MUCode ,Quantity ,Price ,TotalPrice ,rf_idV004 ,rf_idDoctor ,Comments ,
									MUSurgery ,IsNeedUsl)
SELECT  c.rf_idCase ,m.id ,m.GUID_MU ,m.rf_idMO ,m.rf_idSubMO ,m.rf_idDepartmentMO ,m.rf_idV002 ,m.IsChildTariff ,m.DateHelpBegin ,m.DateHelpEnd ,
		m.DiagnosisCode ,mu.MUGroupCode,mu.MUUnGroupCode,mu.MUCode,m.Quantity ,m.Price ,m.TotalPrice ,m.rf_idV004 ,m.rf_idDoctor ,m.Comments ,
		m.MUSurgery , m.IsNeedUsl
FROM RegisterCases.dbo.t_Meduslugi m INNER JOIN #tCase c ON
		m.rf_idCase=c.id
		AND m.GUID_MU=c.Guid_MU
					inner join (SELECT MU ,MUGroupCode,MUUnGroupCode,MUCode FROM AccountOMS.dbo.vw_sprMU  
								UNION ALL SELECT IDRB,0,0,0 FROM AccountOMS.dbo.vw_V001 
								UNION SELECT d.code ,0,0,0 FROM OMS_NSI.dbo.sprDentalMU d) mu ON
		m.MUCode=mu.MU            