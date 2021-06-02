USE AccountOMSReports
go

SELECT * FROM t_SendingFileToFFOMS ORDER BY id
DELETE FROM dbo.t_SendingFileToFFOMS WHERE id>46
DBCC CHECKIDENT('dbo.t_SendingFileToFFOMS',RESEED,46)

update dbo.t_SendingDataIntoFFOMS SET IsUnload=0 WHERE ReportYear=2018 AND IsFullDoubleDate=0 AND ReportMonth=11 AND IsUnload=1

