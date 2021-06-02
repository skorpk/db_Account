USE AccountOMS
GO
DECLARE @codeM CHAR(6)='141022'
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
INSERT #t( CodeA ,NAKT ,DAKT ,Kont ,Typek ,SKONT ,TypeAct,id)
SELECT ROW_NUMBER() OVER(ORDER BY a.id)+@codeA AS CODEA,ROW_NUMBER() OVER(ORDER BY a.id)+@numAct AS NAKT,CAST(GETDATE() AS DATE) AS DAKT, 1 AS KONT,1 AS TYPEK,0 AS SKONT, 1,a.id 
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<=@dtEnd AND a.rf_idSMO='34006' AND f.CodeM=@codeM 
		AND NOT EXISTS(SELECT * FROM dbo.t_RefActOfSettledAccountBySMO WHERE rf_idAccounts=a.id)

DECLARE @maxCodeA int

SELECT @codeA
SELECT @maxCodeA=ISNULL(MAX(CodeA),@codeA) FROM #t
;WITH cte
AS(
SELECT DISTINCT a.id,a.NumAct,a.DateAct,a.TypeCheckup,a.OrderCheckup
FROM dbo.t_Act_Accounts_MEEAndEKMP a
WHERE a.CodeM=@codeM --добавить проверку что бы повторно не выгружались
)
INSERT #t( CodeA ,NAKT ,DAKT ,Kont ,Typek ,SKONT ,TypeAct,id)
SELECT @maxCodeA+ROW_NUMBER() OVER(ORDER BY cte.id),NumAct ,DateAct ,TypeCheckup ,OrderCheckup,1,2,cte.id
FROM cte
------------------------Данные для тега AKT----------------------
SELECT CodeA ,NAKT ,DAKT ,Kont ,Typek ,SKONT FROM #t
------------------------Данные для тега SCHET----------------------
SELECT a.id,t.CODEA,a.idRecord AS CODE,a.rf_idMO AS CODE_MO,a.ReportYear AS [YEAR],a.ReportMonth AS [MONTH],a.Account AS NSCHET,a.DateRegister AS DSCHET,
		'34006',a.AmountPayment AS SUMMAV, a.AmountPayment AS SUMMAP,0 AS SANK_MEK,0 AS SANK_MEE,0 AS SANK_EKMP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN #t t ON
			a.id=t.id                  
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<=@dtEnd AND a.rf_idSMO='34006' AND f.CodeM=@codeM AND t.TypeAct=1
	AND NOT EXISTS(SELECT * FROM dbo.t_RefActOfSettledAccountBySMO WHERE rf_idAccounts=a.id)
UNION ALL
SELECT  id ,CodeA ,CODE ,CODE_MO ,[YEAR] ,[MONTH] ,NSCHET ,DSCHET,'34006' ,SUMMAV ,SUMMAV-Deduction AS SUMP ,SANK_MEK ,SANK_MEE ,SANK_EKMP
FROM (
	SELECT a.id,t.CODEA,a.idRecord AS CODE,a.rf_idMO AS CODE_MO,a.ReportYear AS [YEAR],a.ReportMonth AS [MONTH],a.Account AS NSCHET,a.DateRegister AS DSCHET,
			a.AmountPayment AS SUMMAV, SUM(e.Deduction) AS Deduction,
			SUM(CASE WHEN e.TypeCheckup=1 THEN e.Deduction ELSE 0 END) AS SANK_MEK,
			sum(CASE WHEN e.TypeCheckup=2 THEN e.Deduction ELSE 0 END) AS SANK_MEE,
			sum(CASE WHEN e.TypeCheckup=3 THEN e.Deduction ELSE 0 END) AS SANK_EKMP
	FROM #t t INNER JOIN dbo.t_Act_Accounts_MEEAndEKMP e ON
			t.id=e.id
				INNER JOIN dbo.t_RegistersAccounts a ON
			e.rf_idAccount=a.id          
	WHERE e.CodeM=@codeM AND t.TypeAct=2
	GROUP BY a.id,t.CODEA,a.idRecord,a.rf_idMO ,a.ReportYear ,a.ReportMonth,a.Account ,a.DateRegister,a.AmountPayment
	) t
