USE AccountOMSReports
GO
declare @p1 XML,
		@idoc int

SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\TKR34200001.xml',SINGLE_BLOB) HRM (ZL_LIST)

EXEC sp_xml_preparedocument @idoc OUTPUT, @p1

--SELECT COUNT(*)
--FROM OPENXML (@idoc, 'ZL_LIST/SCHET/ZAP',2)
--	WITH(
--			N_ZAP INT
--		)

SELECT DISTINCT *
INTO #t
FROM OPENXML (@idoc, 'ISP_OB/PODR/ZAP/SLUCH',2)
	WITH(
			DATE_2 DATE ,
			NPOLIS VARCHAR(20) '../PACIENT/NPOLIS',
			DR date '../PACIENT/DR',
			PODR varchar(20),
			DS1 varchar(10),
			K_KSG varchar(10)
		)

EXEC sp_xml_removedocument @idoc

SELECT DISTINCT s.rf_idCase
INTO #tCase
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN #t t ON
			s.NumberPolis=t.NPOLIS
			AND s.DateEnd=t.DATE_2
			AND s.BirthDay=t.DR
			AND s.UnitOfHospital=t.PODR
			AND t.K_KSG = s.K_KSG
			AND t.DS1 = s.DS1

SELECT @@ROWCOUNT

--SELECT * FROM dbo.t_SendingDataIntoFFOMS s WHERE NOT EXISTS(SELECT 1 FROM #tCase ss WHERE ss.rf_idCase=s.rf_idCase)

BEGIN TRANSACTION
	DELETE FROM dbo.t_SendingDataIntoFFOMS  
	FROM dbo.t_SendingDataIntoFFOMS s WHERE NOT EXISTS(SELECT 1 FROM #tCase ss WHERE ss.rf_idCase=s.rf_idCase)
	SELECT @@ROWCOUNT
commit

GO
DROP TABLE #t
GO
DROP TABLE #tCase