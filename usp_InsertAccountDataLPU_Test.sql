use AccountOMS
go
if OBJECT_ID('usp_InsertAccountDataLPU_Test',N'P') is not null
drop proc usp_InsertAccountDataLPU_Test
GO
create proc [dbo].[usp_InsertAccountDataLPU_Test]
			@doc xml,
			@patient xml,
			@file varbinary(max),
			@fileName varchar(26),
			@fileKey varbinary(max)=null--файл цифровой подписи
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
					 SUMMAV decimal(15, 2),
					 COMENTS nvarchar(250)) 

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
	NOVOR nchar(9),
	MO_PR nchar(6)
)


create table #t5 
(
	N_ZAP int,
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
	ED_COL decimal(5, 2),
	TARIF decimal(15, 2),
	SUMV decimal(15, 2),
	--REFREASON tinyint, 
	SANK_MEK decimal(15, 2),
	SANK_MEE decimal(15, 2),
	SANK_EKMP decimal(15, 2),
	COMENTSL nvarchar(250),
	F_SP tinyint
)
					 
create table #t6
(
	IDCASE int,
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
	KOL_USL decimal(6, 2),
	TARIF decimal(15, 2),
	SUMV_USL decimal(15, 2),
	PRVS bigint,
	COMENTU nvarchar(250),
	PODR int
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

insert #t3
SELECT N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,SMO,SMO_OK,NOVOR,MO_PR
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
			NOVOR nchar(9) './PACIENT/NOVOR',
			MO_PR nchar(6) './PACIENT/MO_PR'
		)

insert #t5
SELECT N_ZAP,ID_PAC,IDCASE,ID_C,USL_OK,VIDPOM,NPR_MO,EXTR,LPU,PROFIL,DET,NHISTORY,replace(DATE_1,'-',''),replace(DATE_2,'-',''),DS0,DS1,DS2,CODE_MES1,RSLT,ISHOD,
		PRVS,OS_SLUCH,IDSP,ED_COL,TARIF,SUMV,SANK_MEK,SANK_MEE,SANK_EKMP,COMENTSL,F_SP
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH',3)
	WITH(	
			N_ZAP int '../N_ZAP',
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
			COMENTSL NVARCHAR(250),
			F_SP TINYINT
		)

