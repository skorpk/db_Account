USE RegisterCases
GO

ALTER PROC [dbo].[usp_Test448]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
INSERT #tError
SELECT DISTINCT c.id,448
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND c.rf_idV006=3 AND c.rf_idV008 IN(1,11,12,13) AND c.Comments IS NULL

INSERT #tError
SELECT DISTINCT c.id,448
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND c.rf_idV006=3 AND c.rf_idV008 IN(1,11,12,13) AND c.Comments IS NOT NULL AND DATALENGTH(c.Comments)<2

DECLARE @tN AS TABLE(ColumnN CHAR(3))

INSERT @tN( ColumnN ) VALUES  ( '3:;'),( '4:;'),( '5:;'),( '6:;')

INSERT #tError
SELECT DISTINCT c.id,448
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND c.rf_idV006=3 AND c.rf_idV008 IN(1,11,12,13) AND DATALENGTH(c.Comments)=3 AND NOT EXISTS(SELECT * FROM @tN t WHERE t.ColumnN=c.Comments)

---------CONTENT 2
SELECT c.id,c.Comments,(CONVERT([xml],replace(('<Root><Num num="'+REPLACE(REPLACE(REPLACE(c.Comments,':',''),';',''),'/',':') )+'" /></Root>',':','" /><Num num="'),0)) AS XMLNum
INTO #tmp
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND c.rf_idV006=3 AND c.rf_idV008 IN(1,11,12,13) AND DATALENGTH(c.Comments)>5 AND c.Comments<>':;'AND c.Comments NOT LIKE '[0-9]:;' 


INSERT #tError SELECT id,448 FROM #tmp WHERE Comments NOT LIKE ':[1-7],[a-zA-Z][0-9]%'

IF EXISTS(SELECT * FROM #tmp  WHERE Comments LIKE ':[0,9],[a-zA-Z][0-9]%')
BEGIN
	;WITH cte
	AS(
	SELECT s.id,m.c.value('@num[1]','varchar(30)') AS Comment
	FROM #tmp s CROSS APPLY s.XMLNum.nodes('/Root/Num') AS m(c)
	 WHERE Comments LIKE ':[0,9],[a-zA-Z][0-9]%'
	)			
	SELECT id,LEFT(comment,1) AS X
			,CASE WHEN DATALENGTH(comment)>1 then SUBSTRING(comment,3,CHARINDEX(',', comment, CHARINDEX(',', comment)+1)-3) ELSE NULL END AS DS
			,CASE WHEN DATALENGTH(comment)>1 then SUBSTRING(comment, CHARINDEX(',', comment, CHARINDEX(',', comment)+1)+1, CHARINDEX(',', comment, CHARINDEX(',', comment,CHARINDEX(',', comment)+1)+1)-CHARINDEX(',', comment, CHARINDEX(',', comment)+1)-1) ELSE NULL END  AS DS1
			,CASE WHEN DATALENGTH(comment)>1 then CAST(REPLACE(REVERSE(substring(REVERSE(comment),0,CHARINDEX(',',REVERSE(comment),0))),'-','') AS DATE) ELSE NULL END AS Date1  		
	INTO #tContent
	FROM cte

	IF EXISTS(SELECT 1 FROM #tContent WHERE X IS NOT NULL)
	begin  		
		INSERT #tError SELECT id,448 FROM #tContent WHERE X NOT IN(1,2,4,6,7)
	end
	ELSE
	BEGIN   
		INSERT #tError SELECT id,448 FROM #tContent WHERE DS1 IS NOT NULL AND  NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprMKBDN WHERE DiagnosisCode=DS1 AND DS1 IS NOT null)
		INSERT #tError SELECT id,448 FROM #tContent WHERE NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprMKBDN WHERE DiagnosisCode=DS)
	END 
	DROP TABLE #tContent
END 
go
ALTER PROC [dbo].[usp_Test458]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

CREATE TABLE #tNomencl(code VARCHAR(20), typeSPR tinyint)
--typeSPR=1 то стоматологическая
--typeSPR=1 то из справочника номенклатур
INSERT #tNomencl( code,typeSPR ) SELECT code,1 FROM oms_nsi.dbo.sprDentalMU WHERE isFormula=1

INSERT #tNomencl( code,typeSPR ) SELECT codeNomenclMU,2 FROM oms_nsi.dbo.sprNomenclMUBodyParts

INSERT #tError
SELECT DISTINCT c.id,458
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				
			  INNER JOIN dbo.t_Meduslugi m ON			  
		c.id=m.rf_idCase			  
			  INNER JOIN #tNomencl n ON
		m.MUSurgery=n.code            
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND typeSPR=1  AND  len(ISNULL(m.Comments,''))=0 AND c.rf_idV006=3 AND c.rf_idV002 IN(85,86,87,88,89,90,140,171)

CREATE TABLE #tUsl (rf_idV006 TINYINT, rf_idV008 SMALLINT)
INSERT #tUsl( rf_idV006, rf_idV008 ) VALUES  ( 1,31),(2,null)

INSERT #tError
SELECT DISTINCT c.id,458
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								             
		AND c.DateEnd>='20190101'				
				INNER JOIN #tUsl u ON
		c.rf_idV006=u.rf_idV006
		AND c.rf_idV008=ISNULL(u.rf_idV008,c.rf_idV008) 
			  INNER JOIN dbo.t_Meduslugi m ON			  
		c.id=m.rf_idCase			  
			  INNER JOIN #tNomencl n ON
		m.MUSurgery=n.code            
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND typeSPR=2  AND  len(ISNULL(m.Comments,''))=0


------------Распарсиваем парные органы----------------------

SELECT c.id,m.MUSurgery,CAST(replace( ('<Root><Num num="'+m.Comments)+'" /></Root>', ',' ,'" /><Num num="') AS XML) AS XMLNum
INTO #t
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'
		  	  INNER JOIN #tUsl u ON
		c.rf_idV006=u.rf_idV006
		AND c.rf_idV008=ISNULL(u.rf_idV008,c.rf_idV008) 				
			  INNER JOIN dbo.t_Meduslugi m ON			  
		c.id=m.rf_idCase			  
			  INNER JOIN #tNomencl n ON
		m.MUSurgery=n.code            
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND n.typeSPR=2 AND len(ISNULL(m.Comments,''))>0 AND c.rf_idV006<3

;WITH cte
AS(
SELECT s.id,s.MUSurgery,m.c.value('@num[1]','int') AS CodeParts
FROM #t s CROSS APPLY s.XMLNum.nodes('/Root/Num') as m(c)
)
INSERT #tError SELECT DISTINCT id,458 FROM cte c WHERE NOT EXISTS(SELECT 1 FROM vw_sprNomenclBodyParts WHERE codeNomenclMU=c.MUSurgery AND code=CodeParts)

------------Распарсиваем зубки----------------------

INSERT #tError SELECT DISTINCT c.id,458
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				
			  INNER JOIN dbo.t_Meduslugi m ON			  
		c.id=m.rf_idCase			  
			  INNER JOIN #tNomencl n ON
		m.MUSurgery=n.code            
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND n.typeSPR=1 AND len(ISNULL(m.Comments,''))>0 AND c.rf_idV006=3 AND c.rf_idV002 IN(85,86,87,88,89,90,140,171)
		AND m.Comments LIKE '%[a-zA-Zа-яА-Я!|\/.:; *]%'

CREATE TABLE #tDentalPosition(toothID tinyint)
INSERT #tDentalPosition( toothID )
VALUES (11),(12),(13),(14),(15),(16),(17),(18),(21),(22),(23),(24),(25),(26),(27),(28),(31),(32),(33),(34),(35),(36),(37),(38),(41),(42),(43),(44),(45),(46),(47),(48),(51),(52),(53),(54),(55),(61),(62),(63),(64),(65),(71),(72),(73),(74),(75),(81),(82),(83),(84),(85)

SELECT c.id,m.MUSurgery,CAST(replace( ('<Root><Num num="'+m.Comments)+'" /></Root>', ',' ,'" /><Num num="') AS XML) AS XMLNum
INTO #t2
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				
			  INNER JOIN dbo.t_Meduslugi m ON			  
		c.id=m.rf_idCase			  
			  INNER JOIN #tNomencl n ON
		m.MUSurgery=n.code            
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND n.typeSPR=1 AND len(ISNULL(m.Comments,''))>0 AND c.rf_idV006=3 AND c.rf_idV002 IN(85,86,87,88,89,90,140,171)
	AND m.Comments NOT LIKE '%[a-zA-Zа-яА-Я!|\/.:; *]%'

;WITH cte
AS(
SELECT s.id,m.c.value('@num[1]','varchar(20)') AS ToothId2
FROM #t2 s CROSS APPLY s.XMLNum.nodes('/Root/Num') as m(c)
)
SELECT id INTO #toothId FROM cte WHERE LEN(ToothID2)>2

INSERT #tError SELECT id, 458 from #toothId

;WITH cte
AS(
SELECT s.id,m.c.value('@num[1]','tinyint') AS ToothId2
FROM #t2 s CROSS APPLY s.XMLNum.nodes('/Root/Num') as m(c)
WHERE NOT EXISTS(SELECT 1 FROM #toothId WHERE id=s.id)
)
INSERT #tError SELECT DISTINCT id,458 FROM cte c WHERE NOT EXISTS(SELECT 1 FROM #tDentalPosition WHERE toothID=c.ToothId2)

DROP TABLE #t
DROP TABLE #t2
DROP TABLE #toothId
DROP TABLE #tDentalPosition
DROP TABLE #tNomencl
DROP TABLE #tUsl

GO
GO
ALTER proc [dbo].[usp_DefineSMOIteration2_4]
			@id int,---23.05.2012
			@iteration tinyint,
			@file varchar(26)
			
as
SET xact_abort ON;

--В таблицу ZP1LOG добовляю записи о файле. В качестве имени файла @iteration+@file
declare @count int,
		@fileName varchar(27)=CAST(@iteration as CHAR(1))+@file
---23.05.2012
select @count=count(r.rf_idCase) 
from t_RefCasePatientDefine r 
where rf_idFiles=@id and NOT EXISTS(SELECT * FROM t_CasePatientDefineIteration WHERE rf_idRefCaseIteration=r.id)

--объявляю переменную для того что бы передать ее в удаленную процедуру
declare @xml nvarchar(max)
-- добавляю данные в таблицу PolicyRegister.dbo.ZP1
create table #tmpPerson
(
			RECID bigint,
			FAM varchar(25),
			IM varchar(20),
			OT varchar(20),
			DR date ,
			W tinyint,
			OPDOC varchar(1),
			SPOL varchar(20),
			NPOL varchar(20),
			DOUT datetime,
			DOCTP varchar(2),
			DOCS varchar(20),
			DOCN varchar(20),
			SS varchar(14)
)

if @iteration=2
begin
insert #tmpPerson
select distinct t.id as RECID, left(rtrim(p.Fam),25) as FAM, left(rtrim(p.Im),20) as IM, left(rtrim(p.Ot),20) as OT, p.BirthDay as DR,ISNULL(p.rf_idV005_A,p.rf_idV005) as W, rc.rf_idF008 as OPDOC,
		rtrim(rc.SeriaPolis) as SPOL,rtrim(rc.NumberPolis) as NPOL,c.DateEnd as DOUT,pd.rf_idDocumentType as DOCTP ,rtrim(pd.SeriaDocument) as DOCS,
		rtrim(pd.NumberDocument) as DOCN, pd.SNILS as SS
from (
		select r.id, r.rf_idCase,r.rf_idRegisterPatient
		from t_RefCasePatientDefine r 
	    where rf_idFiles=@id and (IsUnloadIntoSP_TK is null)
	 ) t inner join t_Case c on
					t.rf_idCase=c.id 
		inner join vw_RegisterPatient p on
					t.rf_idRegisterPatient=p.id
		inner join t_RecordCase rc on
					p.rf_idRecordCase=rc.id
					and rc.id=c.rf_idRecordCase
		left join t_RegisterPatientDocument pd on
					p.id=pd.rf_idRegisterPatient

end	
if @iteration=4 AND @count>0
begin
insert #tmpPerson
select distinct t.id as RECID, left(rtrim(p.Fam),25) as FAM, left(rtrim(p.Im),20) as IM, left(rtrim(p.Ot),20) as OT, p.BirthDay as DR,
		ISNULL(p.rf_idV005_A,p.rf_idV005) as W, rc.rf_idF008 as OPDOC,
		rtrim(rc.SeriaPolis) as SPOL,rtrim(rc.NumberPolis) as NPOL,c.DateEnd as DOUT,pd.rf_idDocumentType as DOCTP ,rtrim(pd.SeriaDocument) as DOCS,
		rtrim(pd.NumberDocument) as DOCN, pd.SNILS as SS
from (--получаем список записей которые не определены
		select r.id, r.rf_idCase,r.rf_idRegisterPatient
		from t_RefCasePatientDefine r 
	    where rf_idFiles=@id and NOT EXISTS(SELECT * FROM t_CasePatientDefineIteration WHERE rf_idRefCaseIteration=r.id)	    
	 ) t inner join t_Case c on
					t.rf_idCase=c.id 
		inner join vw_RegisterPatient p on
					t.rf_idRegisterPatient=p.id
		inner join t_RecordCase rc on
					p.rf_idRecordCase=rc.id
					and rc.id=c.rf_idRecordCase
		left join t_RegisterPatientDocument pd on
					p.id=pd.rf_idRegisterPatient
	
end
if(select @@SERVERNAME)!='TSERVER' AND @count>0
begin
	insert t_CaseDefineZP1(rf_idRefCaseIteration,rf_idZP1) exec PolicyRegister.dbo.usp_InsertFilesZP1 @fileName,@count,@xml
end
GO
ALTER proc [dbo].[usp_InsertRegisterCaseFileH2019]
			@doc xml,
			@patient xml,
			@file varbinary(max),
			@countSluch INT=0
as
DECLARE @idoc int,
		@ipatient int,
		@id int,
		@idFile int

---create tempory table----------------------------------------------
declare @t1 as table([VERSION] char(5),DATA date,[FILENAME] varchar(26),SD_Z INT)

declare @t2 as table(CODE BIGINT,CODE_MO int,[YEAR] smallint,[MONTH] tinyint,NSCHET int,DSCHET date,SUMMAV numeric(11, 2),COMENTS nvarchar(250)) 

create table #t3(
				    N_ZAP int,
					PR_NOV tinyint,
					ID_PAC nvarchar(36),
					VPOLIS tinyint,
					SPOLIS nchar(10),
					NPOLIS nchar(20),
					ENP VARCHAR(16), 
					ST_OKATO VARCHAR(5), 
					SMO nchar(5),
					SMO_OK nchar(5),
					SMO_NAM nvarchar(100),
					NOVOR nchar(9),
					MO_PR nchar(6),
					VNOV_D SMALLINT								
				)
------------------сведения о признании лица инвалидом---------------------
CREATE TABLE #tDisabiliti(N_ZAP int,ID_PAC nvarchar(36), INV TINYINT,DATA_INV DATE, REASON_INV TINYINT, DS_INV VARCHAR(10))

create table #t5(N_ZAP int,
				 ID_PAC nvarchar(36),
				 IDCASE bigint,
				 ID_C uniqueidentifier,
				 USL_OK tinyint,
				 VIDPOM smallint,
				 FOR_POM tinyint,
				 VID_HMP varchar(19),
				 METOD_HMP int,
				 NPR_MO nchar(6),				 
				 EXTR tinyint,
				 LPU nchar(6),
				 LPU_1 nchar(8),
				 PODR INT,
				 PROFIL smallint, 				 
				 DET tinyint,	  				 
				 TAL_D DATE, 
				 TAL_P DATE,	  				 
				 NHISTORY nvarchar(50), 
				 P_PER CHAR(1),
				 DATE_1 date,
				 DATE_2 date,
				 DS0 nchar(10),
				 DS1 nchar(10),
				 DN TINYINT,--18.04.2018
				 CODE_MES1 nchar(20),
				 RSLT smallint,
				 ISHOD smallint,
				 PRVS bigint,
				 OS_SLUCH tinyint,
				 IDSP tinyint,
				 ED_COL numeric(5, 2),
				 TARIF numeric(15, 2),
				 SUMV numeric(15, 2),
				 REFREASON tinyint,
				 SANK_MEK numeric(15, 2),
				 SANK_MEE numeric(15, 2),
				 SANK_EKMP numeric(15, 2),
				 COMENTSL nvarchar(250),
				 F_SP tinyint,
				 IDDOCT VARCHAR(25),				 
				 IT_SL DECIMAL(3,2),
				 AD_CRITERION VARCHAR(20),
				 NEXT_VISIT DATE,
				 NPR_DATE DATE,
				 PROFIL_K smallint,
				 P_CEL NVARCHAR(3),
				 TAL_NUM NVARCHAR(20),
				 DKK2 NVARCHAR(10),
				 DS_ONK TINYINT, 
				 C_ZAB TINYINT,
				 MSE TINYINT,
				 SL_ID UNIQUEIDENTIFIER,
				 VB_P TINYINT,
				 Date_Z_1 DATE, 		
				 Date_Z_2 DATE,
				 KD_Z SMALLINT,
				 SUM_M DECIMAL(15,2),
				 KD SMALLINT
				 )
					 
CREATE TABLE #tDS(IDCASE int,ID_C uniqueidentifier,DS varchar(10), TypeDiagnosis TINYINT, SL_ID UNIQUEIDENTIFIER)

CREATE TABLE #tBW(IDCASE int,ID_C uniqueidentifier, BirthWeight SMALLINT, SL_ID UNIQUEIDENTIFIER)

CREATE TABLE #tCoeff(IDCASE BIGINT,ID_C uniqueidentifier, CODE_SL SMALLINT,VAL_C DECIMAL(3,2), SL_ID UNIQUEIDENTIFIER)
---new tempory table 27.12.2017
CREATE TABLE #tKiro(IDCASE BIGINT,ID_C UNIQUEIDENTIFIER,CODE_KIRO INT, VAL_K DECIMAL(3,2), SL_ID UNIQUEIDENTIFIER)
--20.12.2018
CREATE TABLE #ONK_SL
					(
						IDCASE int,
						ID_C UNIQUEIDENTIFIER,
						DS1_T TINYINT,
						STAD SMALLINT, --не обязательные к заполнению
						ONK_T SMALLINT,--не обязательные к заполнению
						ONK_N SMALLINT,--не обязательные к заполнению
						ONK_M SMALLINT,--не обязательные к заполнению
						MTSTZ TINYINT,
						SOD DECIMAL(5,2),						
						SL_ID UNIQUEIDENTIFIER,
						K_FR TINYINT,
						WEI DECIMAL(5,1),
						HEI TINYINT,
						BSA DECIMAL(3,2)							
						 )
CREATE TABLE #B_DIAG(IDCASE int,ID_C UNIQUEIDENTIFIER,DIAG_TIP TINYINT,DIAG_CODE SMALLINT, DIAG_RSLT SMALLINT, DIAG_DATE date, SL_ID UNIQUEIDENTIFIER, REC_RSLT TINYINT)
CREATE TABLE #B_PROT(IDCASE int,ID_C UNIQUEIDENTIFIER,PROT TINYINT,D_PROT DATE, SL_ID UNIQUEIDENTIFIER)
						
					 
create table #t6(IDCASE int,ID_C uniqueidentifier,IDSERV nvarchar(36),ID_U uniqueidentifier,LPU nchar(6),PROFIL smallint,
			VID_VME nvarchar(15),DET tinyint,DATE_IN date,DATE_OUT date,
			DS nchar(10),CODE_USL nchar(20),KOL_USL numeric(6, 2),TARIF numeric(15, 2),SUMV_USL numeric(15, 2),
			PRVS bigint,COMENTU nvarchar(250),PODR INT,CODE_MD VARCHAR(25),LPU_1 NVARCHAR(6), SL_ID UNIQUEIDENTIFIER
			)

create table #NAPR(IDCASE int,ID_C uniqueidentifier,NAPR_DATE DATE, NAPR_MO VARCHAR(6),NAPR_V TINYINT,MET_ISSL TINYINT,NAPR_USL VARCHAR(15), SL_ID UNIQUEIDENTIFIER)
create table #CONS(IDCASE int,ID_C uniqueidentifier,SL_ID UNIQUEIDENTIFIER,PR_CONS TINYINT, DT_CONS DATE)
--20.12.2018
create table #KSG_KPG(IDCASE int,ID_C uniqueidentifier,SL_ID UNIQUEIDENTIFIER,N_KSG VARCHAR(20),CRIT VARCHAR(10),SL_K TINYINT,IT_SL DECIMAL(3,2))

--20.12.2018
create table #ONK_USL
	(
		IDCASE int,
		ID_C uniqueidentifier,
		SL_ID UNIQUEIDENTIFIER,		
		USL_TIP TINYINT, 
		HIR_TIP TINYINT, 
		LEK_TIP_L TINYINT,
		LEK_TIP_V TINYINT,
		LUCH_TIP TINYINT,
		PPTR TINYINT
   )      

create table #LEK_PR
	(
		IDCASE int,
		ID_C uniqueidentifier,
		SL_ID UNIQUEIDENTIFIER,		
		USL_TIP TINYINT, 
		REGNUM NVARCHAR(6),
		CODE_SH NVARCHAR(10),
		DATE_INJ DATE
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
	TEL VARCHAR(10),
	FAM_P nvarchar(40),
	IM_P nvarchar(40),
	OT_P nvarchar(40),
	W_P tinyint,
	DR_P DATE,
	MR nvarchar(100),
	DOCTYPE nchar(2),
	DOCSER nchar(10),
	DOCNUM nchar(20),
	SNILS nchar(14),
	OKATOG nchar(11),
	OKATOP nchar(11),
	COMENTP nvarchar(250)
)

CREATE TABLE #tDost(ID_PAC nvarchar(36),DOST TINYINT, IsAttendant BIT)

declare @tempID as table(id int, ID_PAC nvarchar(36),N_ZAP int)

declare @tableId as table(id int,ID_PAC nvarchar(36))
---------------------------------------------------------------------
EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

insert @t1
SELECT [version],REPLACE(DATA,'-',''),[FILENAME],SD_Z
FROM OPENXML (@idoc, 'ZL_LIST/ZGLV',2)
	WITH(
			[VERSION] NCHAR(5) './VERSION',
			[DATA] NCHAR(10) './DATA',
			[FILENAME] NCHAR(26) './FILENAME',
			SD_Z INT './SD_Z'
		)
--SELECT * FROM @t1		

insert @t2
select CODE,CODE_MO,[YEAR],[MONTH],NSCHET,replace(DSCHET,'-',''),SUMMAV,COMENTS
FROM OPENXML (@idoc, 'ZL_LIST/SCHET',2)
	WITH 
	(	
		CODE bigint './CODE',
		CODE_MO int './CODE_MO',
		[YEAR]	smallint './YEAR',
		[MONTH] tinyint './MONTH',
		NSCHET int './NSCHET',
		DSCHET nchar(10) './DSCHET',
		SUMMAV decimal(11,2) './SUMMAV',
		COMENTS nvarchar(250) './COMENTS'		
	)
--SELECT * FROM @t2

insert #t3
SELECT N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,ENP,ST_OKATO,SMO,SMO_OK,SMO_NAM,NOVOR,MO_PR,VNOV_D
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/PACIENT',2)
	WITH(
			N_ZAP int '../N_ZAP',
			PR_NOV tinyint '../PR_NOV',
			ID_PAC nvarchar(36),
			VPOLIS tinyint ,
			SPOLIS nchar(10),
			NPOLIS nchar(20),
			ENP VARCHAR(16),
			ST_OKATO VARCHAR(5),
			SMO nchar(5) ,
			SMO_OK nchar(5),
			SMO_NAM nvarchar(100),
			NOVOR nchar(9),
			MO_PR nchar(6),
			VNOV_D SMALLINT
		)

--SELECT * FROM #t3

INSERT #tDisabiliti( N_ZAP ,ID_PAC ,INV ,DATA_INV ,REASON_INV ,DS_INV)
SELECT N_ZAP, ID_PAC, INV,REPLACE(DATA_INV,'-',''),REASON_INV,DS_INV
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/PACIENT/DISABILITY',3)
	WITH(
			N_ZAP int '../../N_ZAP',
			ID_PAC nvarchar(36) '../ID_PAC',
			INV TINYINT,
			DATA_INV nchar(10),
			REASON_INV TINYINT,
			DS_INV VARCHAR(10) 
		)
--SELECT * FROM #tDisabiliti

insert #t5( N_ZAP ,ID_PAC ,IDCASE ,ID_C ,USL_OK ,VIDPOM ,FOR_POM ,VID_HMP ,METOD_HMP ,NPR_MO ,EXTR ,LPU ,PROFIL ,DET ,TAL_D ,TAL_P ,NHISTORY ,
			P_PER ,DATE_1 ,DATE_2 ,DS0 ,DS1 ,CODE_MES1 ,RSLT ,ISHOD ,PRVS ,OS_SLUCH ,IDSP ,ED_COL ,TARIF ,SUMV ,COMENTSL ,F_SP ,IDDOCT ,IT_SL,PODR,LPU_1
			,AD_CRITERION,NEXT_VISIT,NPR_DATE,PROFIL_K,P_CEL,TAL_NUM,DN,DKK2,DS_ONK,MSE, C_ZAB ,VB_P,SL_ID,Date_Z_1, Date_Z_2, KD_Z,SUM_M,KD
        )
SELECT N_ZAP,ID_PAC,IDCASE,ID_C,USL_OK,VIDPOM,
		FOR_POM,
		CASE WHEN LEN(VID_HMP)=0 THEN NULL ELSE VID_HMP END,
		CASE WHEN LEN(METOD_HMP)=0 THEN NULL ELSE METOD_HMP END,--13.01.2014					
		NPR_MO, EXTR, LPU, PROFIL, DET, TAL_D,TAL_P, NHISTORY, P_PER, replace(DATE_1,'-',''), replace(DATE_2,'-',''),DS0,DS1,CODE_MES1,RSLT,ISHOD,
		PRVS,OS_SLUCH,IDSP,ED_COL,TARIF,SUMV,COMENTSL,F_SP,IDDOKT,IT_SL,PODR,LPU_1, AD_CRITERION, replace(NEXT_VISIT,'-',''),NPR_DATE,PROFIL_K,P_CEL,TAL_NUM,DN,DKK2
		,DS_ONK,MSE, C_ZAB, VB_P,SL_ID,Date_Z_1, Date_Z_2, KD_Z,SUM_M, KD
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/Z_SL/SL',3)
	WITH(
			N_ZAP int '../../N_ZAP',
			ID_PAC nvarchar(36) '../../PACIENT/ID_PAC',
			IDCASE bigint '../IDCASE',		 --SL
			ID_C UNIQUEIDENTIFIER '../ID_C',	 --SL
			USL_OK tinyint '../USL_OK',
			VIDPOM smallint '../VIDPOM',
			FOR_POM tinyint '../FOR_POM',
			VID_HMP varchar(19),
			METOD_HMP int ,			
			NPR_MO nchar(6) '../NPR_MO',
			EXTR tinyint ,
			LPU nchar(6) '../LPU',
			LPU_1 NCHAR(8),
			PODR int,
			PROFIL smallint,
			DET tinyint ,
			TAL_D DATE,
			TAL_P DATE,
			NHISTORY nvarchar(50) ,
			P_PER CHAR(1),
			DATE_1 nchar(10) ,
			DATE_2 nchar(10) ,
			DS0 nchar(10) ,
			DS1 nchar(10) ,			
			CODE_MES1 nchar(20) ,			
			RSLT smallint '../RSLT',
			ISHOD smallint '../ISHOD',
			PRVS bigint ,			
			OS_SLUCH tinyint ,
			IDSP TINYINT '../IDSP',
			ED_COL DECIMAL(5,2) ,
			TARIF DECIMAL(15,2) ,	
			SUMV DECIMAL(15,2) '../SUMV',				
			COMENTSL NVARCHAR(250),
			F_SP TINYINT,
			IDDOKT VARCHAR(25),
			IT_SL DECIMAL(3,2),
			AD_CRITERION NVARCHAR(20),
			NEXT_VISIT NCHAR(10),			
			NPR_DATE DATE '../NPR_DATE',
			PROFIL_K SMALLINT,
			P_CEL NVARCHAR(3),
			TAL_NUM NVARCHAR(20),
			DN TINYINT,
			DKK2 NVARCHAR(10),
			DS_ONK TINYINT,
			MSE TINYINT '../MSE',
			C_ZAB TINYINT,
			SL_ID UNIQUEIDENTIFIER,
			VB_P TINYINT '../VB_P',
			DATE_Z_1 DATE '../DATE_Z_1', 
			DATE_Z_2 DATE '../DATE_Z_2',  
			KD_Z SMALLINT '../KD_Z',
			SUM_M DECIMAL(15,2),
			KD SMALLINT 
		)

--SELECT * FROM #t5
---множественность диагнозов		

INSERT #tDS (IDCASE,ID_C,DS,TypeDiagnosis,SL_ID) 
SELECT IDCASE,ID_C,DS2,3 , SL_ID
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/DS2',3)
WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../SL_ID',
			DS2 nchar(10) 'text()'  
	)
	
INSERT #tDS (IDCASE,ID_C,DS,TypeDiagnosis, SL_ID) 
SELECT IDCASE,ID_C,DS3,4 , SL_ID
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/DS3',3)
WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../SL_ID',			
			DS3 nchar(10) 'text()'  
	)
--SELECT * FROM #tDS

--Вес новорожденных
INSERT #tBW (IDCASE,ID_C,BirthWeight, SL_ID) 
SELECT IDCASE,ID_C,VNOV_M, SL_ID
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/VNOV_M',3)
WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../SL/SL_ID',
			VNOV_M smallint 'text()'  
	)	

--SELECT * FROM #tBW

INSERT #tCoeff( IDCASE, ID_C, CODE_SL, VAL_C, SL_ID )
SELECT IDCASE,ID_C,ID_SL,VAL_C, SL_ID
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/KSG_KPG/SL_KOEF',3)
WITH(
			IDCASE int '../../../IDCASE',
			ID_C uniqueidentifier '../../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../../SL_ID',
			ID_SL SMALLINT,
			VAL_C DECIMAL(3,2) 
	)
