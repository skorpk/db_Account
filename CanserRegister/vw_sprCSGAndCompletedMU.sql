USE CanserRegister
GO
CREATE VIEW [dbo].[vw_sprCSGAndCompletedMU]
AS
SELECT tCSG.code AS MU, tCSG.name
FROM oms_NSI.dbo.tCSGroup tCSG INNER JOIN oms_NSI.dbo.tCSGType t1 ON
				tCSG.rf_CSGTypeId=t1.CSGTypeId
UNION all
select CAST(MUGroupCode AS varchar(2)) + '.' + CAST(MUUnGroupCode AS varchar(2)) + '.' + CAST(MUCode AS varchar(3)) AS MU, MUName
from OMS_NSI.dbo.vw_sprMU m	
WHERE IsCompletedCase=1										

GO


