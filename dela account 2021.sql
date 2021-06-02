USE AccountOMS
GO
BEGIN TRANSACTION
DELETE FROM dbo.t_FileExit
FROM dbo.t_FileExit ff INNER JOIN (SELECT f.id
				FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
							f.id=a.rf_idFiles
				WHERE f.DateRegistration>'20210120' AND a.ReportYear=2021 AND a.ReportMonth=1 AND f.CodeM IN('451002','101001','121125','146004','176001','186002','251001','251008','161015')				
				) t ON t.id = ff.rf_idFile

commit