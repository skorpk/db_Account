use tempdb
go
declare @doc xml,
		@idoc int
SELECT	@doc=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\20120203\HM255416S34001_120610.xml',SINGLE_BLOB) HRM (ZL_LIST)
----создаем временные таблицы
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
	COMENTSL nvarchar(250)
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
	COMENTU nvarchar(250)
)
create nonclustered index IX_tmpCase on #t5(ID_C,IDCASE)
create nonclustered index IX_tmpMU on #t6(ID_C,IDCASE)
----начинаем обработку xml файла
EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

insert #t5
SELECT N_ZAP,ID_PAC,IDCASE,ID_C,USL_OK,VIDPOM,NPR_MO,EXTR,LPU,PROFIL,DET,NHISTORY,replace(DATE_1,'-',''),replace(DATE_2,'-',''),DS0,DS1,DS2,CODE_MES1,RSLT,ISHOD,
		PRVS,OS_SLUCH,IDSP,ED_COL,TARIF,SUMV,SANK_MEK,SANK_MEE,SANK_EKMP,COMENTSL
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
			COMENTSL NVARCHAR(250) 
		)

insert #t6
SELECT IDCASE,ID_C,IDSERV,ID_U,LPU,PROFIL,DET,replace(DATE_IN,'-',''),replace(DATE_OUT,'-',''),DS,CODE_USL,KOL_USL,TARIF,SUMV_USL,PRVS,COMENTU
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
			COMENTU NVARCHAR(250) 
		)

EXEC sp_xml_removedocument @idoc




-----новая проверка
select c.* 
from #t5 c left join #t6 m on 
		c.ID_C=m.ID_C
		and c.IDCASE=m.IDCASE
where c.CODE_MES1 is null and m.ID_U is null

drop table #t5
drop table #t6