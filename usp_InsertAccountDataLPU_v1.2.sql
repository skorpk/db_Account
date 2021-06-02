use AccountOMS
go
if OBJECT_ID('usp_InsertAccountDataLPU',N'P') is not null
drop proc usp_InsertAccountDataLPU
go

create proc [dbo].[usp_InsertAccountDataLPU]
			@doc xml,
			@patient xml,
			@file varbinary(max),
			@fileName varchar(26),
			@fileKey varbinary(max)=null--файл цифровой подписи
AS
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

DECLARE @idoc int,
		@ipatient int,
		@id int,
		@idFile int--,
		--@error tinyint=0

---create tempory table----------------------------------------------

declare @t1 as table([VERSION] char(5),DATA date,[FILENAME] varchar(26))

declare @t2 as table(
					 CODE int,
					 CODE_MO int,
					 [YEAR] smallint,
					 [MONTH] tinyint,
					 NSCHET nvarchar(15),
					 DSCHET date,
					 PLAT nvarchar(5),
					 SUMMAV decimal(15, 2),
					 COMENTS nvarchar(250)
					 ) 

create table #t3 
(
	N_ZAP int,
	PR_NOV tinyint,
	ID_PAC nvarchar(36),
	VPOLIS tinyint,
	SPOLIS nchar(10),
	NPOLIS nchar(20),
	SMO nchar(5),
	SMO_OK nchar(5),
	SMO_NAM nvarchar(100),
	NOVOR nchar(9),
	MO_PR nchar(6),
	VNOV_D smallint	
)


create table #t5 
(
	N_ZAP int,
	ID_PAC nvarchar(36),
	IDCASE int,
	ID_C uniqueidentifier,
	USL_OK tinyint,
	VIDPOM smallint,
	FOR_POM tinyint,
	VID_HMP varchar(9),
	METOD_HMP SMALLINT, --13.01.2014
	NPR_MO nvarchar(6),
	EXTR tinyint,
	LPU nvarchar(6),
	PROFIL smallint,
	DET tinyint,
	NHISTORY nvarchar(50),
	DATE_1 date,
	DATE_2 date,
	DS0 nvarchar(10),
	DS1 nvarchar(10),
	--DS2 nvarchar(10),
	CODE_MES1 nvarchar(16),
	RSLT smallint,
	ISHOD smallint,
	PRVS bigint,
	OS_SLUCH tinyint,
	IDSP tinyint,
	ED_COL decimal(5, 2),
	TARIF decimal(15, 2),
	SUMV decimal(15, 2),
	--REFREASON tinyint, 
	SANK_MEK decimal(15, 2),
	SANK_MEE decimal(15, 2),
	SANK_EKMP decimal(15, 2),
	COMENTSL nvarchar(250),
	F_SP TINYINT,
	IDDOCT VARCHAR(25)
)
		
CREATE TABLE #tDS(IDCASE int,ID_C uniqueidentifier,DS varchar(10), TypeDiagnosis tinyint)

CREATE TABLE #tBW(IDCASE int,ID_C uniqueidentifier, BirthWeight smallint)
					 

create table #t6
(
	IDCASE int,
	ID_C uniqueidentifier,
	IDSERV nvarchar(36),
	ID_U uniqueidentifier,
	LPU nchar(6),
	PROFIL smallint,
	VID_VME nvarchar(15),
	DET tinyint,
	DATE_IN date,
	DATE_OUT date,
	DS nchar(10),
	CODE_USL nchar(20),
	KOL_USL numeric(6, 2),
	TARIF numeric(15, 2),
	SUMV_USL numeric(15, 2),
	PRVS bigint,
	COMENTU nvarchar(250),
	PODR INT,
	CODE_MD VARCHAR(25)
)

					   
declare @t7 as table([VERSION] nchar(5),DATA date,[FILENAME] nchar(26),FILENAME1 nchar(26))

