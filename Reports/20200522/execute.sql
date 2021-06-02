USE PlanDD
GO
EXEC dbo.usp_ReportDispObservation_I @dateEnd = '20200611 06:20:54', -- datetime
                                     @reportMonth = 5                  -- tinyint
