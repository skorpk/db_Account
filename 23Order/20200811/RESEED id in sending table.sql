USE AccountOMSReports
GO
UPDATE dbo.t_SendingDataIntoFFOMS SET IsUnload=0 WHERE ReportMonth=7 AND ReportYear=2020 AND IsUnload=1

DELETE FROM dbo.t_SendingFileToFFOMS WHERE id>67 

DBCC CHECKIDENT('dbo.t_SendingFileToFFOMS',RESEED,67)

SELECT * FROM t_SendingFileToFFOMS WHERE ReportYear=2020 ORDER BY id
GO