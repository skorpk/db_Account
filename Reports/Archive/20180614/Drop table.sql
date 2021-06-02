USE AccountOMS
GO
DECLARE @tFileA AS TABLE(FilaA VARCHAR(25))
INSERT @tFileA( FilaA )
VALUES  ('FM165531S34002_180100043'),('FM165531S34002_180100081'),('FM165531S34002_180200075'),('FM165531S34002_180200082'),('FM165531S34002_180200077'),('FM165531S34002_180200083'),
		('FM165531S34002_180300077'),('FM165531S34002_180300083'),('FM165531S34002_180300078'),('FM165531S34002_180100044')


SELECT f.id
INTO #tFileDel
FROM dbo.t_File f INNER JOIN @tFileA ff ON
			f.FileNameHR=ff.FilaA





DELETE FROM dbo.t_FileExit 
FROM dbo.t_FileExit fe INNER JOIN #tFileDel d ON
		fe.rf_idFile=d.id

--использую курсор 
declare cRunProcedure cursor for
	select id from #tFileDel
	declare @id int
open cRunProcedure
fetch next from cRunProcedure into @id
while @@FETCH_STATUS = 0
begin		
	-------------------------------------------------------
	exec dbo.usp_DeleteFile @id
	SELECT @id
	-------------------------------------------------------
	fetch next from cRunProcedure into @id
end
close cRunProcedure
deallocate cRunProcedure
/*
SELECT cc.id AS rf_idCase,rb.id, cb.TypePay, ra.rf_idFiles
INTO #tCaseWrong
FROM dbo.t_File f INNER JOIN @tFileA ff ON
			f.FileNameHR=ff.FilaA
				INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
				INNER JOIN dbo.t_RecordCasePatient rp ON
			a.id=rp.rf_idRegistersAccounts
				INNER JOIN dbo.t_Case c ON
			rp.id=c.rf_idRecordCasePatient
				INNER JOIN RegisterCases.dbo.t_Case cc ON
			c.GUID_Case=cc.GUID_Case
				INNER JOIN RegisterCases.dbo.t_RecordCaseBack rb ON
			cc.id=rb.rf_idCase
				INNER JOIN RegisterCases.dbo.t_CaseBack cb ON
			rb.id=cb.rf_idRecordCaseBack  
				INNER JOIN RegisterCases.dbo.t_RecordCase p ON
			cc.rf_idRecordCase=p.id
				INNER JOIN RegisterCases.dbo.t_RegistersCase ra ON				
			p.rf_idRegistersCase=ra.id
WHERE cb.TypePay=1			              

--BEGIN TRANSACTION
--INSERT RegisterCases.dbo.t_ErrorProcessControl( DateRegistration ,ErrorNumber ,rf_idFile ,rf_idCase )
--SELECT GETDATE(),65,rf_idFiles, rf_idCase FROM #tCaseWrong


--UPDATE cb SET cb.TypePay=2
--FROM RegisterCases.dbo.t_CaseBack cb INNER JOIN #tCaseWrong w ON
--			cb.rf_idRecordCaseBack=w.id
COMMIT
*/
GO
DROP TABLE #tFileDel
--DROP TABLE #tCaseWrong