USE AccountOMS
GO
ALTER TABLE dbo.MURepair ADD [MU]  AS ((((CONVERT([varchar](2),[MUGroupCode],(0))+'.')+CONVERT([varchar](2),[MUUnGroupCode],(0)))+'.')+CONVERT([varchar](3),[MUCode],(0)))
ALTER TABLE dbo.MURepair ADD [MUInt]  AS (([MUGroupCode]*(100000)+[MUUnGroupCode]*(1000))+[MUCode])
ALTER TABLE dbo.MURepair ADD [IsNeedUsl] [tinyint] NULL