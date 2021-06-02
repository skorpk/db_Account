use AccountOMS
go
declare @p1 xml,
		@p2 XML,
		@bfile VARBINARY(max),
		@dateStart DATETIME,
		@nameFile VARCHAR(25)='HM186002S34002_1612056'

SELECT @dateStart=GETDATE()		
SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\HM186002S34002_1612056.xml',SINGLE_BLOB) HRM (ZL_LIST)

SELECT	@p2=LRM.PERS_LIST				
FROM	OPENROWSET(BULK 'c:\Test\LM186002S34002_1612056.xml',SINGLE_BLOB) LRM (PERS_LIST)

SELECT	@bfile=f.DataFile
FROM	OPENROWSET(BULK 'c:\Test\HM186002S34002_1612056.zip',SINGLE_BLOB) f (DataFile)

SET STATISTICS TIME ON

exec dbo.usp_InsertAccountDataLPU @doc = @p1,
								  @patient =@p2, -- xml
								  @file = @bfile, -- varbinary(max)
								  @fileName =@nameFile, -- varchar(26)
								  @fileKey = NULL -- varbinary(max)
 

SET STATISTICS TIME OFF

