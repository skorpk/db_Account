USE AccountOMSReports
GO
SELECT * FROM dbo.t_SendingDataIntoFFOMS WHERE ReportMonth=7 AND id=28605

SELECT m.mu,m.rf_idCase
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN dbo.t_Meduslugi m ON
		s.rf_idCase=m.rf_idCase
WHERE ReportMonth=7 AND K_KSG='DIAL' AND s.MUSurgery IS null

BEGIN TRANSACTION
UPDATE dbo.t_SendingDataIntoFFOMS SET MUSurgery='A18.30.001.002'
WHERE ReportMonth=7 AND K_KSG='DIAL' AND MUSurgery IS NULL

SELECT s.MUSurgery
FROM dbo.t_SendingDataIntoFFOMS s 
WHERE ReportMonth=7 AND K_KSG='DIAL' AND s.rf_idCase IN(117688484,117688485,117688486,117688515,117688516)

commit

SELECT * 
FROM dbo.t_Meduslugi 
WHERE rf_idCase=117688484