--SELECT * FROM #tCoeff
--20.12.2018
INSERT #KSG_KPG( IDCASE, ID_C, SL_ID,N_KSG,CRIT,SL_K,IT_SL )
SELECT IDCASE, ID_C, SL_ID,N_KSG,NULL AS CRIT,SL_K,IT_SL
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/KSG_KPG',3)
WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../SL_ID',
			N_KSG NVARCHAR(20) ,			
			SL_K TINYINT ,
			IT_SL DECIMAL(3,2) 
	)
UNION 
SELECT IDCASE, ID_C, SL_ID,N_KSG,CRIT,SL_K,IT_SL
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/KSG_KPG/CRIT',3)
WITH(
			IDCASE int '../../../IDCASE',
			ID_C uniqueidentifier '../../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../../SL_ID',
			N_KSG NVARCHAR(20) '../N_KSG',
			CRIT NVARCHAR(10) 'text()',--20.12.2018
			SL_K TINYINT '../SL_K',
			IT_SL DECIMAL(3,2) '../IT_SL'
	)
--SELECT * FROM #KSG_KPG 
INSERT #tKiro( IDCASE, ID_C, CODE_KIRO, VAL_K, SL_ID )
SELECT IDCASE,ID_C,CODE_KIRO,VAL_K, SL_ID
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/KSG_KPG/S_KIRO',3)
WITH(
			IDCASE int '../../../IDCASE',
			ID_C uniqueidentifier '../../../ID_C',	
			SL_ID UNIQUEIDENTIFIER '../../SL_ID',		
			CODE_KIRO SMALLINT,
			VAL_K DECIMAL(3,2) 
	)
--SELECT * FROM #tKiro
INSERT #NAPR(IDCASE ,ID_C ,NAPR_DATE, NAPR_MO ,NAPR_V ,MET_ISSL ,NAPR_USL,SL_ID )
SELECT IDCASE ,ID_C ,NAPR_DATE, NAPR_MO ,NAPR_V ,MET_ISSL ,NAPR_USL,SL_ID
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/Z_SL/SL/NAPR',3)
	WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',					
			SL_ID UNIQUEIDENTIFIER '../SL_ID',
			NAPR_DATE date,
			NAPR_MO nvarchar(6),
			NAPR_V TINYINT,
			MET_ISSL TINYINT,
			NAPR_USL NVARCHAR(15)
		)
--SELECT * FROM #NAPR

INSERT #CONS(IDCASE ,ID_C ,SL_ID, PR_CONS, DT_CONS )
SELECT IDCASE ,ID_C ,SL_ID, PR_CONS, DT_CONS
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/Z_SL/SL/CONS',3)
	WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',					
			SL_ID UNIQUEIDENTIFIER '../SL_ID',
			PR_CONS tinyint,
			DT_CONS date
		)
--SELECT * FROM #cons

--20.12.2018
INSERT #ONK_SL(IDCASE, ID_C,DS1_T ,STAD,ONK_T,ONK_N,ONK_M,MTSTZ,SOD, SL_ID,K_FR,WEI,HEI,BSA)
SELECT IDCASE,ID_C,DS1_T ,STAD,ONK_T,ONK_N,ONK_M,MTSTZ,SOD, SL_ID,K_FR,WEI,HEI,BSA
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/ONK_SL',3)
WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',		
			SL_ID UNIQUEIDENTIFIER '../SL_ID' ,
			DS1_T TINYINT,
			STAD SMALLINT,
			ONK_T smallint,
			ONK_N smallint,
			ONK_M smallint,
			MTSTZ TINYINT,
			SOD DECIMAL(5,2),
			K_FR TINYINT,
			WEI DECIMAL(5,1),
			HEI TINYINT,
			BSA DECIMAL(3,2)
	)
--SELECT * FROM #ONK_SL

INSERT #B_DIAG(IDCASE, ID_C,DIAG_TIP, DIAG_CODE, DIAG_RSLT,DIAG_DATE, SL_ID,REC_RSLT)
SELECT IDCASE, ID_C,DIAG_TIP, DIAG_CODE, DIAG_RSLT, DIAG_DATE, SL_ID ,REC_RSLT
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/ONK_SL/B_DIAG',3)
WITH(
			IDCASE int '../../../IDCASE',
			ID_C uniqueidentifier '../../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../../SL_ID' ,
			DIAG_DATE DATE,
			DIAG_TIP TINYINT, 
			DIAG_CODE SMALLINT, 
			DIAG_RSLT SMALLINT,
			REC_RSLT TINYINT			
	)
--SELECT * FROM #B_DIAG

INSERT #B_PROT(IDCASE, ID_C,PROT, D_PROT, SL_ID)
SELECT IDCASE, ID_C,PROT, D_PROT, SL_ID
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/ONK_SL/B_PROT',3)
WITH(
			IDCASE int '../../../IDCASE',
			ID_C uniqueidentifier '../../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../../SL_ID' ,
			PROT TINYINT, 
			D_PROT date
	)
--SELECT * FROM #B_PROT
--20.12.2018
INSERT #ONK_USL(IDCASE ,ID_C ,SL_ID ,USL_TIP , HIR_TIP , LEK_TIP_L ,LEK_TIP_V ,LUCH_TIP,PPTR)
SELECT IDCASE ,ID_C ,SL_ID ,USL_TIP , HIR_TIP , LEK_TIP_L ,LEK_TIP_V ,LUCH_TIP,PPTR
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/Z_SL/SL/ONK_SL/ONK_USL',3)
	WITH(
			IDCASE int '../../../IDCASE',
			ID_C uniqueidentifier '../../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../../SL_ID' ,			
			USL_TIP TINYINT, 
			HIR_TIP TINYINT, 
			LEK_TIP_L TINYINT,
			LEK_TIP_V TINYINT,
			LUCH_TIP TINYINT ,
			PPTR TINYINT
		)
--SELECT * FROM #ONK_USL
--новая таблица
INSERT #LEK_PR(IDCASE ,ID_C ,SL_ID ,USL_TIP , REGNUM, DATE_INJ,CODE_SH)
SELECT IDCASE ,ID_C ,SL_ID ,USL_TIP , REGNUM, DATE_INJ,CODE_SH
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/Z_SL/SL/ONK_SL/ONK_USL/LEK_PR/DATE_INJ',3)
	WITH(
			IDCASE int '../../../../../IDCASE',
			ID_C uniqueidentifier '../../../../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../../../../SL_ID' ,			
			USL_TIP TINYINT '../../USL_TIP', 
			REGNUM NVARCHAR(6) '../REGNUM', 
			CODE_SH NVARCHAR(10) '../CODE_SH', 
			DATE_INJ DATE 'text()'
		) 
--SELECT * FROM #LEK_PR

insert #t6
SELECT IDCASE,ID_C,IDSERV,ID_U,LPU,PROFIL,CASE when len(VID_VME)=0 THEN NULL ELSE VID_VME END,
		DET,replace(DATE_IN,'-',''),replace(DATE_OUT,'-',''),DS,CODE_USL,KOL_USL,TARIF,SUMV_USL,PRVS,COMENTU,PODR,CODE_MD,LPU_1, SL_ID
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/Z_SL/SL/USL',3)
	WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',
			SL_ID uniqueidentifier '../SL_ID',
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
			CODE_MD VARCHAR(25),
			LPU_1 NVARCHAR(6) 
		)

--SELECT * FROM #t6  
  
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
--SELECT * FROM @t7
		
INSERT #t8(ID_PAC, FAM, IM, OT, W, DR, TEL, FAM_P, IM_P, OT_P, W_P, DR_P, MR, DOCTYPE, DOCSER, DOCNUM, SNILS, OKATOG, OKATOP, COMENTP)
SELECT DISTINCT ID_PAC,CASE WHEN LEN(FAM)=0 THEN NULL ELSE FAM END ,CASE WHEN LEN(IM)=0 THEN NULL ELSE IM END ,
		CASE WHEN LEN(OT)=0 THEN NULL ELSE OT END ,W,replace(DR,'-',''), TEL,FAM_P,IM_P,OT_P,W_P,replace(DR_P,'-',''),MR,DOCTYPE,DOCSER,DOCNUM,SNILS,OKATOG,OKATOP,COMENTP
FROM OPENXML (@ipatient, 'PERS_LIST/PERS',2)
	WITH(
			ID_PAC NVARCHAR(36),
			FAM NVARCHAR(40),
			IM NVARCHAR(40),
			OT NVARCHAR(40),
			W TINYINT,
			DR NCHAR(10),
			TEL VARCHAR(10),
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
--SELECT * FROM #t8

--1- Код надежности относится к пациента
--2 Код надежности сопровождающего
INSERT #tDOST(ID_PAC, DOST,IsAttendant)				
SELECT DISTINCT ID_PAC,DOST,1
FROM OPENXML (@ipatient, 'PERS_LIST/PERS/DOST',2)
	WITH(
			ID_PAC NVARCHAR(36) '../ID_PAC',
			DOST tinyint  'text()'
		)

INSERT #tDOST(ID_PAC, DOST,IsAttendant)				
SELECT DISTINCT ID_PAC,DOST,2
FROM OPENXML (@ipatient, 'PERS_LIST/PERS/DOST_P',2)
	WITH(
			ID_PAC NVARCHAR(36) '../ID_PAC',
			DOST TINYINT 'text()'
		)  

--SELECT * FROM #tDOST

EXEC sp_xml_removedocument @ipatient
 
 
declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
begin TRY
------Insert into RegisterCase's tables------------------------------
insert t_FileTested(DateRegistration,[FileName],UserName) select GETDATE(),[FILENAME],ORIGINAL_LOGIN() from @t1

SELECT @countSluch=SD_Z from @t1

select @id=SCOPE_IDENTITY()
IF @@SERVERNAME!='SRVSQL2-ST1'
BEGIN
insert t_File(DateRegistration,FileVersion,DateCreate,FileNameHR,FileNameLR,rf_idFileTested,FileZIP,CountSluch)
select GETDATE(),[VERSION],DATA,FILENAME1,[FILENAME],@id,@file,@countSluch  from @t7
END
ELSE 
begin
insert t_File(DateRegistration,FileVersion,DateCreate,FileNameHR,FileNameLR,rf_idFileTested,FileZIP,CountSluch)
select GETDATE(),[VERSION],DATA,FILENAME1,[FILENAME],@id,NULL,@countSluch  from @t7
end

select @idFile=SCOPE_IDENTITY()

insert t_RegistersCase(rf_idFiles,idRecord,rf_idMO,ReportYear,ReportMonth,NumberRegister,DateRegister,AmountPayment,Comments)
select @idFile,CODE,CODE_MO,[YEAR],[MONTH],NSCHET,DSCHET,SUMMAV,COMENTS from @t2

PRINT('t_RegistersCase')

select @id=SCOPE_IDENTITY()
---добавить обработку ошибок по записям которые были отвергнуты на этапе ФЛК
----2012-01-02------------------
insert t_RecordCase(rf_idRegistersCase,idRecord,IsNew,ID_Patient,rf_idF008,SeriaPolis,NumberPolis,NewBorn,AttachLPU,BirthWeight)
output inserted.id,inserted.ID_Patient,inserted.idRecord into @tempID
select @id,N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,NOVOR,MO_PR,VNOV_D
from #t3 
group by N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,NOVOR,MO_PR,VNOV_D

PRINT('t_RecordCase')

--12.03.2012
insert t_PatientSMO(ref_idRecordCase,rf_idSMO,OKATO,Name,ENP,ST_OKATO)
select t2.id,t1.SMO,t1.SMO_OK,case when rtrim(ltrim(t1.SMO_NAM))='' then null else t1.SMO_NAM END
		,ENP,ST_OKATO
from #t3 t1 inner join @tempID t2 on
			t1.ID_PAC=t2.ID_PAC and
			t1.N_ZAP=t2.N_ZAP
group by t2.id,t1.SMO,t1.SMO_OK,t1.SMO_NAM,ENP,ST_OKATO

PRINT('t_PatientSMO')
----------Disability-----------------------
INSERT dbo.t_Disability( ref_idRecordCase ,TypeOfGroup ,DateDefine ,rf_idReasonDisability ,Diagnosis)
SELECT distinct  t2.id, t1.INV, t1.DATA_INV, t1.REASON_INV, t1.DS_INV
from #tDisabiliti t1 inner join @tempID t2 on
				t1.ID_PAC=t2.ID_PAC and
				t1.N_ZAP=t2.N_ZAP 

PRINT('t_Disability')

declare @tmpCase as table(id int,idRecord bigint,GUID_CASE uniqueidentifier)

insert t_Case(rf_idRecordCase, idRecordCase, GUID_Case, rf_idV006, rf_idV008,
			  rf_idV014,rf_idV018,rf_idV019,
			  rf_idDirectMO, HopitalisationType, rf_idMO, rf_idV002, IsChildTariff, 
			  NumberHistoryCase, DateBegin, DateEnd, rf_idV009, rf_idV012, rf_idV004, 
			  IsSpecialCase, rf_idV010, AmountPayment, Comments,Age,[Emergency],rf_idDoctor,IT_SL, TypeTranslation, rf_idDepartmentMO, rf_idSubMO, MSE, C_ZAB, KD)
output inserted.id,inserted.idRecordCase,inserted.GUID_Case into @tmpCase
select t2.id,t1.IDCASE,t1.SL_ID, t1.USL_OK,t1.VIDPOM,
		t1.FOR_POM,t1.VID_HMP,t1.METOD_HMP,
		t1.NPR_MO,t1.EXTR,t1.LPU,t1.PROFIL,t1.DET,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.RSLT,t1.ISHOD,
		t1.PRVS,t1.OS_SLUCH,t1.IDSP,t1.SUM_M,t1.COMENTSL
		,CASE WHEN t3.DR=t1.DATE_Z_1 THEN 0 ELSE (DATEDIFF(YEAR,t3.DR,t1.DATE_Z_1)-CASE WHEN 100*MONTH(t3.DR)+DAY(t3.DR)>100*MONTH(t1.DATE_Z_1)+DAY(t1.DATE_Z_1)-1 THEN 1 ELSE 0 END) end, F_SP
		,CASE WHEN t1.IDDOCT='0' THEN NULL ELSE t1.IDDOCT END,KK.IT_SL, t1.P_PER, t1.PODR, t1.LPU_1
		,MSE, C_ZAB	, KD
from #t5 t1 inner join @tempID t2 on
		t1.N_ZAP=t2.N_ZAP and
		t1.ID_PAC=t2.ID_PAC
			left join #t8 t3 on
		t1.ID_PAC=t3.ID_PAC
			LEFT JOIN #KSG_KPG kk ON
		t1.SL_ID=kk.SL_ID
		AND t1.ID_C=kk.ID_C        
group by t2.id,t1.IDCASE,t1.SL_ID, t1.USL_OK,t1.VIDPOM,
		t1.FOR_POM,t1.VID_HMP,t1.METOD_HMP,
		 t1.NPR_MO,t1.EXTR,t1.LPU,t1.PROFIL,t1.DET,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.RSLT,t1.ISHOD,
		t1.PRVS,t1.OS_SLUCH,t1.IDSP,t1.SUM_M,t1.COMENTSL
		,CASE WHEN t3.DR=t1.DATE_Z_1 THEN 0 ELSE (DATEDIFF(YEAR,t3.DR,t1.DATE_Z_1)-CASE WHEN 100*MONTH(t3.DR)+DAY(t3.DR)>100*MONTH(t1.DATE_Z_1)+DAY(t1.DATE_Z_1)-1 THEN 1 ELSE 0 END) end, F_SP
		,CASE WHEN t1.IDDOCT='0' THEN NULL ELSE t1.IDDOCT END,kk.IT_SL, t1.P_PER, t1.PODR, t1.LPU_1, KD
		,MSE, C_ZAB			

PRINT('t_Case')

INSERT dbo.t_CompletedCase( rf_idRecordCase ,idRecordCase ,GUID_ZSL ,DateBegin ,DateEnd ,VB_P ,HospitalizationPeriod ,AmountPayment)
SELECT DISTINCT t2.id,t1.IDCASE,t1.ID_C,Date_Z_1,Date_Z_2,VB_P,KD_Z,SUMV
from #t5 t1 inner join @tempID t2 on
		t1.N_ZAP=t2.N_ZAP and
		t1.ID_PAC=t2.ID_PAC

PRINT('t_CompletedCase')
------------------------------------------------------------------------------------------------------------------
INSERT dbo.t_SlipOfPaper( rf_idCase ,GetDatePaper ,DateHospitalization,NumberTicket)
SELECT c.id,t1.TAL_P, t1.TAL_D,t1.TAL_NUM
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.SL_ID
		and c.idRecord=t1.IDCASE
WHERE t1.TAL_P IS NOT NULL or t1.TAL_D IS NOT NULL OR t1.TAL_NUM IS NOT null
PRINT('t_SlipOfPaper')

----------NPR_DATE----------------------
INSERT dbo.t_DirectionDate( rf_idCase,DirectionDate)
SELECT c.id,t1.NPR_DATE
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.SL_ID
		and c.idRecord=t1.IDCASE
WHERE t1.NPR_DATE IS not NULL
PRINT('t_DirectionDate')
--16.07.2018
-------------t_DS_ONK_REAB-----------
INSERT dbo.t_DS_ONK_REAB( rf_idCase, DS_ONK )
SELECT c.id,t1.DS_ONK
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.SL_ID
		and c.idRecord=t1.IDCASE
WHERE t1.DS_ONK IS not NULL 
PRINT('t_DS_ONK_REAB')
----------PROFIL_K----------------------
INSERT dbo.t_ProfileOfBed( rf_idCase,rf_idV020)
SELECT c.id,t1.PROFIL_K
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.SL_ID
		and c.idRecord=t1.IDCASE
WHERE t1.PROFIL_K IS not NULL
PRINT('t_ProfileOfBed')
----------P_CEL----------------------
INSERT dbo.t_PurposeOfVisit( rf_idCase, rf_idV025, DN )
SELECT c.id,t1.P_CEL, t1.DN
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.SL_ID
		and c.idRecord=t1.IDCASE
WHERE t1.P_CEL IS not NULL OR t1.DN IS NOT NULL
PRINT('t_PurposeOfVisit')
----------DKK2----------------------
--20.12.2018
--INSERT dbo.t_CombinationOfSchema
--        ( rf_idCase, rf_idV024 )
--SELECT c.id,t1.DKK2
--from @tmpCase c inner join #KSG_KPG t1 on
--		c.GUID_Case=t1.SL_ID
--		and c.idRecord=t1.IDCASE
--WHERE t1.DKK2 IS not NULL
--PRINT('t_CombinationOfSchema')
--------DKK1--------------------
--20.12.2018
INSERT dbo.t_AdditionalCriterion( rf_idCase, rf_idAddCretiria )
SELECT c.id,t1.CRIT
from @tmpCase c inner join #KSG_KPG t1 on
		c.GUID_Case=t1.SL_ID
		and c.idRecord=t1.IDCASE
WHERE t1.CRIT IS not NULL
PRINT('t_AdditionalCriterion')


--------NAPR------------
INSERT dbo.t_DirectionMU( rf_idCase ,DirectionDate ,TypeDirection ,MethodStudy ,DirectionMU,DirectionMO)
SELECT c.id, t1.NAPR_DATE ,t1.NAPR_V ,t1.MET_ISSL ,t1.NAPR_USL, t1.NAPR_MO
from @tmpCase c inner join #NAPR t1 on
		c.GUID_Case=t1.SL_ID	
		and c.idRecord=t1.IDCASE	
WHERE t1.NAPR_DATE IS NOT NULL
PRINT('t_DirectionMU')
-----------------------------------------------------------------------------------------------------------------

INSERT dbo.t_NextVisitDate( rf_idCase, DateVizit )
SELECT c.id,t1.NEXT_VISIT
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.SL_ID
		and c.idRecord=t1.IDCASE
WHERE t1.NEXT_VISIT IS NOT NULL
PRINT('t_NextVisitDate')

insert t_Diagnosis(DiagnosisCode,rf_idCase,TypeDiagnosis)
select DS0,c.id,2 
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.SL_ID
		and c.idRecord=t1.IDCASE
where DS0 is not null
union all
select DS1,c.id,1 
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.SL_ID
		and c.idRecord=t1.IDCASE
union all
select DS,c.id,TypeDiagnosis 
from @tmpCase c inner join #tDS t1 on
		c.GUID_Case=t1.SL_ID	
		and c.idRecord=t1.IDCASE	
PRINT('t_Diagnosis')
------------------------------------------------------------------------------------------------------------------
insert t_BirthWeight(rf_idCase,BirthWeight)		
select c.id,BirthWeight
from @tmpCase c inner join #tBW t1 on
		c.GUID_Case=t1.SL_ID
		and c.idRecord=t1.IDCASE	
PRINT('t_BirthWeight')

INSERT dbo.t_Coefficient
        ( rf_idCase, Code_SL, Coefficient )
select c.id,t1.CODE_SL,t1.VAL_C
from @tmpCase c inner join #tCoeff t1 on
		c.GUID_Case=t1.SL_ID	
		and c.idRecord=t1.IDCASE	
PRINT('t_Coefficient')

INSERT dbo.t_Kiro( rf_idCase, rf_idKiro, ValueKiro )
select c.id,t1.CODE_KIRO,t1.VAL_K
from @tmpCase c inner join #tKiro t1 on
		c.GUID_Case=t1.SL_ID	
		and c.idRecord=t1.IDCASE	
WHERE t1.CODE_KIRO IS NOT NULL
PRINT('t_Kiro')
--16.07.2018
------------ONKOLOGIA----------------------
DECLARE @tONKID AS TABLE(id INT, rf_idCase bigint)
--20.12.2018
INSERT dbo.t_ONK_SL( rf_idCase ,DS1_T ,rf_idN002 ,rf_idN003 ,rf_idN004 ,rf_idN005 ,IsMetastasis ,TotalDose, K_FR,WEI,HEI,BSA)
OUTPUT INSERTED.id, INSERTED.rf_idCase INTO @tONKID
SELECT c.id, DS1_T,STAD,ONK_T,ONK_N,ONK_M,MTSTZ,SOD,K_FR,WEI,HEI,BSA
from @tmpCase c inner join #ONK_SL t1 on
		c.GUID_Case=t1.SL_ID	
		and c.idRecord=t1.IDCASE	
WHERE t1.DS1_T IS NOT null
PRINT('t_ONK_SL')
--20.12.2018
INSERT dbo.t_DiagnosticBlock( rf_idONK_SL ,TypeDiagnostic ,CodeDiagnostic ,ResultDiagnostic, DateDiagnostic,REC_RSLT)
SELECT o.id, DIAG_TIP, DIAG_CODE, DIAG_RSLT,Diag_Date,REC_RSLT
from @tmpCase c INNER JOIN @tONKID o ON
		c.id=o.rf_idCase
				inner join #B_DIAG t1 on
		c.GUID_Case=t1.SL_ID	
		and c.idRecord=t1.IDCASE	
WHERE t1.DIAG_TIP IS NOT NULL --OR DIAG_CODE IS NOT NULL OR DIAG_RSLT IS NOT NULL OR Diag_Date IS NOT NULL OR REC_RSLT IS NOT NULL 
PRINT('t_DiagnosticBlock')

INSERT dbo.t_Contraindications( rf_idONK_SL ,Code ,DateContraindications)
SELECT o.id, PROT, D_PROT
from @tmpCase c INNER JOIN @tONKID o ON
		c.id=o.rf_idCase
				inner join #B_PROT t1 on
		c.GUID_Case=t1.SL_ID
		and c.idRecord=t1.IDCASE	
WHERE t1.PROT IS NOT null OR D_PROT IS NOT NULL
PRINT('t_Contraindications')

--20.12.2018
INSERT dbo.t_ONK_USL( rf_idCase ,rf_idN013 ,TypeSurgery ,TypeDrug ,TypeCycleOfDrug ,TypeRadiationTherapy,PPTR)
SELECT c.id,t1.USL_TIP , t1.HIR_TIP , t1.LEK_TIP_L ,t1.LEK_TIP_V ,t1.LUCH_TIP,PPTR
from @tmpCase c inner join #ONK_USL t1 on
		c.GUID_Case=t1.SL_ID	
		and c.idRecord=t1.IDCASE
WHERE t1.USL_TIP IS NOT NULL
PRINT('t_ONK_USL')

INSERT dbo.t_Consultation( rf_idCase, PR_CONS, DateCons )
SELECT c.id,PR_CONS,DT_CONS
from @tmpCase c inner join #CONS t1 on
		c.GUID_Case=t1.SL_ID	
		and c.idRecord=t1.IDCASE
WHERE t1.PR_CONS IS NOT NULL
PRINT('t_Consultation')
--20.12.2018
INSERT dbo.t_SLK( rf_idCase, SL_K )
SELECT DISTINCT c.id,SL_K
from @tmpCase c inner join #KSG_KPG t1 on
		c.GUID_Case=t1.SL_ID	
		and c.idRecord=t1.IDCASE
PRINT('t_SLK')
--20.12.2018
INSERT dbo.t_DrugTherapy( rf_idCase ,rf_idN013 ,rf_idV020 ,DateInjection,rf_idV024)
SELECT c.id,t1.USL_TIP,t1.REGNUM,t1.DATE_INJ,CODE_SH
from @tmpCase c inner join #LEK_PR t1 on
		c.GUID_Case=t1.SL_ID	
		and c.idRecord=t1.IDCASE
WHERE t1.REGNUM IS NOT NULL
PRINT('t_DrugTherapy')
--------------------------------------------------------------------------------------------------------------------
---таблица для вставленных записей в t_MES. Будит использоваться взямен запуска триггера
CREATE TABLE #iTableMes (rf_idCase bigint,MES varchar(20))

insert t_MES(MES,rf_idCase,TypeMES,Quantity,Tariff,IsCSGTag)
OUTPUT INSERTED.rf_idCase,INSERTED.MES INTO #iTableMes
select t1.CODE_MES1,c.id,1,t1.ED_COL,t1.TARIF,1
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.sl_id
		and c.idRecord=t1.IDCASE
where (t1.CODE_MES1 is not null OR t1.TARIF IS NOT NULL OR t1.ED_COL IS NOT NULL) --добавленна проверка
	AND NOT EXISTS(SELECT 1 FROM #ksg_kpg k WHERE c.GUID_Case=k.sl_id	and c.idRecord=k.IDCASE )
group by t1.CODE_MES1,c.id,t1.ED_COL,t1.TARIF
PRINT('t_MES 1')

insert t_MES(MES,rf_idCase,TypeMES,Quantity,Tariff, IsCSGTag)
OUTPUT INSERTED.rf_idCase,INSERTED.MES INTO #iTableMes
select k.N_KSG,c.id,2,t1.ED_COL,t1.TARIF,2
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.sl_id
		and c.idRecord=t1.IDCASE
				INNER JOIN #ksg_kpg k ON
        c.GUID_Case=k.sl_id
		and c.idRecord=k.IDCASE        
where k.N_KSG is not null 
group by k.N_KSG,c.id,t1.ED_COL,t1.TARIF
PRINT('t_MES 2')


----------------------------------------------------------------Замена тригера-----------------------------------------------
------------------------------------15.04.2013 10:55. Обязательно проверить отключен ли триггер InsertCompletedCaseIntoMU на таблице t_MES
		INSERT t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO,rf_idSubMO,rf_idDepartmentMO,rf_idV002,IsChildTariff,DateHelpBegin,DateHelpEnd,DiagnosisCode,
							MUCode,Quantity,Price,TotalPrice,rf_idV004,rf_idDoctor)
		SELECT DISTINCT  c.id,CAST(c.idRecordCase AS varchar(36)),NEWID(),c.rf_idMO,c.rf_idSubMO,c.rf_idDepartmentMO,c.rf_idV002,c.IsChildTariff,c.DateBegin,c.DateEnd,d.DiagnosisCode
			   ,vw_c.MU_P			  
			   , case when c.rf_idV006=2 then CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2))+1 
					ELSE (case when(CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2)))=0 then 1 
								else CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2))END ) END AS Quantity
			   ,0.00,0.00,c.rf_idV004,c.rf_idDoctor
		FROM t_Case c INNER JOIN (SELECT DISTINCT * FROM #iTableMes) i ON
				c.id=i.rf_idCase
					  INNER JOIN (
								  SELECT rf_idCase,DiagnosisCode 
								  FROM t_Diagnosis 
								  WHERE TypeDiagnosis=1 
								  GROUP BY rf_idCase,DiagnosisCode 
								  ) d ON
				c.id=d.rf_idCase
					  INNER JOIN (
								  SELECT MU,MU_P, AgeGroupShortName 
								  FROM vw_sprMUCompletedCase m LEFT JOIN (SELECT MU AS MUCode FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
																			UNION ALL
																			SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
																			UNION ALL
																			SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72
																		) m1 ON
											m.MU=m1.MUCode
								  WHERE m1.MUCode IS NULL
								  ) vw_c ON
				rtrim(i.MES)=vw_c.MU	
		WHERE c.DateEnd<'20130401' AND vw_c.AgeGroupShortName=(CASE WHEN c.Age>17 THEN 'в' ELSE 'д' END)
		UNION ALL ----- Новый порядок учета Дневного стационара в качестве ЗС. Количество услуг не считается с 01.04.2013
		SELECT DISTINCT  c.id,CAST(c.idRecordCase AS varchar(36)),NEWID(),c.rf_idMO,c.rf_idSubMO,c.rf_idDepartmentMO,c.rf_idV002,c.IsChildTariff,c.DateBegin,c.DateEnd,d.DiagnosisCode
			   ,vw_c.MU_P			  
			   , case when(CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(9,2)))=0 then 1 else CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(9,2))end
			   ,0.00,0.00,c.rf_idV004,c.rf_idDoctor
		FROM t_Case c INNER JOIN (SELECT DISTINCT * FROM #iTableMes) i ON
				c.id=i.rf_idCase
					  INNER JOIN (
								  SELECT rf_idCase,DiagnosisCode 
								  FROM t_Diagnosis 
								  WHERE TypeDiagnosis=1 
								  GROUP BY rf_idCase,DiagnosisCode 
								  ) d ON
				c.id=d.rf_idCase
					  INNER JOIN (
								  SELECT MU,MU_P, AgeGroupShortName 
								  FROM vw_sprMUCompletedCase m LEFT JOIN (SELECT MU AS MUCode FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
																			UNION ALL
																			SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
																			UNION ALL
																			SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72																												) m1 ON
											m.MU=m1.MUCode
								  WHERE m1.MUCode IS NULL
								  ) vw_c ON
				rtrim(i.MES)=vw_c.MU	
		WHERE c.DateEnd>='20130401' AND c.rf_idV006<>2 AND vw_c.AgeGroupShortName=(CASE WHEN c.Age>17 THEN 'в' ELSE 'д' END)

PRINT('t_MEduslugi 1')
---------------------------------------------------------------------------------------------------------------------
insert t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO, rf_idV002,MUSurgery, IsChildTariff, DateHelpBegin, DateHelpEnd, DiagnosisCode, 
					MUCode, Quantity, Price, TotalPrice, rf_idV004, Comments,rf_idDepartmentMO,rf_idDoctor,rf_idSubMO)
