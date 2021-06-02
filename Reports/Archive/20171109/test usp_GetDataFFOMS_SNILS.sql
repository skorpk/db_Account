USE AccountOMS
GO
DECLARE @codeM1 CHAR(6),
		@snils1 VARCHAR(15)

SELECT TOP 1 AttachLPU,SNILS_Doc FROM dbo.t_SNILSAmbulanceFFOMS WHERE ReportMonth=9 and reportYear=2016 order by AttachLPU
		
SELECT TOP 1 @codem1=AttachLPU,@snils1=SNILS_Doc FROM dbo.t_SNILSAmbulanceFFOMS WHERE ReportMonth=9 and reportYear=2016 order by AttachLPU

EXEC dbo.usp_GetDataFFOMS_SNILS @mm = 1, @codeM=@codeM1 ,@snils=@snils1,@id = 0, @reportYear = 2017
