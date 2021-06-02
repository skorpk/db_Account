USE AccountOMSReports
GO

SELECT m.rf_idCase,m.MU,m.MUSurgery
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN dbo.t_Meduslugi m ON
				s.rf_idCase=m.rf_idCase
WHERE ReportMonth=4 AND s.id IN(25340,25341,25342,25343,25344,25345,25346,25347,25348,46,47,17570,17572,25337,25338,25339)

BEGIN TRANSACTION
UPDATE s SET s.idMU=m.id, s.MUSurgery=m.MUSurgery
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN dbo.t_Meduslugi m ON
				s.rf_idCase=m.rf_idCase
WHERE ReportMonth=4 AND s.id IN(25340,25341,25342,25343,25344,25345,25346,25347,25348,46,47,17570,17572,25337,25338,25339)

commit