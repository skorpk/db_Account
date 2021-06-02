USE AccountOMS
GO		
IF OBJECT_ID (N'dbo.fn_CheckAccountExistSPTK', N'IF') IS NOT NULL
    DROP FUNCTION dbo.fn_CheckAccountExistSPTK
GO
--проверка наличия реестра СП и ТК в БД
CREATE FUNCTION dbo.fn_CheckAccountExistSPTK(@account VARCHAR(15),@codeMO CHAR(6),@month TINYINT,@year SMALLINT)
RETURNS TABLE
AS
	RETURN(
	        SELECT r.id
			FROM RegisterCases.dbo.t_FileBack f INNER JOIN RegisterCases.dbo.t_RegisterCaseBack r ON
					f.id=r.rf_idFilesBack
					AND f.CodeM=@codeMO
						  INNER JOIN RegisterCases.dbo.t_RecordCaseBack rec ON
					r.id=rec.rf_idRegisterCaseBack
					AND ReportMonth=@month 
					AND ReportYear=@year 
						INNER JOIN RegisterCases.dbo.t_PatientBack p ON
					rec.id=p.rf_idRecordCaseBack							
			WHERE RTRIM(p.rf_idSMO)+'-'+CAST(r.NumberRegister AS VARCHAR(6))+'-'+CAST(r.PropertyNumberRegister AS CHAR(1))= 
					(CASE WHEN ISNUMERIC(RIGHT(@account,1))=1 THEN @account ELSE SUBSTRING(@account,1,LEN(@account)-1) END)
		)

GO
--------------------------------------------------------------------------------------------
IF OBJECT_ID (N'dbo.fn_CheckAccountExistInDB', N'IF') IS NOT NULL
    DROP FUNCTION dbo.fn_CheckAccountExistInDB
GO
--проверка на наличие уже зарегестрированного счета с такми номером от МО
CREATE FUNCTION dbo.fn_CheckAccountExistInDB(@account VARCHAR(15),@codeMO CHAR(6),@month TINYINT,@year SMALLINT)
RETURNS TABLE
AS
RETURN(
		SELECT DISTINCT a.id
		FROM t_File f INNER JOIN t_RegistersAccounts a ON
				f.id=a.rf_idFiles
				AND f.CodeM=@codeMO
				AND a.ReportYear=@year
		WHERE RTRIM(PrefixNumberRegister)+'-'+CAST(NumberRegister AS VARCHAR(6))+'-'+CAST(PropertyNumberRegister AS CHAR(1))+ISNULL(Letter,'')=@account
	)
GO
----------------------------------------------------------------------------------------------
IF OBJECT_ID('usp_IsCODEExists', N'P') IS NOT NULL
	DROP PROC usp_IsCODEExists
GO
CREATE PROCEDURE usp_IsCODEExists
				@code INT,
				@codeM CHAR(6)
AS
SELECT COUNT(*) 
FROM t_File f INNER JOIN t_RegistersAccounts a ON
		f.id=a.rf_idFiles
WHERE CodeM=@codeM AND a.idRecord=@code
GO
ALTER PROC usp_ReportNotAcceptedAccount
			@num NVARCHAR(MAX)--TVP_ReportMO READONLY
AS
SET LANGUAGE russian
			
DECLARE @t AS TABLE(id INT)
		
DECLARE @idoc INT,
        @err INT,
        @xml XML
        
SELECT @xml=CAST(REPLACE('<Root><Num num="'+@num+'" /></Root>',',','" /><Num num="') AS XML)
--CAST(dbo.fn_SplitNumber(@num) as xml)

 EXEC  @err = sp_xml_preparedocument @idoc OUTPUT, @xml
INSERT @t
SELECT num
FROM OPENXML(@idoc, '/Root/Num', 1)
          WITH (num INT)

 EXEC sp_xml_removedocument @idoc

	SELECT f.FileName,CONVERT(CHAR(10),f.DateCreate,104)+' '+CAST(CAST(f.DateCreate AS TIME(7)) AS VARCHAR(8)) AS DateRegistration
	,e.ErrorNumber,ea.DescriptionError
	FROM t_FileError f INNER JOIN t_Errors e ON
				f.id=e.rf_idFileError
						INNER JOIN @t t1 ON
				f.id=t1.id
						INNER JOIN oms_nsi.dbo.sprAllErrors ea ON
				e.ErrorNumber=ea.Code			
GO
----------------------------------------------------------------------------------------------------
ALTER PROC usp_InsertAccountDataLPU
			@doc XML,
			@patient XML,
			@file VARBINARY(MAX),
			@fileName VARCHAR(26),
			@fileKey VARBINARY(MAX)=null--файл цифровой подпИСИ
AS
DECLARE @idoc INT,
		@ipatient INT,
		@id INT,
		@idFile int--,
		--@error tinyint=0

---create tempory table----------------------------------------------

DECLARE @t1 AS TABLE([VERSION] CHAR(5),DATA DATE,[FILENAME] VARCHAR(26))

DECLARE @t2 AS TABLE(
					 CODE INT,
					 CODE_MO INT,
					 [YEAR] SMALLINT,
					 [MONTH] TINYINT,
					 NSCHET NVARCHAR(15),
					 DSCHET DATE,
					 PLAT NVARCHAR(5),
					 SUMMAV DECIMAL(15, 2),
					 COMENTS NVARCHAR(250)) 

