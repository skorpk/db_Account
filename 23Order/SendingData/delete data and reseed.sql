USE AccountOMS
go

SELECT * FROM t_SendingFileToFFOMS
DELETE FROM dbo.t_SendingFileToFFOMS WHERE id>17
DBCC CHECKIDENT('dbo.t_SendingFileToFFOMS',RESEED,17)

update dbo.t_SendingDataIntoFFOMS SET IsUnload=0 WHERE ReportYear=2016 AND IsFullDoubleDate=0 AND ReportMonth=7

