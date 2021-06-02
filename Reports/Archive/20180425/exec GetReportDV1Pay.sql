USE planDD
GO
DECLARE @startDateReg DATETIME='20180110',
		@endDateReg DATETIME='20181011',
		@endDateRegAkt DATETIME='20181011',
  		@endDateRegPay DATETIME='20181011',
		@reportYear smallint=2018,
		@reportMonth TINYINT=9,
		@codeSMO CHAR(5)='34002',
		@dtEndB DATE='20180930',
		@begin_dd date = '20180101',
		@end_dd date = '20181015'

EXEC [dbo].[GetReportDV1Pay] @startDateReg,@endDateReg,@begin_dd,@end_dd,@reportYear,@reportMonth,@codeSMO,@endDateRegAkt,@endDateRegPay