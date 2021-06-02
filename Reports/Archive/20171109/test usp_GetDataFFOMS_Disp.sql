USE AccountOMS
GO
DECLARE @codeM1 CHAR(6),
		@snils1 VARCHAR(15)

SELECT TOP 1 AttachLPU,SNILS_Doc FROM dbo.t_Report1FFOMS WHERE ReportMonth=2 and reportYear=2017 order by AttachLPU
		
SELECT TOP 1 @codem1=AttachLPU,@snils1=SNILS_Doc FROM dbo.t_Report1FFOMS WHERE ReportMonth=2 and reportYear=2017 order by NEWID()
SELECT @codeM1,@snils1

EXEC dbo.usp_GetDataFFOMS_Disp @mm=2, @codeM='251002' ,@snils='07245873279',@id = 10, @reportYear = 2017