select c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL, t1.VID_VME,t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,t1.CODE_USL,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU,t1.PODR
	,CASE WHEN t1.CODE_MD='0' THEN NULL ELSE t1.CODE_MD END,t1.LPU_1
from #t6 t1 inner join @tmpCase c on
			c.GUID_Case=t1.SL_ID	
			and t1.IDCASE=c.idRecord		
where t1.ID_U is not null
group by c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL, t1.VID_VME, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,t1.CODE_USL,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU,t1.PODR
,CASE WHEN t1.CODE_MD='0' THEN NULL ELSE t1.CODE_MD END,t1.LPU_1

PRINT('t_MEduslugi 2')
----------------------------------------------------------------------------------------------------------------------
--убрал замену слова НЕТ в отчетстве т.к. есть люди у которых в кчестве отчетсва стоит 
insert t_RegisterPatient(rf_idFiles, ID_Patient, Fam, Im, Ot, rf_idV005, BirthDay, BirthPlace, TEL)
	output inserted.id,inserted.ID_Patient into @tableId
select @idFile,t1.ID_PAC,t1.FAM,t1.IM
,t1.Ot--case when t1.OT='НЕТ' then null else t1.OT END
,t1.W,t1.DR,t1.MR, t1.TEL
from #t8 t1 
group by t1.ID_PAC,t1.FAM,t1.IM
/*case when t1.OT='НЕТ' then null else t1.OT END*/,t1.Ot
,t1.W,t1.DR,t1.MR, t1.TEL

insert t_RefRegisterPatientRecordCase(rf_idRecordCase,rf_idRegisterPatient)
select t2.id,t1.id
from  @tableId t1 inner join @tempID t2 on
				t1.ID_PAC=t2.ID_PAC
-----изменения от 22.01.2012-------------------------------------------------------------------

insert t_RegisterPatientDocument(rf_idRegisterPatient, rf_idDocumentType, SeriaDocument, NumberDocument, SNILS, OKATO, OKATO_Place, Comments)
select t2.id,t1.DOCTYPE,t1.DOCSER,t1.DOCNUM,t1.SNILS,t1.OKATOG,t1.OKATOP,t1.COMENTP
from #t8 t1 inner join @tableId t2 on
		t1.ID_PAC=t2.ID_PAC
where (t1.DOCTYPE is not null) or (t1.DOCSER is not null) or (t1.DOCNUM is not null) OR (t1.SNILS IS NOT null) OR (t1.OKATOG IS NOT NULL) OR (t1.OKATOP IS NOT NULL)
group by t2.id,t1.DOCTYPE,t1.DOCSER,t1.DOCNUM,t1.SNILS,t1.OKATOG,t1.OKATOP,t1.COMENTP

insert t_RegisterPatientAttendant(rf_idRegisterPatient, Fam, Im, Ot, rf_idV005, BirthDay)
select t2.id,t1.FAM_P,t1.IM_P,t1.OT_P,t1.W_P,t1.DR_P
from #t8 t1 inner join @tableId t2 on
		upper(t1.ID_PAC)=upper(t2.ID_PAC)
where (t1.FAM_P is not null) or (t1.IM_P is not null) or (t1.W_P is not null) or (t1.DR_P is not null)
group by t2.id,t1.FAM_P,t1.IM_P,t1.OT_P,t1.W_P,t1.DR_P
-------------------------------------------------------------------------------------------------
INSERT dbo.t_ReliabilityPatient( rf_idRegisterPatient ,TypeReliability ,IsAttendant)
SELECT t2.id, t1.DOST, t1.IsAttendant
FROM #tDOST t1 INNER JOIN  @tableId t2 on
		t1.ID_PAC=t2.ID_PAC
WHERE t1.DOST IS NOT NULL

select @idFile

end try
begin catch
	select ERROR_MESSAGE()
	select 'Error'
	if @@TRANCOUNT>0
	rollback transaction
goto Exit1--выходим из обработки данных
end catch
if @@TRANCOUNT>0
	--ROLLBACK transaction
	commit transaction

	
Exit1:
if OBJECT_ID('tempDB..#t5',N'U') is not NULL
	 DROP TABLE #t5
if OBJECT_ID('tempDB..#t8',N'U') is not NULL
	drop table #t8
if OBJECT_ID('tempDB..#t3',N'U') is not NULL
	drop table #t3
if OBJECT_ID('tempDB..#iTableMes',N'U') is not NULL
	DROP TABLE #iTableMes
if OBJECT_ID('tempDB..#CONS',N'U') is not NULL
	DROP TABLE #CONS
if OBJECT_ID('tempDB..#LEK_PR',N'U') is not NULL
DROP TABLE #LEK_PR
if OBJECT_ID('tempDB..#t6',N'U') is not NULL
	DROP TABLE #t6
if OBJECT_ID('tempDB..#tBW',N'U') is not NULL
	DROP TABLE #tBW
if OBJECT_ID('tempDB..#tDS',N'U') is not NULL
	DROP TABLE #tDS
if OBJECT_ID('tempDB..#tCoeff',N'U') is not NULL
	DROP TABLE #tCoeff
if OBJECT_ID('tempDB..#tKiro',N'U') is not NULL
	DROP TABLE #tKiro
if OBJECT_ID('tempDB..#B_DIAG',N'U') is not NULL
	DROP TABLE #B_DIAG
if OBJECT_ID('tempDB..#B_PROT',N'U') is not NULL
	DROP TABLE #B_PROT
if OBJECT_ID('tempDB..#NAPR',N'U') is not NULL
	DROP TABLE #NAPR
if OBJECT_ID('tempDB..#ONK_USL',N'U') is not NULL
	DROP TABLE #ONK_USL
if OBJECT_ID('tempDB..#tDost',N'U') is not NULL
	DROP TABLE #tDost
if OBJECT_ID('tempDB..#tDisabiliti',N'U') is not NULL
	DROP TABLE #tDisabiliti
if OBJECT_ID('tempDB..#ONK_SL',N'U') is not NULL
	DROP TABLE #ONK_SL
if OBJECT_ID('tempDB..#KSG_KPG',N'U') is not NULL
	DROP TABLE #KSG_KPG
GO
ALTER proc [dbo].[usp_DefineSMOIteration1_3]
			@idRecordCase TVP_CasePatient READONLY,
			@iteration tinyint,
			@id int=null
as
declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int)

begin transaction
begin try
--дабовляю в таблицу t_RefCaseIteration сведения с итерацией №1 
if @iteration=1
begin
	insert t_RefCasePatientDefine(rf_idCase,rf_idRegisterPatient,rf_idFiles)
		output inserted.id,inserted.rf_idCase, inserted.rf_idRegisterPatient into @idTable
	select DISTINCT c.rf_idCase as rf_idCase,c.ID_Patient as rf_idPatient,@id
	from @idRecordCase c 
end	
--при итерации №3 добавлять данные в таблицу t_RefCasePatientDefine не нужно т.к. они там уже лежат. 
--мы просто получаем необходимые данные
else 
begin
	insert @idTable
	select cd.id,t.rf_idCase,t.ID_Patient
	from @idRecordCase t inner join t_RefCasePatientDefine cd on
				t.rf_idCase=cd.rf_idCase
				and t.ID_Patient=cd.rf_idRegisterPatient
end
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
-- сначала определяю PID из РС ЕРЗ----------------------------------------------------------------------------------------

------------новый алгоритм определения PID, LPU и действующего страхования
create table #t
(
	nrec bigint not null,		
	pid int null,			
	penp varchar(16) null,	
	sKey varchar(3) null,	
	sid	int null,			
	q varchar(5) null,		
	lid int null,			
	lpu varchar(6) null,	
	spol varchar(20) null,
	npol varchar(20) null,
	enp varchar(16) null,
	fam varchar(40) null,
	im varchar(40) null,
	ot varchar(40) null,
	dr datetime null,
	mr varchar(100) null,
	docn varchar(20) null,
	ss varchar(14) NULL,
	dd DATE NOT NULL,
	IsDelete TINYINT NULL,
	Step TINYINT  NOT NULL DEFAULT 9,
	DateBeg DATE,
	Sex TINYINT 
)

INSERT #t( nrec ,spol ,npol ,enp ,fam ,im ,ot ,dr , mr ,docn ,ss,dd,DateBeg, Sex)
select DISTINCT t.id,rc.SeriaPolis,rc.NumberPolis,ps.ENP,p.Fam,p.Im,p.Ot,p.BirthDay,p.BirthPlace,pd.NumberDocument,pd.SNILS,cc.DateEnd,cc.DateBegin,p.rf_idV005
from @idTable t inner join t_Case c on
		t.rf_idCase=c.id 
				inner join vw_RegisterPatient p on
		t.rf_idRegisterPatient=p.id
				inner join t_RecordCase rc on
		p.rf_idRecordCase=rc.id
		AND c.rf_idRecordCase=rc.id
				INNER JOIN dbo.t_PatientSMO ps ON
		rc.id=ps.ref_idRecordCase              
				INNER JOIN dbo.t_CompletedCase cc ON
		rc.id=cc.rf_idRecordCase              
				left join t_RegisterPatientDocument pd on
		p.id=pd.rf_idRegisterPatient
				

exec Utility.dbo.sp_GetPid 
EXEC Utility.dbo.sp_GetIdPolisLPU_3

--------------------------------------------------------

--------------------------------------------------------
------------кроме скорой-------------------
UPDATE p SET IsDelete=1
FROM #t p INNER JOIN PolicyRegister.dbo.PEOPLE vp ON
		p.PID=vp.ID		
			INNER JOIN t_RefCasePatientDefine rr ON
		p.nrec=rr.id
			INNER JOIN dbo.t_Case c ON
		rr.rf_idCase=c.id	
WHERE vp.ENP IS NOT NULL AND p.dd>vp.DS AND c.rf_idV006<4
-------------для Скорой-------------------------
UPDATE p SET IsDelete=1
FROM #t p INNER JOIN PolicyRegister.dbo.PEOPLE vp ON
		p.PID=vp.ID		
			INNER JOIN t_RefCasePatientDefine rr ON
		p.nrec=rr.id
			INNER JOIN dbo.t_Case c ON
		rr.rf_idCase=c.id	
WHERE vp.ENP IS NOT NULL AND p.dd>DATEADD(day,1,vp.DS) AND c.rf_idV006=4 AND c.rf_idV009 NOT IN(405,409,411)

--ставим все записям с PID=1 
UPDATE t SET Step=1 
from #t t WHERE PID IS NOT null--sKey IN('H10','H20','H30','H40','520','416','H21','H31','H41','521','410','411')

--заменил функцию на хранимую процедуру и табличную переменную на временную таблицу
create table #tPeople
(
	rf_idRefCaseIteration bigint,
	PID int,
    DateEnd DATE,
    IsDelete TINYINT,
    DateBegin DATE,
	Sex TINYINT,
	DR DATE,
	Step TINYINT,
	ENP VARCHAR(20),
	LPU VARCHAR(6),
	LPUid int,  -- id в таблице HISTLPU для определения МО прикрепления
	PolID INT -- id в таблице Polis
)

INSERT #tPeople(rf_idRefCaseIteration ,PID ,DateEnd ,IsDelete ,DateBegin ,Sex ,DR ,Step ,LPUid ,PolID,LPU,ENP)
SELECT nrec,PID,DD,IsDelete,DateBeg,Sex,dr,step,lid,[sid],lpu, penp FROM #t

CREATE NONCLUSTERED INDEX IX_PeopleTMP ON #tPeople(PID) INCLUDE(rf_idRefCaseIteration,PolID,LPUid,LPU,ENP,DateEnd, Step)

UPDATE p SET p.Sex=pp.W
FROM #tPeople p INNER JOIN PolicyRegister.dbo.PEOPLE pp ON
		p.pid=pp.id

DROP TABLE #t
-----------------------------------------------------------------------------------------------------------
--таблица с id случаями по которым определена страховая принадлежность
CREATE TABLE #tableCaseDefine (rf_idRefCaseIteration BIGINT,id INT) 

declare @tmpCaseDefine as table
(
	rf_idRefCaseIteration bigint,
	DateDefine datetime,
	PID int,
	UniqueNumberPolicy varchar(20),
	IsDefined bit,
	SMO varchar(5),
	SPolicy varchar(20) ,
	NPolcy varchar(20),
	RN varchar(11),
	rf_idF008 tinyint,
	DateEnd date,
	LPU char(6)	,
	SNILS CHAR(11),
	Step TINYINT
) 
--вспомогательная таблица для PID у которых нет действ. полиса
declare @tmpCaseDefine3 as table
(
	rf_idRefCaseIteration bigint,
	DateDefine datetime,
	PID int,
	UniqueNumberPolicy varchar(20),
	IsDefined bit,
	SMO varchar(5),
	SPolicy varchar(20) ,
	NPolcy varchar(20),
	RN varchar(11),
	rf_idF008 tinyint,
	DateEnd date,
	LPU char(6)
) 
	insert @tmpCaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,DateEnd,Step, LPU)
	select t.rf_idRefCaseIteration, GETDATE(), t.PID,t.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,DateEnd, t.Step,t.LPU
	from vw_People p inner join #tPeople t on
							p.ID=t.pid
							inner join vw_Polis pol on
								pol.ID=t.PolID
								AND p.ID=pol.PID
	where t.pid is not NULL and t.DateEnd>=pol.DBEG and t.DateEnd<=pol.DEND and (pol.Q is not null) and pol.OKATO='18000'
	
	insert @tmpCaseDefine3(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,DateEnd, LPU)	
	select t.rf_idRefCaseIteration, GETDATE(), t.PID,t.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,t.DateEnd,t.LPU
	from vw_People p inner join #tPeople t on
							p.ID=t.pid
							inner join vw_Polis pol on
								pol.ID=t.PolID
								AND p.ID=pol.PID
	where t.pid is not null and (pol.Q is not null) and pol.OKATO='18000'	

---Получаем СНИЛС врача к которому прикреплен застрахованный.
	update @tmpCaseDefine
	set SNILS=isnull(p.SS_DOCTOR,'000000') 
	from @tmpCaseDefine t INNER JOIN #tPeople tt ON
				t.rf_idRefCaseIteration=tt.rf_idRefCaseIteration
						inner join PolicyRegister.dbo.HISTLPU p ON
			p.ID=tt.PolID
			AND p.kateg=1	
-------------------------------
BEGIN TRANSACTION
BEGIN TRY			
--04.01.2014
--заносим в таблицу ошибок сведения по умершим людям
insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
SELECT 506,r.rf_idFiles,r.rf_idCase
FROM #tPeople p INNER JOIN dbo.t_RefCasePatientDefine r ON
		p.rf_idRefCaseIteration=r.id
WHERE IsDelete=1

--заносим в таблицу ошибок сведения по людям без енп
insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
SELECT 57,r.rf_idFiles,r.rf_idCase
FROM #tPeople p INNER JOIN dbo.t_RefCasePatientDefine r ON
		p.rf_idRefCaseIteration=r.id
WHERE ISNULL(p.ENP,'')='' AND PolID IS NOT null

--599 ошибка. Проводится проверка на соответствие даты рождения или пола от МО и даты рождения или пола в  РСЗ
--03.12.2015 Отключил проверку т.к. МО подает большое количество не корректных данных
--18.01.2016 Enable this test for sex

-----------------checking column sex----------------------
insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
SELECT 599,r.rf_idFiles,r.rf_idCase
FROM #tPeople p INNER JOIN dbo.t_RefCasePatientDefine r ON
		p.rf_idRefCaseIteration=r.id
				INNER JOIN dbo.t_RegisterPatient rp ON
		r.rf_idRegisterPatient=rp.id
		AND r.rf_idFiles=rp.rf_idFiles
				INNER JOIN dbo.t_Case c ON
		r.rf_idCase=c.id
				INNER JOIN dbo.t_RecordCase r1 ON
		c.rf_idRecordCase=r1.id
		AND r1.IsChild=0
WHERE p.sex<>rp.rf_idV005  AND p.PID IS NOT NULL AND p.PolID IS NOT NULL						

insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
SELECT 599,r.rf_idFiles,r.rf_idCase
FROM #tPeople p INNER JOIN dbo.t_RefCasePatientDefine r ON
		p.rf_idRefCaseIteration=r.id
				INNER JOIN dbo.t_RegisterPatient rp ON
		r.rf_idRegisterPatient=rp.id
		AND r.rf_idFiles=rp.rf_idFiles
				INNER JOIN dbo.t_RegisterPatientAttendant att ON
		rp.id=att.rf_idRegisterPatient              
				INNER JOIN dbo.t_Case c ON
		r.rf_idCase=c.id
				INNER JOIN dbo.t_RecordCase r1 ON
		c.rf_idRecordCase=r1.id
		AND r1.IsChild=1
WHERE p.sex<>ISNULL(att.rf_idV005,3) AND p.PID IS NOT NULL AND p.PolID IS NOT NULL

--513 ошибка 
/*
Проводится проверка правомочности проведения диспансеризации определенных групп взрослого населения (R), 
профилактических осмотров определенных групп взрослого населения (O), профилактических(F) и предварительных (V) осмотров несовершеннолетних, 
диспансеризации детей-сирот (U), в том числе усыновленных. 
Указанные виды медицинской помощи должны быть оказаны медицинскими организациями, к которым прикреплены застрахованные лица
 */
insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
SELECT 513,r.rf_idFiles,r.rf_idCase
from @tmpCaseDefine t inner join t_RefCasePatientDefine r on
			t.rf_idRefCaseIteration=r.id
						inner join t_Case c on
			r.rf_idCase=c.id
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
						INNER JOIN (SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='O'
									UNION ALL
									SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='R'
									UNION ALL
									SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='F'
									UNION ALL
									SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='V'
									UNION ALL
									SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='U') l ON
			m.MUCode=l.MU
WHERE m.Price>0 AND c.rf_idMO<>isnull(t.LPU,'000000')

insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
SELECT 513,r.rf_idFiles,r.rf_idCase
from @tmpCaseDefine t inner join t_RefCasePatientDefine r on
			t.rf_idRefCaseIteration=r.id
						inner join t_Case c on
			r.rf_idCase=c.id
						INNER JOIN dbo.t_Mes m ON
			c.id=m.rf_idCase
						INNER JOIN (SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='O'
									UNION ALL
									SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='R'
									UNION ALL
									SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='F'
									UNION ALL
									SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='V'
									UNION ALL
									SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='U') l ON
			m.MES=l.MU
WHERE c.rf_idMO<>isnull(t.LPU,'000000')


--Изменение от 20.12.2016 добавлено полу IdStep
--1- это значит что человек нашелся по ФИО+ДР. В usp_FillBackTables идет обработка этих данных т.к. могут быть ошибки при подсчете МТР
insert t_CaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,AttachCodeM,IDStep)	
		output inserted.rf_idRefCaseIteration, INSERTED.id into #tableCaseDefine
select rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,LPU,
		CASE WHEN step=1 THEN 1 ELSE 9 END AS step -- когда определили на 1 шаге, то ставим 1 а иначе ставим 9(для того что бы ставить OPLATA=2)
from (
		select rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined,CASE WHEN c.SMO='34001' THEN '34007' ELSE c.SMO END AS SMO
				,SPolicy,NPolcy,RN,rf_idF008,LPU,c.step
		from @tmpCaseDefine c INNER JOIN dbo.t_RefCasePatientDefine r ON
				c.rf_idRefCaseIteration=r.id
						INNER JOIN t_Case c1 ON
				r.rf_idCase=c1.id
						 left join vw_sprSMODisable s on
					c.SMO=s.SMO
		where s.id is null
		union all
		select rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, c.SMO,SPolicy,NPolcy,RN,rf_idF008,LPU, c.step
		from @tmpCaseDefine  c inner join vw_sprSMODisable s on
					c.SMO=s.SMO
		where c.DateEnd<s.DateEnd
		union all
		select rf_idRefCaseIteration,DateDefine,c.PID,UniqueNumberPolicy,IsDefined, lp.Q as SMO,lp.SPOL as SPolicy,lp.NPOL as NPolcy
				,lp.RN,rf_idF008,LPU, c.step
		from @tmpCaseDefine c inner join vw_sprSMODisable s on
					c.SMO=s.SMO
							 inner join dbo.ListPeopleFromPlotnikov lp on
				c.PID=lp.ID
		where c.DateEnd>=s.DateEnd
		UNION ALL--все записи по умершим которые не определились на первом этапе и что бы они дальше не пошли отсортировываем их
		---если застрахованный определился на нашем регистре как Капиталовский переопределяем его в РГС
		SELECT p.rf_idRefCaseIteration,GETDATE(),p.PID,CASE WHEN r1.rf_idF008=3 THEN r1.NumberPolis ELSE NULL END,1
				,CASE WHEN ps.rf_idSMO='34001' THEN '34007' ELSE ISNULL(ps.rf_idSMO,'34') END,r1.SeriaPolis,r1.NumberPolis
				,pe.RN,r1.rf_idF008,'000000',p.Step
		FROM #tPeople p INNER JOIN dbo.t_RefCasePatientDefine r ON
				p.rf_idRefCaseIteration=r.id
						INNER JOIN t_Case c ON
				r.rf_idCase=c.id
						INNER JOIN dbo.t_RecordCase r1 ON
				c.rf_idRecordCase=r1.id
						INNER JOIN dbo.t_PatientSMO ps ON
				r1.id=ps.ref_idRecordCase
						INNER JOIN dbo.vw_People pe ON
				p.PID=pe.ID
		WHERE NOT EXISTS(SELECT * FROM @tmpCaseDefine WHERE rf_idRefCaseIteration=p.rf_idRefCaseIteration) and p.IsDelete=1 					
		
	) t
	---вставка данных найденных и определенных, но имеющих неточности в ФИО+ДР, кроме умерших
--ускорил вставку
SELECT  id ,rf_idFiles ,FAM ,Im ,Ot ,rf_idV005 , BirthDay 
INTO #t1 FROM dbo.vw_RegisterPatient WHERE rf_idFiles=@id

INSERT dbo.t_Correction( rf_idCaseDefine ,pid ,FAM ,IM ,OT ,BirthDay,TypeEquale)
SELECT t2.id,t.PID,p.FAM,p.im,p.ot,p.DR,
	 CASE WHEN ISNULL(p.FAM,'bla')!=ISNULL(pp.FAM,'bla') THEN 1 WHEN ISNULL(p.IM,'bla')!=ISNULL(pp.IM,'bla') THEN 2 
		  WHEN ISNULL(p.OT,'bla')!=ISNULL(pp.OT,'bla') THEN 3 WHEN ISNULL(p.DR,'bla')!=ISNULL(pp.BirthDay,'bla') THEN 4 end												
FROM dbo.t_CaseDefine t INNER JOIN #tableCaseDefine t2 ON
			t.id=t2.id
					INNER JOIN dbo.vw_People p ON
			t.pid=p.id 
					INNER JOIN dbo.t_RefCasePatientDefine rp ON
			t.rf_idRefCaseIteration=rp.id
					INNER JOIN #t1 pp ON
			rp.rf_idFiles=pp.rf_idFiles
			AND rp.rf_idRegisterPatient=pp.id                
WHERE (CASE WHEN ISNULL(p.FAM,'bla')!=ISNULL(pp.FAM,'bla') THEN 1 WHEN ISNULL(p.IM,'bla')!=ISNULL(pp.IM,'bla') THEN 2 
		  WHEN ISNULL(p.OT,'bla')!=ISNULL(pp.OT,'bla') THEN 3 WHEN ISNULL(p.DR,'bla')!=ISNULL(pp.BirthDay,'bla') THEN 4 END) IS NOT null												

------------вставка 57 ошибки-------------
--Если запись присутствует в таблицы t_Correction то PID мы нашли и есть несоответствия в персональных данных 
insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)						 
SELECT DISTINCT 57,rf.rf_idFiles,rf.rf_idCase
FROM dbo.t_CaseDefine cd INNER JOIN #tableCaseDefine t2 ON
			cd.id=t2.id
						INNER JOIN t_RefCasePatientDefine rf ON
			rf.id=cd.rf_idRefCaseIteration
						INNER JOIN dbo.t_Correction cc ON
			cd.id=cc.rf_idCaseDefine                      
--WHERE cd.idStep>1

---Information about Doctor's SNILS saves into table t_CaseSNILSDefine
INSERT dbo.t_CaseSNILSDefine(rf_idRefCaseIteration ,SNILS)
SELECT t.rf_idRefCaseIteration,ISNULL(t.SNILS,'0')
FROM @tmpCaseDefine t INNER JOIN #tableCaseDefine t2 ON
			t.rf_idRefCaseIteration=t2.rf_idRefCaseIteration
			 
--сохраняю сведения с id случаем и номером итерации на котором данный случай был определен
insert t_CasePatientDefineIteration(rf_idRefCaseIteration,rf_idIteration)
select rf_idRefCaseIteration,@iteration from #tableCaseDefine

--28.02.2014
--сохраняю определение кода прикрепления МО для счетов с буквой O,R,F,V,U если человек застрахован в ВО
-- т.к. при 2 и 4 итерации код МО прикрепления не известен 
IF @iteration=1
BEGIN
--Изменения от 18.03.2014
	INSERT dbo.t_RefCaseAttachLPUItearion2( rf_idCase ,rf_idFiles ,rf_idRefCaseIteration ,AttachLPU,PID)	
	SELECT r.rf_idCase,r.rf_idFiles,t.rf_idRefCaseIteration,t.LPU,t.PID
	from @tmpCaseDefine3 t inner join t_RefCasePatientDefine r on
			t.rf_idRefCaseIteration=r.id
			AND ISNULL(t.LPU,'000000')!='000000'
						inner join t_Case c on
			r.rf_idCase=c.id			
	WHERE NOT EXISTS(SELECT * FROM #tableCaseDefine WHERE rf_idRefCaseIteration=r.id ) 


END
--
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction	
--записи по тем пациентам по которым не определан страховая принадлежность, передаем в процедуру usp_DefineSMOIteration2_4
--для определения страховой принадлежности в ЦС ЕРЗ
select c.rf_idCase, c.ID_Patient
from @idRecordCase c left join		(
										select rfc.id,rf_idCase,rfc.rf_idRegisterPatient
										from t_RefCasePatientDefine rfc inner join t_CaseDefine cd on
													rfc.id=cd.rf_idRefCaseIteration										
									 ) rfc on
				c.rf_idCase=rfc.rf_idCase and 
			c.ID_Patient=rfc.rf_idRegisterPatient
where rfc.id is null
group by c.rf_idCase, c.ID_Patient

GO
ALTER PROCEDURE [dbo].[usp_PlanOrders]
		@codeLPU VARCHAR(6),@month TINYINT,@year SMALLINT
AS
DECLARE @plan1 TABLE(
						CodeLPU VARCHAR(6),
						UnitCode INT,
						Vm DECIMAL(11,2),
						Vdm DECIMAL(11,2),
						Spred DECIMAL(11,2)
					)
--план заказов расчитывается по новому с 2011-12-12. В качестве отчетного месяца бере максимальный месяц из реестра сведений с оплатой 1
-- и сравниваем с @month и берем из них максимальное значения для фильтрации.

--план заказов расчитывается по новому с 2012-02-24. В качестве отчетного месяца берем данные за квартал 
-------------------------------------------------------------------------------------
DECLARE @monthMax TINYINT,
		@monthMin TINYINT,
		@dateStart DATETIME


		
-------------------------------------------------------------------------------------
DECLARE @t AS TABLE(MonthID TINYINT,QuarterID TINYINT,partitionQuarterID TINYINT)
INSERT @t VALUES(1,1,1),(2,1,2),(3,1,3),
				(4,2,1),(5,2,2),(6,2,3),
				(7,3,1),(8,3,2),(9,3,3),
				(10,4,1),(11,4,2),(12,4,3)
				
SELECT @monthMin=MIN(t1.MonthID),@monthMax=MAX(t1.MonthID)
FROM @t t INNER JOIN @t t1 ON
		t.QuarterID=t1.QuarterID
WHERE t.MonthID=@month		

--declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@monthMin as varchar(2)),2)+'01'
--declare @dateEnd1 date=CAST(@year as CHAR(4))+right('0'+CAST(@monthMin as varchar(2)),2)+'01'

--declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateEnd1),@dateEnd1))	

		
--first query:расчет V суммарный объем планов-заказов, соответствующий всем предшествующим календарным кварталам за текущий год
--second query:расчет N*Int(Vt/3) объема плана-заказа делится 
--на 3 и умножается на порядковый номер отчетного месяца в квартале и остаток от деления Vt-Int(Vt/3) c 24.02.2012 он не нужен т.к. расчет идет покрватально
--third query: расчет Vkm сумарного объема всех изменений планов заказов из tPlanCorrection без МЕК
--third query: расчет Vdm сумарного объема всех изменений планов заказов из tPlanCorrection только МЕК
--------------------------------------------------------------------------------------------------------------------------------
DECLARE @tPlan AS TABLE(tfomsCode CHAR(6),unitCode SMALLINT,Vkm DECIMAL(11,2),Vdm DECIMAL(11,2), Vt DECIMAL(11,2),O DECIMAL(11,2),V DECIMAL(11,2))
INSERT @tPlan(tfomsCode,unitCode)
SELECT @codeLPU, unitCode
FROM oms_NSI.dbo.tPlanUnit


