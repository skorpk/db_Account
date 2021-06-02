USE AccountOMS
GO
SELECT ActFileName AS FName
INTO #t
FROM dbo.t_ActFileBySMO WHERE DateCreate>'20170101'


--SELECT *
--FROM expertAccounts.dbo.t_ExpertActArchive e 
--WHERE LoginName='vtfoms\astepanova' AND EXISTS(SELECT * FROM #t WHERE FName=e.filename)

BEGIN TRANSACTION
DELETE FROM expertAccounts.dbo.t_ExpertActArchive 
FROM expertAccounts.dbo.t_ExpertActArchive e 
WHERE LoginName='vtfoms\astepanova' AND EXISTS(SELECT * FROM #t WHERE FName=e.filename)

SELECT f.id
FROM ExchangeFinancing.dbo.t_AFileTested f INNER JOIN #t v ON
				f.FileNameTested=v.FName
						INNER JOIN ExchangeFinancing.dbo.t_AError e ON
				f.id=e.rf_idAFileTested
WHERE e.xmlElementPR IS NULL
				
DELETE ExchangeFinancing.dbo.t_AFileOUT				
FROM ExchangeFinancing.dbo.t_AFileTested f INNER JOIN #t v ON
				f.FileNameTested=v.FName
						INNER JOIN ExchangeFinancing.dbo.t_AFileIn fi ON
				f.id=fi.rf_idAFileTested
						INNER JOIN ExchangeFinancing.dbo.t_AFileOUT fo ON
				fi.id=fo.rf_idAFile				
SELECT @@ROWCOUNT
				
DELETE ExchangeFinancing.dbo.t_AFileTested 				
FROM ExchangeFinancing.dbo.t_AFileTested f INNER JOIN #t v ON
				f.FileNameTested=v.FName
						INNER JOIN ExchangeFinancing.dbo.t_AError e ON
				f.id=e.rf_idAFileTested
WHERE e.xmlElementPR IS NULL

SELECT @@ROWCOUNT	
			
SELECT f.id
FROM ExchangeFinancing.dbo.t_AFileTested f INNER JOIN #t v ON
				f.FileNameTested=v.FName

DELETE FROM dbo.t_ActFileBySMO WHERE DateCreate>'20170101'				
--ROLLBACK
COMMIT
GO
DROP TABLE #t