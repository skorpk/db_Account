USE RegisterCases
GO
--DROP TABLE AccountOMS.dbo.tmpNeedUSL
SELECT m.GUID_MU,m.IsNeedUsl,c.id
INTO AccountOMS.dbo.tmpNeedUSL
from AccountOMS.dbo.t_File f INNER JOIN AccountOMS.dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles				            
				inner JOIN AccountOMS.dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN AccountOMS.dbo.t_Case c ON
		r.id=c.rf_idRecordCasePatient
				INNER JOIN dbo.t_Case cc ON
		c.GUID_Case=cc.GUID_Case
				INNER JOIN dbo.t_Meduslugi m ON
		cc.id=m.rf_idCase              
WHERE f.DateRegistration>'20160101' AND c.DateEnd>='20160101' AND m.IsNeedUsl IS NOT null