UPDATE @tPlan
SET Vkm=t.Vkm,Vdm=t.Vdm
FROM @tPlan p INNER JOIN (
						SELECT LEFT(mo.tfomsCode,6) AS tfomsCode,pu.unitCode,SUM(CASE WHEN pc.mec=0 THEN ISNULL(pc.correctionRate,0) ELSE 0 END) AS Vkm,
								SUM(CASE WHEN pc.mec=1 THEN ISNULL(pc.correctionRate,0) ELSE 0 END) AS Vdm
						FROM oms_NSI.dbo.tPlanYear py INNER JOIN oms_NSI.dbo.tMO mo ON
									py.rf_MOId=mo.MOId AND
									py.[year]=@year
										INNER JOIN oms_NSI.dbo.tPlan pl ON
									py.PlanYearId=pl.rf_PlanYearId AND 
									pl.flag='A'
										INNER JOIN oms_NSI.dbo.tPlanUnit pu ON
									pl.rf_PlanUnitId=pu.PlanUnitId
										LEFT JOIN oms_NSI.dbo.tPlanCorrection pc ON
									pl.PlanId=pc.rf_PlanId AND pc.flag='A'
									AND pc.rf_MonthId>=cast(@monthMin as bigint) AND pc.rf_MonthId<=cast(@monthMax as bigint)
						WHERE LEFT(mo.tfomsCode,6)=@codeLPU 
						GROUP BY mo.tfomsCode,pu.unitCode
						) t ON p.tfomsCode=t.tfomsCode AND p.unitCode=t.unitCode


UPDATE @tPlan
SET V=t.V
FROM @tPlan p INNER JOIN (						
							SELECT LEFT(mo.tfomsCode,6) AS tfomsCode,SUM(pl.rate) AS V,pu.unitCode
							FROM oms_NSI.dbo.tPlanYear py INNER JOIN oms_NSI.dbo.tMO mo ON
										py.rf_MOId=mo.MOId AND
										py.[year]=@year
											INNER JOIN oms_NSI.dbo.tPlan pl ON
										py.PlanYearId=pl.rf_PlanYearId AND pl.flag='A'
											INNER JOIN oms_NSI.dbo.tPlanUnit pu ON
										pl.rf_PlanUnitId=pu.PlanUnitId
											INNER JOIN @t t ON
										pl.rf_QuarterId=t.QuarterID				
							WHERE LEFT(mo.tfomsCode,6)=@codeLPU AND t.MonthID=cast(@month as bigint)
							GROUP BY mo.tfomsCode,pu.unitCode
						) t ON  p.tfomsCode=t.tfomsCode AND p.unitCode=t.unitCode

INSERT @plan1(CodeLPU,UnitCode,Vm,Vdm)
SELECT p.tfomsCode,p.unitCode,ISNULL(p.V,0)+ISNULL(p.Vt,0)+ISNULL(p.O,0)+ISNULL(p.Vkm,0),ISNULL(p.Vdm,0)
FROM @tPlan p
 
SET @dateStart=CAST(@year AS CHAR(4))+RIGHT('0'+CAST(@monthMin AS VARCHAR(2)),2)+'01' 

CREATE TABLE #p (id int)
------------------------------------------------------------
insert #p 
SELECT distinct cb.rf_idCase
FROM t_FileBack f INNER JOIN t_RegisterCaseBack r ON
			f.id=r.rf_idFilesBack		
			and f.CodeM=@codeLPU
				  INNER JOIN t_RecordCaseBack cb ON
	        cb.rf_idRegisterCaseBack=r.id AND
			r.ReportMonth>=@monthMin AND r.ReportMonth<=@monthMax AND
			r.ReportYear=@year			
			INNER JOIN dbo.t_CaseBack cp ON
				cb.id=cp.rf_idRecordCaseBack					
				and cp.TypePay=1
			inner loop join t_PatientBack p ON 
			cb.id=p.rf_idRecordCaseBack
						INNER JOIN vw_sprSMO s ON 
			p.rf_idSMO=s.smocod	
WHERE f.DateCreate>=@dateStart AND f.DateCreate<=GETDATE()
CREATE CLUSTERED INDEX IX_idCase on #p(id)
------------------------------------------------------------ 
---Изменения от 27.11.2013 добавился период действия единиц учета
DECLARE @tS AS TABLE(CodeLPU CHAR(6),unitCode SMALLINT,Rate DECIMAL(11,2))
--берутся все случаи представленные в реестрах СП и ТК с типом оплаты 1 и если данный случай не является иногородним
SELECT MU, ChildUET,AdultUET, beginDate, endDate, unitCode INTO #tMU1 FROM dbo.vw_sprMU WHERE unitCode IS NOT NULL AND calculationType=1
SELECT MU, ChildUET,AdultUET, beginDate, endDate, unitCode INTO #tMU2 FROM dbo.vw_sprMU WHERE unitCode IS NOT NULL AND calculationType=2

CREATE NONCLUSTERED INDEX IX_MU1 ON #tMU1(MU,beginDate,endDate) INCLUDE(ChildUET,AdultUET,unitCode)
CREATE NONCLUSTERED INDEX IX_MU1 ON #tMU2(MU,beginDate,endDate) INCLUDE(ChildUET,AdultUET,unitCode)

INSERT @ts
SELECT c.rf_idMO
		,t1.unitCode
		,SUM(CASE WHEN m.IsChildTariff=1 THEN m.Quantity*t1.ChildUET ELSE m.Quantity*t1.AdultUET END) AS Quantity
FROM t_Case c INNER JOIN t_Meduslugi m ON
		c.id=m.rf_idCase AND c.rf_idMO=@codeLPU		
				INNER JOIN #tMU1 t1 ON
		m.MUCode=t1.MU			
		--AND t1.unitCode IS NOT NULL
				INNER JOIN #p  p ON
		c.id=p.id									
WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate --AND t1.calculationType=1
GROUP BY c.rf_idMO,t1.unitCode

---Completed case
--добавил вычисление по КСГ
insert @ts
SELECT c.rf_idMO
		,t1.unitCode
		,SUM(CASE WHEN c.IsChildTariff=1 THEN m.Quantity*t1.ChildUET ELSE m.Quantity*t1.AdultUET END) AS Quantity
FROM t_Case c INNER JOIN t_MES m ON
		c.id=m.rf_idCase AND c.rf_idMO=@codeLPU		
		and c.IsCompletedCase=1
				INNER JOIN (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU WHERE calculationType=1 
							UNION ALL 
							SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=1
							) t1 ON
		m.MES=t1.MU			
		AND t1.unitCode IS NOT NULL
				INNER JOIN #p  p ON
		c.id=p.id									
WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate--добавил фильтр по дате действия единиц учета
GROUP BY c.rf_idMO,t1.unitCode		


 IF @year<2019	--считаем на уровне таблицы t_Case
 BEGIN
		INSERT @ts
		SELECT c.rf_idMO
				,t1.unitCode
				,COUNT(DISTINCT c.id) AS Quantity
		FROM t_Case c INNER JOIN t_Meduslugi m ON
				c.id=m.rf_idCase AND c.rf_idMO=@codeLPU		
						INNER JOIN #tMU2 t1 ON
				m.MUCode=t1.MU			
				--AND t1.unitCode IS NOT NULL
						INNER JOIN #p  p ON
				c.id=p.id									
		WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate --AND t1.calculationType=2
		GROUP BY c.rf_idMO,t1.unitCode
		insert @ts
		SELECT c.rf_idMO
				,t1.unitCode
				,COUNT(DISTINCT c.id) AS Quantity
		FROM t_Case c INNER JOIN t_MES m ON
				c.id=m.rf_idCase AND c.rf_idMO=@codeLPU		
				and c.IsCompletedCase=1
						INNER JOIN (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU WHERE calculationType=2 
									UNION ALL 
									SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=2
									) t1 ON
				m.MES=t1.MU			
				AND t1.unitCode IS NOT NULL
						INNER JOIN #p  p ON
				c.id=p.id									
		WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate--добавил фильтр по дате действия единиц учета
		GROUP BY c.rf_idMO,t1.unitCode		
 END
 ELSE
  BEGIN
		INSERT @ts
		SELECT t.rf_idMO,t.unitCode,COUNT(DISTINCT Quantity)
		FROM (
				SELECT c.rf_idMO
						,t1.unitCode
						,cc.id AS Quantity
				FROM dbo.t_CompletedCase cc INNER JOIN t_Case c ON
						cc.rf_idRecordCase=c.rf_idRecordCase
											INNER JOIN t_Meduslugi m ON
						c.id=m.rf_idCase AND c.rf_idMO=@codeLPU		
								INNER JOIN #tMU2 t1 ON
						m.MUCode=t1.MU			
						--AND t1.unitCode IS NOT NULL
								INNER JOIN #p  p ON
						c.id=p.id									
				WHERE cc.DateEnd>= t1.beginDate AND cc.DateEnd<=t1.endDate --AND t1.calculationType=2
				UNION  all
				SELECT c.rf_idMO
						,t1.unitCode
						,cc.id AS Quantity
				FROM dbo.t_CompletedCase cc INNER JOIN t_Case c ON
						cc.rf_idRecordCase=c.rf_idRecordCase
											INNER JOIN t_MES m ON
						c.id=m.rf_idCase AND c.rf_idMO=@codeLPU		
						and c.IsCompletedCase=1
								INNER JOIN (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU WHERE calculationType=2 
											UNION ALL 
											SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=2
											) t1 ON
						m.MES=t1.MU			
						AND t1.unitCode IS NOT NULL
								INNER JOIN #p  p ON
						c.id=p.id									
				WHERE cc.DateEnd>= t1.beginDate AND cc.DateEnd<=t1.endDate--добавил фильтр по дате действия единиц учета
			) t
			GROUP BY t.rf_idMO,t.unitCode
end



if @year=2011			
begin
	INSERT @tS SELECT CodeLPU,unitCode,SUM(Rate)FROM t_PlanOrders2011 
	WHERE CodeLPU=@codeLPU AND MonthRate>=@monthMin AND MonthRate<=@monthMax AND YearRate=@year GROUP BY CodeLPU,unitCode
end
--------------------------------------------------------------------------------------
INSERT @plan1(CodeLPU,UnitCode,Vm,Vdm,Spred)
SELECT t.CodeLPU,t.unitCode,0,0,t.Rate
FROM @tS t

insert #tmpPlan(CodeLPU,UnitCode,Vm,Vdm,Spred,[month])	
SELECT CodeLPU,UnitCode,SUM(Vm),SUM(Vdm),ISNULL(SUM(Spred),0),(SELECT t.QuarterID FROM @t t WHERE t.MonthID=@month)
FROM @plan1 GROUP BY CodeLPU,UnitCode
DROP TABLE #p

GO

ALTER PROC [dbo].[usp_Test50]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
if NOT EXISTS (select * from sprLPUEnableCalendar where CodeM=@codeLPU and typePR_NOV=0)
begin 
--Это если запись подается впервые
	insert #tError
	select c.id,50
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				and r.IsNew=0
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join sprCalendarPR_NOV0 cal on
				a.ReportMonth=cal.ReportMonth
				and a.ReportYear=cal.ReportYear
							INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase
	where GETDATE()>=(case when c.DateEnd>=isnull(cal.ReportDate1,'20221231') and c.DateEnd<=isnull(cal.ReportDate2,'20221231') 
								then isnull(cal.ControlDate2,'20221231') else isnull(cal.ControlDate1,'20221231') end)
			AND NOT EXISTS(SELECT * FROM dbo.vw_CaseTypePay WHERE GUID_Case=cc.GUID_ZSL)

end 
if NOT EXISTS (select * from sprLPUEnableCalendar where CodeM=@codeLPU and typePR_NOV=1)
begin
--если ошибка была 57 то на данный случай не накладываем услоивия контроля дат
--все остальные повторно выставленные случаи проверяем повторно на график выставления случаев
declare @dateAdd tinyint,
		@dateNow date=getdate()
--вычисляем кол-во дней на исправление неправильных записей
select @dateAdd=spr.ControlDateDay
from t_RegistersCase a inner join sprCalendarPR_NOV1 spr on
		a.ReportYear=spr.ReportYear
		and a.rf_idFiles=@idFile

--изменил 28.04.2014
INSERT #tError
SELECT c1.id,50
FROM(
		SELECT TOP 1 WITH ties c.id,c1.id AS id2,cb.TypePay,fb.DateCreate
		from t_RegistersCase a inner join t_RecordCase r on
							a.id=r.rf_idRegistersCase
							and a.rf_idFiles=@idFile
							and r.IsNew=0
										inner join t_Case c on
							r.id=c.rf_idRecordCase
										inner join t_Case c1 on
						c.GUID_Case=c1.GUID_Case
						and c.id<>c1.id
										inner join t_RecordCaseBack rb on
						c1.id=rb.rf_idCase
										inner join t_CaseBack cb on
						rb.id=cb.rf_idRecordCaseBack   						
										inner join t_RegisterCaseBack ab on
						rb.rf_idRegisterCaseBack=ab.id
										inner join t_FileBack fb on
						ab.rf_idFilesBack=fb.id	
							INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase
		where EXISTS(SELECT * FROM dbo.vw_CaseTypePay WHERE GUID_Case=cc.GUID_ZSL)							
		ORDER BY ROW_NUMBER() OVER(PARTITION BY c.id ORDER BY fb.DateCreate desc)	
) c1
where NOT EXISTS(select * from t_ErrorProcessControl e where ErrorNumber IN (57,513) AND e.rf_idCase=c1.id2) 
		AND @dateNow>cast(DATEADD(DAY,@dateAdd,c1.DateCreate) as date) 

END
GO
PRINT N'Altering [dbo].[usp_Test591]'
GO
ALTER PROC [dbo].[usp_Test591]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	
--Проверка заполнености тега USL. Он должен быть заполнен при CODE_MES1=2.78.*
--01.04.2013
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72										
										) mc on
				mes.MES=mc.MU
							left join t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
where m.id is NULL
--для амбулаторных условий и кодов ЗС из групп 70.*, 72.* могут быть представлены услуги НЕ ТОЛЬКО  из класса 2.3,
--но хотя бы одна из услуг должна быть из класса 2.3.*,
-- но не могут быть представлены услуги из класса 2.60.*
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72										
										) mc on
				mes.MES=mc.MU
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
where m.MUCode LIKE '2.60.%'

--дневного стационара (для справки в настоящее время это коды КСГ, которые будут присутствовать в N_KSG) проводится проверка на обязательное наличие тега USL
--04.01.2019
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
WHERE c.rf_idV006=2 AND mes.IsCSGTag=2 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=c.id)

INSERT #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase													
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase				 				
where m.MUCode LIKE '2.60.%' AND c.rf_idV006=3	AND EXISTS(SELECT * FROM dbo.t_MES WHERE MES NOT LIKE '2.78.%' AND rf_idcase=c.id)
--проверяем есть ли услуги из класа 2.3.*
--Добавленна новая проверка 01.02.2014
--Изменил проверку 17.10.2014
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72										
										) mc on
				mes.MES=mc.MU			
where NOT EXISTS (SELECT DISTINCT rf_idCase from t_Meduslugi m1 WHERE m1.MUCode LIKE '2.3.%' AND m1.rf_idCase=c.id)


--------------------------------------------------09/04/2013--------------------------------------------------
-------Проверка на наличие медуслуг 2.3.* при ЗС=2.78.* 
-------c 2014 могут буть только услуги 2.60.*
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				AND a.ReportYear<2014
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78																	
										) mc on
				mes.MES=mc.MU
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase							
WHERE m.MUCode NOT LIKE '2.3.%'

insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				AND a.ReportYear>2013 AND a.ReportYear<2016
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78																	
										) mc on
				mes.MES=mc.MU
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
WHERE m.MUCode NOT LIKE '2.60.%'
 --Since 2016-0-18 We can use 57.* with 2.78.*
--для АПП и ЗС из класса 2.78.* за отчетный период 2016 и позже – или только класс 2.60 или только класс 57.*,  
 --или только медуслуги из Классификатора стоматологических услуг
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
    a.id=r.rf_idRegistersCase
    and a.rf_idFiles=@idFile
    AND a.ReportYear>2015
      inner join t_Case c on
    r.id=c.rf_idRecordCase 
      inner join t_MES mes on
    c.id=mes.rf_idCase       
    AND mes.MES LIKE '2.78.%'
       INNER JOIN t_Meduslugi m on
    mes.rf_idCase=m.rf_idCase
WHERE NOT EXISTS(SELECT * FROM vw_DentalMU WHERE MU=m.MUCode UNION ALL SELECT MU FROM dbo.vw_sprMU WHERE MUGroupCode=4)

 
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				AND a.ReportYear>2015
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
				AND mes.MES LIKE '2.78.%'
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
WHERE m.MUCode LIKE '57.%' AND EXISTS(SELECT MUCode FROM dbo.t_Meduslugi m1 WHERE m1.MUCode NOT LIKE '57.%' AND m1.rf_idCase=c.id)
---заменить---------------------------

CREATE TABLE #tMU(MU VARCHAR(20))
INSERT #tMU( MU )
SELECT MU
FROM dbo.vw_sprMU_20170801 WHERE MUGroupCode=2 AND MUUnGroupCode=60
UNION ALL
SELECT MU
FROM dbo.vw_sprMU_20170801 WHERE MUGroupCode=4
UNION ALL 
SELECT DISTINCT code FROM OMS_NSI.dbo.sprDentalMU 

CREATE UNIQUE NONCLUSTERED INDEX TMP_MU ON #tMU(MU)

insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				AND a.ReportYear>2015
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
				AND mes.MES LIKE '2.78.%'
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
WHERE c.rf_idV006=3 AND m.MUCode LIKE '2.60.%' AND c.DateEnd<'20170801'  AND EXISTS(SELECT MUCode FROM dbo.t_Meduslugi m1 WHERE m1.MUCode NOT LIKE '2.60.%' AND m1.rf_idCase=c.id)

insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				AND a.ReportYear>2015
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
						INNER JOIN dbo.vw_sprMU_20170801 sm ON
				mes.MES=sm.MU                      
						INNER JOIN dbo.t_Meduslugi m ON
				mes.rf_idCase=m.rf_idCase							
WHERE sm.MUGroupCode=2 AND MUUnGroupCode=78 and c.DateEnd>'20170831' and c.rf_idV006=3 AND NOT EXISTS(SELECT 1 FROM #tMU WHERE MU=m.MUCode)
AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprDentalMU WHERE code=m.MUSurgery)
																																			 
DROP TABLE #tMU
---заменить---------------------------
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				AND a.ReportYear>2015
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
				AND mes.MES LIKE '2.78.%'
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
							INNER JOIN OMS_NSI.dbo.sprDentalMU d ON
														m.MUCode=d.code
WHERE EXISTS(SELECT MUCode FROM dbo.t_Meduslugi m1 WHERE m1.rf_idCase=c.id AND NOT EXISTS(SELECT 1 FROM OMS_NSI.dbo.sprDentalMU d where m1.MUCode=d.code) )
--------

-----если представлены услуги из класса 2.3.*, 2.60.*  а на уровне случая отсутствует код законченного случая по соответствующим условиям оказания 
----С 13.05.2015 услуга 2.3.* Без ЗС. Надо проверять, если есть услуга 2.90.* то может быть и 2.3.*
insert #tError
SELECT DISTINCT c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase				
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase
							INNER JOIN vw_sprMU mu ON
				m.MUCode=mu.MU
									LEFT JOIN t_MES mes ON 
							c.id=mes.rf_idCase
WHERE mu.MUGroupCode=2 AND mu.MUUnGroupCode=60 /*IN (3,60)*/ AND mes.rf_idCase IS NULL	--AND c.rf_idV006=3
UNION ALL 
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase				
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase
							INNER JOIN vw_sprMU mu ON
				m.MUCode=mu.MU
									LEFT JOIN t_MES mes ON 
							c.id=mes.rf_idCase
WHERE mu.MUGroupCode=2 AND mu.MUUnGroupCode=60 /*IN (3,60)*/  AND mes.rf_idCase IS NULL	AND c.rf_idV006<>3

---11.04.2017 услуга 2.90.* не может быть без 2.3.*
--данная проверка пока не включена
INSERT #tError
select c.id,591
FROM t_File f INNER join t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND f.id=@idFile
			  inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				
						inner join t_Case c on
				r.id=c.rf_idRecordCase				
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase
WHERE m.MUCode LIKE '2.90.%' and NOT EXISTS(SELECT * FROM dbo.t_Meduslugi t where t.rf_idCase=m.rf_idCase AND t.MUCode LIKE '2.3.%')
---при дневном стационаре обязательно должна быть услуга на 55.1.*  и c 2019 года могут быть представлены услуги из класса 60.3.* и может присутствовать услуга из V001
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase				
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
WHERE c.DateEnd>='20130401' AND c.rf_idV006=2  AND NOT EXISTS(SELECT * FROM dbo.vw_sprMUUnionV001 WHERE MU=m.MUCode)

--при диализе если на 6 позиции КСГ стоит девятка, то пациенто дни не указываются
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase																	
						INNER JOIN dbo.t_MES mm ON
				c.id=mm.rf_idCase                      
WHERE c.DateEnd>='20130401' AND mm.mes not LIKE '_____9__' AND c.rf_idV006=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=c.id AND MUCode LIKE '55.1.%')
-------если представлены услуги из класса 55.1.*, а на уровне случая отсутствует код законченного случая по соответствующим условиям оказания 
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase							
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_sprMUUnionV001 v ON
				m.MUCode=v.MU							
WHERE c.rf_idV006=2 and c.DateEnd>='20130401' AND c.rf_idV010<>4 AND NOT EXISTS(SELECT * FROM t_MES mes WHERE rf_idCase=c.id)
--------------------------------Новые проверки от 23.01.2015------------------

--при стационарной помощи тег USL должен быть заполнен. А чем именно проверяется ниже
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase			
WHERE c.rf_idV006=1 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=c.id)

-- к 1.11.1 добваляется услуга 1.11.2 с 2015 года
insert #tError
select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join (SELECT rf_idRecordCase,id,rf_idV010 from t_Case WHERE rf_idV010<>32 AND rf_idV002!=158 AND DateEnd>=@dateStart AND DateEnd<@dateEnd) c on
			r.id=c.rf_idRecordCase	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						INNER JOIN (VALUES('1.11.1'),('1.11.2') ) v(MU) ON
			m.MUCode=v.mu			
WHERE  c.rf_idV010<>33
--23.01.2015
INSERT #tError
select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 			
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
WHERE m.MUCode='1.11.2' AND c.rf_idV010 NOT IN(32,33) AND c.rf_idV002<>158


INSERT #tError
select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV010=32 AND c.rf_idV002=58 AND EXISTS(SELECT * FROM dbo.t_Meduslugi m LEFT JOIN oms_nsi.dbo.V001 v ON m.MUCode=v.IDRB
																	  WHERE v.IDRB IS null AND m.rf_idCase=c.id AND MUCode<>'1.11.2')
-------------------------20.09.2016------------------------------------
--могут присутствовать (могут не присутвовать ) услуги из Номенклатуры медицинских услуг, с 2019 года могут присутствовать услуги из класса 60.3.* 
INSERT #tError
select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase                      
WHERE c.rf_idV006=1 AND m.MUCode NOT LIKE '1.11.%' AND NOT EXISTS(select IDRB FROM oms_nsi.dbo.V001 WHERE IDRB=m.MUCode 
																  UNION ALL
																  SELECT MU FROM dbo.vw_sprMU WHERE MUGroupCode=60 AND MUUnGroupCode=3 AND mu=m.MUCode
																  UNION ALL --с 2019 года
																  SELECT MU FROM dbo.vw_sprMU WHERE MUGroupCode=1 AND MUUnGroupCode=19 AND mu=m.MUCode
																 )

 --может быть медуслуга 1.11.1 или 1.11.2, вместе в одном случае их не может быть
;WITH cte
AS(
select distinct c.id,m.MUCode
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase                      
WHERE c.rf_idV006=1 AND m.MUCode LIKE '1.11.%' 
)
INSERT #tError
SELECT id,591 FROM cte GROUP BY id HAVING COUNT(*)>1
GO

PRINT N'Altering [dbo].[usp_Test65]'
GO
ALTER PROC [dbo].[usp_Test65]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

/*
----Если стационар за апрель 2018, то выдаем ошибку 65. Сделлано для того что бы принимать оставшуюся медпомощь.
insert #tError
select c.id,65
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase						
where c.rf_idV006=1 AND c.DateEnd>'20180630' AND c.DateEnd<'20180801'
*/
--TARIF
insert #tError
select mes.rf_idCase,65
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
					inner join t_MES mes on
			c.id=mes.rf_idCase
where mes.Tariff=0	

--на дату окончания лечения определяется уровень оплаты для данного медицинского учреждения  и  представленного в случае условия оказания 
insert #tError
select mes.rf_idCase,65
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
					inner join t_MES mes on
			c.id=mes.rf_idCase
where mes.Tariff is null

--определяется возраст (на дату начала лечения) пациента: если возраст меньше 18, то применяются детские тарифы, если возраст пациента не меньше 18, то применяются взрослые тарифы
-----применяется для стционара с кодом 101003, 103001, 131001, 171004 после 01.08.2017 т.е для них берем значение из поля rf_idDepartmentMO

insert #tError
select mes.rf_idCase,65
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase
						inner join t_MES mes on
				c.id=mes.rf_idCase
						left join dbo.vw_sprPriceLevelMO t1 on
				c.rf_idMO =t1.CodeM
				AND ISNULL(c.rf_idDepartmentMO,0)=ISNULL(t1.DeptCode,0)
				AND c.rf_idV006=t1.rf_idV006
				and cc.DateEnd>=t1.DateBegin
				and cc.DateEnd<=t1.DateEnd
where t1.CodeM is null
-------------------------------------------------------для общих тариффов
-----применяется для стционара с кодом 101003, 103001, 131001, 171004 после 01.08.2017 т.е для них берем значение из поля rf_idDepartmentMO
insert #tError
select t.id,65
from (
		select c.id,mes.MES,cc.DateEnd,t1.LevelPayType, c.IsChild as IsChildTariff,mes.Tariff
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
								INNER JOIN dbo.t_CompletedCase cc ON
						r.id=cc.rf_idRecordCase
								inner join t_MES mes on
						c.id=mes.rf_idCase
								inner join (SELECT MU FROM dbo.vw_sprMUCompletedCase
											 UNION ALL SELECT code FROM vw_sprCSG
											 ) m on
						mes.MES=m.MU
								inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO =t1.CodeM
						AND ISNULL(c.rf_idDepartmentMO,0)=ISNULL(t1.DeptCode,0)
						and c.rf_idV006=t1.rf_idV006
						and cc.DateEnd>=t1.DateBegin
						and cc.DateEnd<=t1.DateEnd
						and t1.LevelPayType<>'4'
		) t left join vw_sprTarrif mp on
				t.MES=mp.MU
				and t.LevelPayType=ISNULL(mp.LevelType,t.LevelPayType)
				and t.IsChildTariff=mp.IsChild
				and t.DateEnd>=mp.MUPriceDateBeg
				and t.DateEnd<=mp.MUPriceDateEnd
				and t.Tariff=mp.Price
where mp.MU is null
-------------------------------------------------------для индивидуальных тарифов

--TARIF
--02.08.2016
--Если в качестве услуги представлена хирургическая операция (класс А16 из Номенклатуры медицинских услуг) или Классификатора стоматологических услуг, 
--	то тариф должен быть равен 0
insert #tError
select distinct c.id,65
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase	
						inner join oms_NSI.dbo.V001	vm on
			m.MUCode=vm.IDRB						
where m.Price<>0

INSERT #tError
select distinct c.id,65
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase	
						inner join oms_NSI.dbo.sprDentalMU	vm on
			m.MUCode=vm.code
where m.Price<>0

--Проверка тарифов
--на дату окончания лечения определяется уровень оплаты для данного медицинского учреждения  и  представленного в случае условия оказания 
insert #tError
select mes.rf_idCase,65
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase
						inner join t_Meduslugi mes on
				c.id=mes.rf_idCase
						left join dbo.vw_sprPriceLevelMO t1 on
				c.rf_idMO=t1.CodeM
				AND c.rf_idV006=t1.rf_idV006
				and cc.DateEnd>=t1.DateBegin
				and cc.DateEnd<=t1.DateEnd
where t1.CodeM is null
--В Справочнике медицинских услуг и тарифов для данного медицинского учреждения (если уровень оплаты - индивидуальный), 
--кода медицинской услуги, возраста пациента, уровня оплаты осуществляется поиск действующего на дату окончания лечения тарифа и 
--производится сравнение с представленным значением
-------------------------------------------------------для общих тариффов

--Изменения 17.10.2014

SELECT CodeM, DeptCode,rf_idV006,DateBegin,DateEnd,LevelPayType
INTO #tmpLevel
FROM vw_sprPriceLevelMO 
WHERE CodeM=@codeLPU 
--проверяем все услуги даже нулевые, не учитываем только СМП
INSERT #tError
select t.id,65
from (
  select c.id,mes.MUCode,cc.DateEnd,t1.LevelPayType,c.IsChild AS IsChildTariff,mes.Price
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase
								INNER JOIN dbo.t_CompletedCase cc ON
						r.id=cc.rf_idRecordCase	
								inner join t_Meduslugi mes on
						c.id=mes.rf_idCase
								inner join vw_sprMU m on
						mes.MUCode=m.MU
								inner join #tmpLevel t1 on
						c.rf_idMO =t1.CodeM
						AND ISNULL(c.rf_idDepartmentMO,0)=ISNULL(t1.DeptCode,0)
						and c.rf_idV006=t1.rf_idV006
						and cc.DateEnd>=t1.DateBegin
						and cc.DateEnd<=t1.DateEnd
						and t1.LevelPayType<>'4'
	WHERE c.IsCompletedCase=0 --AND mes.Price>0
  ) t     
