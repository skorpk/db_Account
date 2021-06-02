use AccountOMS
go
declare @p1 xml,
		@p2 XML,
		@dateStart DATETIME

SELECT @dateStart=GETDATE()		
SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'd:\Test\FM165531S34007_190100055.XML',SINGLE_BLOB) HRM (ZL_LIST)

SELECT	@p2=LRM.PERS_LIST				
FROM	OPENROWSET(BULK 'd:\Test\LM165531S34007_190100055.xml',SINGLE_BLOB) LRM (PERS_LIST)

SET STATISTICS TIME ON


exec dbo.usp_TestAccountDataLPUFileF2019_Test @doc=@p1,@patient=@p2,@fileName=N'FM165531S34007_190100055'
--exec dbo.usp_TestAccountDataLPUFileH @doc=@p1,@patient=@p2,@fileName=N'HM103001S34007_180800001'

SET STATISTICS TIME OFF

--SELECT * FROM dbo.t_Errors WHERE rf_idFileError=33652

