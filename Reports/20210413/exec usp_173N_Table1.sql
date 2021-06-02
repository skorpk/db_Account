USE PlanDD
GO
EXEC dbo.usp_173N_Table1 @dateStartReg = '20210101',    -- datetime
                         @dateEndReg = '20210414 04:58:44',      -- datetime
                         @dateStartRegRAK = '20210414 04:58:44', -- datetime
                         @dateEndRegRAK = '20210414 04:58:44',   -- datetime
                         @reportYear =2021,                          -- smallint
                         @reportMonth = 3                          -- tinyint