insert #t6
SELECT IDCASE,ID_C,IDSERV,ID_U,LPU,PROFIL,DET,replace(DATE_IN,'-',''),replace(DATE_OUT,'-',''),DS,CODE_USL,KOL_USL,TARIF,SUMV_USL,PRVS,COMENTU,PODR
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH/USL',3)
	WITH(
			IDCASE int '../IDCASE',
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
			COMENTU NVARCHAR(250),
			PODR int 
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
--select * from @t7
--select * from #t8

declare @account varchar(15),
		@codeMO char(6),
		@month tinyint,
		@year smallint
---26.12.2011----------------------------------------------
select @codeMO=(substring(@fileName,(3),(6))) 
declare @et as table(errorId smallint,id tinyint)
----------------------------------------------------------
--DATA
if exists(select * from @t1 where DATA>GETDATE() ) 
begin
	insert @et values(904,1)
end
if NOT EXISTS(select * from @et)
begin
	if exists(select * from @t2 where DSCHET>GETDATE() ) 
	begin
		insert @et values(904,2)
	end
end
--проверка CODE_MO в теге SCHET
declare @mcodeFile char(6),
		@mcodeSPR char(6)

select @mcodeFile=CODE_MO from @t2
	
	select @mcodeSPR=mcod from dbo.vw_sprT001 where CodeM=@codeMO
	
if(@mcodeFile!=@mcodeSPR)
begin
		insert @et values(904,3)
end
----------------
--NSCHET
if NOT EXISTS(select * from @et)
begin
	select @account=NSCHET,@year=[YEAR],@month=[MONTH] from @t2
	--проверяем счет на соответствие ему реестра СП и ТК. добавить проверку счета на уникальность
	
	if NOT EXISTS(select * from dbo.fn_CheckAccountExistSPTK(@account,@codeMO,@month,@year))
	begin	
		insert @et values(585,4)
	end
	if EXISTS(select * from dbo.fn_CheckAccountExistInDB(@account,@codeMO,@month,@year))
	begin	
		insert @et values(586,5)
	end
	--признак модернизационного счета должен быть латиницей
	--if exists(select * from @t2 where NSCHET like '%М') 
	--begin
	--	insert @et values(585,6)
	--end
end
--Enable 2013-01-01 
-- check parameter of number account
	declare @letter char(1)
	select @letter=right(NSCHET,1) from @t2
if NOT EXISTS(select * from @et)
begin
	if NOT EXISTS(select * from vw_sprMuWithParamAccount where AccountParam=@Letter)
	begin
		insert @et values(590,21)
	end
end
--compare MU with vw_sprMuWithParamAccount by AccountParam
if NOT EXISTS(select * from @et)
begin	
	if EXISTS(select * 
			  from (select CODE_USL from #t6 union all select CODE_MES1 from #t5)m  
						INNER JOIN dbo.vw_sprMUAll m1 ON
							m.CODE_USL=m1.MU
						 left join vw_sprMuWithParamAccount s on			  
						m.CODE_USL=s.MU	and ISNULL(AccountParam,@letter)=@Letter 
					where s.MU is null 
			  )
	BEGIN	
		insert @et values(590,21)		
	end
end
	
--DSCHET
if NOT EXISTS(select * from @et)
begin	
	declare @dateAccount date
	declare @dateStart date
	
	--проверка на дату счета и дата окончания случая должна принадлежать отчетному месяцу
	select @dateAccount=DSCHET, @dateStart=CAST([YEAR] as CHAR(4))+right('0'+CAST([month] as varchar(2)),2)+'01' from @t2
	
	if EXISTS(select * from #t5 where DATE_2>@dateAccount and DATE_2<@dateStart)
	begin
		insert @et values(587,7)
	end	
end
--SUMMAV
if NOT EXISTS(select * from @et)
begin
	--производим проверку суммы всех случаев и суммы счета	
	if(select SUM(t.SUMV) from #t5 t)!=(select t.SUMMAV from @t2 t)
	begin
		insert @et values(51,8)
	end
end
--N_ZAP
if NOT EXISTS(select * from @et)
begin
	
	if EXISTS(select * from (select ROW_NUMBER() OVER(order by t.N_ZAP asc) as id,t.N_ZAP from #t3 t) t where id<>N_ZAP)
	begin
		insert @et values(530,9)
	end
end
--PR_NOV
if NOT EXISTS(select * from @et)
begin
	
	if EXISTS(select * from #t3 t where t.PR_NOV<>0)
	begin
		insert @et values(531,10)
	end
end
--ID_PAC
if NOT EXISTS(select * from @et)
begin
	if EXISTS(select * 
			  from #t3 t left join #t8 p on
					t.ID_PAC=p.ID_PAC
			  where p.ID_PAC is null)
	begin
		insert @et values(532,11)
	end
	
	if EXISTS(select * 
			  from #t3 t right join #t8 p on
					t.ID_PAC=p.ID_PAC
			  where t.ID_PAC is null)
	begin
		insert @et values(532,12)
	end
end
declare @number int,
			@property tinyint,
			@smo char(5)

			
if NOT EXISTS(select * from @et)
begin
	select @number=dbo.fn_NumberRegister(@account),@smo=dbo.fn_PrefixNumberRegister(@account),@property=dbo.fn_PropertyNumberRegister(@account)
end
--Поиск некорректных данных с ошибкой 588 в ZAP
if NOT EXISTS(select * from @et)
begin
	
	declare @zapRC int,
			@zapA int
	
	--изменения от 23.03.2012

	--Изменения от 14.06.2012 новая ошибка номер 17
	-- проверка данных из тэга ZAP
	SELECT t.*
	from (
			select distinct cast(r1.ID_Patient as nvarchar(36)) as ID_Patient,p.rf_idF008,p.SeriaPolis,p.NumberPolis,p.rf_idSMO,p.OKATO
					,cast(r1.NewBorn as nvarchar(9)) as NewBorn,isnull(p.AttachCodeM,'000000') as MO_PR
			from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack a on 
							f.id=a.rf_idFilesBack
							and f.CodeM=@codeMO
							and a.NumberRegister=@number
							and a.PropertyNumberRegister=@property
							AND a.ReportYear=@year
							AND a.ReportMonth=@month
												inner join RegisterCases.dbo.t_RecordCaseBack r on
							a.id=r.rf_idRegisterCaseBack
							and r.TypePay=1
												inner join RegisterCases.dbo.t_RecordCase r1 on
							r.rf_idRecordCase=r1.id
												inner join RegisterCases.dbo.t_PatientBack p on
							r.id=p.rf_idRecordCaseBack
							and p.rf_idSMO=@smo
		  ) r RIGHT join #t3 t on
					r.ID_Patient=t.ID_PAC
					and r.rf_idF008=t.VPOLIS
					and COALESCE(r.SeriaPolis,'')=COALESCE(t.SPOLIS,'')
					and r.NumberPolis=t.NPOLIS
					and r.rf_idSMO=t.SMO
					and r.OKATO=COALESCE(t.SMO_OK,'18000')
					and r.NewBorn=t.NOVOR
					and isnull(r.MO_PR,'000000')=t.MO_PR
		WHERE r.ID_Patient IS NULL
	
	
	--select distinct cast(r1.ID_Patient as nvarchar(36)) as ID_Patient,p.rf_idF008,p.SeriaPolis,p.NumberPolis,p.rf_idSMO,p.OKATO
	--				,cast(r1.NewBorn as nvarchar(9)) as NewBorn,isnull(p.AttachCodeM,'000000') as MO_PR
	--		from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack a on 
	--						f.id=a.rf_idFilesBack
	--						and f.CodeM=@codeMO
	--						and a.NumberRegister=@number
	--						and a.PropertyNumberRegister=@property
	--						AND a.ReportYear=@year
	--						AND a.ReportMonth=@month
	--											inner join RegisterCases.dbo.t_RecordCaseBack r on
	--						a.id=r.rf_idRegisterCaseBack
	--						and r.TypePay=1
	--											inner join RegisterCases.dbo.t_RecordCase r1 on
	--						r.rf_idRecordCase=r1.id
	--											inner join RegisterCases.dbo.t_PatientBack p on
	--						r.id=p.rf_idRecordCaseBack
	--						and p.rf_idSMO=@smo
	--WHERE ID_Patient IN ('AA20138A-7D3C-013E-99BA-F9BC1B7D8283','1EBD7188-0503-DDA9-6DC1-C9BC0AB78E16')
	-----------------2012-12-28
	select @zapA=COUNT(*) from #t3
	
	select @zapRC=COUNT(*)
	from (
			select distinct cast(r1.ID_Patient as nvarchar(36)) as ID_Patient,p.rf_idF008,p.SeriaPolis,p.NumberPolis,p.rf_idSMO,p.OKATO
					,cast(r1.NewBorn as nvarchar(9)) as NewBorn,isnull(p.AttachCodeM,'000000') as MO_PR
			from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack a on 
							f.id=a.rf_idFilesBack
							and f.CodeM=@codeMO
							and a.NumberRegister=@number
							and a.PropertyNumberRegister=@property
							AND a.ReportYear=@year
							AND a.ReportMonth=@month
												inner join RegisterCases.dbo.t_RecordCaseBack r on
							a.id=r.rf_idRegisterCaseBack
							and r.TypePay=1
												inner join RegisterCases.dbo.t_RecordCase r1 on
							r.rf_idRecordCase=r1.id
												inner join RegisterCases.dbo.t_PatientBack p on
							r.id=p.rf_idRecordCaseBack
							and p.rf_idSMO=@smo
		  ) r inner join #t3 t on
					r.ID_Patient=t.ID_PAC
					and r.rf_idF008=t.VPOLIS
					and COALESCE(r.SeriaPolis,'')=COALESCE(t.SPOLIS,'')
					and r.NumberPolis=t.NPOLIS
					and r.rf_idSMO=t.SMO
					and r.OKATO=COALESCE(t.SMO_OK,'18000')
					and r.NewBorn=t.NOVOR
					and isnull(r.MO_PR,'000000')=t.MO_PR	
	
	if(@zapRC-@zapA)<>0	
	begin
		insert @et values(588,13)
	end	
end

--Поиск некорректных данных с ошибкой 588 в SLUCH
if NOT EXISTS(select * from @et)
begin
	
	if EXISTS(select * from (select ROW_NUMBER() OVER(order by t.IDCASE asc) as id,t.IDCASE from #t5 t) t where id<>IDCASE)
	begin
		insert @et values(588,14)
	end
end

if NOT EXISTS(select * from @et)
begin
declare @caseRC int,
		@caseA int
	---Изменения от 23.03.2012 заменил функцию на ХП
	---проверяем совпадение по случаям предоставленным МУ и то что должны предоставить
	--считаем количество строк по случаем в файле
select @caseA=count(*)  from #t5 t	
----------2012-12-29
create table #case
(
	ID_Patient varchar(36) NOT NULL,
	GUID_Case uniqueidentifier NOT NULL,
	rf_idV006 tinyint NULL,
	rf_idV008 smallint NULL,
	rf_idDirectMO char(6) NULL,
	HopitalisationType tinyint NULL,
	rf_idMO char(6) NOT NULL,
	rf_idV002 smallint NOT NULL,
	IsChildTariff bit NOT NULL,
	NumberHistoryCase nvarchar(50) NOT NULL,
	DateBegin date NOT NULL,
	DateEnd date NOT NULL,
	DS0 char(10) NULL,
	DS1 char(10) NULL,
	DS2 char(10) NULL,
	MES char(16) NULL,
	rf_idV009 smallint NOT NULL,
	rf_idV012 smallint NOT NULL,
	rf_idV004 int NOT NULL,
	IsSpecialCase tinyint NULL,
	rf_idV010 tinyint NOT NULL,
	Quantity decimal(5, 2) NULL,
	Tariff decimal(15, 2) NULL,
	AmountPayment decimal(15, 2) NOT NULL,
	SANK_MEK decimal(15, 2) NULL,
	SANK_MEE decimal(15, 2) NULL,
	SANK_EKMP decimal(15, 2) NULL,
	[Emergency] tinyint NULL
	
)
if OBJECT_ID('tempDB..#case',N'U') is not null
begin
	exec usp_GetCaseFromRegisterCaseDB @account,@codeMO,@month,@year
end
												
	select @caseRC=COUNT(distinct t.GUID_Case)
	from #case t inner join #t5 t1 on
			ID_PAC=upper(t.ID_Patient) 
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
			and ISNULL(t.[Emergency],0)=ISNULL(t1.F_SP,0)
			
			
			SELECT * FROM #case WHERE GUID_Case IN ('3B96065C-2D49-4535-8B02-6C12B102B1FE','506ACC78-E52D-4D49-A444-097C5C65DA72')
			
			SELECT t1.*
			from #case t right join #t5 t1 on
			ID_PAC=upper(t.ID_Patient) 
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
			and ISNULL(t.[Emergency],0)=ISNULL(t1.F_SP,0)
			WHERE t.GUID_Case IS null
			
	SELECT @caseA,@caseRC
	
	if(isnull(@caseRC,0)-isnull(@caseA,0))<>0
	begin
		insert @et values(588,15)
	end
end
--Поиск некорректных данных с ошибкой 588 в USL
--проверка на порядок
if NOT EXISTS(select * from @et)
begin
	
	if EXISTS(select * from (select ROW_NUMBER() OVER(order by t.IDSERV asc) as id,t.IDSERV from #t6 t) t where id<>IDSERV)
	begin
		insert @et values(588,16)
	end
end
if NOT EXISTS(select * from @et)
begin
declare @meduslugiRC int,
		@meduslugiA int
--внес изменения т.к при зачистке данных в базе Реестров сведений за Страмным удалил хирургические операции.
	select @meduslugiA=count(*) from #t6 t inner join vw_sprMU m on  
			t.CODE_USL=m.MU
	CREATE TABLE #meduslugi 
		(
			GUID_Case uniqueidentifier NOT NULL,
			id int NOT NULL,
			GUID_MU uniqueidentifier NOT NULL,
			rf_idMO char(6) NOT NULL,
			rf_idV002 smallint NOT NULL,
			IsChildTariff bit NOT NULL,
			DateHelpBegin date NOT NULL,
			DateHelpEnd date NOT NULL,
			DiagnosisCode char(10) NOT NULL,
			MUCode varchar(16) NOT NULL,
			Quantity decimal(6, 2) NOT NULL,
			Price decimal(15, 2) NOT NULL,
			TotalPrice decimal(15, 2) NOT NULL,
			rf_idV004 int NOT NULL
		)		
	EXEC usp_GetMeduslugiFromRegisterCaseDB @account,@codeMO,@month,@year						
													
	select @meduslugiRC=COUNT(distinct t0.GUID_MU)
	from #meduslugi t0 inner join #t6 t on
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
			--		inner join vw_sprMU m on   --надо отключить будит в понедельник
			--t0.MUCode=m.MU
			
	--SELECT t.*
	--from #meduslugi t0 RIGHT join #t6 t on
	--		ID_C=t0.GUID_Case
	--		and ID_U= GUID_MU
	--		and LPU=rf_idMO
	--		and PROFIL=rf_idV002
	--		and DET =IsChildTariff
	--		and DATE_IN =DateHelpBegin
	--		and DATE_OUT =DateHelpEnd
	--		and rtrim(DS) =rtrim(DiagnosisCode)
	--		and rtrim(CODE_USL)=rtrim(MUCode)
	--		and KOL_USL= Quantity
	--		and TARIF=Price
	--		and SUMV_USL =TotalPrice
	--		and PRVS=rf_idV004
	--		--		inner join vw_sprMU m on   --надо отключить будит в понедельник
	--		--t0.MUCode=m.MU
	--		WHERE t0.GUID_MU IS null
			
	
		DROP TABLE #meduslugi
	if(isnull(@meduslugiRC,0)-isnull(@meduslugiA,0))<>0
	begin
		insert @et values(588,17)
	end
end

--проверка на кооректное выставление мед.услуг в случае
if NOT EXISTS(select * from @et)
begin
	if EXISTS(	
				select c.ID_C,c.SUMV
				from #t5 c inner join #t6 m on 
						c.ID_C=m.ID_C
						and c.IDCASE=m.IDCASE
				where c.CODE_MES1 is null
				group by c.ID_C,c.SUMV
				having c.SUMV<>cast(SUM(m.KOL_USL*m.TARIF) as decimal(15,2))
			  )	
	begin
			insert @et values(588,18)
	end
end

if NOT EXISTS(select * from @et)
begin
---------поиск случаев без медуслуг
	if EXISTS(	
				select c.* 
				from #t5 c left join #t6 m on 
						c.ID_C=m.ID_C
						and c.IDCASE=m.IDCASE
				where c.CODE_MES1 is null and m.ID_U is null
			  )	
	begin
		insert @et values(588,19)
	end
END
----------01.04.2013
if NOT EXISTS(select * from @et)
begin
---------поиск случаев без медуслуг для ЗС с кодом 2.78.*; 70.*.*;72.*.*
	if EXISTS(	
				select c.* 
				from #t5 c INNER JOIN (SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72
										) mc ON
						c.CODE_MES1=mc.MU
							left join #t6 m on 
						c.ID_C=m.ID_C
						and c.IDCASE=m.IDCASE
				where c.CODE_MES1 IS NOT NULL and m.ID_U is null
			  )	
	begin
		insert @et values(588,19)
	end
end
---------------------------------Проверка данных из файла L----------------------------------------------------------------------
if NOT EXISTS(select * from @et)
begin
	declare @persA int,
			@persRC int,	
			@idf int
			
	select top 1 @idf=f.rf_idFiles
	from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack a on 
				f.id=a.rf_idFilesBack
				and f.CodeM=@codeMO
				and a.NumberRegister=@number
				and a.PropertyNumberRegister=@property
				
	select @persRC=COUNT(*) 
	from(
			select distinct r1.ID_Patient,rp.Fam,rp.Im,rp.Ot,rp.rf_idV005 as W,rp.BirthDay as DR,ra.Fam as Fam_P, ra.Im as IM_P, ra.Ot as Ot_P,ra.rf_idV005 as W_P,
				  ra.BirthDay as DR_P, rp.BirthPlace as MR, doc.rf_idDocumentType as DOCTYPE, doc.SeriaDocument as DOCSER, doc.NumberDocument as DOCNUM, 
				  doc.SNILS, doc.OKATO as OKATOG, doc.OKATO_Place as OKATOP
			from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack a on 
				f.id=a.rf_idFilesBack
				and f.rf_idFiles=@idF			
									inner join RegisterCases.dbo.t_RecordCaseBack r on
				a.id=r.rf_idRegisterCaseBack
				and r.TypePay=1
									inner join RegisterCases.dbo.t_RecordCase r1 on
				r.rf_idRecordCase=r1.id
									inner join RegisterCases.dbo.t_PatientBack p on
				r.id=p.rf_idRecordCaseBack
				and p.rf_idSMO=@smo
									inner join RegisterCases.dbo.t_RefRegisterPatientRecordCase rf on				
				r1.id=rf.rf_idRecordCase
									inner join RegisterCases.dbo.t_RegisterPatient rp on
				rf.rf_idRegisterPatient=rp.id
				and rp.rf_idFiles=@idF
									left join RegisterCases.dbo.t_RegisterPatientAttendant ra on
				rp.id=ra.rf_idRegisterPatient
									left join RegisterCases.dbo.t_RegisterPatientDocument doc on
				rp.id=doc.rf_idRegisterPatient
		) t inner join #t8 t1 on
			t.ID_Patient=t1.ID_PAC
			and t.FAM =t1.FAM 
			and t.IM =t1.IM 
			and t.OT=t1.OT 
			and t.W =t1.W 
			and t.DR =t1.DR 
			and isnull(t.FAM_P,'')=isnull(t1.FAM_P,'')
			and isnull(t.FAM_P,'')=isnull(t1.FAM_P,'')
			and isnull(t.OT_P,'') =isnull(t1.OT_P,'') 
			and isnull(t.W_P,'') =isnull(t1.W_P,'') 
			and isnull(t.DR_P,'') =isnull(t1.DR_P,'') 
			and isnull(t.MR,'') =isnull(t1.MR,'') 
			and isnull(t.DOCTYPE,'')=isnull(t1.DOCTYPE,'')
			and isnull(t.DOCSER,'') =isnull(t1.DOCSER,'') 
			and isnull(t.DOCNUM,'') =isnull(t1.DOCNUM,'') 
			and isnull(t.SNILS,'') =isnull(t1.SNILS,'') 
			and isnull(t.OKATOG,'') =isnull(t1.OKATOG,'') 
			and isnull(t.OKATOP,'') =isnull(t1.OKATOP,'') 

	select @persA=COUNT(*) from #t8

	if(@persRC-@persRC)<>0	
	begin
		insert @et values(588,20)
	end	
end
-------------------------------------------------------------------------------------------------------
SELECT * FROM @et
--------------------------------------------
drop table #t3
drop table #t5
drop table #t6


GO