create table #t8
(
	ID_PAC nvarchar(36),
	FAM nvarchar(40),
	IM nvarchar(40),
	OT nvarchar(40),
	W tinyint,
	DR date,
	FAM_P nvarchar(40),
	IM_P nvarchar(40),
	OT_P nvarchar(40),
	W_P tinyint,
	DR_P date,
	MR nvarchar(100),
	DOCTYPE nchar(2),
	DOCSER nchar(10),
	DOCNUM nchar(20),
	SNILS nchar(14),
	OKATOG nchar(11),
	OKATOP nchar(11),
	COMENTP nvarchar(250)
)

declare @tempID as table(id int, ID_PAC nvarchar(36),N_ZAP int)

declare @tableId as table(id int,ID_PAC nvarchar(36))
---------------------------------------------------------------------
EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

insert @t1
SELECT [version],REPLACE(DATA,'-',''),[FILENAME]
FROM OPENXML (@idoc, 'ZL_LIST/ZGLV',2)
	WITH(
			[VERSION] NCHAR(5) './VERSION',
			[DATA] NCHAR(10) './DATA',
			[FILENAME] NCHAR(26) './FILENAME'
		)
	
insert @t2
select CODE,CODE_MO,[YEAR],[MONTH],NSCHET,replace(DSCHET,'-',''),PLAT,SUMMAV,COMENTS
FROM OPENXML (@idoc, 'ZL_LIST/SCHET',2)
	WITH 
	(	
		CODE int './CODE',
		CODE_MO int './CODE_MO',
		[YEAR]	smallint './YEAR',
		[MONTH] tinyint './MONTH',
		NSCHET nvarchar(15) './NSCHET',
		DSCHET nchar(10) './DSCHET',
		PLAT nvarchar(5) './PLAT',
		SUMMAV decimal(15,2) './SUMMAV',
		COMENTS nvarchar(250) './COMENTS'		
	)
PRINT '#t3 start'
--добавил Вес новорожденного 13.01.2014

insert #t3
SELECT N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,SMO,SMO_OK,SMO_NAM,NOVOR,MO_PR,VNOV_D
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/PACIENT',2)
	WITH(
			N_ZAP int '../N_ZAP',
			PR_NOV tinyint '../PR_NOV',
			ID_PAC nvarchar(36),
			VPOLIS tinyint ,
			SPOLIS nchar(10),
			NPOLIS nchar(20),
			SMO nchar(5) ,
			SMO_OK nchar(5),
			SMO_NAM nvarchar(100),
			NOVOR nchar(9),
			MO_PR nchar(6),
			VNOV_D smallint 
		)		
PRINT '#t3 end'

insert #t5(N_ZAP ,ID_PAC ,IDCASE ,ID_C ,USL_OK ,VIDPOM 
			,FOR_POM 
			,VID_HMP
			,METOD_HMP 
			,NPR_MO ,EXTR ,LPU ,PROFIL ,DET ,NHISTORY ,DATE_1 ,DATE_2 ,DS0 ,DS1 ,CODE_MES1 ,RSLT ,ISHOD 
			,PRVS,OS_SLUCH ,IDSP ,ED_COL ,TARIF ,SUMV ,SANK_MEK ,SANK_MEE ,SANK_EKMP ,COMENTSL ,F_SP,IDDOCT )
