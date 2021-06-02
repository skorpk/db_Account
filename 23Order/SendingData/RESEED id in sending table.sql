USE AccountOMSReports
GO
UPDATE dbo.t_SendingDataIntoFFOMS SET IsUnload=0 WHERE ReportMonth=4 AND ReportYear=2020 AND IsUnload=1

DELETE FROM dbo.t_SendingFileToFFOMS WHERE id>64 

DBCC CHECKIDENT('dbo.t_SendingFileToFFOMS',RESEED,64)

SELECT * FROM t_SendingFileToFFOMS WHERE ReportYear=2020 ORDER BY id
GO
--INSERT dbo.t_SendingFileToFFOMS
--(
--    NameFile,
--    ReportMonth,
--    ReportYear,
--    DateCreate,
--    NumberOfEndFile,
--    UserName
--)
--VALUES
--(   'TKR34200003',3,2020,'20200414 14:05',3, 'VTFOMS\oscherbakova'         -- UserName - varchar(50)
--    )