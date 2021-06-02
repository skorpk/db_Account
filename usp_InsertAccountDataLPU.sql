use AccountOMS
go
if OBJECT_ID('usp_InsertAccountDataLPU',N'P') is not null
drop proc usp_InsertAccountDataLPU
go
create proc usp_InsertAccountDataLPU
			@doc xml,
			@patient xml,
			@file varbinary(max),
			@fileName varchar(26)
as
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
					 SUMMAV numeric(11, 2),
					 COMENTS nvarchar(250)) 

declare @t3 as table(
					  N_ZAP int,
					  PR_NOV tinyint,
					  ID_PAC nvarchar(36),
					  VPOLIS tinyint,
					  SPOLIS nchar(10),
					  NPOLIS nchar(20),
					  SMO nchar(5),
					  SMO_OK nchar(5),
					  NOVOR nchar(9)
					 )


declare @t5 as table(
						ID_PAC nvarchar(36),
						IDCASE int,
						ID_C uniqueidentifier,
						USL_OK tinyint,
						VIDPOM smallint,
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
						DS2 nvarchar(10),
						CODE_MES1 nvarchar(16),
						RSLT smallint,
						ISHOD smallint,
						PRVS bigint,
						OS_SLUCH tinyint,
						IDSP tinyint,
						ED_COL numeric(5, 2),
						TARIF numeric(15, 2),
						SUMV numeric(15, 2),
						--REFREASON tinyint, 
						SANK_MEK numeric(15, 2),
						SANK_MEE numeric(15, 2),
						SANK_EKMP numeric(15, 2),
						COMENTSL nvarchar(250)
					)
					 
declare @t6 as table (
					   ID_C uniqueidentifier,
					   IDSERV int,
					   ID_U uniqueidentifier,
					   LPU nvarchar(6),
					   PROFIL smallint,
					   DET tinyint,
					   DATE_IN date,
					   DATE_OUT date,
					   DS nvarchar(10),
					   CODE_USL nvarchar(16),
					   KOL_USL numeric(6, 2),
					   TARIF numeric(15, 2),
					   SUMV_USL numeric(15, 2),
					   PRVS bigint,
					   COMENTU nvarchar(250)
					   )
					   
declare @t7 as table([VERSION] nchar(5),DATA date,[FILENAME] nchar(26),FILENAME1 nchar(26))

declare @t8 as table(
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

declare @tempID as table(id int, ID_PAC nvarchar(36))

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
		SUMMAV decimal(11,2) './SUMMAV',
		COMENTS nvarchar(250) './COMENTS'		
	)

insert @t3
SELECT N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,SMO,SMO_OK,NOVOR
FROM OPENXML (@idoc, 'ZL_LIST/ZAP',2)
	WITH(
			N_ZAP int './N_ZAP',
			PR_NOV tinyint './PR_NOV',
			ID_PAC nvarchar(36)'./PACIENT/ID_PAC',
			VPOLIS tinyint './PACIENT/VPOLIS',
			SPOLIS nchar(10) './PACIENT/SPOLIS',
			NPOLIS nchar(20) './PACIENT/NPOLIS',
			SMO nchar(5) './PACIENT/SMO',
			SMO_OK nchar(5) './PACIENT/SMO_OK',
			NOVOR nchar(9) './PACIENT/NOVOR'
		)

insert @t5
SELECT ID_PAC,IDCASE,ID_C,USL_OK,VIDPOM,NPR_MO,EXTR,LPU,PROFIL,DET,NHISTORY,replace(DATE_1,'-',''),replace(DATE_2,'-',''),DS0,DS1,DS2,CODE_MES1,RSLT,ISHOD,
		PRVS,OS_SLUCH,IDSP,ED_COL,TARIF,SUMV,SANK_MEK,SANK_MEE,SANK_EKMP,COMENTSL
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH',3)
	WITH(
			ID_PAC nvarchar(36) '../PACIENT/ID_PAC',
			IDCASE int ,
			ID_C uniqueidentifier,
			USL_OK tinyint ,
			VIDPOM smallint,
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
			DS2 nchar(10) ,
			CODE_MES1 nchar(16) ,			
			RSLT smallint ,
			ISHOD smallint,
			PRVS bigint ,
			OS_SLUCH tinyint ,
			IDSP TINYINT ,
			ED_COL DECIMAL(5,2) ,
			TARIF DECIMAL(15,2) ,	
			SUMV DECIMAL(15,2) ,	
			SANK_MEK DECIMAL(15,2),
			SANK_MEE DECIMAL(15,2),
			SANK_EKMP DECIMAL(15,2),
			COMENTSL NVARCHAR(250) 
		)