------------------------Данные для тега SLUCH----------------------
SELECT a.id, c.idRecordCase AS IDCASE,c.GUID_Case AS ID_C,c.rf_idMO AS LPU, 1 AS OPLATA,c.AmountPayment AS SUMP, NULL AS REFREASON,0 AS SANK_MEK,0 AS SANK_MEE,0 AS SANK_EKMP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
				  INNER JOIN #t t ON
			a.id=t.id 
			AND t.TypeAct=1
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient                  
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<=@dtEnd AND a.rf_idSMO='34006' AND f.CodeM=@codeM AND NOT EXISTS(SELECT * FROM dbo.t_RefActOfSettledAccountBySMO WHERE rf_idAccounts=a.id)
UNION ALL
SELECT a.id, c.idRecordCase AS IDCASE,c.GUID_Case AS ID_C,c.rf_idMO AS LPU,
		 CASE WHEN c.AmountPayment-e.Deduction=0 THEN 2 
			  WHEN  c.AmountPayment-e.Deduction>0 AND  c.AmountPayment-e.Deduction<c.AmountPayment THEN 3 
			  WHEN c.AmountPayment-e.Deduction=c.AmountPayment THEN 1 END AS OPLATA,
		 c.AmountPayment-e.Deduction AS SUMP,e.Reason AS REFREASON,
		 CASE WHEN e.TypeCheckup=1 THEN e.Deduction ELSE 0 END AS SANK_MEK,
		 CASE WHEN e.TypeCheckup=2 THEN e.Deduction ELSE 0 END AS SANK_MEE,
		 CASE WHEN e.TypeCheckup=3 THEN e.Deduction ELSE 0 END AS SANK_EKMP
FROM #t t INNER JOIN dbo.t_Act_Accounts_MEEAndEKMP e ON
			t.id=e.id
				INNER JOIN dbo.t_RegistersAccounts a ON
			e.rf_idAccount=a.id          
				INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient                  
			AND c.id=e.rf_idCase
WHERE e.CodeM=@codeM AND t.TypeAct=2
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
   */
DECLARE @id INT=0
IF UPPER(ORIGINAL_LOGIN())!=UPPER('VTFOMS\skrainov')
BEGIN
	--вставка в общую таблицу для формирования РАК
	--INSERT expertAccounts.dbo.t_ExpertActArchive ( codea, filename, DateCreate,LoginName ) 
	--SELECT ROW_NUMBER() OVER(ORDER BY a.id)+@codeA AS CODEA,@fileName, GETDATE(),ORIGINAL_LOGIN()
	--FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
	--			f.id=a.rf_idFiles					  
	--WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<=@dtEnd AND a.rf_idSMO='34006' AND f.CodeM=@codeM and NOT EXISTS(SELECT * FROM dbo.t_RefActOfSettledAccountBySMO WHERE rf_idAccounts=a.id)
	
	INSERT expertAccounts.dbo.t_ExpertActArchive ( codea, filename, DateCreate,LoginName ) 	SELECT CodeA,@fileName, GETDATE(),ORIGINAL_LOGIN() FROM #t


	--вставка в таблицу данных о проэкспертированных счетах
	
	INSERT dbo.t_ActFileBySMO( ActFileName, DateCreate )VALUES  ( @filename,GETDATE())

	
	SET @id=SCOPE_IDENTITY()

	INSERT dbo.t_RefActOfSettledAccountBySMO( rf_idActFileBySMO ,CodeSMO ,CodeM ,NumberAct ,rf_idAccounts ,DateAct ,ReportYear,CodeA)
	SELECT @id,a.rf_idSMO,f.CodeM,t.NAKT,a.id,CAST(GETDATE() AS DATE),a.ReportYear, t.CODEA
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
					  INNER JOIN #t t ON
				a.id=t.id 						
	WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<=@dtEnd AND a.rf_idSMO='34006' AND f.CodeM=@codeM AND t.TypeAct=1
		and NOT EXISTS(SELECT * FROM dbo.t_RefActOfSettledAccountBySMO WHERE rf_idAccounts=a.id)

	INSERT dbo.t_RefActOfSettledAccount_EKMP_MEE( rf_idActFileBySMO ,CodeSMO ,CodeM ,rf_idAccounts ,rf_idCase ,rf_idAct_Accounts_MEEAndEKMP ,CodeA)
	select @id, a.rf_idSMO, t.CodeM, e.rf_idAccount, e.rf_idCase, a.id, t.CODEA
	FROM #t t INNER JOIN dbo.t_Act_Accounts_MEEAndEKMP e ON
			t.id=e.id  
			  INNER JOIN dbo.t_RegistersAccounts a ON
			e.rf_idAccount=a.id 
	WHERE t.CodeM=@CodeM and t.TypeAct=2
	
END
--возвращает 0 если данные не вставленны
SELECT @id
GO 
DROP TABLE #t