where NOT EXISTS(SELECT 1 FROM vw_sprNotCompletedCaseMUTariff mp WHERE t.MUCode=mp.MU and t.LevelPayType=mp.LevelType and t.IsChildTariff=mp.IsChild and t.DateEnd>=mp.MUPriceDateBeg
					and t.DateEnd<=mp.MUPriceDateEnd and t.Price=mp.Price
				 UNION ALL 
				 SELECT 1 FROM oms_nsi.dbo.PriceMU mp1 WHERE t.MUCode=mp1.CODE_PRICE and t.LevelPayType=ISNULL(mp1.LEVEL_PAY,T.LevelPayType) 
						and t.IsChildTariff=mp1.AGE and t.DateEnd>=mp1.DATE_B and t.DateEnd<=mp1.DATE_E and t.Price=mp1.Price) 
DROP TABLE #tmpLevel
-------------------------------------------------------для индивидуальных тарифов
IF @year<2018
begin
	select c.id,mes.MES,cc.DateEnd,t1.LevelPayType,c.IsChild AS IsChildTariff,mes.Tariff,(CASE WHEN c.rf_idMO IS NOT NULL THEN c.rf_idDepartmentMO ELSE c.rf_idMO END) AS rf_idMO
	INTO #tmpCasePriceMES
	from t_RegistersCase a inner join t_RecordCase r on
							a.id=r.rf_idRegistersCase
							and a.rf_idFiles=@idFile
									inner join t_Case c on
							r.id=c.rf_idRecordCase	
									INNER JOIN dbo.t_CompletedCase cc ON
							r.id=cc.rf_idRecordCase
									inner join t_MES mes on
							c.id=mes.rf_idCase
									inner join (SELECT MU FROM dbo.vw_sprMUCompletedCase 
												UNION ALL SELECT code FROM vw_sprCSG
												) m on
							mes.MES=m.MU
									inner join dbo.vw_sprPriceLevelMO t1 on
							c.rf_idMO =t1.CodeM
							AND ISNULL(c.rf_idDepartmentMO,0)=ISNULL(t1.DeptCode,0)
							and c.rf_idV006=t1.rf_idV006
							and cc.DateEnd>=t1.DateBegin
							and cc.DateEnd<=t1.DateEnd
							and t1.LevelPayType='4'

	INSERT #tError SELECT t.id,65
	FROM #tmpCasePriceMES t																		
	where NOT EXISTS( SELECT * FROM (SELECT CodeM,MU,LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,Price FROM vw_sprCompletedCaseMUTariff 
									 UNION ALL 
									 SELECT CodeM,MU,LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,Price FROM OMS_NSI.dbo.vw_sprCompletedCaseCSGTariff) mp  
					WHERE t.MES=mp.MU and t.rf_idMO=mp.CodeM and t.LevelPayType=mp.LevelType and t.IsChildTariff=mp.IsChild and t.DateEnd>=mp.MUPriceDateBeg
						  and t.DateEnd<=mp.MUPriceDateEnd and t.Tariff=mp.Price)     

	DROP TABLE #tmpCasePriceMES
----------------------------------------------------------------------------------------------------

select c.id,mes.MUCode,cc.DateEnd,t1.LevelPayType, c.IsChild AS IsChildTariff,mes.Price,c.rf_idMO
INTO #tmpCasePrice
from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
								INNER JOIN dbo.t_CompletedCase cc ON
						r.id=cc.rf_idRecordCase
								inner join t_Meduslugi mes on
						c.id=mes.rf_idCase
								inner join vw_sprMU m on
						mes.MUCode=m.MU								
								inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO =t1.CodeM
						AND ISNULL(c.rf_idDepartmentMO,0)=ISNULL(t1.DeptCode,0)
						and c.rf_idV006=t1.rf_idV006
						and cc.DateEnd>=t1.DateBegin
						and cc.DateEnd<=t1.DateEnd
						and t1.LevelPayType='4'				
where c.IsCompletedCase=0 --AND mes.Price>0

INSERT #tError SELECT t.id,65 FROM #tmpCasePrice t																		
where NOT EXISTS( SELECT * FROM vw_sprNotCompletedCaseMUTariff mp WHERE t.MUCode=mp.MU and t.rf_idMO=mp.CodeM and t.LevelPayType=mp.LevelType
																		and t.IsChildTariff=mp.IsChild and t.DateEnd>=mp.MUPriceDateBeg
																		and t.DateEnd<=mp.MUPriceDateEnd and t.Price=mp.Price)     
DROP TABLE #tmpCasePrice
END
GO

PRINT N'Altering [dbo].[usp_Test570]'
GO
ALTER PROC [dbo].[usp_Test570]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	
--услуг  из  Номенклатуры медицинских услуг (V001) при условиях оказания = 1 
insert #tError
select distinct c.id,570
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 			
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
						inner join t_Meduslugi m on
			c.id=m.rf_idCase									
where NOT EXISTS(SELECT * FROM vw_sprV002 WHERE id=m.rf_idV002) 
	
--2016-08-10 
insert #tError
select distinct c.id,570
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 			
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
						inner join t_Meduslugi m on
			c.id=m.rf_idCase			
						left join vw_sprV002 v on
			m.rf_idV002=v.id
where c.rf_idV006 IN(1,2) AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.V001 WHERE IDRB=m.MUCode) and v.id is null						
---------------2014-02-04---------------

--16.12.2013 добавил в представлени vw_idCaseWithOutPRVSandProfilCompare что проверка не производиться по КСГ
insert #tError
select distinct c.id,570
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			and c.rf_idV002!=158
			AND c.IsSpecialCase IS null	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
			c.id=ce.id
			AND ce.rf_idFiles=@idFile				
where ce.id IS NULL and c.rf_idV002<>m.rf_idV002 AND NOT EXISTS(SELECT * FROM OMS_NSI.dbo.V001 WHERE IDRB=m.MUCode)

--2014-02-27
INSERT #tError
select distinct c.id,570
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join (SELECT rf_idRecordCase,id,rf_idV002,IsSpecialCase from t_Case WHERE rf_idV010<>33 AND DateEnd>=@dateStart AND DateEnd<@dateEnd) c on
			r.id=c.rf_idRecordCase
			and c.rf_idV002!=158
			AND c.IsSpecialCase IS null	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase			
where c.rf_idV002<>m.rf_idV002 AND NOT EXISTS(SELECT * from vw_idCaseWithOutPRVSandProfilCompare 
											  WHERE rf_idFiles=@idFile AND DateEnd>=@dateStart AND DateEnd<@dateEnd AND id=c.id)  
											  AND NOT EXISTS(SELECT * FROM OMS_NSI.dbo.V001 WHERE IDRB=m.MUCode)

GO
PRINT N'Altering [dbo].[usp_Test477]'
GO
ALTER PROC [dbo].[usp_Test477]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
-- на соответсвие справочнику V027
insert #tError
SELECT DISTINCT c.id,477
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'	
				INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase						 
				INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase              
where a.rf_idFiles=@idFile AND m.Tariff IS NOT NULL AND MES IS null
GO

PRINT N'Altering [dbo].[usp_Test476]'
GO
ALTER PROC [dbo].[usp_Test476]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
-- на соответсвие справочнику V027
insert #tError
SELECT DISTINCT c.id,476
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'	
				INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase						 
				INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase              
where a.rf_idFiles=@idFile AND m.Quantity IS NOT NULL AND MES IS null
GO
PRINT N'Creating [dbo].[usp_Test479]'
GO

ALTER PROC [dbo].[usp_Test479]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
SELECT DISTINCT c.id,479
from t_file f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190501'	
				INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase	
				INNER JOIN (SELECT rf_idCase,MIN(DateHelpBegin) AS DateHelpBegin FROM dbo.t_Meduslugi	GROUP BY rf_idCase) m ON
		c.id=m.rf_idCase              
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND (m.DateHelpBegin<>c.DateBegin OR c.DateBegin<>cc.DateBegin) AND f.TypeFile='H'
GO
GRANT EXECUTE ON usp_Test479 TO db_RegisterCase 
GO
PRINT N'Altering [dbo].[usp_PlanOrdersReport]'
GO
ALTER procedure [dbo].[usp_PlanOrdersReport]---заменил табличные переменные на временные таблицы
@idFile int=null,
				@idFileBack int
as
SET LANGUAGE russian
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@number varchar(15),
		@dateCreate datetime,
		@dateStart DATETIME
--присваеваю параметрам данные из таблиц реестра СП и ТК
select @number=cast(rc.NumberRegister as varchar(13))+'-'+cast(rc.PropertyNumberRegister as CHAR(1))
		,@dateCreate=fb.DateCreate
		,@month=rc.ReportMonth
		,@year=rc.ReportYear
		,@codeLPU=fb.CodeM
from t_RegisterCaseBack rc inner join t_FileBack fb on
			rc.rf_idFilesBack=fb.id
where fb.id=@idFileBack

CREATE TABLE #plan1(
						CodeLPU varchar(6),
						UnitCode int,
						Vm DECIMAL(11,2),
						Vdm DECIMAL(11,2),
						Spred decimal(11,2)
					)
--план заказов расчитывается по новому с 2012-02-24. В качестве отчетного месяца берем данные за квартал 
-------------------------------------------------------------------------------------
declare @monthMax tinyint,
		@monthMin tinyint
-------------------------------------------------------------------------------------
declare @t as table
(
		MonthID tinyint
		,QuarterID tinyint
		,partitionQuarterID tinyint
		,QuarterName as (case when QuarterID=1 then 'первый квартал'
								when QuarterID=2 then 'второй квартал' 
								when QuarterID=3 then 'третий квартал' else 'четвертый квартал' end)
)
insert @t values(1,1,1),(2,1,2),(3,1,3),
				(4,2,1),(5,2,2),(6,2,3),
				(7,3,1),(8,3,2),(9,3,3),
				(10,4,1),(11,4,2),(12,4,3)
				
select @monthMin=MIN(t1.MonthID),@monthMax=MAX(t1.MonthID)
from @t t inner join @t t1 on
		t.QuarterID=t1.QuarterID
where t.MonthID=@month	

SET @dateStart=CAST(@year AS CHAR(4))+RIGHT('0'+CAST(@monthMin AS varCHAR(2)),2)+'01'			
--first query:расчет V суммарный объем планов-заказов, соответствующий всем предшествующим календарным кварталам за текущий год
--second query:расчет N*Int(Vt/3) объема плана-заказа делится 
--на 3 и умножается на порядковый номер отчетного месяца в квартале и остаток от деления Vt-Int(Vt/3) c 24.02.2012 он не нужен т.к. расчет идет покрватально
--third query: расчет Vkm сумарного объема всех изменений планов заказов из tPlanCorrection без МЕК
--third query: расчет Vdm сумарного объема всех изменений планов заказов из tPlanCorrection только МЕК
--------------------------------------------------------------------------------------------------------------------------------
CREATE table #tPlan(tfomsCode char(6),unitCode SMALLINT,Vkm DECIMAL(11,2),Vdm DECIMAL(11,2), Vt DECIMAL(11,2),O DECIMAL(11,2),V DECIMAL(11,2))
insert #tPlan(tfomsCode,unitCode) select @codeLPU, unitCode from oms_NSI.dbo.tPlanUnit
CREATE NONCLUSTERED INDEX ix_1 ON #tPlan(tfomsCode,unitCode)

update #tPlan
set Vkm=t.Vkm,Vdm=t.Vdm
from #tPlan p inner join (
						select left(mo.tfomsCode,6) as tfomsCode,pu.unitCode,sum(case when pc.mec=0 then ISNULL(pc.correctionRate,0) else 0 end) as Vkm,
								sum(case when pc.mec=1 then ISNULL(pc.correctionRate,0) else 0 end) as Vdm
						from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
									py.rf_MOId=mo.MOId and
									py.[year]=@year
										inner join oms_NSI.dbo.tPlan pl on
									py.PlanYearId=pl.rf_PlanYearId and 
									pl.flag='A'
										inner join oms_NSI.dbo.tPlanUnit pu on
									pl.rf_PlanUnitId=pu.PlanUnitId
										left join oms_NSI.dbo.tPlanCorrection pc on
									pl.PlanId=pc.rf_PlanId and pc.flag='A'
									and pc.rf_MonthId>=@monthMin and pc.rf_MonthId<=@monthMax 
						where left(mo.tfomsCode,6)=@codeLPU 
						group by mo.tfomsCode,pu.unitCode
						) t on p.tfomsCode=t.tfomsCode and p.unitCode=t.unitCode


update #tPlan
set V=t.V
from #tPlan p inner join (						
							select left(mo.tfomsCode,6) as tfomsCode,SUM(pl.rate) as V,pu.unitCode
							from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
										py.rf_MOId=mo.MOId and
										py.[year]=@year
											inner join oms_NSI.dbo.tPlan pl on
										py.PlanYearId=pl.rf_PlanYearId and pl.flag='A'
											inner join oms_NSI.dbo.tPlanUnit pu on
										pl.rf_PlanUnitId=pu.PlanUnitId
											inner join @t t on
										pl.rf_QuarterId=t.QuarterID				
							where left(mo.tfomsCode,6)=@codeLPU and t.MonthID=@month
							group by mo.tfomsCode,pu.unitCode
						) t on  p.tfomsCode=t.tfomsCode and p.unitCode=t.unitCode

insert #plan1(CodeLPU,UnitCode,Vm,Vdm)
select p.tfomsCode,p.unitCode,isnull(p.V,0)+isnull(p.Vt,0)+isnull(p.O,0)+isnull(p.Vkm,0),isnull(p.Vdm,0)
from #tPlan p

CREATE table #p (id int)
insert #p
SELECT distinct p.rf_idRecordCaseBack
FROM t_FileBack f INNER JOIN t_RegisterCaseBack r ON
			f.id=r.rf_idFilesBack		
			and f.CodeM=@codeLPU
				  INNER JOIN t_RecordCaseBack cb ON
	        cb.rf_idRegisterCaseBack=r.id AND
			r.ReportMonth>=@monthMin AND r.ReportMonth<=@monthMax AND
			r.ReportYear=@year
			inner join t_PatientBack p ON 
			cb.id=p.rf_idRecordCaseBack
			and p.rf_idSMO<>'00000'
						INNER JOIN vw_sprSMO s ON 
			p.rf_idSMO=s.smocod	
WHERE f.DateCreate>=@dateStart AND f.DateCreate<=@dateCreate
--OPTION(MAXDOP 4)				

SELECT calculationType,MU, beginDate, endDate,unitCode,ChildUET,AdultUET
INTO #tmpMU
FROM dbo.vw_sprMU WHERE unitCode IS NOT NULL

CREATE NONCLUSTERED INDEX IX_MU ON #tmpMU(MU,beginDate, endDate,calculationType)
INCLUDE(ChildUET,AdultUET, unitCode)

----------------------------------------Медуслуги-------------------------------
insert #plan1(CodeLPU,UnitCode,Vm,Vdm,Spred)
select t.rf_idMO,t.unitCode,0,0,SUM(t.Quantity)
from (
		select c.rf_idMO
				,t1.unitCode
				,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
		from t_FileBack f inner join t_RegisterCaseBack r on
				f.id=r.rf_idFilesBack		
				and f.DateCreate<=@dateCreate
						  inner join t_RecordCaseBack cb on
				cb.rf_idRegisterCaseBack=r.id and
				r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
				r.ReportYear=@year
						INNER JOIN dbo.t_CaseBack cp ON
				cb.id=cp.rf_idRecordCaseBack					
				and cp.TypePay=1
						inner join t_Case c on
				c.id=cb.rf_idCase
						inner join t_Meduslugi m on
				c.id=m.rf_idCase and c.rf_idMO=@codeLPU
						inner join #tmpMU t1 on
				m.MUCode=t1.MU	
						inner join #p p on
				cb.id=p.id	
		WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND t1.calculationType=1
		group by c.rf_idMO,t1.unitCode
		UNION ALL---new algorithm since 27.12.2017 
		select c.rf_idMO
				,t1.unitCode
				,COUNT(DISTINCT c.id) as Quantity
		from t_FileBack f inner join t_RegisterCaseBack r on
				f.id=r.rf_idFilesBack		
				and f.DateCreate<=@dateCreate
						  inner join t_RecordCaseBack cb on
				cb.rf_idRegisterCaseBack=r.id and
				r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
				r.ReportYear=@year
				AND r.ReportYear<2019
						INNER JOIN dbo.t_CaseBack cp ON
				cb.id=cp.rf_idRecordCaseBack					
				and cp.TypePay=1
						inner join t_Case c on
				c.id=cb.rf_idCase
						inner join t_Meduslugi m on
				c.id=m.rf_idCase and c.rf_idMO=@codeLPU
						inner join #tmpMU t1 on
				m.MUCode=t1.MU	
						inner join #p p on
				cb.id=p.id	
		WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND t1.calculationType=2
		group by c.rf_idMO,t1.unitCode	
		UNION ALL---для случаев после 2018
		select c.rf_idMO
				,t1.unitCode
				,SUM(case when c.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
		from t_FileBack f inner join t_RegisterCaseBack r on
				f.id=r.rf_idFilesBack		
				and f.DateCreate<=@dateCreate
						  inner join t_RecordCaseBack cb on
				cb.rf_idRegisterCaseBack=r.id and
				r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
				r.ReportYear=@year
						INNER JOIN dbo.t_CaseBack cp ON
				cb.id=cp.rf_idRecordCaseBack					
				and cp.TypePay=1
						inner join t_Case c on
				c.id=cb.rf_idCase
						inner join t_MES m on
				c.id=m.rf_idCase and c.rf_idMO=@codeLPU
						inner join (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU WHERE calculationType=1
									UNION ALL 
									SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=1
									) t1 on
				m.MES=t1.MU			
				and t1.unitCode is not null
						inner join #p p on
				cb.id=p.id							
		WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate 
		group by c.rf_idMO,t1.unitCode			
		) t
group by t.rf_idMO,t.unitCode
-----------------------------------------ЗС------------------------------
insert #plan1(CodeLPU,UnitCode,Vm,Vdm,Spred)
select t.rf_idMO,t.unitCode,0,0,count(DISTINCT t.Quantity)
from (
		select c.rf_idMO
				,t1.unitCode
				,cc.id as Quantity
		from t_FileBack f inner join t_RegisterCaseBack r on
				f.id=r.rf_idFilesBack		
				and f.DateCreate<=@dateCreate
						  inner join t_RecordCaseBack cb on
				cb.rf_idRegisterCaseBack=r.id and
				r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
				r.ReportYear=@year
				AND r.ReportYear>2018
						INNER JOIN dbo.t_CaseBack cp ON
				cb.id=cp.rf_idRecordCaseBack					
				and cp.TypePay=1						                      
						inner join t_Case c on
				c.id=cb.rf_idCase
						INNER JOIN dbo.t_CompletedCase cc ON
				c.rf_idRecordCase=cc.rf_idRecordCase
						inner join t_Meduslugi m on
				c.id=m.rf_idCase and c.rf_idMO=@codeLPU
						inner join #tmpMU t1 on
				m.MUCode=t1.MU	
						inner join #p p on
				cb.id=p.id	
		WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND t1.calculationType=2
		UNION ALL 
		select c.rf_idMO
				,t1.unitCode
				,c.id as Quantity
		from t_FileBack f inner join t_RegisterCaseBack r on
				f.id=r.rf_idFilesBack		
				and f.DateCreate<=@dateCreate
						  inner join t_RecordCaseBack cb on
				cb.rf_idRegisterCaseBack=r.id and
				r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
				r.ReportYear=@year
				AND r.ReportYear<2019
						INNER JOIN dbo.t_CaseBack cp ON
				cb.id=cp.rf_idRecordCaseBack					
				and cp.TypePay=1
						inner join t_Case c on
				c.id=cb.rf_idCase
						inner join t_MES m on
				c.id=m.rf_idCase and c.rf_idMO=@codeLPU
						inner join (SELECT MU,beginDate,endDate,unitCode FROM dbo.vw_sprMU WHERE calculationType=2
									UNION ALL 
									SELECT CSGCode,beginDate,endDate,UnitCode FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=2
									) t1 on
				m.MES=t1.MU			
				and t1.unitCode is not null
						inner join #p p on
				cb.id=p.id							
		WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate 
		UNION ALL --случай после 2018
		select c.rf_idMO
				,t1.unitCode
				,cc.id as Quantity
		from t_FileBack f inner join t_RegisterCaseBack r on
				f.id=r.rf_idFilesBack		
				and f.DateCreate<=@dateCreate
						  inner join t_RecordCaseBack cb on
				cb.rf_idRegisterCaseBack=r.id and
				r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
				r.ReportYear=@year
				AND r.ReportYear>2018
						INNER JOIN dbo.t_CaseBack cp ON
				cb.id=cp.rf_idRecordCaseBack					
				and cp.TypePay=1
						inner join t_Case c on
				c.id=cb.rf_idCase
						INNER JOIN dbo.t_CompletedCase cc ON
				c.rf_idRecordCase=cc.rf_idRecordCase
						inner join t_MES m on
				c.id=m.rf_idCase and c.rf_idMO=@codeLPU
						inner join (SELECT MU,beginDate,endDate,unitCode FROM dbo.vw_sprMU WHERE calculationType=2
									UNION ALL 
									SELECT CSGCode,beginDate,endDate,UnitCode FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=2
									) t1 on
				m.MES=t1.MU			
				and t1.unitCode is not null
						inner join #p p on
				cb.id=p.id							
		WHERE cc.DateEnd>= t1.beginDate AND cc.DateEnd<=t1.endDate 
		) t
group by t.rf_idMO,t.unitCode	      

select u.unitCode
		,u.unitName
		,p.Vdm as MEK
		,p.Vm as Utv
		,p.Spred
		,p.Spred-(p.Vdm+p.Vm) as Diff
		,(select QuarterName+' '+cast(@year as CHAR(4))+' г.' from @t where MonthID=@month) as ReportDate
		,v.NameS as LPU
		, @number as NumberRegister
		,cast(p.Spred as decimal(15,2))/(case when p.Vdm+p.Vm=0 then 1 else cast((p.Vdm+p.Vm) as decimal(15,2))end) as [Percent]
		,@dateCreate as DateCreateBack
from (
		select CodeLPU,UnitCode,cast(sum(Vm) as decimal(11,2)) as Vm,sum(Vdm) as Vdm
				,isnull(sum(Spred),0)  as Spred
		from #plan1 
		group by CodeLPU,UnitCode
	 ) p inner join vw_sprUnit u on
			p.UnitCode=u.unitCode
		 inner join oms_nsi.dbo.vw_sprT001 v on
			p.CodeLPU=v.CodeM	
where p.Vm+p.Spred+p.Vdm>0
order by 1


	
--------------------------------------------------------------------------------------
	
select u.unitCode
		,u.unitName
		,p.Vdm as MEK
		,p.Vm as Utv
		,p.Spred
		,p.Spred-(p.Vdm+p.Vm) as Diff
		,(select QuarterName+' '+cast(@year as CHAR(4))+' г.' from @t where MonthID=@month) as ReportDate
		,v.NameS as LPU
		, @number as NumberRegister
		,cast(p.Spred as decimal(15,2))/(case when p.Vdm+p.Vm=0 then 1 else cast((p.Vdm+p.Vm) as decimal(15,2))end) as [Percent]
		,@dateCreate as DateCreateBack
from (
		select CodeLPU,UnitCode,cast(sum(Vm) as decimal(11,2)) as Vm,sum(Vdm) as Vdm
				,isnull(sum(Spred),0)  as Spred
		from #plan1 
		group by CodeLPU,UnitCode
	 ) p inner join vw_sprUnit u on
			p.UnitCode=u.unitCode
		 inner join oms_nsi.dbo.vw_sprT001 v on
			p.CodeLPU=v.CodeM	
where p.Vm+p.Spred+p.Vdm>0
order by 1
DROP TABLE #tPlan
DROP TABLE #Plan1
DROP TABLE #tmpMU
GO
PRINT N'Altering [dbo].[usp_GetPlanOrders]'
GO
ALTER PROCEDURE [dbo].[usp_GetPlanOrders]
				@idFile INT,
				@idFileBack INT
AS
---для внесения пропущенных данных в таблицу t_PlanOrders		
SET LANGUAGE russian
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@number varchar(15),
		@dateCreate datetime ,
		@dateStart DATETIME
--присваеваю параметрам данные из таблиц реестра СП и ТК
select @number=cast(rc.NumberRegister as varchar(13))+'-'+cast(rc.PropertyNumberRegister as CHAR(1))
		,@dateCreate=fb.DateCreate
		,@month=rc.ReportMonth
		,@year=rc.ReportYear
		,@codeLPU=fb.CodeM
from t_RegisterCaseBack rc inner join t_FileBack fb on
			rc.rf_idFilesBack=fb.id
where fb.id=@idFileBack

CREATE TABLE #plan1(
						CodeLPU varchar(6),
						UnitCode int,
						Vm DECIMAL(11,2),
						Vdm DECIMAL(11,2),
						Spred decimal(11,2)
					)
--план заказов расчитывается по новому с 2012-02-24. В качестве отчетного месяца берем данные за квартал 
-------------------------------------------------------------------------------------
declare @monthMax tinyint,
		@monthMin tinyint
-------------------------------------------------------------------------------------
declare @t as table
(
		MonthID tinyint
		,QuarterID tinyint
		,partitionQuarterID tinyint
		,QuarterName as (case when QuarterID=1 then 'первый квартал'
								when QuarterID=2 then 'второй квартал' 
								when QuarterID=3 then 'третий квартал' else 'четвертый квартал' end)
)
insert @t values(1,1,1),(2,1,2),(3,1,3),
				(4,2,1),(5,2,2),(6,2,3),
				(7,3,1),(8,3,2),(9,3,3),
				(10,4,1),(11,4,2),(12,4,3)
				
select @monthMin=MIN(t1.MonthID),@monthMax=MAX(t1.MonthID)
from @t t inner join @t t1 on
		t.QuarterID=t1.QuarterID
where t.MonthID=@month				

SET @dateStart=CAST(@year AS CHAR(4))+RIGHT('0'+CAST(@monthMin AS varCHAR(2)),2)+'01'
--first query:расчет V суммарный объем планов-заказов, соответствующий всем предшествующим календарным кварталам за текущий год
--second query:расчет N*Int(Vt/3) объема плана-заказа делится 
--на 3 и умножается на порядковый номер отчетного месяца в квартале и остаток от деления Vt-Int(Vt/3) c 24.02.2012 он не нужен т.к. расчет идет покрватально
--third query: расчет Vkm сумарного объема всех изменений планов заказов из tPlanCorrection без МЕК
--third query: расчет Vdm сумарного объема всех изменений планов заказов из tPlanCorrection только МЕК
--------------------------------------------------------------------------------------------------------------------------------
declare @tPlan as table(tfomsCode char(6),unitCode SMALLINT,Vkm bigint,Vdm bigint, Vt bigint,O bigint,V bigint)
insert @tPlan(tfomsCode,unitCode) select @codeLPU, unitCode from oms_NSI.dbo.tPlanUnit

update @tPlan
set Vkm=t.Vkm,Vdm=t.Vdm
from @tPlan p inner join (
						select left(mo.tfomsCode,6) as tfomsCode,pu.unitCode,sum(case when pc.mec=0 then ISNULL(pc.correctionRate,0) else 0 end) as Vkm,
								sum(case when pc.mec=1 then ISNULL(pc.correctionRate,0) else 0 end) as Vdm
						from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
									py.rf_MOId=mo.MOId and
									py.[year]=@year
										inner join oms_NSI.dbo.tPlan pl on
									py.PlanYearId=pl.rf_PlanYearId and 
									pl.flag='A'
										inner join oms_NSI.dbo.tPlanUnit pu on
									pl.rf_PlanUnitId=pu.PlanUnitId
										left join oms_NSI.dbo.tPlanCorrection pc on
									pl.PlanId=pc.rf_PlanId and pc.flag='A'
									and pc.rf_MonthId>=@monthMin and pc.rf_MonthId<=@monthMax 
						where left(mo.tfomsCode,6)=@codeLPU 
						group by mo.tfomsCode,pu.unitCode
						) t on p.tfomsCode=t.tfomsCode and p.unitCode=t.unitCode


update @tPlan
set V=t.V
from @tPlan p inner join (						
							select left(mo.tfomsCode,6) as tfomsCode,SUM(pl.rate) as V,pu.unitCode
							from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
										py.rf_MOId=mo.MOId and
										py.[year]=@year
											inner join oms_NSI.dbo.tPlan pl on
										py.PlanYearId=pl.rf_PlanYearId and pl.flag='A'
											inner join oms_NSI.dbo.tPlanUnit pu on
										pl.rf_PlanUnitId=pu.PlanUnitId
											inner join @t t on
										pl.rf_QuarterId=t.QuarterID				
							where left(mo.tfomsCode,6)=@codeLPU and t.MonthID=@month
							group by mo.tfomsCode,pu.unitCode
						) t on  p.tfomsCode=t.tfomsCode and p.unitCode=t.unitCode

insert #plan1(CodeLPU,UnitCode,Vm,Vdm)
select p.tfomsCode,p.unitCode,isnull(p.V,0)+isnull(p.Vt,0)+isnull(p.O,0)+isnull(p.Vkm,0),isnull(p.Vdm,0)
from @tPlan p

CREATE TABLE #p(id int)
insert #p
SELECT distinct p.rf_idRecordCaseBack
FROM t_FileBack f INNER JOIN t_RegisterCaseBack r ON
			f.id=r.rf_idFilesBack		
			and f.CodeM=@codeLPU
				  INNER JOIN t_RecordCaseBack cb ON
	        cb.rf_idRegisterCaseBack=r.id AND
			r.ReportMonth>=@monthMin AND r.ReportMonth<=@monthMax AND
			r.ReportYear=@year
			inner join t_PatientBack p ON 
			cb.id=p.rf_idRecordCaseBack
			and p.rf_idSMO<>'00000'
			INNER JOIN dbo.t_CaseBack cp ON
				cb.id=cp.rf_idRecordCaseBack					
				and cp.TypePay=1
						INNER JOIN vw_sprSMO s ON 
			p.rf_idSMO=s.smocod	