SELECT N_ZAP,ID_PAC,IDCASE,ID_C,USL_OK,VIDPOM,
		FOR_POM,
		CASE WHEN LEN(VID_HMP)=0 THEN NULL ELSE VID_HMP END,
		CASE WHEN LEN(METOD_HMP)=0 THEN NULL ELSE METOD_HMP END,--13.01.2014	
		NPR_MO,EXTR,LPU,PROFIL,DET,NHISTORY,replace(DATE_1,'-',''),replace(DATE_2,'-',''),DS0,DS1,CODE_MES1,RSLT,ISHOD,
		PRVS,OS_SLUCH,IDSP,ED_COL,TARIF,SUMV,SANK_MEK,SANK_MEE,SANK_EKMP,COMENTSL,F_SP,IDDOKT
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH',3)
	WITH(
			N_ZAP int '../N_ZAP',
			ID_PAC nvarchar(36) '../PACIENT/ID_PAC',
			IDCASE bigint ,
			ID_C uniqueidentifier,
			USL_OK tinyint ,
			VIDPOM smallint,
			FOR_POM tinyint,
			VID_HMP varchar(9),
			METOD_HMP smallint ,			
			NPR_MO nchar(6),
			EXTR tinyint ,
			LPU nchar(6) ,
			PROFIL smallint,
			DET tinyint ,
			NHISTORY nvarchar(50) ,
			DATE_1 nchar(10) ,
			DATE_2 nchar(10) ,
			DS0 nchar(10) ,
			DS1 nchar(10) ,			
			CODE_MES1 nchar(20) ,			
			RSLT smallint ,
			ISHOD smallint,
			PRVS bigint ,
			OS_SLUCH tinyint ,
			IDSP TINYINT ,
			ED_COL DECIMAL(5,2) ,
			TARIF DECIMAL(15,2) ,	
			SUMV DECIMAL(15,2) ,	
			REFREASON TINYINT ,
			SANK_MEK DECIMAL(15,2),
			SANK_MEE DECIMAL(15,2),
			SANK_EKMP DECIMAL(15,2),
			COMENTSL NVARCHAR(250),
			F_SP TINYINT,
			IDDOKT VARCHAR(25)
		)
PRINT '#t5 end'		
---множественность диагнозов		
INSERT #tDS (IDCASE,ID_C,DS,TypeDiagnosis) 
SELECT IDCASE,ID_C,DS2,3
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/SLUCH/DS2',3)
WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',			
			DS2 nchar(10) 'text()'  
	)
	
INSERT #tDS (IDCASE,ID_C,DS,TypeDiagnosis) 
SELECT IDCASE,ID_C,DS3,4
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/SLUCH/DS3',3)
WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',			
			DS3 nchar(10) 'text()'  
	)
--Вес новорожденных
INSERT #tBW (IDCASE,ID_C,BirthWeight) 
SELECT IDCASE,ID_C,VNOV_M
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/SLUCH/VNOV_M',3)
WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',			
			VNOV_M smallint 'text()'  
	)	
				
insert #t6
SELECT IDCASE,ID_C,IDSERV,ID_U,LPU,PROFIL,CASE when len(VID_VME)=0 THEN NULL ELSE VID_VME END,
		DET,replace(DATE_IN,'-',''),replace(DATE_OUT,'-',''),DS,CODE_USL,KOL_USL,TARIF,SUMV_USL,PRVS,COMENTU,PODR,CODE_MD
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH/USL',3)
	WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',
			IDSERV nvarchar(36) ,
			ID_U uniqueidentifier ,
			LPU nchar(6) ,
			PROFIL smallint,
			VID_VME nvarchar(15),
			DET tinyint ,
			DATE_IN nchar(10),
			DATE_OUT nchar(10),
			DS nchar(10),
			CODE_USL nchar(20),
			KOL_USL DECIMAL(6,2),
			TARIF DECIMAL(15,2) ,	
			SUMV_USL DECIMAL(15,2),	
			PRVS bigint ,
			COMENTU NVARCHAR(250),
			PODR INT,
			CODE_MD VARCHAR(25) 
		)
EXEC sp_xml_removedocument @idoc

---------------Patient----------------------------------
EXEC sp_xml_preparedocument @ipatient OUTPUT, @patient

insert @t7
SELECT [VERSION],replace(DATA,'-',''),[FILENAME],FILENAME1
FROM OPENXML (@ipatient, 'PERS_LIST/ZGLV',2)
	WITH(
			[VERSION] NCHAR(5) './VERSION',
			[DATA] NCHAR(10) './DATA',
			[FILENAME] NCHAR(26) './FILENAME',
			[FILENAME1] NCHAR(26) './FILENAME1'
		)
		
