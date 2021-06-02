USE AccountOMS
GO
DECLARE @reportMonth TINYINT=MONTH(GETDATE()),
		@reportYear SMALLINT=YEAR(GETDATE())

SELECT @reportYear=(CASE WHEN @reportMonth=1 THEN @reportYear-1 ELSE @reportYear END),
		@reportMonth=(CASE WHEN @reportMonth=1 THEN 12 ELSE @reportMonth-1 END)
SELECT @reportMonth,@reportYear

IF EXISTS(SELECT * FROM dbo.sprDate146Order WHERE ReportMonth=@reportMonth AND ReportYear=ReportYear AND DateEnd<GETDATE())
BEGIN
	IF NOT EXISTS(SELECT * FROM t_Data146Order WHERE ReportMonth=@reportMonth AND ReportYear=@reportYear)
	BEGIN    
	 EXEC dbo.usp_CreateData146Order @reportMonth,@reportYear 	 
	END    
END 