WHERE f.DateCreate>=@dateStart AND f.DateCreate<=@dateCreate

--берутся все случаи представленные в реестрах СП и ТК с типом оплаты 1 и если данный случай не является иногородним
---Изменения от 27.12.2017 добавился вид расчета
SELECT calculationType,MU, beginDate, endDate,unitCode,ChildUET,AdultUET
INTO #tmpMU
FROM dbo.vw_sprMU WHERE unitCode IS NOT NULL

CREATE NONCLUSTERED INDEX IX_MU ON #tmpMU(MU,beginDate, endDate,calculationType)
INCLUDE(ChildUET,AdultUET, unitCode)

--берутся все случаи представленные в реестрах СП и ТК с типом оплаты 1 и если данный случай не является иногородним
---Изменения от 27.12.2017 добавился вид расчета
insert #plan1(CodeLPU,UnitCode,Vm,Vdm,Spred)
select t.rf_idMO,t.unitCode,0,0,SUM(t.Quantity)
from (
		select c.rf_idMO
				,t1.unitCode
				,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
		from t_FileBack f inner join t_RegisterCaseBack r on
				f.id=r.rf_idFilesBack		
				and f.DateCreate<=@dateCreate
						  inner join t_RecordCaseBack cb on
				cb.rf_idRegisterCaseBack=r.id and
				r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
				r.ReportYear=@year
						INNER JOIN dbo.t_CaseBack cp ON
				cb.id=cp.rf_idRecordCaseBack					
				and cp.TypePay=1
						inner join t_Case c on
				c.id=cb.rf_idCase
						inner join t_Meduslugi m on
				c.id=m.rf_idCase and c.rf_idMO=@codeLPU
						inner join #tmpMU t1 on
				m.MUCode=t1.MU	
						inner join #p p on
				cb.id=p.id	
		WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND t1.calculationType=1
		group by c.rf_idMO,t1.unitCode
		UNION ALL---new algorithm since 27.12.2017 
		-----------------------------------------------
		SELECT t.rf_idMO,t.unitCode,COUNT(DISTINCT t.Quantity)
		FROM (
				select DISTINCT c.rf_idMO,t1.unitCode,cc.id as Quantity
				from t_FileBack f inner join t_RegisterCaseBack r on
						f.id=r.rf_idFilesBack		
						and f.DateCreate<=@dateCreate
								  inner join t_RecordCaseBack cb on
						cb.rf_idRegisterCaseBack=r.id and
						r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
						r.ReportYear=@year
								INNER JOIN dbo.t_CaseBack cp ON
						cb.id=cp.rf_idRecordCaseBack					
						and cp.TypePay=1
								inner join t_Case c on
						c.id=cb.rf_idCase
								INNER JOIN dbo.t_CompletedCase cc ON
						c.rf_idRecordCase=cc.rf_idRecordCase                              
								inner join t_Meduslugi m on
						c.id=m.rf_idCase and c.rf_idMO=@codeLPU
								inner join #tmpMU t1 on
						m.MUCode=t1.MU	
								inner join #p p on
						cb.id=p.id	
				WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND t1.calculationType=2
				UNION ALL ---new algorithm since 27.12.2017
				select DISTINCT c.rf_idMO,t1.unitCode,cc.id as Quantity
				from t_FileBack f inner join t_RegisterCaseBack r on
						f.id=r.rf_idFilesBack		
						and f.DateCreate<=@dateCreate
								  inner join t_RecordCaseBack cb on
						cb.rf_idRegisterCaseBack=r.id and
						r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
						r.ReportYear=@year
								INNER JOIN dbo.t_CaseBack cp ON
						cb.id=cp.rf_idRecordCaseBack					
						and cp.TypePay=1
								inner join t_Case c on
						c.id=cb.rf_idCase
								INNER JOIN dbo.t_CompletedCase cc ON
						c.rf_idRecordCase=cc.rf_idRecordCase
								inner join t_MES m on
						c.id=m.rf_idCase and c.rf_idMO=@codeLPU
								inner join (SELECT MU,beginDate,endDate,unitCode FROM dbo.vw_sprMU WHERE calculationType=2
											UNION ALL 
											SELECT CSGCode,beginDate,endDate,UnitCode FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=2
											) t1 on
						m.MES=t1.MU			
						and t1.unitCode is not null
								inner join #p p on
						cb.id=p.id							
				WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate 
			) t
			GROUP BY t.rf_idMO, t.unitCode

		) t
group by t.rf_idMO,t.unitCode

insert #plan1(CodeLPU,UnitCode,Vm,Vdm,Spred)
select t.rf_idMO,t.unitCode,0,0,SUM(t.Quantity)
from (
		select c.rf_idMO
				,t1.unitCode
				,SUM(case when c.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
		from t_FileBack f inner join t_RegisterCaseBack r on
				f.id=r.rf_idFilesBack		
				and f.DateCreate<=@dateCreate
						  inner join t_RecordCaseBack cb on
				cb.rf_idRegisterCaseBack=r.id and
				r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
				r.ReportYear=@year
						INNER JOIN dbo.t_CaseBack cp ON
				cb.id=cp.rf_idRecordCaseBack					
				and cp.TypePay=1
						inner join t_Case c on
				c.id=cb.rf_idCase
						inner join t_MES m on
				c.id=m.rf_idCase and c.rf_idMO=@codeLPU
						inner join (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU WHERE calculationType=1
									UNION ALL 
									SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=1
									) t1 on
				m.MES=t1.MU			
				and t1.unitCode is not null
						inner join #p p on
				cb.id=p.id							
		WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate 
		group by c.rf_idMO,t1.unitCode				
		) t
group by t.rf_idMO,t.unitCode

SELECT @idFile,@idFileBack,p.CodeLPU,u.UnitCode,Vm,Vdm,Spred,@month,@year 
from (
		select CodeLPU,UnitCode,cast(sum(Vm) as decimal(11,2)) as Vm,sum(Vdm) as Vdm
				,isnull(sum(Spred),0)  as Spred
		from #plan1 
		group by CodeLPU,UnitCode
	 ) p inner join vw_sprUnit u on
			p.UnitCode=u.unitCode
		 inner join oms_nsi.dbo.vw_sprT001 v on
			p.CodeLPU=v.CodeM	
where p.Vm+p.Spred+p.Vdm>0
GO
PRINT N'Altering [dbo].[usp_Test514]'
GO
ALTER PROC [dbo].[usp_Test514]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

IF(SELECT TypeFile FROM dbo.t_File WHERE id=@idFile)='H'
begin
SELECT m.MU
INTO #tMU
FROM dbo.vw_sprMUAll m INNER JOIN (VALUES ('4.8.504'), ('4.11.538'),('4.11.539'),('4.12.501'),('4.12.502'),('4.12.521'),('4.12.531'),('4.12.532'),('4.12.533'),('4.12.552'),
											('4.12.553'),('4.12.561'),('4.12.566'),('4.12.591'),('4.12.592'),('4.12.614'),('4.12.616'),('4.12.617'),('4.12.618'),('4.12.621'),
											('4.12.637'),('4.12.669'),('4.12.670'),('4.12.672'),('4.12.675'),('4.12.676'),('4.12.677'),('4.12.678'),('4.12.679'),('4.12.680'),
											('4.12.681'),('4.12.682'),('4.12.683'),('4.12.684'),('4.12.685'),('4.12.686'),('4.12.687'),('4.12.688'),('4.12.689'),('4.12.690'),
											('4.12.691'),('4.12.692'),('4.12.661'),('4.13.501'),('4.13.502'),('4.13.503'),('4.13.504'),('4.13.505'),('4.13.506'),('4.15.501'),
											('4.15.502'),('4.15.503'),('4.15.504'),('4.15.505'),('4.15.506'),('4.15.507'),('4.15.508'),('4.15.509'),('4.15.510'),('4.15.511'),
											('4.15.512'),('4.15.513'),('4.15.514'),('4.15.515'),('4.15.516'),('4.15.517'),('4.15.518'),('4.15.519'),('4.15.520'),('4.15.521'),
											('4.15.522'),('4.15.523'),('4.15.524'),('4.15.525'),('4.15.526'),('4.15.527'),('4.15.528'),('4.15.529'),('4.15.530'),('4.15.531'),
											('4.15.532'),('4.15.533'),('4.15.534'),('4.15.535'),('4.15.536'),('4.15.537'),('4.15.538'),('4.15.539'),('4.15.540'),('4.15.541'),
											('4.15.542'),('4.15.543'),('4.15.544'),('4.15.545'),('4.16.501'),('4.16.502'),('4.16.503'),('4.16.504'),('4.16.505'),('4.16.506'),
											('4.16.507'),('4.16.508'),('4.16.509'),('4.16.510'),('4.16.511'),('4.16.512'),('4.16.513'),('4.16.514'),('4.16.515'),('4.16.516'),
											('4.16.517'),('4.16.518'),('4.16.519'),('4.16.520'),('4.16.521'),('4.16.522'),('4.16.523'),('4.16.524'),('4.16.525'),('4.16.526'),
											('4.16.527'),('4.16.528'),('4.16.529'),('4.16.530'),('4.16.531'),('4.16.532'),('4.16.533'),('4.16.534'),('4.16.535'),('4.16.536'),
											('4.16.537'),('4.16.538'),('4.16.539'),('4.16.540'),('4.17.501'),('4.17.502'),('4.17.503'),('4.17.504'),('4.17.505'),('4.17.506'),
											('4.17.507'),('4.17.508'),('4.17.509'),('4.17.510'),('4.17.511'),('4.17.512'),('4.17.513'),('4.17.514'),('4.17.515'),('4.17.516'),
											('4.17.517'),('4.17.518'),('4.17.519'),('4.17.520'),('4.17.521'),('4.17.522'),('4.17.523'),('4.17.524'),('4.17.525'),('4.17.526'),
											('4.17.527'),('4.17.528'),('4.17.529'),('4.17.530'),('4.17.531'),('4.17.532'),('4.17.533'),('4.17.534'),('4.17.535'),('4.17.536'),
											('4.17.537'),('4.17.538'),('4.17.539'),('4.17.540'),('4.17.541'),('4.17.542'),('4.17.543'),('4.17.544'),('4.17.545'),('4.17.546'),
											('4.17.547'),('4.17.548'),('4.17.549'),('4.17.550'),('4.17.551'),('4.17.552'),('4.17.553'),('4.17.554'),('4.17.555'),('4.17.556'),
											('4.17.557'),('4.17.558'),('4.17.559'),('4.17.560'),('4.17.561'),('4.17.562'),('4.17.563'),('4.17.564'),('4.17.565'),('4.17.566'),
											('4.17.567'),('4.17.568'),('4.17.569'),('4.17.570'),('4.17.571'),('4.17.572'),('4.17.573'),('4.17.574'),('4.17.575'),('4.17.576'),('4.11.540')) v(MU) ON
								m.MU=v.mu
UNION ALL
SELECT IDRB FROM oms_nsi.dbo.v001 WHERE isTelemedicine=1
/*
•	в поле COMENTU указано ОТКАЗ,
•   когда Медуслуга не из списка
•	DATE_IN< DATE_1
•	Значение в поле LPU на уровне случая не равно значению в теге LPU для услуги. 

*/
	INSERT #tError
	select distinct c.id,514
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile 						
							inner join t_Case c on
				r.id=c.rf_idRecordCase				
							inner join t_Meduslugi m on
				c.id=m.rf_idCase
	WHERE m.rf_idDoctor IS NULL AND m.DateHelpBegin>=c.DateBegin AND c.rf_idMO=m.rf_idMO AND UPPER(ISNULL(m.Comments,'bla-bla'))<>'ОТКАЗ' 
			AND NOT EXISTS(SELECT * FROM #tMU t WHERE t.MU=m.MUCode) AND c.rf_idMO NOT IN('125901' ,'805965')

DROP TABLE #tMU

END

IF(SELECT TypeFile FROM dbo.t_File WHERE id=@idFile)='F'
BEGIN
/* 
•	в поле P_OTK на уровне медуслуги указано значение, большее  0 (раньше было: большее 1),
•	DATE_IN< DATE_1
•	Значение в поле LPU на уровне случая не равно значению в теге LPU для услуги.

*/
	INSERT #tError
	select distinct c.id,514
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile 						
							inner join t_Case c on
				r.id=c.rf_idRecordCase				
							inner join t_Meduslugi m on
				c.id=m.rf_idCase
	WHERE m.rf_idDoctor IS NULL AND m.DateHelpBegin>=c.DateBegin AND c.rf_idMO=m.rf_idMO AND m.IsNeedUsl=0 
			--AND NOT EXISTS(SELECT * FROM #tMU t WHERE t.MU=m.MUCode)
 END

----При оказании амбулаторной помощи  в КДП2
IF (@CodeLPU<>'125901' AND  @CodeLPU<>'805965')
BEGIN 
	INSERT #tError
	select distinct c.id,514
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile 						
							inner join t_Case c on
				r.id=c.rf_idRecordCase										
	WHERE c.rf_idDoctor IS NULL AND c.rf_idV006<>3
end 
 
GO
PRINT N'Altering [dbo].[usp_Test512]'
GO
ALTER PROC [dbo].[usp_Test512]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--512
--02.08.2016
insert #tError 
select c.id,512
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase						
WHERE m.MUSurgery IS NOT NULL AND NOT EXISTS(SELECT * FROM vw_sprV001_DentalMU WHERE IDRB=m.MUSurgery)

--Если значение не совпадает со значением в теге CODE_USL или не соответствует номенклатуре медицинских услуг (V001)
insert #tError 
select c.id,512
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013
			AND a.ReportYear<2019
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
						INNER JOIN vw_sprV001_DentalMU v ON
			m.MUSurgery=v.IDRB
WHERE m.MUSurgery IS NOT NULL AND m.MUSurgery<>m.MUCode	

insert #tError 
select c.id,512
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
WHERE m.MUSurgery IS NOT NULL AND NOT EXISTS(SELECT 1 FROM vw_sprV001_DentalMU v WHERE v.IDRB=m.MUSurgery)
--не ввели в действие т.к. вылетает весь диализ

GO

PRINT N'Creating [dbo].[usp_Test480]'
GO

alter PROC [dbo].[usp_Test480]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
SELECT DiagnosisCode
INTO #tDS
FROM dbo.vw_sprMKB10 WHERE DiagnosisCode LIKE 'C%' OR DiagnosisCode LIKE 'D0%'

insert #tError
SELECT DISTINCT c.id,480
from t_file f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190501'	
				INNER JOIN t_DispInfo d1 ON
		c.id=d1.rf_idCase				
				INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase 
				INNER JOIN #tDS dd ON
		d.DiagnosisCode=dd.DiagnosisCode             
where a.rf_idFiles=@idFile AND f.TypeFile='f' AND d.TypeDiagnosis=1 AND d1.IsOnko=1

insert #tError
SELECT DISTINCT c.id,480
from t_file f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190501'	
				INNER JOIN t_DispInfo d1 ON
		c.id=d1.rf_idCase				
				INNER JOIN dbo.t_DS2_Info d ON
		c.id=d.rf_idCase 
				INNER JOIN #tDS dd ON
		d.DiagnosisCode=dd.DiagnosisCode             
where a.rf_idFiles=@idFile AND f.TypeFile='f' AND d1.IsOnko=1 
GO
GRANT EXECUTE ON usp_Test480 TO db_RegisterCase 
go
PRINT N'Altering [dbo].[usp_Test420]'
GO
ALTER PROC [dbo].[usp_Test420]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
-- на соответсвие справочнику V027
insert #tError
SELECT DISTINCT c.id,420
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'	
				INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase						 
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.C_ZAB IS NOT NULL AND NOT EXISTS(SELECT * FROM  oms_nsi.dbo.sprV027 WHERE IDCZ=c.C_ZAB AND cc.DateEnd BETWEEN DATEBEG AND DATEEND)

--Тег обязательно присутствует, если (USL_OK=3 and DS1 not is like Z%) 
insert #tError
SELECT DISTINCT c.id,420
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'							 
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.C_ZAB IS NULL AND c.rf_idV006=3 AND d.DS1 NOT LIKE 'Z[0-9][0-9]%'

--Тег обязательно присутствует, если (DS1 is like C% or DS1 like D0%)
SELECT DiagnosisCode INTO #tDS1 FROM dbo.vw_sprMKB10 WHERE DiagnosisCode LIKE 'C%'
INSERT #tDS1( DiagnosisCode ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE DiagnosisCode LIKE 'D0%'
insert #tError
SELECT DISTINCT c.id,420
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'							 
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS1 dd ON
		d.DS1=dd.DiagnosisCode              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.C_ZAB IS NULL 

--Тег обязательно присутствует, если (DS1 like D70% and один из сопутствующих DS2 из диапазона (C00-C80,C97))
SELECT DiagnosisCode INTO #tDS2 FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C00' AND 'C80'
INSERT #tDS2 SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS='C97'

insert #tError
SELECT DISTINCT c.id,420
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'							 
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS2 dd ON
		d.DS2=dd.DiagnosisCode              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.C_ZAB IS NULL AND d.DS1 LIKE 'D70%'

DROP TABLE #tDS1
DROP TABLE #tDS2
GO

PRINT N'Altering [dbo].[usp_RunFirstProcessControl]'
GO
--не запускать пока не пройдена стадия тестирования	
ALTER proc [dbo].[usp_RunFirstProcessControl]
			@idFile int			
as
set nocount on

create table #tError (rf_idCase bigint,ErrorNumber smallint)

declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6),
		@typeFile char(1)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO, @typeFile=UPPER(f.TypeFile)
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

DECLARE @period INT

SET @period=CONVERT([int],CONVERT([char](4),@year,(0))+right('0'+CONVERT([varchar](2),@month,(0)),(2)),(0))
------------------------
---------------only H file type--------------
IF @typeFile='H'
BEGIN
	exec usp_Test507 @idFile,@month,@year,@codeLPU	
	exec usp_Test509 @idFile,@month,@year,@codeLPU
	exec usp_Test510 @idFile,@month,@year,@codeLPU
	exec usp_Test512 @idFile,@month,@year,@codeLPU
	exec usp_Test543 @idFile,@month,@year,@codeLPU
	--exec usp_Test544 @idFile,@month,@year,@codeLPU
	exec usp_Test547 @idFile,@month,@year,@codeLPU
	exec usp_Test553 @idFile,@month,@year,@codeLPU
	
	exec usp_Test570 @idFile,@month,@year,@codeLPU
	exec usp_Test571 @idFile,@month,@year,@codeLPU
	exec usp_Test572 @idFile,@month,@year,@codeLPU
	exec usp_Test574 @idFile,@month,@year,@codeLPU
	exec usp_Test404 @idFile,@month,@year,@codeLPU
	exec usp_Test412 @idFile,@month,@year,@codeLPU
	exec usp_Test413 @idFile,@month,@year,@codeLPU
	exec usp_Test414 @idFile,@month,@year,@codeLPU --включить позже
	exec usp_Test415 @idFile,@month,@year,@codeLPU--включить позже
	exec usp_Test416 @idFile,@month,@year,@codeLPU
	exec usp_Test417 @idFile,@month,@year,@codeLPU
	IF @year>2017
	BEGIN
		exec usp_Test405 @idFile,@month,@year,@codeLPU	  
		exec usp_Test406 @idFile,@month,@year,@codeLPU	  
		exec usp_Test407 @idFile,@month,@year,@codeLPU	
		exec usp_Test408 @idFile,@month,@year,@codeLPU	
		exec usp_Test409 @idFile,@month,@year,@codeLPU	
	END
	IF @period>201808 
	BEGIN
		exec usp_Test419 @idFile,@month,@year,@codeLPU	  
		exec usp_Test420 @idFile,@month,@year,@codeLPU	 
		exec usp_Test421 @idFile,@month,@year,@codeLPU	  
		exec usp_Test422 @idFile,@month,@year,@codeLPU	  
		exec usp_Test423 @idFile,@month,@year,@codeLPU	  
		exec usp_Test424 @idFile,@month,@year,@codeLPU	  
		exec usp_Test425 @idFile,@month,@year,@codeLPU	  
		exec usp_Test426 @idFile,@month,@year,@codeLPU	  
		exec usp_Test427 @idFile,@month,@year,@codeLPU	  

		exec usp_Test428 @idFile,@month,@year,@codeLPU	  
		exec usp_Test429 @idFile,@month,@year,@codeLPU	  
		exec usp_Test430 @idFile,@month,@year,@codeLPU	  

		exec usp_Test431 @idFile,@month,@year,@codeLPU	  
		exec usp_Test432 @idFile,@month,@year,@codeLPU	  
		--exec usp_Test433 @idFile,@month,@year,@codeLPU	  
		--exec usp_Test434 @idFile,@month,@year,@codeLPU	  
		exec usp_Test435 @idFile,@month,@year,@codeLPU	  
		exec usp_Test436 @idFile,@month,@year,@codeLPU	  
		exec usp_Test437 @idFile,@month,@year,@codeLPU	  
		exec usp_Test438 @idFile,@month,@year,@codeLPU	  
		exec usp_Test439 @idFile,@month,@year,@codeLPU	  
		exec usp_Test440 @idFile,@month,@year,@codeLPU	  
		exec usp_Test441 @idFile,@month,@year,@codeLPU	  
		exec usp_Test442 @idFile,@month,@year,@codeLPU	
		----------------------------------------------
		exec usp_Test443 @idFile,@month,@year,@codeLPU	  
		exec usp_Test444 @idFile,@month,@year,@codeLPU	  
		exec usp_Test445 @idFile,@month,@year,@codeLPU	  
		exec usp_Test446 @idFile,@month,@year,@codeLPU	  
		exec usp_Test447 @idFile,@month,@year,@codeLPU	  
		exec usp_Test448 @idFile,@month,@year,@codeLPU	  
		exec usp_Test449 @idFile,@month,@year,@codeLPU	  
		exec usp_Test450 @idFile,@month,@year,@codeLPU	  
		exec usp_Test451 @idFile,@month,@year,@codeLPU	  
		exec usp_Test452 @idFile,@month,@year,@codeLPU	  
		exec usp_Test453 @idFile,@month,@year,@codeLPU	  
		exec usp_Test454 @idFile,@month,@year,@codeLPU	  
		exec usp_Test455 @idFile,@month,@year,@codeLPU	  
		exec usp_Test456 @idFile,@month,@year,@codeLPU	  
		exec usp_Test457 @idFile,@month,@year,@codeLPU	  
		exec usp_Test458 @idFile,@month,@year,@codeLPU	  
		exec usp_Test459 @idFile,@month,@year,@codeLPU	
		
		exec usp_Test460 @idFile,@month,@year,@codeLPU	  
		exec usp_Test461 @idFile,@month,@year,@codeLPU	  
		exec usp_Test462 @idFile,@month,@year,@codeLPU	  
		exec usp_Test463 @idFile,@month,@year,@codeLPU	  
		exec usp_Test464 @idFile,@month,@year,@codeLPU	  
		exec usp_Test465 @idFile,@month,@year,@codeLPU	  
		exec usp_Test474 @idFile,@month,@year,@codeLPU	  
	END   
--включил для всех МО т.к не помню почему исключали КДП 2
	--IF @codeLPU<>'125901'
	--begin
		exec usp_Test577 @idFile,@month,@year,@codeLPU
	--end
	--exec usp_Test594 @idFile,@month,@year,@codeLPU --отменена для HR и FR
END

IF @typeFile='F'
BEGIN
	 exec usp_Test526 @idFile,@month,@year,@codeLPU
	 exec usp_Test527 @idFile,@month,@year,@codeLPU
	 exec usp_Test528 @idFile,@month,@year,@codeLPU
	 exec usp_Test529 @idFile,@month,@year,@codeLPU
	 exec usp_Test400 @idFile,@month,@year,@codeLPU
	 exec usp_Test401 @idFile,@month,@year,@codeLPU
	 exec usp_Test403 @idFile,@month,@year,@codeLPU
	 exec usp_Test410 @idFile,@month,@year,@codeLPU
	 exec usp_Test411 @idFile,@month,@year,@codeLPU


	 exec usp_Test596 @idFile,@month,@year,@codeLPU
	 exec usp_Test597 @idFile,@month,@year,@codeLPU
	 exec usp_Test592 @idFile,@month,@year,@codeLPU
	 exec usp_Test593 @idFile,@month,@year,@codeLPU
-----------14.02.2019--------------------
	exec usp_Test466 @idFile,@month,@year,@codeLPU
	exec usp_Test467 @idFile,@month,@year,@codeLPU
	exec usp_Test468 @idFile,@month,@year,@codeLPU
	exec usp_Test469 @idFile,@month,@year,@codeLPU
	exec usp_Test470 @idFile,@month,@year,@codeLPU
	exec usp_Test471 @idFile,@month,@year,@codeLPU
	exec usp_Test472 @idFile,@month,@year,@codeLPU
	exec usp_Test473 @idFile,@month,@year,@codeLPU
END


exec usp_Test519 @idFile,@month,@year,@codeLPU
exec usp_Test520 @idFile,@month,@year,@codeLPU
exec usp_Test521 @idFile,@month,@year,@codeLPU
exec usp_Test522 @idFile,@month,@year,@codeLPU
exec usp_Test475 @idFile,@month,@year,@codeLPU
exec usp_Test476 @idFile,@month,@year,@codeLPU
exec usp_Test477 @idFile,@month,@year,@codeLPU
exec usp_Test478 @idFile,@month,@year,@codeLPU
exec usp_Test479 @idFile,@month,@year,@codeLPU
exec usp_Test480 @idFile,@month,@year,@codeLPU
IF @year>2016
begin
	exec usp_Test523 @idFile,@month,@year,@codeLPU
end
exec usp_Test524 @idFile,@month,@year,@codeLPU
exec usp_Test525 @idFile,@month,@year,@codeLPU
-------------------------
exec usp_Test50 @idFile,@month,@year,@codeLPU
exec usp_Test501 @idFile,@month,@year,@codeLPU
exec usp_Test502 @idFile,@month,@year,@codeLPU
exec usp_Test504 @idFile,@month,@year,@codeLPU
exec usp_Test505 @idFile,@month,@year,@codeLPU

exec usp_Test508 @idFile,@month,@year,@codeLPU

exec usp_Test511 @idFile,@month,@year,@codeLPU

exec usp_Test514 @idFile,@month,@year,@codeLPU
exec usp_Test515 @idFile,@month,@year,@codeLPU
exec usp_Test516 @idFile,@month,@year,@codeLPU
exec usp_Test518 @idFile,@month,@year,@codeLPU
exec usp_Test531 @idFile,@month,@year,@codeLPU
exec usp_Test532 @idFile,@month,@year,@codeLPU
exec usp_Test533 @idFile,@month,@year,@codeLPU
exec usp_Test534 @idFile,@month,@year,@codeLPU
exec usp_Test535 @idFile,@month,@year,@codeLPU
exec usp_Test536 @idFile,@month,@year,@codeLPU
exec usp_Test537 @idFile,@month,@year,@codeLPU
exec usp_Test538 @idFile,@month,@year,@codeLPU
exec usp_Test541 @idFile,@month,@year,@codeLPU
exec usp_Test542 @idFile,@month,@year,@codeLPU

exec usp_Test545 @idFile,@month,@year,@codeLPU
exec usp_Test546 @idFile,@month,@year,@codeLPU

exec usp_Test548 @idFile,@month,@year,@codeLPU
exec usp_Test549 @idFile,@month,@year,@codeLPU
exec usp_Test55 @idFile,@month,@year,@codeLPU
exec usp_Test550 @idFile,@month,@year,@codeLPU
exec usp_Test551 @idFile,@month,@year,@codeLPU,@mcod
exec usp_Test552 @idFile,@month,@year,@codeLPU
exec usp_Test554 @idFile,@month,@year,@codeLPU --включил для всех типов файлов 08.02.2017

exec usp_Test556 @idFile,@month,@year,@codeLPU
exec usp_Test557 @idFile,@month,@year,@codeLPU
exec usp_Test558 @idFile,@month,@year,@codeLPU
exec usp_Test559 @idFile,@month,@year,@codeLPU,@dateReg
exec usp_Test560 @idFile,@month,@year,@codeLPU
exec usp_Test561 @idFile,@month,@year,@codeLPU
exec usp_Test562 @idFile,@month,@year,@codeLPU
--exec usp_Test563 @idFile,@month,@year,@codeLPU --отменена для HR и FR
exec usp_Test564 @idFile,@month,@year,@codeLPU
exec usp_Test565 @idFile,@month,@year,@codeLPU
exec usp_Test566 @idFile,@month,@year,@codeLPU
exec usp_Test568 @idFile,@month,@year,@codeLPU
exec usp_Test569 @idFile,@month,@year,@codeLPU

exec usp_Test573 @idFile,@month,@year,@codeLPU

exec usp_Test575 @idFile,@month,@year,@codeLPU
exec usp_Test576 @idFile,@month,@year,@codeLPU

exec usp_Test578 @idFile,@month,@year,@codeLPU
exec usp_Test579 @idFile,@month,@year,@codeLPU
exec usp_Test580 @idFile,@month,@year,@codeLPU
exec usp_Test582 @idFile,@month,@year,@codeLPU
exec usp_Test583 @idFile,@month,@year,@codeLPU
--exec usp_Test584 @idFile,@month,@year,@codeLPU -- проверка отменена 14.08.2017 по приказу Антоновой т.к. в некоторых МУ происходит интеграция одной системы с другой
exec usp_Test591 @idFile,@month,@year,@codeLPU


exec usp_Test595 @idFile,@month,@year,@codeLPU

exec usp_Test598 @idFile,@month,@year,@codeLPU
exec usp_Test63 @idFile,@month,@year,@codeLPU
exec usp_Test65 @idFile,@month,@year,@codeLPU
exec usp_Test66 @idFile,@month,@year,@codeLPU
exec usp_Test71 @idFile,@month,@year,@codeLPU

begin transaction
begin try
	if(select @@SERVERNAME)!='TSERVER'
	begin
		insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
		select distinct ErrorNumber,@idFile,c.id
		FROM #tError e INNER JOIN t_Case c ON 
				e.rf_idCase=c.id
						INNER JOIN t_Case cc ON
				c.rf_idRecordCase=cc.rf_idRecordCase     
	end
	drop table #tError
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()	
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
GO

PRINT N'Altering [dbo].[usp_RunProcessControl]'
GO
ALTER proc [dbo].[usp_RunProcessControl]
			@CaseDefined TVP_CasePatient READONLY,		
			@idFile int
	
as
declare @tError as table(rf_idCase bigint,ErrorNumber smallint)

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--------------------------------------проверка на дулированность случая по пациенту в РС F от 15/08/2017--------------------------------
IF EXISTS(SELECT * FROM oms_nsi.dbo.vw_sprT001 WHERE CodeM=@codeLPU AND pfs=1 )
BEGIN
	insert @tError
	select c.id,589
	from @CaseDefined cd inner join t_Case c on
					cd.rf_idCase=c.id
					and c.rf_idV006=4					
						inner join t_Meduslugi m on
					c.id=m.rf_idCase										 
	where NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.v001 WHERE IDRB=m.MUCode AND isTelemedicine=1
					 UNION ALL 
					 SELECT 1 FROM vw_sprMUSplitByGroup mu WHERE m.MUCode=mu.MU and mu.MUGroupCode=71 and mu.MUUnGroupCode IN (1 ,3)
					 )
	group by c.id
END
IF EXISTS(SELECT 1 FROM dbo.t_File WHERE id=@idFile AND TypeFile='F')
BEGIN 
		----проверка на дулированность случая по пациенту в РС F от 15/08/2017
		CREATE TABLE #tab(rf_idCase bigint,IdStep tinyint)
		--собираем данные по файлу
		--данные по застрахованным определенным на 1-ом этапе
		INSERT #tab( rf_idCase, IdStep )
		SELECT rf.rf_idCase,1
		FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
						rf.id=i.rf_idRefCaseIteration		          
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration=1				                          

		---для данных вернувшихся из ФФОМС
		INSERT #tab( rf_idCase, IdStep )
		SELECT rf.rf_idCase,2
		FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
						rf.id=i.rf_idRefCaseIteration
										INNER JOIN @CaseDefined cd ON
						rf.rf_idCase=cd.rf_idCase                              
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration>1				                          

		------------------------------------------------------------------
		----проверка на дулированность случая по пациенту в РС F
		IF EXISTS(SELECT 1 FROM t_File WHERE id=@idFile AND TypeFile='F')
		BEGIN
			;WITH cteDouble
			AS
			(  
			SELECT ROW_NUMBER() OVER(PARTITION BY UniqueNumberPolicy,d.TypeDisp ORDER BY cd.IdStep,c.idRecordCase ASC) AS idRow, c.id,c.idRecordCase,pb.UniqueNumberPolicy AS enp
				,d.TypeDisp,cd.IdStep
			from #tab cd inner join t_Case c on
							cd.rf_idCase=c.id	
								 INNER JOIN dbo.t_RecordCaseBack rb ON
							c.id=rb.rf_idCase
								INNER JOIN dbo.t_DispInfo d ON
							c.id=d.rf_idCase  
								 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
								--INNER JOIN dbo.t_CaseDefine pb ON
								INNER JOIN dbo.vw_CaseDefineAll pb ON
							rp.id=pb.rf_idRefCaseIteration 										                 
			WHERE d.TypeDisp IN('ДВ1','ДВ2','ОПВ')   
			)
			insert @tError 
			SELECT distinct id,71 FROM cteDouble WHERE idRow>1
		-----------------------------------------------------70 error--------------------------------------------------
		CREATE TABLE #tmpCasesDouble(id BIGINT, ENP VARCHAR(20), TypeDisp VARCHAR(3), ReportYear SMALLINT, NumberRegister INT, GUID_Case UNIQUEIDENTIFIER)

		IF EXISTS(SELECT * 
		FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
						rf.id=i.rf_idRefCaseIteration
										INNER JOIN @CaseDefined cd ON
						rf.rf_idCase=cd.rf_idCase                              
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration=1)
		BEGIN
		--Test 70
			INSERT #tmpCasesDouble (id,ENP,TypeDisp,ReportYear,NumberRegister,GUID_Case)
			SELECT c.id,pb.UniqueNumberPolicy AS ENP,d.TypeDisp,a.ReportYear, a.NumberRegister,c.GUID_Case
			from @CaseDefined cd inner join t_Case c on
							cd.rf_idCase=c.id
						 INNER JOIN dbo.t_RecordCase r ON
							c.rf_idRecordCase=r.id
						 INNER JOIN dbo.t_RegistersCase a ON
			  				r.rf_idRegistersCase=a.id			 
						 INNER JOIN dbo.t_DispInfo d ON
							c.id=d.rf_idCase
						 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
						 INNER JOIN dbo.t_CaseDefine pb ON
							rp.id=pb.rf_idRefCaseIteration
			WHERE d.TypeDisp IN('ДВ1','ДВ2','ОПВ') 
		END
		IF EXISTS(SELECT * 
		FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
						rf.id=i.rf_idRefCaseIteration
										INNER JOIN @CaseDefined cd ON
						rf.rf_idCase=cd.rf_idCase                              
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration>1)
		BEGIN
		--Test 70
			INSERT #tmpCasesDouble (id,ENP,TypeDisp,ReportYear,NumberRegister,GUID_Case)
			SELECT c.id,pb.UniqueNumberPolicy AS ENP,d.TypeDisp,a.ReportYear, a.NumberRegister,c.GUID_Case	
			from @CaseDefined cd inner join t_Case c on
							cd.rf_idCase=c.id
						 INNER JOIN dbo.t_RecordCase r ON
							c.rf_idRecordCase=r.id
						 INNER JOIN dbo.t_RegistersCase a ON
			  				r.rf_idRegistersCase=a.id			 
						 INNER JOIN dbo.t_DispInfo d ON
							c.id=d.rf_idCase
						 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
						 INNER JOIN dbo.t_CaseDefineZP1Found pb ON
							rp.id=pb.rf_idRefCaseIteration
			WHERE d.TypeDisp IN('ДВ1','ДВ2','ОПВ') 
		END

		insert @tError 
		SELECT distinct id,70--,ENP,GUID_Case
		FROM #tmpCasesDouble c 
		WHERE EXISTS (SELECT 1 FROM dbo.vw_CaseDispNotExistInAccount WHERE rf_idFiles<>@idFile and ENP=c.ENP AND TypeDisp=c.TypeDisp AND ReportYear=c.ReportYear AND CodeM=@codeLPU)
		---2. Когда случай был выставлен в счетах, без РАК.
		insert @tError 
		SELECT distinct id,70--,enp,GUID_Case
		FROM #tmpCasesDouble c 
		WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_CaseDispInAccountWithoutFin WHERE NumberRegister<>c.NumberRegister and ENP=c.ENP AND TypeDisp=c.TypeDisp AND ReportYear=c.ReportYear AND CodeM=@codeLPU)	

		---3. Когда случай был выставлен в счетах и присутствует РАК без полного снятия.
		insert @tError 
		SELECT distinct id,70--,ENP
		FROM #tmpCasesDouble c 
		WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_CaseDispInAccountFin WHERE NumberRegister<>c.NumberRegister and ENP=c.ENP AND TypeDisp=c.TypeDisp AND ReportYear=c.ReportYear AND CodeM=@codeLPU)

		DROP TABLE #tmpCasesDouble
						                        
		END 

		DROP TABLE #tab				                        
