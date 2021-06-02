USE AccountOMS
GO
BEGIN TRANSACTION
UPDATE dbo.t_SendingDataIntoFFOMS SET IsUnload=0 WHERE ReportYear=2017 AND ReportMonth=11 AND IsUnload=1

commit