insert #t8
SELECT ID_PAC,FAM,IM,OT,W,replace(DR,'-',''),FAM_P,IM_P,OT_P,W_P,replace(DR_P,'-',''),MR,DOCTYPE,DOCSER,DOCNUM,SNILS,OKATOG,OKATOP,COMENTP
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
--раскладываем данные по таблица в базе счета
	begin transaction
	begin try
	------Insert into RegisterCase's tables------------------------------
		
	insert t_File(DateRegistration,FileVersion,DateCreate,FileNameHR,FileNameLR,FileZIP)
	select GETDATE(),[VERSION],DATA,FILENAME1,[FILENAME],@file  from @t7
	select @idFile=SCOPE_IDENTITY()
	
	if @fileKey is not null
	begin
		insert t_FileKey(rf_idFiles,FileNameKey,FileKey) values(@idFile,@fileName,@fileKey)
	end

	insert t_RegistersAccounts(rf_idFiles,idRecord,rf_idMO,ReportYear,ReportMonth,NumberRegister,PrefixNumberRegister,PropertyNumberRegister,
								DateRegister,rf_idSMO,AmountPayment,Comments,Letter)
	select @idFile,CODE,CODE_MO,[YEAR],[MONTH],dbo.fn_NumberRegister(NSCHET),dbo.fn_PrefixNumberRegister(NSCHET),dbo.fn_PropertyNumberRegister(NSCHET),
			DSCHET,PLAT,SUMMAV,COMENTS,dbo.fn_LetterNumberRegister(NSCHET)
	from @t2
	select @id=SCOPE_IDENTITY()
	----------14.01.2014----------
	insert t_RecordCasePatient(rf_idRegistersAccounts,idRecord,IsNew,ID_Patient,rf_idF008,SeriaPolis,NumberPolis,NewBorn,AttachLPU,BirthWeight)
	output inserted.id,inserted.ID_Patient,inserted.idRecord into @tempID
	select @id,N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,NOVOR,MO_PR ,VNOV_D from #t3
	
	insert t_PatientSMO(rf_idRecordCasePatient,rf_idSMO,OKATO,Name)
	select t2.id,t1.SMO,t1.SMO_OK, t1.SMO_NAM
	from #t3 t1 inner join @tempID t2 on
				t1.ID_PAC=t2.ID_PAC
				AND t1.N_ZAP=t2.N_ZAP
	where t1.SMO is not null
	group by t2.id,t1.SMO,t1.SMO_OK, t1.SMO_NAM
	
	declare @tmpCase as table(id int,idRecord BIGINT,GUID_CASE uniqueidentifier)
	----------2012-12-01----------
	insert t_Case(rf_idRecordCasePatient, idRecordCase, GUID_Case, rf_idV006, rf_idV008,
				  rf_idV014,rf_idV018,rf_idV019,
				  rf_idDirectMO, HopitalisationType, rf_idMO, rf_idV002, IsChildTariff, 
				  NumberHistoryCase, DateBegin, DateEnd, rf_idV009, rf_idV012, rf_idV004, 
				  IsSpecialCase, rf_idV010, AmountPayment, Comments,Age,[Emergency],rf_idDoctor)
	output inserted.id,inserted.idRecordCase,inserted.GUID_Case into @tmpCase
	select t2.id,t1.IDCASE,t1.ID_C, t1.USL_OK,t1.VIDPOM, 
			t1.FOR_POM,t1.VID_HMP,t1.METOD_HMP,
			t1.NPR_MO,t1.EXTR,t1.LPU,t1.PROFIL,t1.DET,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.RSLT,t1.ISHOD,
			t1.PRVS,t1.OS_SLUCH,t1.IDSP,t1.SUMV,t1.COMENTSL
			,DATEDIFF(YEAR,t3.DR,t1.DATE_1)-CASE WHEN 100*MONTH(t3.DR)+DAY(t3.DR)>100*MONTH(t1.DATE_1)+DAY(t1.DATE_1) THEN 1 ELSE 0 END, F_SP
			,CASE WHEN t1.IDDOCT='0' THEN NULL ELSE t1.IDDOCT END
	from #t5 t1 inner join @tempID t2 on
			t1.N_ZAP=t2.N_ZAP and
			t1.ID_PAC=t2.ID_PAC
				left join #t8 t3 on
			t1.ID_PAC=t3.ID_PAC
	group by t2.id,t1.IDCASE,t1.ID_C, t1.USL_OK,t1.VIDPOM, 
			t1.FOR_POM,t1.VID_HMP,t1.METOD_HMP,
			t1.NPR_MO,t1.EXTR,t1.LPU,t1.PROFIL,t1.DET,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.RSLT,t1.ISHOD,
			t1.PRVS,t1.OS_SLUCH,t1.IDSP,t1.SUMV,t1.COMENTSL
			,DATEDIFF(YEAR,t3.DR,t1.DATE_1)-CASE WHEN 100*MONTH(t3.DR)+DAY(t3.DR)>100*MONTH(t1.DATE_1)+DAY(t1.DATE_1) THEN 1 ELSE 0 END, F_SP
			,CASE WHEN t1.IDDOCT='0' THEN NULL ELSE t1.IDDOCT END
	
	------------------------------------------------------------------------------------------------------------------
	insert t_Diagnosis(DiagnosisCode,rf_idCase,TypeDiagnosis)
	select DS0,c.id,2 
	from @tmpCase c inner join #t5 t1 on
			c.GUID_Case=t1.ID_C
			and c.idRecord=t1.IDCASE
	where DS0 is not null
	union all
	select DS1,c.id,1 
	from @tmpCase c inner join #t5 t1 on
			c.GUID_Case=t1.ID_C
			and c.idRecord=t1.IDCASE
	union all
	select DS,c.id,TypeDiagnosis 
	from @tmpCase c inner join #tDS t1 on
			c.GUID_Case=t1.ID_C	
			and c.idRecord=t1.IDCASE	
			
	--insert data into t_BirthWeight		
	insert t_BirthWeight(rf_idCase,BirthWeight)		
	select c.id,BirthWeight
	from @tmpCase c inner join #tBW t1 on
			c.GUID_Case=t1.ID_C	
			and c.idRecord=t1.IDCASE	
	--------------------------------------------------------------------------------------------------------------------
	insert t_MES(MES,rf_idCase,TypeMES,Quantity,Tariff)	
	select t1.CODE_MES1,c.id,1,t1.ED_COL,t1.TARIF
	from @tmpCase c inner join #t5 t1 on
			c.GUID_Case=t1.ID_C
			and c.idRecord=t1.IDCASE
	where t1.CODE_MES1 is not null
	group by t1.CODE_MES1,c.id,t1.ED_COL,t1.TARIF
	
	
	----------------------------------------------------------------------------------------------------------------------
	insert t_FinancialSanctions(rf_idCase,Amount,TypeSanction)
	select c.id,t1.SANK_MEK,1
	from @tmpCase c inner join #t5 t1 on
			c.GUID_Case=t1.ID_C
			and c.idRecord=t1.IDCASE
	where t1.SANK_MEK is not null
	union all
	select c.id,t1.SANK_MEE,2
	from @tmpCase c inner join #t5 t1 on
			c.GUID_Case=t1.ID_C
			and c.idRecord=t1.IDCASE
	where t1.SANK_MEE is not null
	union all
	select c.id,t1.SANK_EKMP,3
	from @tmpCase c inner join #t5 t1 on
			c.GUID_Case=t1.ID_C
			and c.idRecord=t1.IDCASE
	where t1.SANK_EKMP is not null

	-------------------------------------------------------------------------------------------------------------------------
