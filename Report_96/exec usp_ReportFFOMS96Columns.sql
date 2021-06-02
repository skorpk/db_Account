USE AccountOMS
go
EXEC dbo.usp_ReportFFOMS96Columns @dateStart = '20200101', -- datetime
                                  @dateEnd = '20200218 12:31:49',   -- datetime
                                  @reportYear = 2020,                    -- smallint
                                  @reportMonth = 1,                   -- tinyint
                                  @dateEndAkt = '20200218 12:31:49' -- datetime
