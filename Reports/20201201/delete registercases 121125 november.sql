USE RegisterCases
GO
SELECT DISTINCT f.id
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
WHERE f.DateRegistration>'20201101' AND a.ReportYear=2020 AND a.ReportMonth=11 AND f.CodeM='121125' --AND a.rf_idSMO='34007'


BEGIN TRANSACTION

DELETE FROM dbo.t_FileBack
FROM dbo.t_FileBack f INNER JOIN #t t ON
		f.rf_idFiles=t.id

DELETE FROM dbo.t_File
FROM dbo.t_File f INNER JOIN #t t ON
		f.id=t.id

commit
GO
DROP TABLE #t