CREATE TABLE #t3 
(
	N_ZAP INT,
	PR_NOV TINYINT,
	ID_PAC NVARCHAR(36),
	VPOLIS TINYINT,
	SPOLIS NCHAR(10),
	NPOLIS NCHAR(20),
	SMO NCHAR(5),
	SMO_OK NCHAR(5),
	NOVOR NCHAR(9)
)


CREATE TABLE #t5 
(
	N_ZAP INT,
	ID_PAC NVARCHAR(36),
	IDCASE INT,
	ID_C UNIQUEIDENTIFIER,
	USL_OK TINYINT,
	VIDPOM SMALLINT,
	NPR_MO NVARCHAR(6),
	EXTR TINYINT,
	LPU NVARCHAR(6),
	PROFIL SMALLINT,
	DET TINYINT,
	NHISTORY NVARCHAR(50),
	DATE_1 DATE,
	DATE_2 DATE,
	DS0 NVARCHAR(10),
	DS1 NVARCHAR(10),
	DS2 NVARCHAR(10),
	CODE_MES1 NVARCHAR(16),
	RSLT SMALLINT,
	ISHOD SMALLINT,
	PRVS BIGINT,
	OS_SLUCH TINYINT,
	IDSP TINYINT,
	ED_COL DECIMAL(5, 2),
	TARIF DECIMAL(15, 2),
	SUMV DECIMAL(15, 2),
	--REFREASON tinyint, 
	SANK_MEK DECIMAL(15, 2),
	SANK_MEE DECIMAL(15, 2),
	SANK_EKMP DECIMAL(15, 2),
	COMENTSL NVARCHAR(250)
)
					 
CREATE TABLE #t6
(
	IDCASE INT,
	ID_C UNIQUEIDENTIFIER,
	IDSERV INT,
	ID_U UNIQUEIDENTIFIER,
	LPU NVARCHAR(6),
	PROFIL SMALLINT,
	DET TINYINT,
	DATE_IN DATE,
	DATE_OUT DATE,
	DS NVARCHAR(10),
	CODE_USL NVARCHAR(16),
	KOL_USL DECIMAL(6, 2),
	TARIF DECIMAL(15, 2),
	SUMV_USL DECIMAL(15, 2),
	PRVS BIGINT,
	COMENTU NVARCHAR(250)
)
					   
DECLARE @t7 AS TABLE([VERSION] NCHAR(5),DATA DATE,[FILENAME] NCHAR(26),FILENAME1 NCHAR(26))

CREATE TABLE #t8
(
	ID_PAC NVARCHAR(36),
	FAM NVARCHAR(40),
	IM NVARCHAR(40),
	OT NVARCHAR(40),
	W TINYINT,
	DR DATE,
	FAM_P NVARCHAR(40),
	IM_P NVARCHAR(40),
	OT_P NVARCHAR(40),
	W_P TINYINT,
	DR_P DATE,
	MR NVARCHAR(100),
	DOCTYPE NCHAR(2),
	DOCSER NCHAR(10),
	DOCNUM NCHAR(20),
	SNILS NCHAR(14),
	OKATOG NCHAR(11),
	OKATOP NCHAR(11),
	COMENTP NVARCHAR(250)
)

DECLARE @tempID AS TABLE(id INT, ID_PAC NVARCHAR(36),N_ZAP INT)

DECLARE @tableId AS TABLE(id INT,ID_PAC NVARCHAR(36))
---------------------------------------------------------------------
EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

INSERT @t1
SELECT [VERSION],REPLACE(DATA,'-',''),[FILENAME]
FROM OPENXML (@idoc, 'ZL_LIST/ZGLV',2)
	WITH(
			[VERSION] NCHAR(5) './VERSION',
			[DATA] NCHAR(10) './DATA',
			[FILENAME] NCHAR(26) './FILENAME'
		)
	
INSERT @t2
SELECT CODE,CODE_MO,[YEAR],[MONTH],NSCHET,REPLACE(DSCHET,'-',''),PLAT,SUMMAV,COMENTS
FROM OPENXML (@idoc, 'ZL_LIST/SCHET',2)
	WITH 
	(	
		CODE INT './CODE',
		CODE_MO INT './CODE_MO',
		[YEAR]	SMALLINT './YEAR',
		[MONTH] TINYINT './MONTH',
		NSCHET NVARCHAR(15) './NSCHET',
		DSCHET NCHAR(10) './DSCHET',
		PLAT NVARCHAR(5) './PLAT',
		SUMMAV DECIMAL(15,2) './SUMMAV',
		COMENTS NVARCHAR(250) './COMENTS'		
	)

INSERT #t3
SELECT N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,SMO,SMO_OK,NOVOR
FROM OPENXML (@idoc, 'ZL_LIST/ZAP',2)
	WITH(
			N_ZAP INT './N_ZAP',
			PR_NOV TINYINT './PR_NOV',
			ID_PAC NVARCHAR(36)'./PACIENT/ID_PAC',
			VPOLIS TINYINT './PACIENT/VPOLIS',
			SPOLIS NCHAR(10) './PACIENT/SPOLIS',
			NPOLIS NCHAR(20) './PACIENT/NPOLIS',
			SMO NCHAR(5) './PACIENT/SMO',
			SMO_OK NCHAR(5) './PACIENT/SMO_OK',
			NOVOR NCHAR(9) './PACIENT/NOVOR'
		)

