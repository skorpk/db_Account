USE AccountOMSReports
GO
SELECT * FROM dbo.t_SendingDataIntoFFOMS WHERE MES LIKE '%.%.%' AND ReportMonth=4

--SELECT * FROM vw_sprCSG WHERE code='st12.008.2'

BEGIN TRANSACTION
UPDATE dbo.t_SendingDataIntoFFOMS SET KSG_PG=1 WHERE MES LIKE '%.%.%' AND ReportMonth=4
commit

--BEGIN TRANSACTION
--UPDATE dbo.t_SendingDataIntoFFOMS SET VZST=6 WHERE rf_idCase=114542321
--SELECT * FROM dbo.t_SendingDataIntoFFOMS WHERE id=150 AND ReportMonth=4

--UPDATE dbo.t_SendingDataIntoFFOMS SET MUSurgery=NULL, idMU=NULL 
--WHERE MUSurgery IN('A18.05.002.001','A18.05.011.001','A18.05.002.002') AND ReportMonth=4
--commit