--добавить обработку хирургических операций с помощью конструкции if exists
	
	insert t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO, rf_idV002,MUSurgery, IsChildTariff, DateHelpBegin, DateHelpEnd, DiagnosisCode,MUGroupCode,MUUnGroupCode
						,MUCode, Quantity, Price, TotalPrice, rf_idV004, Comments,rf_idDepartmentMO,rf_idDoctor)
	select c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL,t1.VID_VME, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,mu.MUGroupCode,mu.MUUnGroupCode,mu.MUCode			
			,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU, PODR
			,CASE WHEN t1.CODE_MD='0' THEN NULL ELSE t1.CODE_MD END
	from #t6 t1 inner join @tmpCase c on
				t1.ID_C=c.GUID_Case
				and t1.IDCASE=c.idRecord	
					inner join (SELECT MU ,MUGroupCode,MUUnGroupCode,MUCode FROM vw_sprMU  UNION ALL SELECT IDRB,0,0,0 FROM dbo.vw_V001) mu on
			t1.CODE_USL=mu.MU
	where t1.ID_U is not null
	group by c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL,t1.VID_VME, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,mu.MUGroupCode,mu.MUUnGroupCode,mu.MUCode
			,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU,PODR,CASE WHEN t1.CODE_MD='0' THEN NULL ELSE t1.CODE_MD END
	--вставка хирургического вмешательства
	/*
	insert t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO, rf_idV002, IsChildTariff, DateHelpBegin, DateHelpEnd, DiagnosisCode,MUSurgery, Quantity
						,Price, TotalPrice, rf_idV004, Comments,MUGroupCode,MUUnGroupCode,MUCode,rf_idDepartmentMO)
	select c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,mu.IDRB
			,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU,0,0,0,PODR
	from #t6 t1 inner join @tmpCase c on
				t1.ID_C=c.GUID_Case
				and t1.IDCASE=c.idRecord	
				inner join vw_V001 mu on
			t1.CODE_USL=mu.IDRB
	where t1.ID_U is not null
	group by c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,mu.IDRB,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU,PODR
	*/
	----------------------------------------------------------------------------------------------------------------------

	insert t_RegisterPatient(rf_idFiles, ID_Patient, Fam, Im, Ot, rf_idV005, BirthDay, BirthPlace,rf_idRecordCase)
		output inserted.id,inserted.ID_Patient into @tableId
	select @idFile,t1.ID_PAC,t1.FAM,t1.IM,case when t1.OT='НЕТ' then null else t1.OT end,t1.W,t1.DR,t1.MR,t2.id
	from #t8 t1 left join @tempID t2 on
					t1.ID_PAC=t2.ID_PAC
	group by t1.ID_PAC,t1.FAM,t1.IM,case when t1.OT='НЕТ' then null else t1.OT end,t1.W,t1.DR,t1.MR,t2.id

	insert t_RegisterPatientDocument(rf_idRegisterPatient, rf_idDocumentType, SeriaDocument, NumberDocument, SNILS, OKATO, OKATO_Place, Comments)
	select t2.id,t1.DOCTYPE,t1.DOCSER,t1.DOCNUM,t1.SNILS,t1.OKATOG,t1.OKATOP,t1.COMENTP
	from #t8 t1 inner join @tableId t2 on
			t1.ID_PAC=t2.ID_PAC
	where (t1.DOCTYPE is not null) or (t1.DOCSER is not null) or (t1.DOCNUM is not null)

	insert t_RegisterPatientAttendant(rf_idRegisterPatient, Fam, Im, Ot, rf_idV005, BirthDay)
	select t2.id,t1.FAM_P,t1.IM_P,t1.OT_P,t1.W_P,t1.DR_P
	from #t8 t1 inner join @tableId t2 on
			t1.ID_PAC=t2.ID_PAC
	where (t1.FAM_P is not null) and (t1.IM_P is not null) and (t1.W_P is not null) and (t1.DR_P is not null)
	
	
	end try
	begin catch
	if @@TRANCOUNT>0
		select ERROR_MESSAGE(),ERROR_LINE()
		rollback transaction
	goto Exit1
	end catch
	if @@TRANCOUNT>0	
		COMMIT TRANSACTION		
---------------End of batch
Exit1:
EXEC usp_InsertCompletedCaseIntoMeduslugi @idFile
select @idFile,0
--------------------------------------------
drop table #t3
drop table #t5
drop table #t6
DROP TABLE #tBW
DROP TABLE #tDS

GO