END
------------------------------------проверка на полные дубли для файлов HR по стационару и дневному-----------------
IF EXISTS(SELECT 1 FROM dbo.t_File WHERE id=@idFile AND TypeFile='H')
BEGIN 
declare @reportYear SMALLINT,
		@numReg int
SELECT @reportYear=ReportYear , @numReg=NumberRegister FROM dbo.t_RegistersCase WHERE rf_idFiles=@idFile 
		----проверка на дулированность случая по пациенту в РС H от 10/10/2017 для стационара и дневного стационара
		CREATE TABLE #tabStac(rf_idCase bigint,IdStep TINYINT,ENP VARCHAR(16),DateBeg DATE,DateEnd DATE,NewBorn VARCHAR(9),DS1 VARCHAR(9),rf_idFile INT, NumberCase INT, rf_idV006 tinyint)
		--собираем данные по файлу
		--данные по застрахованным определенным на 1-ом этапе
		INSERT #tabStac
		SELECT DISTINCT rf.rf_idCase,1,pb.UniqueNumberPolicy,cc.DateBegin,cc.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006
		FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
						rf.id=i.rf_idRefCaseIteration
										INNER JOIN t_Case c ON
						rf.rf_idCase=c.id		          
										INNER JOIN dbo.t_RecordCase r ON
						c.rf_idRecordCase=r.id
										INNER JOIN dbo.t_CompletedCase cc ON
						r.id=cc.rf_idRecordCase
										 INNER JOIN dbo.t_RecordCaseBack rb ON
							c.id=rb.rf_idCase								
										 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
										INNER JOIN dbo.t_CaseDefine pb ON
							rp.id=pb.rf_idRefCaseIteration 							
										INNER JOIN dbo.t_Diagnosis d ON
							c.id=d.rf_idCase
							AND d.TypeDiagnosis=1			                                      
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration=1	AND c.rf_idV006 <3

		---для данных вернувшихся из ФФОМС
		INSERT #tabStac
		SELECT DISTINCT rf.rf_idCase,2,pb.UniqueNumberPolicy,cc.DateBegin,cc.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006
		FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
						rf.id=i.rf_idRefCaseIteration
										INNER JOIN @CaseDefined cd ON
						rf.rf_idCase=cd.rf_idCase 
										INNER JOIN t_Case c ON
						rf.rf_idCase=c.id              
										INNER JOIN dbo.t_RecordCase r ON
						c.rf_idRecordCase=r.id
											INNER JOIN dbo.t_CompletedCase cc ON
						r.id=cc.rf_idRecordCase
										 INNER JOIN dbo.t_RecordCaseBack rb ON
							c.id=rb.rf_idCase								
										 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
										INNER JOIN dbo.t_CaseDefineZP1Found pb ON
							rp.id=pb.rf_idRefCaseIteration 							
										INNER JOIN dbo.t_Diagnosis d ON
							c.id=d.rf_idCase
							AND d.TypeDiagnosis=1			               
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration>1 AND c.rf_idV006<3				                          

		------------------------------------------------------------------
		----проверка на дулированность случая по пациенту в РС по стационару и дневному стационару
			;WITH cteDouble
			AS
			(  
			SELECT ROW_NUMBER() OVER(PARTITION BY s1.ENP,DateBeg,DateEnd,/*DS1,*/NewBorn,rf_idV006 ORDER BY s1.IdStep,s1.NumberCase ASC) AS idRow, s1.rf_idCase,s1.NumberCase,s1.ENP				
			from #tabStac s1
			)
			insert @tError 
			SELECT distinct rf_idCase,71 FROM cteDouble WHERE idRow>1
	------------------------------------------------------70-----------------------------------
	/*Данныу берем из  той же временной таблицы*/
		insert @tError 
		SELECT distinct rf_idCase,70--,ENP,GUID_Case
		FROM #tabStac c 
		WHERE EXISTS (SELECT 1 FROM dbo.vw_CaseNotExistInAccount 
					  WHERE rf_idFiles<>@idFile and ENP=c.ENP /*AND DS1=c.DS1*/ AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
							AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006)
		---2. Когда случай был выставлен в счетах, без РАК.
		insert @tError 
		SELECT distinct rf_idCase,70--,enp,GUID_Case
		FROM #tabStac c 
		WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_CaseInAccountWithoutFin 
					  WHERE NumberRegister<>@numReg and ENP=c.ENP /*AND DS1=c.DS1*/ AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
							AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006)

		---3. Когда случай был выставлен в счетах и присутствует РАК без полного снятия.
		insert @tError 
		SELECT distinct rf_idCase,70
		FROM #tabStac c 
		WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_CaseInAccountFin 
					  WHERE NumberRegister<>@numReg AND ENP=c.ENP/*AND DS1=c.DS1*/ AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
							AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006)

		DROP TABLE #tabStac	
END
-----------------------------22.02.2018---------------------------
------------------------------------проверка на полные дубли для файлов HR по АМП-----------------
IF EXISTS(SELECT 1 FROM dbo.t_File WHERE id=@idFile AND TypeFile='H')
BEGIN 
--declare @reportYear SMALLINT,
--		@numReg int
		SELECT @reportYear=ReportYear , @numReg=NumberRegister FROM dbo.t_RegistersCase WHERE rf_idFiles=@idFile 
		----проверка на дулированность случая по пациенту в РС H от 10/10/2017 для стационара и дневного стационара
		CREATE TABLE #tabAmb(rf_idCase bigint,IdStep TINYINT,ENP VARCHAR(16),DateBeg DATE,DateEnd DATE,NewBorn VARCHAR(9),DS1 VARCHAR(9),rf_idFile INT, NumberCase INT, rf_idV006 TINYINT, rf_idV002 smallint, rf_idV004 int)
		--собираем данные по файлу
		--данные по застрахованным определенным на 1-ом этапе
		INSERT #tabAmb
		SELECT DISTINCT rf.rf_idCase,1,pb.UniqueNumberPolicy,c.DateBegin,c.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006,c.rf_idV002, c.rf_idV004
		FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
						rf.id=i.rf_idRefCaseIteration
										INNER JOIN t_Case c ON
						rf.rf_idCase=c.id		          
										INNER JOIN dbo.t_RecordCase r ON
						c.rf_idRecordCase=r.id
										 INNER JOIN dbo.t_RecordCaseBack rb ON
							c.id=rb.rf_idCase								
										 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
										INNER JOIN dbo.t_CaseDefine pb ON
							rp.id=pb.rf_idRefCaseIteration 							
										INNER JOIN dbo.t_Diagnosis d ON
							c.id=d.rf_idCase
							AND d.TypeDiagnosis=1			                                      
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration=1	AND c.rf_idV006=3 AND c.rf_idV002<>34

		---для данных вернувшихся из ФФОМС
		INSERT #tabAmb
		SELECT DISTINCT rf.rf_idCase,2,pb.UniqueNumberPolicy,c.DateBegin,c.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006,c.rf_idV002, c.rf_idV004
		FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
						rf.id=i.rf_idRefCaseIteration
										INNER JOIN @CaseDefined cd ON
						rf.rf_idCase=cd.rf_idCase 
										INNER JOIN t_Case c ON
						rf.rf_idCase=c.id              
										INNER JOIN dbo.t_RecordCase r ON
						c.rf_idRecordCase=r.id
										 INNER JOIN dbo.t_RecordCaseBack rb ON
							c.id=rb.rf_idCase								
										 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
										INNER JOIN dbo.t_CaseDefineZP1Found pb ON
							rp.id=pb.rf_idRefCaseIteration 							
										INNER JOIN dbo.t_Diagnosis d ON
							c.id=d.rf_idCase
							AND d.TypeDiagnosis=1			               
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration>1 AND c.rf_idV006=3 AND c.rf_idV002<>34 AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl WHERE rf_idCase=c.id)				                          

		------------------------------------------------------------------
		----проверка на дулированность случая по пациенту в РС по стационару и дневному стационару
			;WITH cteDouble
			AS
			(  
				SELECT ROW_NUMBER() OVER(PARTITION BY s1.ENP,DateBeg,DateEnd,DS1,NewBorn,rf_idV006,rf_idV002, rf_idV004 ORDER BY s1.IdStep,s1.NumberCase ASC) AS idRow, s1.rf_idCase,s1.NumberCase,s1.ENP				
				from #tabAmb s1
			)
			insert @tError 
			SELECT distinct rf_idCase,71 FROM cteDouble WHERE idRow>1
	------------------------------------------------------70-----------------------------------	
	/*Данныу берем из  той же временной таблицы*/
		insert @tError 
		SELECT distinct rf_idCase,70--,ENP,GUID_Case
		FROM #tabAmb c 
		WHERE EXISTS (SELECT 1 FROM dbo.vw_AmbCaseNotExistInAccount 
					  WHERE rf_idFiles<>@idFile and ENP=c.ENP AND DS1=c.DS1 AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
							AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006 AND rf_idV002=c.rf_idV002 AND rf_idV004=c.rf_idV004)
		---2. Когда случай был выставлен в счетах, без РАК.
		insert @tError 
		SELECT distinct rf_idCase,70--,enp,GUID_Case
		FROM #tabAmb c 
		WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_AmbCaseInAccountWithoutFin 
					  WHERE NumberRegister<>@numReg and ENP=c.ENP AND DS1=c.DS1 AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
							AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006 AND rf_idV002=c.rf_idV002 AND rf_idV004=c.rf_idV004)

		---3. Когда случай был выставлен в счетах и присутствует РАК без полного снятия.
		insert @tError 
		SELECT distinct rf_idCase,70
		FROM #tabAmb c 
		WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_AmbCaseInAccountFin 
					  WHERE NumberRegister<>@numReg AND ENP=c.ENP AND DS1=c.DS1 AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
							AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006 AND rf_idV002=c.rf_idV002 AND rf_idV004=c.rf_idV004)
		

		DROP TABLE #tabAmb	
END
--------------------------------------------------------------------------------------------

------------------------------------------------------------------
--Проверка N: проверка плана-заказа. Всегда должна быть последней
--внес корректировки с тем что некоторые МО просят сдать данные за предыдущий отчетный год

create table #tmpPlan
(
	CodeLPU varchar(6),
	UnitCode int,
	Vm DECIMAL(11,2),
	Vdm DECIMAL(11,2),
	Spred decimal(11,2),
	[month] tinyint
)
exec usp_PlanOrders @CodeLPU,@month,@year

if NOT EXISTS(select * from t_LPUPlanOrdersDisabled where CodeM=@codeLPU and ReportYear=@year and BeforeDate>=GETDATE())
begin
	declare @t1 as table(rf_idCase bigint,idRecordCase int,Quantity decimal(11,2),unitCode int,TotalRest decimal(11,2))
		------------------------------------------------------

	insert @t1(rf_idCase,Quantity,unitCode,idRecordCase)
	select id,Quantity,unitCode,idRecordCase 
	from vw_dataPlanOrder c inner join @CaseDefined cd on
				c.id=cd.rf_idCase
	where rf_idFiles=@idFile	
	order by idRecordCase asc
		
		--использую курсор т.к. на данный момент это проще всего, но его потом следует заменить
		declare cPlan cursor for
			select f.UnitCode,f.Vdm,f.Vm,f.Spred,f.Vdm+f.Vm-f.Spred from #tmpPlan f
			declare @unit int,@vdm decimal(11,2), @vm decimal(11,2), @spred decimal(11,2),@totalPlan decimal(11,2)
		open cPlan
		fetch next from cPlan into @unit,@vdm,@vm,@spred,@totalPlan
		while @@FETCH_STATUS = 0
		begin					
			update @t1 set @totalPlan=TotalRest=@totalPlan-Quantity where unitCode=@unit
			
			fetch next from cPlan into @unit,@vdm,@vm,@spred,@totalPlan
		end
		close cPlan
		deallocate cPlan

		insert @tError	select distinct rf_idCase,62 from @t1 where TotalRest<0
end

begin transaction
begin try
	--insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
	--select ErrorNumber,@idFile,rf_idCase 
	--from @tError
	insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
	select distinct ErrorNumber,@idFile,c.id
	FROM @tError e INNER JOIN t_Case c ON 
				e.rf_idCase=c.id
						INNER JOIN t_Case cc ON
				c.rf_idRecordCase=cc.rf_idRecordCase  
end try

begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	drop table #tmpPlan
	commit transaction
	
GO

PRINT N'Altering [dbo].[usp_RegistrationRegisterCaseReport]'
GO
ALTER procedure [dbo].[usp_RegistrationRegisterCaseReport]
				@idFile int,
				@idFileBack int
as
SET LANGUAGE russian
declare @countIdCase int,
		@countIdCasePR int,
		@countIdCaseE int,
		@FileNameBack varchar(26),
		@NumberSPTK varchar(15),
		@DateRegisterBack char(10),
		@countIdCaseE1 int,
		@countNotDefined INT,
		@countErroFLK smallint

select @countIdCasePR=count(distinct rc.rf_idRecordCase)
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack
		and f.id=@idFileBack 
		and f.rf_idFiles=@idFile 
				inner join t_RecordCaseBack rc on
		r.id=rc.rf_idRegisterCaseBack
				INNER JOIN dbo.t_CaseBack cb ON
		rc.id=cb.rf_idRecordCaseBack              
WHERE cb.TypePay=1 
----------------------------------------------------------------------------------------------------------------------------------------------
select @countIdCase=COUNT(Distinct c.rf_idRecordCase)
from t_File f inner join t_RegistersCase r on
			f.id=r.rf_idFiles
				  inner join t_RecordCase rc on
			r.id=rc.rf_idRegistersCase
				  inner join t_Case c on
			rc.id=c.rf_idRecordCase				  
where f.id=@idFile	
--------------------------------------------------------------------------------------------------------------------------------------------
select @FileNameBack=FileNameHRBack,@DateRegisterBack=CONVERT(char(10),r.DateCreate,104),
		@NumberSPTK=CAST(NumberRegister as varchar(8))+'-'+CAST(PropertyNumberRegister as varchar(3))
from t_FileBack fb inner join t_RegisterCaseBack r on
		fb.id=r.rf_idFilesBack
where rf_idFiles=@idFile and fb.id=@idFileBack
-------------------------------количество всех ошибок---------------------------------------------------------------------------------------------------------------
select @countIdCaseE=count(distinct rf.id)
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack
					inner join t_RecordCaseBack rc on
		r.id=rc.rf_idRegisterCaseBack		
					inner join dbo.t_Case rf on
		rf.id=rc.rf_idCase
					inner join dbo.t_ErrorProcessControl e on
		rf.id=e.rf_idCase
		--and e.ErrorNumber!=57
		and e.rf_idFile=@idFile
where f.id=@idFileBack and f.rf_idFiles=@idFile


--количество записей по которым не определена страховая принадлежность
IF NOT EXISTS(SELECT * FROM dbo.t_RegisterCaseBack WHERE rf_idFilesBack=@idFileBack AND PropertyNumberRegister=2)
BEGIN 
	select @countNotDefined=count(distinct c.rf_idRecordCase)
	from dbo.t_RefCasePatientDefine f INNER JOIN dbo.t_Case c ON
			f.rf_idCase=c.id  
	where f.rf_idFiles=@idFile AND f.IsUnloadIntoSP_TK IS NULL
end  
ELSE 
BEGIN
	select @countNotDefined=count(distinct rc.rf_idRecordCase)
	from t_FileBack f inner join t_RegisterCaseBack r on
			f.id=r.rf_idFilesBack
						inner join t_RecordCaseBack rc on
			r.id=rc.rf_idRegisterCaseBack							
						inner join t_ErrorProcessControl e on
			rc.rf_idCase=e.rf_idCase
			and e.ErrorNumber=57
			and e.rf_idFile=@idFile										
	where f.id=@idFileBack and f.rf_idFiles=@idFile 

END

SELECT @countErroFLK=COUNT(e.rf_idGuidFieldError)
FROM dbo.t_File f INNER JOIN dbo.t_FileTested ft ON
			   f.rf_idFileTested=ft.id
					INNER JOIN dbo.t_FileError fe ON
				ft.id=fe.rf_idFileTested                  
					 inner join t_FileNameError fn on
			fe.id=fn.rf_idFileError
					INNER JOIN dbo.t_Error e ON
				fn.id=e.rf_idFileNameError
WHERE f.id=@idFile
--------------------------------------------------------------------------------------------------------------------------------------------
select rtrim(f.FileNameHR)+'.zip' as FileZIP,t001.NameS,dbo.fn_MonthName(r.ReportYear,r.ReportMonth) as ReportDate,r.ReportMonth,r.ReportYear,
		convert(CHAR(10),f.DateRegistration,104)+' '+cast(cast(f.DateRegistration as time(7)) as varchar(8)) as DateRegistration,
		f.CountSluch+@countErroFLK AS CountSluch
		,@countErroFLK as ErrorFLK
		,@countIdCase as CountIdCase
		,r.NumberRegister
		,CONVERT(char(10),r.DateRegister,104) as DateRegister
		,fe.FileNameP
		,@countIdCasePR as countIdCasePR
		,@countIdCasePR as countIdCaseNoE --количество записей без ошибок
		,@FileNameBack as FileNameBack
		,@NumberSPTK as NumberSPTK
		,@DateRegisterBack as DateRegisterBack
		,@countIdCaseE as ErrorTK1 --ошибки на ТК1	
		,@countNotDefined as UnDefined
from t_File f inner join t_RegistersCase r on
		f.id=r.rf_idFiles
			  inner join vw_sprT001 t001 on
		f.CodeM=t001.CodeM
				inner join t_FileTested ft on
		f.rf_idFileTested=ft.id
				left join t_FileError fe on
		ft.id=fe.rf_idFileTested
where f.id=@idFile
GO

PRINT N'Altering [dbo].[usp_RegisterSP_TK2019]'
GO

ALTER proc [dbo].[usp_RegisterSP_TK2019]
			@idFileBack int
as
DECLARE @idFile INT 

update t_FileBack set IsUnload=1 where id=@idFileBack and IsUnload=0

SELECT @idFile=rf_idFiles FROM dbo.t_FileBack WHERE id=@idFileBack

select FileVersion as [VERSION],cast(DateCreate as date) as DATA,FileNameHRBack as [FILENAME]
from t_FileBack
where id=@idFileBack

select id as CODE, ref_idF003 as CODE_MO,cast(ReportYear as int) as [YEAR],cast(ReportMonth as int) as [MONTH],
		CAST(NumberRegister as varchar(8))+'-'+CAST(PropertyNumberRegister as char(1)) as NSCHET,
		DateCreate as DSCHET
from t_RegisterCaseBack
where rf_idFilesBack=@idFileBack
/* 
т.к совершил ошибку и уходили случай на определение страховой принадлежности в ФФОМС, когда они были отданы в реестре СП и ТК с №1
решил исключить такие случаи
*/	
-----------------------------------------------------------------------------
DECLARE @step TINYINT

SELECT @step=PropertyNumberRegister FROM dbo.t_RegisterCaseBack WHERE rf_idFilesBack=@idFileBack
CREATE TABLE #t(rf_idRecordCase int)
IF @step=2
BEGIN 
		INSERT #t( rf_idRecordCase )
		SELECT DISTINCT recb.rf_idRecordCase
		FROM dbo.t_FileBack f INNER join t_RegisterCaseBack rcb ON
					f.id=rcb.rf_idFilesBack
						inner join t_RecordCaseBack recb on
					rcb.id=recb.rf_idRegisterCaseBack
									inner join t_RecordCase rc on
					recb.rf_idRecordCase=rc.id
		where f.rf_idFiles=@idFile AND PropertyNumberRegister=1
