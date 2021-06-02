USE AccountOMS
GO
DECLARE @codeM CHAR(6)='251001'
DECLARE @dtEnd DATETIME=GETDATE(),
		@yyyy smallint=YEAR(GETDATE()),
		@mm CHAR(2)=RIGHT('0'+CAST(MONTH(GETDATE()) AS varchar(2)),2),
		@packNum CHAR(3),
		@codeA INT,
		@numAct INT
DECLARE @dtStart DATETIME='20160923'

SELECT @codeA=ISNULL(MAX(codea),0),
		@packNum=RIGHT('00'+cast(ISNULL(MAX(PackageNumber),0)+1 AS varchar(3)),3)
FROM expertAccounts.dbo.t_ExpertActArchive	e WHERE e.CodeM=@codeM AND ReportMonth=CAST(@mm AS TINYINT) AND e.ReportYear=RIGHT(CAST(@yyyy AS CHAR(4)),2)

DECLARE @filename VARCHAR(25)='AT34M'+@codeM+'_'+RIGHT(CAST(@yyyy AS CHAR(4)),2)+@mm+@packNum

SELECT '1.2' AS [Version],CAST(GETDATE() AS DATE) AS DATA,@filename AS FILENAME
----------tag AKT
SELECT @numAct=ISNULL(MAX(NumberAct),0) FROM t_RefActOfSettledAccountBySMO WHERE CodeM=@codeM AND ReportYear=@yyyy
----формируем акты контроля
CREATE TABLE #t
(	
	CodeA BIGINT,
	NAKT VARCHAR(15),
	DAKT DATE,
	Kont TINYINT,
	Typek TINYINT,
	SKONT TINYINT,
	TypeAct TINYINT,
	id INT --для счетов с первичным МЭК берем rf_idAccounts, для повторных экспертиз id из таблицы t_Act_Accounts_MEEAndEKMP
)
INSERT #t( CodeA ,NAKT ,DAKT ,Kont ,Typek ,SKONT ,TypeAct)
SELECT ROW_NUMBER() OVER(ORDER BY a.id)+@codeA AS CODEA,ROW_NUMBER() OVER(ORDER BY a.id)+@numAct AS NAKT,CAST(GETDATE() AS DATE) AS DAKT, 1 AS KONT,1 AS TYPEK,0 AS SKONT, 1 
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<=@dtEnd AND a.rf_idSMO='34006' AND f.CodeM=@codeM 
		AND NOT EXISTS(SELECT * FROM dbo.t_RefActOfSettledAccountBySMO WHERE rf_idAccounts=a.id)

DECLARE @maxCodeA int

SELECT @maxCodeA=MAX(CodeA) FROM #t
;WITH cte
AS(
SELECT DISTINCT a.id,a.NumAct,a.DateAct,a.TypeCheckup,a.OrderCheckup
FROM dbo.t_Act_Accounts_MEEAndEKMP a
WHERE a.CodeM=@codeM --добавить проверку что бы повторно не выгружались
)
INSERT #t( CodeA ,NAKT ,DAKT ,Kont ,Typek ,SKONT ,TypeAct)
SELECT @maxCodeA+ROW_NUMBER() OVER(ORDER BY cte.id),NumAct ,DateAct ,TypeCheckup ,OrderCheckup,1,2
FROM cte

/*
---формируем счета для актов котнроля
SELECT a.id,ROW_NUMBER() OVER(ORDER BY a.id)+@codeA AS CODEA,a.idRecord AS CODE,a.rf_idMO AS CODE_MO,a.ReportYear AS [YEAR],a.ReportMonth AS [MONTH],a.Account AS NSCHET,a.DateRegister AS DSCHET,
		'34006',a.AmountPayment AS SUMMAV, a.AmountPayment AS SUMMAP,0 AS SANK_MEK,0 AS SANK_MEE,0 AS SANK_EKMP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<=@dtEnd AND a.rf_idSMO='34006' AND f.CodeM=@codeM AND NOT EXISTS(SELECT * FROM dbo.t_RefActOfSettledAccountBySMO WHERE rf_idAccounts=a.id)

---случаи
SELECT a.id, c.idRecordCase AS IDCASE,c.GUID_Case AS ID_C,c.rf_idMO AS LPU, 1 AS OPLATA,c.AmountPayment AS SUMP,0 AS SANK_MEK,0 AS SANK_MEE,0 AS SANK_EKMP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient                  
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<=@dtEnd AND a.rf_idSMO='34006' AND f.CodeM=@codeM AND NOT EXISTS(SELECT * FROM dbo.t_RefActOfSettledAccountBySMO WHERE rf_idAccounts=a.id)

DECLARE @id INT=0
IF UPPER(ORIGINAL_LOGIN())!=UPPER('VTFOMS\skrainov')
BEGIN
	--вставка в общую таблицу для формирования РАК
	INSERT expertAccounts.dbo.t_ExpertActArchive ( codea, filename, DateCreate,LoginName ) 
	SELECT ROW_NUMBER() OVER(ORDER BY a.id)+@codeA AS CODEA,@fileName, GETDATE(),ORIGINAL_LOGIN()
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
	WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<=@dtEnd AND a.rf_idSMO='34006' AND f.CodeM=@codeM AND NOT EXISTS(SELECT * FROM dbo.t_RefActOfSettledAccountBySMO WHERE rf_idAccounts=a.id)
	--вставка в таблицу данных о проэкспертированных счетах
	INSERT dbo.t_ActFileBySMO( ActFileName, DateCreate )VALUES  ( @filename,GETDATE())

	
	SET @id=SCOPE_IDENTITY()

	INSERT dbo.t_RefActOfSettledAccountBySMO( rf_idActFileBySMO ,CodeSMO ,CodeM ,NumberAct ,rf_idAccounts ,DateAct ,ReportYear,CodeA)
	SELECT @id,a.rf_idSMO,f.CodeM, ROW_NUMBER() OVER(ORDER BY a.id)+@numAct,a.id,CAST(GETDATE() AS DATE),a.ReportYear, ROW_NUMBER() OVER(ORDER BY a.id)+@codeA AS CODEA
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
	WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<=@dtEnd AND a.rf_idSMO='34006' AND f.CodeM=@codeM AND NOT EXISTS(SELECT * FROM dbo.t_RefActOfSettledAccountBySMO WHERE rf_idAccounts=a.id)
	
END
--возвращает 0 если данные не вставленны
SELECT @id
*/
GO 
DROP TABLE #t