INSERT #t5
SELECT N_ZAP,ID_PAC,IDCASE,ID_C,USL_OK,VIDPOM,NPR_MO,EXTR,LPU,PROFIL,DET,NHISTORY,REPLACE(DATE_1,'-',''),REPLACE(DATE_2,'-',''),DS0,DS1,DS2,CODE_MES1,RSLT,ISHOD,
		PRVS,OS_SLUCH,IDSP,ED_COL,TARIF,SUMV,SANK_MEK,SANK_MEE,SANK_EKMP,COMENTSL
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH',3)
	WITH(	
			N_ZAP INT '../N_ZAP',
			ID_PAC NVARCHAR(36) '../PACIENT/ID_PAC',
			IDCASE INT ,
			ID_C UNIQUEIDENTIFIER,
			USL_OK TINYINT ,
			VIDPOM SMALLINT,
			NPR_MO NCHAR(6),
			EXTR TINYINT ,
			LPU NCHAR(6) ,
			PROFIL SMALLINT,
			DET TINYINT ,
			NHISTORY NVARCHAR(50) ,
			DATE_1 NCHAR(10) ,
			DATE_2 NCHAR(10) ,
			DS0 NCHAR(10) ,
			DS1 NCHAR(10) ,
			DS2 NCHAR(10) ,
			CODE_MES1 NCHAR(16) ,			
			RSLT SMALLINT ,
			ISHOD SMALLINT,
			PRVS BIGINT ,
			OS_SLUCH TINYINT ,
			IDSP TINYINT ,
			ED_COL DECIMAL(5,2) ,
			TARIF DECIMAL(15,2) ,	
			SUMV DECIMAL(15,2) ,	
			SANK_MEK DECIMAL(15,2),
			SANK_MEE DECIMAL(15,2),
			SANK_EKMP DECIMAL(15,2),
			COMENTSL NVARCHAR(250) 
		)

INSERT #t6
SELECT IDCASE,ID_C,IDSERV,ID_U,LPU,PROFIL,DET,REPLACE(DATE_IN,'-',''),REPLACE(DATE_OUT,'-',''),DS,CODE_USL,KOL_USL,TARIF,SUMV_USL,PRVS,COMENTU
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH/USL',3)
	WITH(
			IDCASE INT '../IDCASE',
			ID_C UNIQUEIDENTIFIER '../ID_C',
			IDSERV INT ,
			ID_U UNIQUEIDENTIFIER ,
			LPU NCHAR(6) ,
			PROFIL SMALLINT,
			DET TINYINT ,
			DATE_IN NCHAR(10),
			DATE_OUT NCHAR(10),
			DS NCHAR(10),
			CODE_USL NCHAR(16),
			KOL_USL DECIMAL(6,2),
			TARIF DECIMAL(15,2) ,	
			SUMV_USL DECIMAL(15,2),	
			PRVS BIGINT ,
			COMENTU NVARCHAR(250) 
		)

EXEC sp_xml_removedocument @idoc

---------------Patient----------------------------------
EXEC sp_xml_preparedocument @ipatient OUTPUT, @patient

INSERT @t7
SELECT [VERSION],REPLACE(DATA,'-',''),[FILENAME],FILENAME1
FROM OPENXML (@ipatient, 'PERS_LIST/ZGLV',2)
	WITH(
			[VERSION] NCHAR(5) './VERSION',
			[DATA] NCHAR(10) './DATA',
			[FILENAME] NCHAR(26) './FILENAME',
			[FILENAME1] NCHAR(26) './FILENAME1'
		)
		
INSERT #t8
SELECT ID_PAC,FAM,IM,OT,W,REPLACE(DR,'-',''),FAM_P,IM_P,OT_P,W_P,REPLACE(DR_P,'-',''),MR,DOCTYPE,DOCSER,DOCNUM,SNILS,OKATOG,OKATOP,COMENTP
FROM OPENXML (@ipatient, 'PERS_LIST/PERS',2)
	WITH(
			ID_PAC NVARCHAR(36),
			FAM NVARCHAR(40),
			IM NVARCHAR(40),
			OT NVARCHAR(40),
			W TINYINT,
			DR NCHAR(10),
			FAM_P NVARCHAR(40),
			IM_P NVARCHAR(40),
			OT_P NVARCHAR(40),
			W_P TINYINT,
			DR_P NCHAR(10),
			MR NVARCHAR(100),
			DOCTYPE NCHAR(2),
			DOCSER NCHAR(10),
			DOCNUM NCHAR(20),
			SNILS NCHAR(14),
			OKATOG NCHAR(11),
			OKATOP NCHAR(11),
			COMENTP NVARCHAR(250)
		)		
EXEC sp_xml_removedocument @ipatient
--select * from @t7
--select * from #t8

DECLARE @account VARCHAR(15),
		@codeMO CHAR(6),
		@month TINYINT,
		@year SMALLINT
---26.12.2011----------------------------------------------
SELECT @codeMO=(SUBSTRING(@fileName,(3),(6))) 
DECLARE @et AS TABLE(errorId SMALLINT,id TINYINT)
----------------------------------------------------------
--DATA
--проверка CODE_MO в теге SCHET
DECLARE @mcodeFile CHAR(6),
		@mcodeSPR CHAR(6)

SELECT @mcodeFile=CODE_MO FROM @t2
	
	SELECT @mcodeSPR=mcod FROM dbo.vw_sprT001 WHERE CodeM=@codeMO
	
IF(@mcodeFile!=@mcodeSPR)
BEGIN
		INSERT @et VALUES(904,5)