insert @t6
SELECT ID_C,IDSERV,ID_U,LPU,PROFIL,DET,replace(DATE_IN,'-',''),replace(DATE_OUT,'-',''),DS,CODE_USL,KOL_USL,TARIF,SUMV_USL,PRVS,COMENTU
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH/USL',3)
	WITH(
			ID_C uniqueidentifier '../ID_C',
			IDSERV INT ,
			ID_U uniqueidentifier ,
			LPU nchar(6) ,
			PROFIL smallint,
			DET tinyint ,
			DATE_IN nchar(10),
			DATE_OUT nchar(10),
			DS nchar(10),
			CODE_USL nchar(16),
			KOL_USL DECIMAL(6,2),
			TARIF DECIMAL(15,2) ,	
			SUMV_USL DECIMAL(15,2),	
			PRVS bigint ,
			COMENTU NVARCHAR(250) 
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
		
insert @t8
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
--select * from @t7
--select * from @t8

declare @account varchar(15),
		@codeMO char(6),
		@month tinyint,
		@year smallint
select @account=NSCHET,@year=[YEAR],@month=[MONTH],@codeMO=CODE_MO from @t2
declare @et as table(errorId smallint)
--проверяем счет на соответствие ему реестра СП и ТК. добавить проверку счета на уникальность
--select dbo.fn_CheckAccount(@account,@codeMO,@month,@year)
--select @account,@codeMO,@month,@year
if dbo.fn_CheckAccount(@account,@codeMO,@month,@year)=1
begin
	--select 'проверяем случаи и медуслуги, должны ли они выставить все случаи или нет'
	declare @caseRC int,
			@caseA int,
			@meduslugiRC int,
			@meduslugiA int
			
	
	--select @caseRC=CHECKSUM_AGG(BINARY_CHECKSUM(*)) from dbo.fn_GetCaseFromRegisterCaseDB(@account,@codeMO,@month,@year)	
	select @caseA=count(*)  from @t5 t	
												
	select @caseRC=COUNT(*)
	from dbo.fn_GetCaseFromRegisterCaseDB(@account,@codeMO,@month,@year) t inner join @t5 t1 on
			upper(ID_PAC)=upper(t.ID_Patient) 
			and ID_C=t.GUID_Case
			and USL_OK=t.rf_idV006 
			and VIDPOM=t.rf_idV008
			and isnull(NPR_MO,0)=isnull(t.rf_idDirectMO,0)
			and isnull(EXTR,0)=isnull(t.HopitalisationType,0)
			and LPU=t.rf_idMO
			and PROFIL=t.rf_idV002
			and DET =t.IsChildTariff
			and NHISTORY =NumberHistoryCase
			and DATE_1=DateBegin
			and DATE_2=DateEnd
			and isnull(t1.DS0,0)=isnull(t.DS0,0)
			and t1.DS1=t.DS1
			and isnull(t1.DS2,2)=isnull(t.DS2,2)
			and isnull(CODE_MES1,0)=isnull(t.MES,0) 
			and RSLT=t.rf_idV009  
			and ISHOD=t.rf_idV012  
			and PRVS=t.rf_idV004  
			and isnull(OS_SLUCH,0)=isnull(t.IsSpecialCase,0)
			and IDSP=t.rf_idV010  
			and isnull(ED_COL,0)=ISNULL(t.Quantity,0) 
			and isnull(TARIF ,0)=ISNULL(t.Tariff,0) 
	
	--select @caseRC,@caseA
	
	if(isnull(@caseRC,0)-isnull(@caseA,0))<0
	begin
		insert @et values(50)
	end
	--
	--select @meduslugiRC=CHECKSUM_AGG(BINARY_CHECKSUM(*)) from dbo.fn_GetMeduslugiFromRegisterCaseDB(@account,@codeMO,@month,@year)	
	select @meduslugiA=count(*) from @t6 t
													
	select @meduslugiRC=COUNT(*)
	from dbo.fn_GetMeduslugiFromRegisterCaseDB(@account,@codeMO,@month,@year) t0 inner join @t6 t on
			ID_C=t0.GUID_Case
			and ID_U= GUID_MU
			and LPU=rf_idMO
			and PROFIL=rf_idV002
			and DET =IsChildTariff
			and DATE_IN =DateHelpBegin
			and DATE_OUT =DateHelpEnd
			and rtrim(DS) =rtrim(DiagnosisCode)
			and rtrim(CODE_USL)=rtrim(MUCode)
			and KOL_USL= Quantity
			and TARIF=Price
			and SUMV_USL =TotalPrice
			and PRVS=rf_idV004
	
	
	if(isnull(@meduslugiRC,0)-isnull(@meduslugiA,0))<0
	begin
		insert @et values(50)
	end
	
end
else
begin	
	insert @et values(50)
end
--возвращаем @idFile и 0 или 1 отличное от нуля(0- ошибок нету,  1-ошибки есть)
if (select count(*) from @et)>0
begin
	insert t_FileError([FileName]) values(@fileName)
	set @idFile=SCOPE_IDENTITY()
	insert t_Errors(rf_idFileError,ErrorNumber) select @idFile,errorId from @et	
end
else
begin
--раскладываем данные по таблица в базе счета

	begin transaction
	begin try
	------Insert into RegisterCase's tables------------------------------
		
	insert t_File(DateRegistration,FileVersion,DateCreate,FileNameHR,FileNameLR,FileZIP)
	select GETDATE(),[VERSION],DATA,FILENAME1,[FILENAME],@file  from @t7
	select @idFile=SCOPE_IDENTITY()
	
	insert t_RegistersAccounts(rf_idFiles,idRecord,rf_idMO,ReportYear,ReportMonth,NumberRegister,PrefixNumberRegister,PropertyNumberRegister,
								DateRegister,rf_idSMO,AmountPayment,Comments,Letter)
	select @idFile,CODE,CODE_MO,[YEAR],[MONTH],dbo.fn_NumberRegister(NSCHET),dbo.fn_PrefixNumberRegister(NSCHET),dbo.fn_PropertyNumberRegister(NSCHET),
			DSCHET,PLAT,SUMMAV,COMENTS,dbo.fn_LetterNumberRegister(NSCHET)
	from @t2
	select @id=SCOPE_IDENTITY()
	
	insert t_RecordCasePatient(rf_idRegistersAccounts,idRecord,IsNew,ID_Patient,rf_idF008,SeriaPolis,NumberPolis,NewBorn)
	output inserted.id,inserted.ID_Patient into @tempID
	select @id,N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,NOVOR from @t3
	
	insert t_PatientSMO(rf_idRecordCasePatient,rf_idSMO,OKATO)
	select t2.id,t1.SMO,t1.SMO_OK
	from @t3 t1 inner join @tempID t2 on
				t1.ID_PAC=t2.ID_PAC
	where t1.SMO is not null
	group by t2.id,t1.SMO,t1.SMO_OK
	
	insert t_Case(rf_idRecordCasePatient, idRecordCase, GUID_Case, rf_idV006, rf_idV008, rf_idDirectMO, HopitalisationType, rf_idMO, rf_idV002, IsChildTariff, 
				NumberHistoryCase, DateBegin, DateEnd, rf_idV009, rf_idV012, rf_idV004, IsSpecialCase, rf_idV010, AmountPayment, Comments,Age)
	select t2.id,t1.IDCASE,t1.ID_C, t1.USL_OK,t1.VIDPOM, t1.NPR_MO,t1.EXTR,t1.LPU,t1.PROFIL,t1.DET,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.RSLT,t1.ISHOD,
			t1.PRVS,t1.OS_SLUCH,t1.IDSP,t1.SUMV,t1.COMENTSL,dbo.fn_FullYear(t3.DR,t1.DATE_1)
	from @t5 t1 inner join @tempID t2 on
			t1.ID_PAC=t2.ID_PAC
				left join @t8 t3 on
			t1.ID_PAC=t3.ID_PAC
	group by t2.id,t1.IDCASE,t1.ID_C, t1.USL_OK,t1.VIDPOM, t1.NPR_MO,t1.EXTR,t1.LPU,t1.PROFIL,t1.DET,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.RSLT,t1.ISHOD,
			t1.PRVS,t1.OS_SLUCH,t1.IDSP,t1.SUMV,t1.COMENTSL,dbo.fn_FullYear(t3.DR,t1.DATE_1)
	
	------------------------------------------------------------------------------------------------------------------
	insert t_Diagnosis(DiagnosisCode,rf_idCase,TypeDiagnosis)
	select DS0,c.id,2 
	from t_Case c inner join @t5 t1 on
			c.GUID_Case=t1.ID_C
	where DS0 is not null
	union all
	select DS1,c.id,1 
	from t_Case c inner join @t5 t1 on
			c.GUID_Case=t1.ID_C
	union all
	select DS2,c.id,3 
	from t_Case c inner join @t5 t1 on
			c.GUID_Case=t1.ID_C		
	where DS2 is not null
	--------------------------------------------------------------------------------------------------------------------

	insert t_MES(MES,rf_idCase,TypeMES,Quantity,Tariff)
	select t1.CODE_MES1,c.id,1,t1.ED_COL,t1.TARIF
	from t_Case c inner join @t5 t1 on
			c.GUID_Case=t1.ID_C
	where t1.CODE_MES1 is not null
	group by t1.CODE_MES1,c.id,t1.ED_COL,t1.TARIF
	---------------------------------------------------------------------------------------------------------------------
		--блокап где вставляются причины отказа нету т.к. счета должны быть принесены чистыми
	---------------------------------------------------------------------------------------------------------------------
	insert t_FinancialSanctions(rf_idCase,Amount,TypeSanction)
	select c.id,t1.SANK_MEK,1
	from t_Case c inner join @t5 t1 on
			c.GUID_Case=t1.ID_C
	where t1.SANK_MEK is not null
	union all
	select c.id,t1.SANK_MEE,2
	from t_Case c inner join @t5 t1 on
			c.GUID_Case=t1.ID_C
	where t1.SANK_MEE is not null
	union all
	select c.id,t1.SANK_EKMP,3
	from t_Case c inner join @t5 t1 on
			c.GUID_Case=t1.ID_C
	where t1.SANK_EKMP is not null
	-------------------------------------------------------------------------------------------------------------------------
	insert t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO, rf_idV002, IsChildTariff, DateHelpBegin, DateHelpEnd, DiagnosisCode,MUGroupCode,MUUnGroupCode
						,MUCode, Quantity, Price, TotalPrice, rf_idV004, Comments)
	select c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,mu.MUGroupCode,mu.MUUnGroupCode,mu.MUCode
			,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU
	from @t6 t1 inner join t_Case c on
				t1.ID_C=c.GUID_Case
				inner join vw_sprMU mu on
			t1.CODE_USL=mu.MU
	where t1.ID_U is not null
	group by c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,mu.MUGroupCode,mu.MUUnGroupCode,mu.MUCode
			,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU
	----------------------------------------------------------------------------------------------------------------------

	insert t_RegisterPatient(rf_idFiles, ID_Patient, Fam, Im, Ot, rf_idV005, BirthDay, BirthPlace,rf_idRecordCase)
		output inserted.id,inserted.ID_Patient into @tableId
	select @idFile,t1.ID_PAC,t1.FAM,t1.IM,case when t1.OT='НЕТ' then null else t1.OT end,t1.W,t1.DR,t1.MR,t2.id
	from @t8 t1 left join @tempID t2 on
					t1.ID_PAC=t2.ID_PAC
	group by t1.ID_PAC,t1.FAM,t1.IM,case when t1.OT='НЕТ' then null else t1.OT end,t1.W,t1.DR,t1.MR,t2.id

	insert t_RegisterPatientDocument(rf_idRegisterPatient, rf_idDocumentType, SeriaDocument, NumberDocument, SNILS, OKATO, OKATO_Place, Comments)
	select t2.id,t1.DOCTYPE,t1.DOCSER,t1.DOCNUM,t1.SNILS,t1.OKATOG,t1.OKATOP,t1.COMENTP
	from @t8 t1 inner join @tableId t2 on
			t1.ID_PAC=t2.ID_PAC
	where (t1.DOCTYPE is not null) or (t1.DOCSER is not null) or (t1.DOCNUM is not null)

	insert t_RegisterPatientAttendant(rf_idRegisterPatient, Fam, Im, Ot, rf_idV005, BirthDay)
	select t2.id,t1.FAM_P,t1.IM_P,t1.OT_P,t1.W_P,t1.DR_P
	from @t8 t1 inner join @tableId t2 on
			t1.ID_PAC=t2.ID_PAC
	where (t1.FAM_P is not null) and (t1.IM_P is not null) and (t1.W_P is not null) and (t1.DR_P is not null)
	
	
	end try
	begin catch
	if @@TRANCOUNT>0
		select ERROR_MESSAGE(),ERROR_LINE()
		rollback transaction
	end catch
	if @@TRANCOUNT>0
		commit transaction
end

if(select COUNT(*) from @et)>0
	select @idFile,1
else 
	select @idFile,0

GO