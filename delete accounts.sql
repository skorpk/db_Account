USE AccountOMS
GO
SELECT f.id
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
WHERE CodeM='121125' AND a.ReportYear=2018 AND a.ReportMonth=11	AND f.DateRegistration>'20181101'
BEGIN TRANSACTION

DELETE FROM dbo.t_FileExit
FROM dbo.t_FileExit f INNER JOIN #t t ON
			f.rf_idFile=t.id
SELECT @@ROWCOUNT

DECLARE @id	int
DECLARE delID CURSOR LOCAL FOR
    SELECT id FROM #t
OPEN delID
FETCH NEXT FROM delID INTO @id
WHILE @@FETCH_STATUS=0
BEGIN
    SELECT @id
	EXEC dbo.usp_DeleteFile @id 	
    FETCH NEXT FROM delID
      INTO @id
END
CLOSE delID
DEALLOCATE delID

commit
GO
DROP TABLE #t