END
----------------
--NSCHET
IF NOT EXISTS(SELECT * FROM @et)
BEGIN
	SELECT @account=NSCHET,@year=[YEAR],@month=[MONTH] FROM @t2
	--проверяем счет на соответствие ему реестра СП и ТК. добавить проверку счета на уникальность
	
	IF NOT EXISTS(SELECT * FROM dbo.fn_CheckAccountExistSPTK(@account,@codeMO,@month,@year))
	BEGIN	
		INSERT @et VALUES(585,9)
	END
	IF EXISTS(SELECT * FROM dbo.fn_CheckAccountExistInDB(@account,@codeMO,@month,@year))
	BEGIN	
		INSERT @et VALUES(586,9)
	END
	--признак модернизационного счета должен быть латиницей
	IF EXISTS(SELECT * FROM @t2 WHERE NSCHET LIKE '%М') 
	BEGIN
		INSERT @et VALUES(585,10)
	END
END
	
--DSCHET
IF NOT EXISTS(SELECT * FROM @et)
BEGIN	
	DECLARE @dateAccount DATE
	DECLARE @dateStart DATE
	
	--проверка на дату счета и дата окончания случая должна принадлежать отчетному месяцу
	SELECT @dateAccount=DSCHET, @dateStart=CAST([YEAR] AS CHAR(4))+RIGHT('0'+CAST([MONTH] AS VARCHAR(2)),2)+'01' FROM @t2
	
	IF EXISTS(SELECT * FROM #t5 WHERE DATE_2>@dateAccount AND DATE_2<@dateStart)
	BEGIN
		INSERT @et VALUES(587,16)
	END	
END
--SUMMAV
IF NOT EXISTS(SELECT * FROM @et)
BEGIN
	--производим проверку суммы всех случаев и суммы счета	
	IF(SELECT SUM(t.SUMV) FROM #t5 t)!=(SELECT t.SUMMAV FROM @t2 t)
	BEGIN
		INSERT @et VALUES(51,14)
	END
END
--N_ZAP
IF NOT EXISTS(SELECT * FROM @et)
BEGIN
	
	IF EXISTS(SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY t.N_ZAP ASC) AS id,t.N_ZAP FROM #t3 t) t WHERE id<>N_ZAP)
	BEGIN
		INSERT @et VALUES(530,14)
	END
END
--PR_NOV
IF NOT EXISTS(SELECT * FROM @et)
BEGIN
	
	IF EXISTS(SELECT * FROM #t3 t WHERE t.PR_NOV<>0)
	BEGIN
		INSERT @et VALUES(531,14)
	END
END
--ID_PAC
IF NOT EXISTS(SELECT * FROM @et)
BEGIN
	IF EXISTS(SELECT * 
			  FROM #t3 t LEFT JOIN #t8 p ON
					t.ID_PAC=p.ID_PAC
			  WHERE p.ID_PAC IS NULL)
	BEGIN
		INSERT @et VALUES(532,14)
	END
	
	IF EXISTS(SELECT * 
			  FROM #t3 t RIGHT JOIN #t8 p ON
					t.ID_PAC=p.ID_PAC
			  WHERE t.ID_PAC IS NULL)
	BEGIN
		INSERT @et VALUES(532,14)
	END
END
DECLARE @number INT,
		@property TINYINT,
		@smo CHAR(5)
SELECT @number=dbo.fn_NumberRegister(@account),@smo=dbo.fn_PrefixNumberRegister(@account),@property=dbo.fn_PropertyNumberRegister(@account)
--Поиск некорректных данных с ошибкой 588 в ZAP
IF NOT EXISTS(SELECT * FROM @et)
BEGIN
	
	DECLARE @zapRC INT,
			@zapA INT
	
	--изменения от 23.03.2012

	--Изменения от 14.06.2012 новая ошибка номер 17
	-- проверка данных из тэга ZAP
	
	SELECT @zapA=COUNT(*) FROM #t3
	
	SELECT @zapRC=COUNT(*)
	FROM (
			SELECT DISTINCT CAST(r1.ID_Patient AS NVARCHAR(36)) AS ID_Patient,p.rf_idF008,p.SeriaPolis,p.NumberPolis,p.rf_idSMO,p.OKATO
					,CAST(r1.NewBorn AS NVARCHAR(9)) AS NewBorn 
			FROM RegisterCases.dbo.t_FileBack f INNER JOIN RegisterCases.dbo.t_RegisterCaseBack a ON 
							f.id=a.rf_idFilesBack
							AND f.CodeM=@codeMO
							AND a.NumberRegister=@number
							AND a.PropertyNumberRegister=@property
												INNER JOIN RegisterCases.dbo.t_RecordCaseBack r ON
							a.id=r.rf_idRegisterCaseBack
							AND r.TypePay=1
												INNER JOIN RegisterCases.dbo.t_RecordCase r1 ON
							r.rf_idRecordCase=r1.id
												INNER JOIN RegisterCases.dbo.t_PatientBack p ON
							r.id=p.rf_idRecordCaseBack
							AND p.rf_idSMO=@smo
		  ) r INNER JOIN #t3 t ON
					r.ID_Patient=t.ID_PAC
					AND r.rf_idF008=t.VPOLIS
					AND COALESCE(r.SeriaPolis,'')=COALESCE(t.SPOLIS,'')
					AND r.NumberPolis=t.NPOLIS
					AND r.rf_idSMO=t.SMO
					AND r.OKATO=COALESCE(t.SMO_OK,'18000')
					AND r.NewBorn=t.NOVOR
		
	
	
	IF(@zapRC-@zapA)<>0	
	BEGIN
		INSERT @et VALUES(588,17)
	END	
END

--Поиск некорректных данных с ошибкой 588 в SLUCH
IF NOT EXISTS(SELECT * FROM @et)
BEGIN
DECLARE @caseRC INT,
		@caseA INT
	---Изменения от 23.03.2012 заменил функцию на ХП
	---проверяем совпадение по случаям предоставленным МУ и то что должны предоставить
	--считаем количество строк по случаем в файле
SELECT @caseA=COUNT(*)  FROM #t5 t	

CREATE TABLE #CASE
(
	ID_Patient VARCHAR(36) NOT NULL,
	GUID_Case UNIQUEIDENTIFIER NOT NULL,
	rf_idV006 TINYINT NULL,
	rf_idV008 SMALLINT NULL,
	rf_idDirectMO CHAR(6) NULL,
	HopitalisationType TINYINT NULL,
	rf_idMO CHAR(6) NOT NULL,
	rf_idV002 SMALLINT NOT NULL,
	IsChildTariff BIT NOT NULL,
	NumberHistoryCase NVARCHAR(50) NOT NULL,
	DateBegin DATE NOT NULL,
	DateEnd DATE NOT NULL,
	DS0 CHAR(10) NULL,
	DS1 CHAR(10) NULL,
	DS2 CHAR(10) NULL,
	MES CHAR(16) NULL,
	rf_idV009 SMALLINT NOT NULL,
	rf_idV012 SMALLINT NOT NULL,
	rf_idV004 INT NOT NULL,
	IsSpecialCase TINYINT NULL,
	rf_idV010 TINYINT NOT NULL,
	Quantity DECIMAL(5, 2) NULL,
	Tariff DECIMAL(15, 2) NULL,
	AmountPayment DECIMAL(15, 2) NOT NULL,
	SANK_MEK DECIMAL(15, 2) NULL,
	SANK_MEE DECIMAL(15, 2) NULL,
	SANK_EKMP DECIMAL(15, 2) NULL
)
IF OBJECT_ID('tempDB..#case',N'U') IS NOT NULL
BEGIN
	EXEC usp_GetCaseFromRegisterCaseDB @account,@codeMO,@month,@year
END
												
	SELECT @caseRC=COUNT(DISTINCT t.GUID_Case)
	FROM #CASE t INNER JOIN #t5 t1 ON
			ID_PAC=UPPER(t.ID_Patient) 
			AND ID_C=t.GUID_Case
			AND USL_OK=t.rf_idV006 
			AND VIDPOM=t.rf_idV008
			AND ISNULL(NPR_MO,0)=ISNULL(t.rf_idDirectMO,0)
			AND ISNULL(EXTR,0)=ISNULL(t.HopitalisationType,0)
			AND LPU=t.rf_idMO
			AND PROFIL=t.rf_idV002
			AND DET =t.IsChildTariff
			AND NHISTORY =NumberHistoryCase
			AND DATE_1=DateBegin
			AND DATE_2=DateEnd
			AND ISNULL(t1.DS0,0)=ISNULL(t.DS0,0)
			AND t1.DS1=t.DS1
			AND ISNULL(t1.DS2,2)=ISNULL(t.DS2,2)
			AND ISNULL(CODE_MES1,0)=ISNULL(t.MES,0) 
			AND RSLT=t.rf_idV009  
			AND ISHOD=t.rf_idV012  
			AND PRVS=t.rf_idV004  
			AND ISNULL(OS_SLUCH,0)=ISNULL(t.IsSpecialCase,0)
			AND IDSP=t.rf_idV010  
			AND ISNULL(ED_COL,0)=ISNULL(t.Quantity,0) 
			AND ISNULL(TARIF ,0)=ISNULL(t.Tariff,0) 
	
	
	IF(ISNULL(@caseRC,0)-ISNULL(@caseA,0))<>0
	BEGIN
		INSERT @et VALUES(588,11)
	END
END
--Поиск некорректных данных с ошибкой 588 в USL
IF NOT EXISTS(SELECT * FROM @et)
BEGIN
DECLARE @meduslugiRC INT,
		@meduslugiA INT

	SELECT @meduslugiA=COUNT(*) FROM #t6 t
													
	SELECT @meduslugiRC=COUNT(DISTINCT t0.GUID_MU)
	FROM dbo.fn_GetMeduslugiFromRegisterCaseDB(@account,@codeMO,@month,@year) t0 INNER JOIN #t6 t ON
			ID_C=t0.GUID_Case
			AND ID_U= GUID_MU
			AND LPU=rf_idMO
			AND PROFIL=rf_idV002
			AND DET =IsChildTariff
			AND DATE_IN =DateHelpBegin
			AND DATE_OUT =DateHelpEnd
			AND RTRIM(DS) =RTRIM(DiagnosisCode)
			AND RTRIM(CODE_USL)=RTRIM(MUCode)
			AND KOL_USL= Quantity
			AND TARIF=Price
			AND SUMV_USL =TotalPrice
			AND PRVS=rf_idV004
	
	
	IF(ISNULL(@meduslugiRC,0)-ISNULL(@meduslugiA,0))<>0
	BEGIN
		INSERT @et VALUES(588,12)
	END
END

--проверка на кооректное выставление мед.услуг в случае
IF NOT EXISTS(SELECT * FROM @et)
BEGIN
	IF EXISTS(	
				SELECT c.ID_C,c.SUMV
				FROM #t5 c INNER JOIN #t6 m ON 
						c.ID_C=m.ID_C
						AND c.IDCASE=m.IDCASE
				WHERE c.CODE_MES1 IS NULL
				GROUP BY c.ID_C,c.SUMV
				HAVING c.SUMV<>CAST(SUM(m.KOL_USL*m.TARIF) AS DECIMAL(15,2))
			  )	
	BEGIN
			INSERT @et VALUES(588,21)
	END
END

IF NOT EXISTS(SELECT * FROM @et)
BEGIN
---------поиск случаев без медуслуг
	IF EXISTS(	
				SELECT c.* 
				FROM #t5 c LEFT JOIN #t6 m ON 
						c.ID_C=m.ID_C
						AND c.IDCASE=m.IDCASE
				WHERE c.CODE_MES1 IS NULL AND m.ID_U IS NULL
			  )	
	BEGIN
		INSERT @et VALUES(588,21)
	END
END
---------------------------------Проверка данных из файла L----------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM @et)
BEGIN
	DECLARE @persA INT,
			@persRC INT,	
			@idf INT
			
	SELECT TOP 1 @idf=f.rf_idFiles
	FROM RegisterCases.dbo.t_FileBack f INNER JOIN RegisterCases.dbo.t_RegisterCaseBack a ON 
				f.id=a.rf_idFilesBack
				AND f.CodeM=@codeMO
				AND a.NumberRegister=@number
				AND a.PropertyNumberRegister=@property
				
	SELECT @persRC=COUNT(*) 
	FROM(
			SELECT DISTINCT r1.ID_Patient,rp.Fam,rp.Im,rp.Ot,rp.rf_idV005 AS W,rp.BirthDay AS DR,ra.Fam AS Fam_P, ra.Im AS IM_P, ra.Ot AS Ot_P,ra.rf_idV005 AS W_P,
				  ra.BirthDay AS DR_P, rp.BirthPlace AS MR, doc.rf_idDocumentType AS DOCTYPE, doc.SeriaDocument AS DOCSER, doc.NumberDocument AS DOCNUM, 
				  doc.SNILS, doc.OKATO AS OKATOG, doc.OKATO_Place AS OKATOP
			FROM RegisterCases.dbo.t_FileBack f INNER JOIN RegisterCases.dbo.t_RegisterCaseBack a ON 
				f.id=a.rf_idFilesBack
				AND f.rf_idFiles=@idF			
									INNER JOIN RegisterCases.dbo.t_RecordCaseBack r ON
				a.id=r.rf_idRegisterCaseBack
				AND r.TypePay=1
									INNER JOIN RegisterCases.dbo.t_RecordCase r1 ON
				r.rf_idRecordCase=r1.id
									INNER JOIN RegisterCases.dbo.t_PatientBack p ON
				r.id=p.rf_idRecordCaseBack
				AND p.rf_idSMO=@smo
									INNER JOIN RegisterCases.dbo.t_RefRegisterPatientRecordCase rf ON				
				r1.id=rf.rf_idRecordCase
									INNER JOIN RegisterCases.dbo.t_RegisterPatient rp ON
				rf.rf_idRegisterPatient=rp.id
				AND rp.rf_idFiles=@idF
									LEFT JOIN RegisterCases.dbo.t_RegisterPatientAttendant ra ON
				rp.id=ra.rf_idRegisterPatient
									LEFT JOIN RegisterCases.dbo.t_RegisterPatientDocument doc ON
				rp.id=doc.rf_idRegisterPatient
		) t INNER JOIN #t8 t1 ON
			t.ID_Patient=t1.ID_PAC
			AND t.FAM =t1.FAM 
			AND t.IM =t1.IM 
			AND t.OT=t1.OT 
			AND t.W =t1.W 
			AND t.DR =t1.DR 
			AND ISNULL(t.FAM_P,'')=ISNULL(t1.FAM_P,'')
			AND ISNULL(t.FAM_P,'')=ISNULL(t1.FAM_P,'')
			AND ISNULL(t.OT_P,'') =ISNULL(t1.OT_P,'') 
			AND ISNULL(t.W_P,'') =ISNULL(t1.W_P,'') 
			AND ISNULL(t.DR_P,'') =ISNULL(t1.DR_P,'') 
			AND ISNULL(t.MR,'') =ISNULL(t1.MR,'') 
			AND ISNULL(t.DOCTYPE,'')=ISNULL(t1.DOCTYPE,'')
			AND ISNULL(t.DOCSER,'') =ISNULL(t1.DOCSER,'') 
			AND ISNULL(t.DOCNUM,'') =ISNULL(t1.DOCNUM,'') 
			AND ISNULL(t.SNILS,'') =ISNULL(t1.SNILS,'') 
			AND ISNULL(t.OKATOG,'') =ISNULL(t1.OKATOG,'') 
			AND ISNULL(t.OKATOP,'') =ISNULL(t1.OKATOP,'') 

	SELECT @persA=COUNT(*) FROM #t8

	IF(@persRC-@persRC)<>0	
	BEGIN
		INSERT @et VALUES(588,17)
	END	
END
-------------------------------------------------------------------------------------------------------

--возвращаем @idFile и 0 или 1 отличное от нуля(0- ошибок нету,  1-ошибки есть)
IF (SELECT COUNT(*) FROM @et)>0
BEGIN
	INSERT t_FileError([FileName]) VALUES(@fileName)
	
	SET @idFile=SCOPE_IDENTITY()
	
	INSERT t_Errors(rf_idFileError,ErrorNumber,rf_sprErrorAccount) SELECT DISTINCT @idFile,errorId,id FROM @et	
END
ELSE
BEGIN
--раскладываем данные по таблица в базе счета

	BEGIN TRANSACTION
	BEGIN TRY
	------Insert into RegisterCase's tables------------------------------
		
	INSERT t_File(DateRegistration,FileVersion,DateCreate,FileNameHR,FileNameLR,FileZIP)
	SELECT GETDATE(),[VERSION],DATA,FILENAME1,[FILENAME],@file  FROM @t7
	SELECT @idFile=SCOPE_IDENTITY()
	
	IF @fileKey IS NOT NULL
	BEGIN
		INSERT t_FileKey(rf_idFiles,FileNameKey,FileKey) VALUES(@idFile,@fileName,@fileKey)
	END

	INSERT t_RegistersAccounts(rf_idFiles,idRecord,rf_idMO,ReportYear,ReportMonth,NumberRegister,PrefixNumberRegister,PropertyNumberRegister,
								DateRegister,rf_idSMO,AmountPayment,Comments,Letter)
	SELECT @idFile,CODE,CODE_MO,[YEAR],[MONTH],dbo.fn_NumberRegister(NSCHET),dbo.fn_PrefixNumberRegister(NSCHET),dbo.fn_PropertyNumberRegister(NSCHET),
			DSCHET,PLAT,SUMMAV,COMENTS,dbo.fn_LetterNumberRegister(NSCHET)
	FROM @t2
	SELECT @id=SCOPE_IDENTITY()
	
	INSERT t_RecordCasePatient(rf_idRegistersAccounts,idRecord,IsNew,ID_Patient,rf_idF008,SeriaPolis,NumberPolis,NewBorn)
	OUTPUT inserted.id,inserted.ID_Patient,inserted.idRecord INTO @tempID
	SELECT @id,N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,NOVOR FROM #t3
	
	INSERT t_PatientSMO(rf_idRecordCasePatient,rf_idSMO,OKATO)
	SELECT t2.id,t1.SMO,t1.SMO_OK
	FROM #t3 t1 INNER JOIN @tempID t2 ON
				t1.ID_PAC=t2.ID_PAC
	WHERE t1.SMO IS NOT NULL
	GROUP BY t2.id,t1.SMO,t1.SMO_OK
	
	DECLARE @tmpCase AS TABLE(id INT,idRecord INT,GUID_CASE UNIQUEIDENTIFIER)
	
	INSERT t_Case(rf_idRecordCasePatient, idRecordCase, GUID_Case, rf_idV006, rf_idV008, rf_idDirectMO, HopitalisationType, rf_idMO, rf_idV002, IsChildTariff, 
				NumberHistoryCase, DateBegin, DateEnd, rf_idV009, rf_idV012, rf_idV004, IsSpecialCase, rf_idV010, AmountPayment, Comments,Age)
	OUTPUT inserted.id,inserted.idRecordCase,inserted.GUID_Case INTO @tmpCase
	SELECT t2.id,t1.IDCASE,t1.ID_C, t1.USL_OK,t1.VIDPOM, t1.NPR_MO,t1.EXTR,t1.LPU,t1.PROFIL,t1.DET,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.RSLT,t1.ISHOD,
			t1.PRVS,t1.OS_SLUCH,t1.IDSP,t1.SUMV,t1.COMENTSL,dbo.fn_FullYear(t3.DR,t1.DATE_1)
	FROM #t5 t1 INNER JOIN @tempID t2 ON
			t1.N_ZAP=t2.N_ZAP AND
			t1.ID_PAC=t2.ID_PAC
				LEFT JOIN #t8 t3 ON
			t1.ID_PAC=t3.ID_PAC
	GROUP BY t2.id,t1.IDCASE,t1.ID_C, t1.USL_OK,t1.VIDPOM, t1.NPR_MO,t1.EXTR,t1.LPU,t1.PROFIL,t1.DET,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.RSLT,t1.ISHOD,
			t1.PRVS,t1.OS_SLUCH,t1.IDSP,t1.SUMV,t1.COMENTSL,dbo.fn_FullYear(t3.DR,t1.DATE_1)
	
	------------------------------------------------------------------------------------------------------------------
	INSERT t_Diagnosis(DiagnosisCode,rf_idCase,TypeDiagnosis)
	SELECT DS0,c.id,2 
	FROM @tmpCase c INNER JOIN #t5 t1 ON
			c.GUID_Case=t1.ID_C
			AND c.idRecord=t1.IDCASE
	WHERE DS0 IS NOT NULL
	UNION ALL
	SELECT DS1,c.id,1 
	FROM @tmpCase c INNER JOIN #t5 t1 ON
			c.GUID_Case=t1.ID_C
			AND c.idRecord=t1.IDCASE
	UNION ALL
	SELECT DS2,c.id,3 
	FROM @tmpCase c INNER JOIN #t5 t1 ON
			c.GUID_Case=t1.ID_C	
			AND c.idRecord=t1.IDCASE	
	WHERE DS2 IS NOT NULL
	--------------------------------------------------------------------------------------------------------------------

	INSERT t_MES(MES,rf_idCase,TypeMES,Quantity,Tariff)
	SELECT t1.CODE_MES1,c.id,1,t1.ED_COL,t1.TARIF
	FROM @tmpCase c INNER JOIN #t5 t1 ON
			c.GUID_Case=t1.ID_C
			AND c.idRecord=t1.IDCASE
	WHERE t1.CODE_MES1 IS NOT NULL
	GROUP BY t1.CODE_MES1,c.id,t1.ED_COL,t1.TARIF

	----------------------------------------------------------------------------------------------------------------------
	INSERT t_FinancialSanctions(rf_idCase,Amount,TypeSanction)
	SELECT c.id,t1.SANK_MEK,1
	FROM @tmpCase c INNER JOIN #t5 t1 ON
			c.GUID_Case=t1.ID_C
			AND c.idRecord=t1.IDCASE
	WHERE t1.SANK_MEK IS NOT NULL
	UNION ALL
	SELECT c.id,t1.SANK_MEE,2
	FROM @tmpCase c INNER JOIN #t5 t1 ON
			c.GUID_Case=t1.ID_C
			AND c.idRecord=t1.IDCASE
	WHERE t1.SANK_MEE IS NOT NULL
	UNION ALL
	SELECT c.id,t1.SANK_EKMP,3
	FROM @tmpCase c INNER JOIN #t5 t1 ON
			c.GUID_Case=t1.ID_C
			AND c.idRecord=t1.IDCASE
	WHERE t1.SANK_EKMP IS NOT NULL

	-------------------------------------------------------------------------------------------------------------------------
--добавить обработку хирургических операций с помощью конструкции if exists
	
	INSERT t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO, rf_idV002, IsChildTariff, DateHelpBegin, DateHelpEnd, DiagnosisCode,MUGroupCode,MUUnGroupCode
						,MUCode, Quantity, Price, TotalPrice, rf_idV004, Comments)
	SELECT c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,mu.MUGroupCode,mu.MUUnGroupCode,mu.MUCode
			,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU
	FROM #t6 t1 INNER JOIN @tmpCase c ON
				t1.ID_C=c.GUID_Case
				AND t1.IDCASE=c.idRecord	
				INNER JOIN vw_sprMU mu ON
			t1.CODE_USL=mu.MU
	WHERE t1.ID_U IS NOT NULL
	GROUP BY c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,mu.MUGroupCode,mu.MUUnGroupCode,mu.MUCode
			,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU
	--вставка хирургического вмешательства
	INSERT t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO, rf_idV002, IsChildTariff, DateHelpBegin, DateHelpEnd, DiagnosisCode,MUSurgery, Quantity
						,Price, TotalPrice, rf_idV004, Comments,MUGroupCode,MUUnGroupCode,MUCode)
	SELECT c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,mu.IDRB
			,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU,0,0,0
	FROM #t6 t1 INNER JOIN @tmpCase c ON
				t1.ID_C=c.GUID_Case
				AND t1.IDCASE=c.idRecord	
				INNER JOIN vw_V001 mu ON
			t1.CODE_USL=mu.IDRB
	WHERE t1.ID_U IS NOT NULL
	GROUP BY c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,mu.IDRB,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU
	----------------------------------------------------------------------------------------------------------------------

	INSERT t_RegisterPatient(rf_idFiles, ID_Patient, Fam, Im, Ot, rf_idV005, BirthDay, BirthPlace,rf_idRecordCase)
		OUTPUT inserted.id,inserted.ID_Patient INTO @tableId
	SELECT @idFile,t1.ID_PAC,t1.FAM,t1.IM,CASE WHEN t1.OT='НЕТ' THEN NULL ELSE t1.OT END,t1.W,t1.DR,t1.MR,t2.id
	FROM #t8 t1 LEFT JOIN @tempID t2 ON
					t1.ID_PAC=t2.ID_PAC
	GROUP BY t1.ID_PAC,t1.FAM,t1.IM,CASE WHEN t1.OT='НЕТ' THEN NULL ELSE t1.OT END,t1.W,t1.DR,t1.MR,t2.id

	INSERT t_RegisterPatientDocument(rf_idRegisterPatient, rf_idDocumentType, SeriaDocument, NumberDocument, SNILS, OKATO, OKATO_Place, Comments)
	SELECT t2.id,t1.DOCTYPE,t1.DOCSER,t1.DOCNUM,t1.SNILS,t1.OKATOG,t1.OKATOP,t1.COMENTP
	FROM #t8 t1 INNER JOIN @tableId t2 ON
			t1.ID_PAC=t2.ID_PAC
	WHERE (t1.DOCTYPE IS NOT NULL) OR (t1.DOCSER IS NOT NULL) OR (t1.DOCNUM IS NOT NULL)

	INSERT t_RegisterPatientAttendant(rf_idRegisterPatient, Fam, Im, Ot, rf_idV005, BirthDay)
	SELECT t2.id,t1.FAM_P,t1.IM_P,t1.OT_P,t1.W_P,t1.DR_P
	FROM #t8 t1 INNER JOIN @tableId t2 ON
			t1.ID_PAC=t2.ID_PAC
	WHERE (t1.FAM_P IS NOT NULL) AND (t1.IM_P IS NOT NULL) AND (t1.W_P IS NOT NULL) AND (t1.DR_P IS NOT NULL)
	
	
	END TRY
	BEGIN CATCH
	IF @@TRANCOUNT>0
		SELECT ERROR_MESSAGE(),ERROR_LINE()
		ROLLBACK TRANSACTION
	END CATCH
	IF @@TRANCOUNT>0
		COMMIT TRANSACTION
END

IF EXISTS(SELECT * FROM @et)
	SELECT @idFile,1	
ELSE 
	SELECT @idFile,0
--------------------------------------------
DROP TABLE #t3
DROP TABLE #t5
DROP TABLE #t6

GO