end
-----------------------------------------------------------------------------
select rc.idRecord as N_ZAP
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
where rf_idFilesBack=@idFileBack AND NOT EXISTS(SELECT 1 FROM #t t WHERE t.rf_idRecordCase=recb.rf_idRecordCase)
group by  rc.idRecord
order by N_ZAP
 /*
 Разделил выбор т.к код МО при диспансеризации и всякое другое .... не возвращается на 2 и 4 итерации, но если мы нашли человека на 1 итерации, то учитываем тот код МО.
 */
SELECT DISTINCT  upper(rc.ID_Patient) as ID_PAC,p.rf_idF008 as VPOLIS,
		case when rtrim(p.SeriaPolis)='' then null else rtrim(p.SeriaPolis) end as SPOLIS
		,rtrim(p.NumberPolis) as NPOLIS
		,case WHEN p.OKATO<>'18000' THEN '34'else ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end as SMO
		,p.OKATO as SMO_OK,rc.idRecord as N_ZAP		
		,isnull(p.AttachCodeM,'000000') as MO_PR,p.ENP,recb.IdStep AS [IDENTITY]
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack							
where rf_idFilesBack=@idFileBack AND NOT EXISTS(SELECT * FROM dbo.t_RefCaseAttachLPUItearion2 WHERE rf_idFiles=@idFile AND rf_idCase=recb.rf_idCase)
		AND NOT EXISTS(SELECT 1 FROM #t t WHERE t.rf_idRecordCase=recb.rf_idRecordCase)
group by rc.ID_Patient,p.rf_idF008,p.SeriaPolis,p.NumberPolis
		,case WHEN p.OKATO<>'18000' THEN '34'else ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end 
		,p.OKATO ,rc.idRecord,isnull(p.AttachCodeM,'000000'),p.ENP,recb.IdStep 
UNION
SELECT DISTINCT upper(rc.ID_Patient) as ID_PAC,p.rf_idF008 as VPOLIS,
		case when rtrim(p.SeriaPolis)='' then null else rtrim(p.SeriaPolis) end as SPOLIS
		,rtrim(p.NumberPolis) as NPOLIS
		,case WHEN p.OKATO<>'18000' THEN '34'else ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end as SMO
		,p.OKATO as SMO_OK,rc.idRecord as N_ZAP
		,CASE WHEN p.OKATO<>'18000' THEN '000000' ELSE att.AttachLPU end as MO_PR
		,p.ENP
		,recb.IdStep AS IdStep
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack							
							INNER JOIN dbo.t_RefCaseAttachLPUItearion2 att on
			att.rf_idFiles=@idFile 
			AND att.rf_idCase=recb.rf_idCase
where rf_idFilesBack=@idFileBack AND NOT EXISTS(SELECT 1 FROM #t t WHERE t.rf_idRecordCase=recb.rf_idRecordCase)
group by rc.ID_Patient,p.rf_idF008,p.SeriaPolis,p.NumberPolis
		,case WHEN p.OKATO<>'18000' THEN '34'else ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end 
		,p.OKATO ,rc.idRecord		  
		,CASE WHEN p.OKATO<>'18000' THEN '000000' ELSE att.AttachLPU end,p.ENP,recb.IdStep 
order by N_ZAP


SELECT  t.IDCASE ,t.ID_C ,MAX(t.OPLATA) AS OPLATA,t.N_ZAP ,t.COMENTSL
FROM (
select cc.idRecordCase as IDCASE,upper(cc.GUID_ZSL) as ID_C ,cd.TypePay as OPLATA,rc.idRecord as N_ZAP,null as COMENTSL
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
				rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
				recb.rf_idRecordCase=rc.id
							INNER JOIN dbo.t_CompletedCase cc ON --new
				rc.id=cc.rf_idRecordCase                          
							inner join t_Case c on
				recb.rf_idCase=c.id
							inner JOIN t_CaseBack cd on
				recb.id=cd.rf_idRecordCaseBack
where rf_idFilesBack=@idFileBack AND NOT EXISTS(SELECT 1 FROM #t t WHERE t.rf_idRecordCase=recb.rf_idRecordCase)
group by cc.idRecordCase,cc.GUID_ZSL,cd.TypePay,rc.idRecord
) t
GROUP BY t.IDCASE ,t.ID_C ,t.N_ZAP ,t.COMENTSL
order by N_ZAP

select upper(cc.GUID_ZSL) as ID_C,cast(e.ErrorNumber as int) as REFREASON
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
				rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
				recb.rf_idRecordCase=rc.id
							INNER JOIN dbo.t_CompletedCase cc ON --new
				rc.id=cc.rf_idRecordCase 
							inner join t_Case c on
				recb.rf_idCase=c.id						
							inner join t_ErrorProcessControl e on
				recb.rf_idCase=e.rf_idCase
				AND e.rf_idFile=@idFile
where rf_idFilesBack=@idFileBack AND NOT EXISTS(SELECT 1 FROM #t t WHERE t.rf_idRecordCase=recb.rf_idRecordCase)
group by cc.GUID_ZSL,e.ErrorNumber
-------------------------------Correction Information----------------------------------------------------------------------

SELECT DISTINCT upper(rc.ID_Patient) as ID_PAC,CASE WHEN cor.TypeEquale=1 then cor.FAM ELSE NULL END AS Fam
		,CASE WHEN cor.TypeEquale=2 then isnull(cor.IM,'') ELSE NULL END AS Im
		,CASE WHEN cor.TypeEquale=3 then isnull(cor.OT,'') ELSE NULL END AS Ot
		,CASE WHEN cor.TypeEquale=4 then cor.BirthDay ELSE NULL END AS DR
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							INNER JOIN dbo.t_RefCasePatientDefine rf ON
			recb.rf_idCase=rf.rf_idCase
							INNER JOIN dbo.t_CaseDefine cd ON
			rf.id=cd.rf_idRefCaseIteration
							INNER JOIN dbo.t_Correction cor ON
			cor.rf_idCaseDefine=cd.id                          
where rf_idFilesBack=@idFileBack AND recb.IdStep=1 AND NOT EXISTS(SELECT 1 FROM #t t WHERE t.rf_idRecordCase=recb.rf_idRecordCase)
-----------------------------------------------------------------------------------------------------
DROP TABLE #t
GO

PRINT N'Altering [dbo].[usp_FillBackTablesAfterAllIteration]'
GO
--подаем id файла реестра сведений по котором закончена определения страховой принадлежности
--запуск производится только в том случае если по всем случаям присутствет запись в t_CasePatientDefineIteration
ALTER proc [dbo].[usp_FillBackTablesAfterAllIteration]
			@idFile int
as
if NOT EXISTS(
				select * from vw_getFileBack v where v.rf_idFiles=@idFile and v.PropertyNumberRegister=0
				union all
				select * from vw_getFileBack v where v.rf_idFiles=@idFile and v.PropertyNumberRegister=2
			 )
begin
		declare @property tinyint=2

		declare @fileName varchar(29),
				@idFileBack int,
				@idRegisterCaseBack int
		declare @idRecordCaseBack as table(rf_idRecordCaseBack int,rf_idCase BIGINT, STep TINYINT)

		--имя реестра СП и ТК
		select @fileName=dbo.fn_GetFileNameBack(@idFile)
		INSERT dbo.t_FileBackNumberOrder( FILENAMEBack) VALUES(@fileName)
		--временная таблица для того что бы не было двойных записей по пациентам
		--данные индекс будит вдальнейшем висеть на таблице t_PatientBack, сейчас пока не вычестил двойников из нее.
		CREATE TABLE #PatientBack
		(
			rf_idRecordCaseBack int NOT NULL,
			rf_idF008 tinyint NOT NULL,
			SeriaPolis varchar(10) NULL,
			NumberPolis varchar(20) NOT NULL,
			rf_idSMO char(5) NOT NULL,
			OKATO char(5) NULL,
			AttachLPU VARCHAR(6),
			ENP VARCHAR(16)
		)

		create unique nonclustered index UQ_IDRecordCaseBack on #PatientBack(rf_idRecordCaseBack) with IGNORE_DUP_KEY


		declare @CaseDefined TVP_CasePatient,--общая
				@CaseDefined1 TVP_CasePatient,--для местных
				@CaseDefined2 TVP_CasePatient --для иногородних

		insert @CaseDefined(rf_idCase,ID_Patient)
		select rf_idCase,rf_idRegisterPatient
		from t_RefCasePatientDefine
		where rf_idFiles=@idFile and (IsUnloadIntoSP_TK is null)
		--не иногородние
		insert @CaseDefined1(rf_idCase,ID_Patient)
		select rf.rf_idCase,rf.rf_idRegisterPatient
		from (
				select rf.rf_idCase,rf.rf_idRegisterPatient
				from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
							rf.id=c.rf_idRefCaseIteration
							and c.OKATO ='18000'		
										inner join t_CasePatientDefineIteration i on
							rf.id=i.rf_idRefCaseIteration
							and i.rf_idIteration in (2,4)			  
				where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
				union all
				select rf.rf_idCase,rf.rf_idRegisterPatient
				from t_RefCasePatientDefine rf inner join t_CasePatientDefineIteration i on
							rf.id=i.rf_idRefCaseIteration
							and i.rf_idIteration in (3)			  
				where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
				group by rf.rf_idCase,rf.rf_idRegisterPatient
			 ) rf

		
		--12.01.2017
		--По иногородним должна быть определена страховая принадлежность т.к. другие регионы нам отказывают в оплате
		---иногородние
		--сюда необходимо добавить выборку иногородних 05.02.2012
		insert @CaseDefined2(rf_idCase,ID_Patient)
		select rf.rf_idCase,rf.rf_idRegisterPatient
		from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
					rf.id=c.rf_idRefCaseIteration
					and c.OKATO is not null
					and c.OKATO!='18000'									  
		where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
	
		--производим технологический контроль для застрахованных в других территориях
		--убрал проверку 28.03.2012 т.к. все проверки реализованный на ТК1
		--exec usp_RunProcessControl2 @CaseDefined2,@idFile

		begin transaction T1
		begin try
		--записи по которым не была определена страховая пр инадлежность. делаем пометку в таблице ошибок с номером 57
		--сюда необходимо добавить выборку иногородних 05.02.2012 что бы они не попадали в ошибки
			insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
			select 57,@idFile,c1.id
			from @CaseDefined cd inner join t_RefCasePatientDefine rf on
						cd.rf_idCase=rf.rf_idCase
								  inner join t_CaseDefineZP1Found c on
						rf.id=c.rf_idRefCaseIteration
								  inner join t_CasePatientDefineIteration i on
						rf.id=i.rf_idRefCaseIteration
						and i.rf_idIteration =4 --ошибка 57 может быть определена только на 4 шаге
									inner join t_Case c1 on
						cd.rf_idCase=c1.id
									inner join t_RecordCase rc on
						c1.rf_idRecordCase=rc.id
									inner join t_RegistersCase reg on
						rc.rf_idRegistersCase=reg.id
									left join @CaseDefined2 cd2 on
						cd.rf_idCase=cd.rf_idCase
						and cd.ID_Patient=cd2.ID_Patient					
			where (c.OGRN_SMO is null) and (c.NPolcy is null) and (cd2.rf_idCase is null)
			group by c1.id
			
			--производим технологический контроль для застрахованных в Волгоградской области
			if(select @@SERVERNAME)!='TSERVER'
			begin
				--проверка услуг скорой помощи для иногородних.
				IF EXISTS(SELECT * 
						  FROM dbo.vw_getIdFileNumber f INNER JOIN OMS_NSI.dbo.vw_sprT001 l ON
										f.CodeM=l.CodeM
						  WHERE f.id=@idFile AND l.pfs=1
						  )
				BEGIN		  
			
					insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
					select 589,@idFile,c.id
					from @CaseDefined2 cd inner join t_Case c on
									cd.rf_idCase=c.id
									and c.rf_idV006=4					
										inner join t_Meduslugi m on
									c.id=m.rf_idCase										 
					where NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.v001 WHERE IDRB=m.MUCode AND isTelemedicine=1
									 UNION ALL 
									 SELECT 1 FROM vw_sprMUSplitByGroup mu WHERE m.MUCode=mu.MU and mu.MUGroupCode=71 and mu.MUUnGroupCode IN (2 ,3)
									 )
					group by c.id
				END		
				------------------------------------------------------------------
				/*
				Ошибка по счетам с литерами O,R,F,V,U. Если застрахованный является нашим, то надо проверять в таблице t_RefCaseAttachLPUItearion2. Для
				определения код МО прикрепления. Если случай там за фиксированн, то не попадает в 513 ошибку.
				*/
				-------------------------2014-02-28-----------------------------------------
				insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
				SELECT 513,@idFile,r.rf_idCase
				FROM (
						select rf.rf_idCase,rf.rf_idRegisterPatient
						from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
									rf.id=c.rf_idRefCaseIteration
									and c.OKATO ='18000'		
												inner join t_CasePatientDefineIteration i on
									rf.id=i.rf_idRefCaseIteration
									and i.rf_idIteration in (2,4)			  
						where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
					 ) r inner join t_Case c on
							r.rf_idCase=c.id
										INNER JOIN dbo.t_Meduslugi m ON
							c.id=m.rf_idCase
										INNER JOIN (SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='O'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='R'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='F'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='V'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='U') l ON
							m.MUCode=l.MU
				WHERE m.Price>0 AND NOT EXISTS(SELECT * FROM t_RefCaseAttachLPUItearion2 WHERE rf_idFiles=@idFile AND rf_idCase=r.rf_idCase AND AttachLPU=c.rf_idMO)
				
				insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
				SELECT 513,@idFile,r.rf_idCase
				FROM (
						select rf.rf_idCase,rf.rf_idRegisterPatient
						from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
									rf.id=c.rf_idRefCaseIteration
									and c.OKATO ='18000'		
												inner join t_CasePatientDefineIteration i on
									rf.id=i.rf_idRefCaseIteration
									and i.rf_idIteration in (2,4,3)			  
						where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
					 ) r inner join t_Case c on
							r.rf_idCase=c.id
										INNER JOIN dbo.t_MES m ON
							c.id=m.rf_idCase
										INNER JOIN (SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='O'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='R'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='F'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='V'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='U') l ON
							m.MES=l.MU
				 WHERE NOT EXISTS(SELECT * FROM t_RefCaseAttachLPUItearion2 WHERE rf_idFiles=@idFile AND rf_idCase=r.rf_idCase AND AttachLPU=c.rf_idMO)
				 ------------------------------Случаи на 3 итерации
				 insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
				SELECT 513,@idFile,r.rf_idCase
				FROM (
						select rf.rf_idCase,rf.rf_idRegisterPatient,c.AttachCodeM
						from t_RefCasePatientDefine rf inner join dbo.t_CaseDefine c on
									rf.id=c.rf_idRefCaseIteration
												inner join t_CasePatientDefineIteration i on
									rf.id=i.rf_idRefCaseIteration
									and i.rf_idIteration=3			  
						where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
					 ) r inner join t_Case c on
							r.rf_idCase=c.id
										INNER JOIN dbo.t_Meduslugi m ON
							c.id=m.rf_idCase
										INNER JOIN (SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='O'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='R'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='F'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='V'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='U') l ON
							m.MUCode=l.MU
				WHERE m.Price>0 AND r.AttachCodeM<>c.rf_idMO
				
				insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
				SELECT 513,@idFile,r.rf_idCase
				FROM (
						select rf.rf_idCase,rf.rf_idRegisterPatient,c.AttachCodeM
						from t_RefCasePatientDefine rf inner join dbo.t_CaseDefine c on
									rf.id=c.rf_idRefCaseIteration
												inner join t_CasePatientDefineIteration i on
									rf.id=i.rf_idRefCaseIteration
									and i.rf_idIteration=3
						where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
					 ) r inner join t_Case c on
							r.rf_idCase=c.id
										INNER JOIN dbo.t_MES m ON
							c.id=m.rf_idCase
										INNER JOIN (SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='O'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='R'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='F'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='V'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='U') l ON
							m.MES=l.MU
				 WHERE r.AttachCodeM<>c.rf_idMO
				 
				----------------------------------------------------------------------------
				exec usp_RunProcessControl @CaseDefined1,@idFile
			end
			--помечаем случаи из таблицы итерации, которые были отданы в Реестре СП и ТК
			update t_RefCasePatientDefine
			set IsUnloadIntoSP_TK=1
			from t_RefCasePatientDefine rf inner join @CaseDefined cd on
						rf.rf_idCase=cd.rf_idCase and
						rf.rf_idRegisterPatient=cd.ID_Patient

		 DECLARE @version VARCHAR(5)

		 --SELECT @version=(CASE WHEN ReportYear<2014 THEN '1.2' ELSE '2.11' END) from t_RegistersCase c where c.rf_idFiles=@idFile
		 IF EXISTS(SELECT 1 FROM dbo.vw_getFileBack WHERE idFileBack=@idFileBack AND Period<201901)
		BEGIN
			SELECT @version='2.12'
		END
		ELSE 
		BEGIN
			SELECT @version='3.11'
		END

		 insert t_FileBack(rf_idFiles,FileVersion,FileNameHRBack) values(@idFile,@version,@fileName)
		 select @idFileBack=SCOPE_IDENTITY()
		 
		 insert t_RegisterCaseBack(rf_idFilesBack,ref_idF003,ReportYear,ReportMonth,DateCreate,NumberRegister,PropertyNumberRegister)
		 select @idFileBack,c.rf_idMO,c.ReportYear,c.ReportMonth,GETDATE(),NumberRegister,@property
		 from t_RegistersCase c
		 where c.rf_idFiles=@idFile
		 select @idRegisterCaseBack=SCOPE_IDENTITY()
		 
		 -----для тех людей, которые найдены на 2 и 4 шаге
		 insert t_RecordCaseBack(rf_idRecordCase,rf_idRegisterCaseBack,rf_idCase,IdStep)
			output inserted.id,inserted.rf_idCase, INSERTED.IdStep into @idRecordCaseBack
		 select c.rf_idRecordCase,@idRegisterCaseBack,c.id,0
		 from @CaseDefined cd inner join t_Case c on
				cd.rf_idCase=c.id
		 WHERE NOT EXISTS(SELECT * FROM dbo.t_ErrorProcessControl WHERE rf_idCase=c.id AND ErrorNumber=57)
				AND NOT EXISTS(SELECT * FROM vw_CasePatientDefine WHERE rf_idCase=c.id)
		 
		 -----для тех людей, которые найдены на 3 шаге
		 insert t_RecordCaseBack(rf_idRecordCase,rf_idRegisterCaseBack,rf_idCase,IdStep)
			output inserted.id,inserted.rf_idCase, INSERTED.IdStep into @idRecordCaseBack
		 select c.rf_idRecordCase,@idRegisterCaseBack,c.id,CASE WHEN d.idStep=1 THEN 0 ELSE 1 END 
		 from @CaseDefined cd inner join t_Case c on
				cd.rf_idCase=c.id
								INNER JOIN dbo.vw_CasePatientDefine d ON
				cd.rf_idCase=d.rf_idCase                              
		 WHERE NOT EXISTS(SELECT * FROM dbo.t_ErrorProcessControl WHERE rf_idCase=c.id AND ErrorNumber=57)


		 insert t_RecordCaseBack(rf_idRecordCase,rf_idRegisterCaseBack,rf_idCase,IdStep)
			output inserted.id,inserted.rf_idCase, INSERTED.IdStep into @idRecordCaseBack
		 select c.rf_idRecordCase,@idRegisterCaseBack,c.id,2
		 from @CaseDefined cd inner join t_Case c on
				cd.rf_idCase=c.id
		 WHERE EXISTS(SELECT * FROM dbo.t_ErrorProcessControl WHERE rf_idCase=c.id AND ErrorNumber=57)

		end try
		begin catch
		if @@TRANCOUNT>0
			select ERROR_MESSAGE()
			rollback transaction T1
			goto END_Point1
		end catch
		if @@TRANCOUNT>0
			commit transaction T1

			
		--т.к. определение страховой может быть как в таблице t_CaseDefine или t_CaseDefineZP1Found		
		--изменения от 02.07.2012
		insert #PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO,AttachLPU,ENP)
		SELECT DISTINCT rcb.rf_idRecordCaseBack,c.rf_idF008
				,case when c.rf_idF008=3 then null else c.SPolicy end as SPolicy
				,case when c.rf_idF008=3 then c.UniqueNumberPolicy else c.NPolcy end as NPolcy
				,CASE WHEN c.SMO='34001' AND c1.DateEnd>='20160801' THEN '34007' ELSE c.SMO END,18000,c.AttachCodeM
				,c.UniqueNumberPolicy AS ENP
		from @CaseDefined cd inner join t_RefCasePatientDefine rf on
					cd.rf_idCase=rf.rf_idCase
							  inner join t_CaseDefine c on
					rf.id=c.rf_idRefCaseIteration
							  inner join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
					and i.rf_idIteration=3
								inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase		
								INNER JOIN dbo.t_Case c1 ON
					rf.rf_idCase=c1.id				
		--group by rcb.rf_idRecordCaseBack,c.rf_idF008,c.SPolicy,c.NPolcy,c.SMO,c.UniqueNumberPolicy,c.AttachCodeM
					
		--вставляем записи по которым определена страховая принадлежность на 2 и 4 шаге.
		--если человек иногородний то заменяем на значение по умолчанию			
		--Изменения от 03.01.2011------------------------------------------------------------------
		declare @tPatient as table(
									rf_idRecordCaseBack int NOT NULL,
									rf_idF008 tinyint NOT NULL,
									SeriaPolis varchar(10) NULL,
									NumberPolis varchar(20) NOT NULL,
									SMO char(5) NOT NULL,
									OKATO char(5) NULL,
									Fam nvarchar(40) not null,
									Im nvarchar(40) not null,
									Ot nvarchar(40) null,
									rf_idV005 tinyint not null,
									BirthDay date not null,
									DateEnd DATE,
									ENP VARCHAR(16)
								  )

		--изменения от 20.01.2012
		insert @tPatient	
		select distinct rcb.rf_idRecordCaseBack,cast(c.TypePolicy as tinyint)
				,case when c.TypePolicy=3 then null else c.SPolicy end as SPolicy
				,case when c.TypePolicy=3 then c.UniqueNumberPolicy else c.NPolcy end as NPolcy
				,case when s.SMOKOD='34001' THEN '34007' ELSE s.SMOKOD end,
				isnull(c.OKATO,'00000'),p.Fam,p.Im,p.Ot,p.rf_idV005,p.BirthDay,c1.DateEnd
				,c.UniqueNumberPolicy
		from @CaseDefined cd inner join t_RefCasePatientDefine rf on
					cd.rf_idCase=rf.rf_idCase
							  inner join t_CaseDefineZP1Found c on
					rf.id=c.rf_idRefCaseIteration
							  inner join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
					and i.rf_idIteration in (2,4)
							inner join t_Case c1 on
					cd.rf_idCase=c1.id
							 inner join vw_RegisterPatient p on
					cd.ID_Patient=p.id
								inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase
								left join dbo.vw_sprSMOGlobal s on
					c.OGRN_SMO=s.OGRN
					and c.OKATO=s.OKATO
		where (OGRN_SMO is not null) and (NPolcy is not null) AND isnull(c.OKATO,'00000')='18000'

		insert @tPatient	
		select distinct rcb.rf_idRecordCaseBack,cast(c.TypePolicy as tinyint)
				,case when c.TypePolicy=3 then null else c.SPolicy end as SPolicy
				,case when c.TypePolicy=3 then c.UniqueNumberPolicy else c.NPolcy end as NPolcy
				,'34',
				isnull(c.OKATO,'00000'),p.Fam,p.Im,p.Ot,p.rf_idV005,p.BirthDay,c1.DateEnd
				,c.UniqueNumberPolicy
		from @CaseDefined cd inner join t_RefCasePatientDefine rf on
					cd.rf_idCase=rf.rf_idCase
							  inner join t_CaseDefineZP1Found c on
					rf.id=c.rf_idRefCaseIteration
							  inner join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
					and i.rf_idIteration in (2,4)
							inner join t_Case c1 on
					cd.rf_idCase=c1.id
							 inner join vw_RegisterPatient p on
					cd.ID_Patient=p.id
								inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase
								left join dbo.vw_sprSMOGlobal s on
					c.OGRN_SMO=s.OGRN
					and c.OKATO=s.OKATO
		where (OGRN_SMO is not null) and (NPolcy is not null) AND isnull(c.OKATO,'00000')<>'18000'
		-----------------------------------------------03.01.2012-----------------------------------------------
		insert #PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO,ENP)
		select t.rf_idRecordCaseBack,t.rf_idF008,t.SeriaPolis,t.NumberPolis,t.SMO,t.OKATO,t.ENP
		from (
				select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO,p.ENP
				from @tPatient p
				where p.SMO='34'
				union all
				select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO,p.ENP
				from @tPatient p left join vw_sprSMODisable s on
									p.SMO=s.SMO
				where p.OKATO='18000' and s.id is null
				union all
				select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO,p.ENP
				from @tPatient p inner join vw_sprSMODisable s on
									p.SMO=s.SMO					
				where p.OKATO='18000' and p.DateEnd<s.DateEnd
				union all
				select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,'00','00000',p.ENP
				from @tPatient p inner join vw_sprSMODisable s on
									p.SMO=s.SMO
								left join dbo.ListPeopleFromPlotnikov lp on
									upper(p.Fam)=upper(lp.FAM)
									and upper(p.Im)=upper(lp.IM)
									and ISNULL(upper(p.Ot),'bla-bla')=ISNULL(upper(lp.OT),'bla-bla')
									and p.BirthDay=lp.DR				
				where p.OKATO='18000' and p.DateEnd>=s.DateEnd and lp.FAM is null		
				union all
				select distinct p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,lp.Q as SMO,p.OKATO,p.ENP
				from @tPatient p inner join vw_sprSMODisable s on
									p.SMO=s.SMO
									--and p.OKATO='18000'
											 inner join dbo.ListPeopleFromPlotnikov lp on
									upper(p.Fam)=upper(lp.FAM)
									and upper(p.Im)=upper(lp.IM)
									and ISNULL(upper(p.Ot),'bla-bla')=ISNULL(upper(lp.OT),'bla-bla')
									and p.BirthDay=lp.DR
				where p.OKATO='18000' and p.DateEnd>=s.DateEnd
			) t 
		group by t.rf_idRecordCaseBack,t.rf_idF008,t.SeriaPolis,t.NumberPolis,t.SMO,t.OKATO,t.ENP


		--добавляем записи в t_PatientBack  для иногородних по тем у кого не определена страховая принадлежность, но есть ОКАТО не волгоградской области
		insert #PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO,ENP)
		select rcb.rf_idRecordCaseBack,rc.rf_idF008,rc.SeriaPolis,rc.NumberPolis,34,p.OKATO,c.UniqueNumberPolicy
		from @CaseDefined cd inner join t_RefCasePatientDefine rf on
					cd.rf_idCase=rf.rf_idCase
							  inner join t_CaseDefineZP1Found c on
					rf.id=c.rf_idRefCaseIteration
							  inner join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
					and i.rf_idIteration in (2,4)
								inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase	
								inner join t_Case c1 on
					cd.rf_idCase=c1.id
								inner join t_RecordCase rc on
					c1.rf_idRecordCase=rc.id										
								inner join t_PatientSMO p on
					rc.id=p.ref_idRecordCase
					and p.OKATO!='18000' 
					and p.OKATO is not null						
		where (OGRN_SMO is null) and (NPolcy is null) 

		insert #PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO,ENP)
		select rcb.rf_idRecordCaseBack,rc.rf_idF008,rc.SeriaPolis,rc.NumberPolis,isnull(reg.rf_idSMO,'00'),'00000'
		,c.UniqueNumberPolicy
		from @CaseDefined cd inner join t_RefCasePatientDefine rf on
					cd.rf_idCase=rf.rf_idCase
							  inner join t_CaseDefineZP1Found c on
					rf.id=c.rf_idRefCaseIteration
							  inner join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
					and i.rf_idIteration =4
								inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase	
								inner join t_Case c1 on
					cd.rf_idCase=c1.id
								inner join t_RecordCase rc on
					c1.rf_idRecordCase=rc.id
								inner join t_RegistersCase reg on
					rc.rf_idRegistersCase=reg.id		
								left join @CaseDefined2 cd2 on
					cd.rf_idCase=cd.rf_idCase
					and cd.ID_Patient=cd2.ID_Patient							
		where (OGRN_SMO is null) and (NPolcy is null)  and (cd2.rf_idCase is null)	

		begin transaction T2	
		begin try

		-----------------------------------------------02.07.2012-----------------------------------------------
		--федеральный регистр застрахованных может вернуть гражданина который не застрахован в действующей СМО.
		--делаем пометку в таблице ошибок с номером 57
		-----------04/02/2015
		----добавил условие, что если страхование у ЗЛ принадлежит не действующим СМО, то выкидывать его в 57 ошибку
		insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
		select 57,@idFile,r.rf_idCase
		from @tPatient p inner join t_RecordCaseBack r on
							  p.rf_idRecordCaseBack=r.id
							inner join vw_sprSMODisable s on
									p.SMO=s.SMO					
		where p.OKATO='18000' and p.DateEnd>=s.DateEnd	AND NOT EXISTS(SELECT * FROM #PatientBack WHERE rf_idRecordCaseBack=p.rf_idRecordCaseBack AND rf_idSMO<>'00' )		
		--Есть люди у которых есть полюса закрытых СМО, но их нету в таблице ListPeopleFromPlotnikov
		insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
		select 57,@idFile,r.rf_idCase
		from @tPatient p inner join t_RecordCaseBack r on
							  p.rf_idRecordCaseBack=r.id
						INNER JOIN #PatientBack p1 ON
							  p1.rf_idRecordCaseBack=p.rf_idRecordCaseBack							
		where p1.rf_idSMO='00'--EXISTS(SELECT * FROM #PatientBack WHERE rf_idRecordCaseBack=p.rf_idRecordCaseBack AND rf_idSMO='00' )		

		------------------------------insert t_PatientBack-----------------------------------------------------
		insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO,AttachCodeM,ENP) 
		select rf_idRecordCaseBack,case when rf_idF008=0 then 3 else rf_idF008 end,SeriaPolis,NumberPolis,rf_idSMO,OKATO,AttachLPU,ENP
		from #PatientBack
		-------------------------------------------------------------------------------------------------------
		 insert t_CaseBack(rf_idRecordCaseBack,TypePay)		
		 select DISTINCT rcb.rf_idRecordCaseBack,(case when e.ErrorNumber is null AND rcb.Step=0 then 1 else 2 end) as TypePay
		 from @CaseDefined cd inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase
							  left join t_ErrorProcessControl e on
					cd.rf_idCase=e.rf_idCase and
					e.rf_idFile=@idFile						
		--------------------------------данные для отчета по плану заказов---------------------------------------------
			declare @month tinyint,
					@year smallint,
					@codeLPU char(6)		
			if @idFileBack is not null		
			BEGIN
			
				select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
				from t_FileBack f inner join t_RegisterCaseBack rc on
							f.id=rc.rf_idFilesBack
									inner join oms_nsi.dbo.vw_sprT001 v on
							f.CodeM=v.CodeM		
				where f.id=@idFileBack
				
			create table #tmpPlan
			(
				CodeLPU varchar(6),
				UnitCode int,
				Vm int,
				Vdm int,
				Spred decimal(11,2),
				[month] tinyint
			)
			EXEC dbo.usp_PlanOrders @codeLPU,@month,@year
			
			insert t_PlanOrdersReport(rf_idFile,rf_idFileBack,CodeLPU,UnitCode,Vm,Vdm,Spred,MonthReport,YearReport)
			select @idFile,@idFileBack,f.CodeLPU,f.UnitCode,f.Vm,f.Vdm,f.Spred,@month,@year
			FROM #tmpPlan f
			
			DROP TABLE #tmpPlan	
				
			end
			------------------------------------------------------------------------------------------------------------------			
		end try
		begin catch
		if @@TRANCOUNT>0
			select ERROR_MESSAGE()
			rollback transaction T2
			goto END_Point1			
		end catch
		if @@TRANCOUNT>0
			commit transaction T2
		
		goto END_Point2

end
else 
begin
	select 'Данный реестр СП и ТК был сформирован ранее'
	goto END_Point2
end
END_Point1:
		---зачищаем все следы			
			delete from t_FileBack where id=@idFileBack

			update t_RefCasePatientDefine 
			set IsUnloadIntoSP_TK=null
			from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration i on
					r.id=i.rf_idRefCaseIteration
			where rf_idFiles =@idFile and i.rf_idIteration<>1
			
END_Point2:

GO

PRINT N'Altering permissions on [dbo].[t_File]'
GO
GRANT SELECT ON  [dbo].[t_File] TO [db_RegisterCase]
GRANT INSERT ON  [dbo].[t_File] TO [db_RegisterCase]
GO
PRINT N'Altering permissions on [dbo].[usp_Test479]'
GO
GRANT EXECUTE ON  [dbo].[usp_Test479] TO [db_RegisterCase]
GO
PRINT N'Altering permissions on [dbo].[usp_Test480]'
GO
GRANT EXECUTE ON  [dbo].[usp_Test480] TO [db_RegisterCase]
GO
