USE AccountOMSReports
GO
declare @p1 XML,
		@idoc INT,
		@p2 XML,
		@idPac int

SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'e:\Test\TKR34190002.xml',SINGLE_BLOB) HRM (ZL_LIST)

DECLARE @reportMonth tinyint

EXEC sp_xml_preparedocument @idoc OUTPUT, @p1

SELECT @reportMonth=[MONTH]
FROM OPENXML (@idoc, 'ISP_OB/SVD',2)
	WITH(
			[MONTH] TINYINT
		)

SELECT *
INTO #t1
FROM OPENXML (@idoc, 'ISP_OB/PODR/ZAP/SLUCH',2)
	WITH(
			PODR NVARCHAR(15),
			IDCASE int 	 ,
			NPOLIS varchar(20) '../PACIENT/NPOLIS'
		)

EXEC sp_xml_removedocument @idoc
--смотримхорошая ли запись или нет
SELECT DISTINCT s.rf_idCase,s.NumberPolis , IsFullDoubleDate
FROM dbo.t_SendingDataIntoFFOMS2019 s		
where ReportMonth=@reportMonth AND s.NewValue=0	AND  EXISTS(SELECT 1 FROM #t1 t WHERE t.podr=s.UnitOfHospital AND t.IDCASE=s.id AND RTRIM(t.NPolis)=RTRIM(s.NumberPolis) )
GO
DROP TABLE #t1
