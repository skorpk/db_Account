USE CanserRegister
GO
/*
if(OBJECT_ID('t_PeopleEnp',N'U')) is not null
	drop table dbo.t_PeopleEnp
GO
CREATE TABLE t_PeopleEnp
(
	id INT IDENTITY(1,1) NOT NULL,	
	DateRegistration DATETIME DEFAULT(GETDATE()) NOT NULL,	
	ENP VARCHAR(20) NOT NULL,	
	Fam VARCHAR(50) NOT NULL,
	Im VARCHAR(50) NOT NULL,
	Ot VARCHAR(50) ,
	Dr DATE NOT NULL,	
	Sex CHAR(1) NOT NULL,
	TypeSearch TINYINT --1 Диагноз и 2 DS_ONK
	)
GO
if(OBJECT_ID('t_HistPeopleEnp',N'U')) is not null
	drop table dbo.t_HistPeopleEnp
GO
CREATE TABLE t_HistPeopleEnp
(
	rf_idPeopleENP INT NOT NULL,
	DateRegistration DATETIME DEFAULT(GETDATE()) NOT NULL,		
	Fam VARCHAR(50) NOT NULL,
	Im VARCHAR(50) NOT NULL,
	Ot VARCHAR(50) ,
	Dr DATE NOT NULL
	)
GO
CREATE UNIQUE NONCLUSTERED INDEX UQ_ENP ON dbo.t_PeopleEnp(ENP) WITH IGNORE_DUP_KEY
--пересчитывается
if(OBJECT_ID('t_PeopleDS_ONK',N'U')) is not null
	drop table dbo.t_PeopleDS_ONK
GO
CREATE TABLE t_PeopleDS_ONK
(
	rf_idPeopleENP INT NOT NULL,
	DS_ONK TINYINT NOT NULL,
	DateDS_ONK DATE NOT NULL,
	rf_idCase BIGINT
	
)
go
CREATE UNIQUE NONCLUSTERED INDEX UQ_IdPeople ON dbo.t_PeopleDS_ONK(rf_idPeopleENP) WITH IGNORE_DUP_KEY
GO
--пересчитывается
if(OBJECT_ID('t_PeopleBiopsy',N'U')) is not null
	drop table dbo.t_PeopleBiopsy
GO
CREATE TABLE t_PeopleBiopsy
(
	rf_idPeopleENP INT NOT NULL,
	DirectionDate DATE NOT NULL,
	rf_idCase BIGINT
)
GO
CREATE UNIQUE NONCLUSTERED INDEX UQ_IdPeopleBiopsy ON dbo.t_PeopleBiopsy(rf_idPeopleENP) WITH IGNORE_DUP_KEY
GO
--не пересчитывается
if(OBJECT_ID('t_PeopleDiagnosis',N'U')) is not null
	drop table dbo.t_PeopleDiagnosis
GO
CREATE TABLE t_PeopleDiagnosis
(
	rf_idPeopleENP INT NOT NULL,
	DiagnosisCode VARCHAR(10) NOT NULL,
	DateSetup DATE NOT NULL,
	rf_idCase BIGINT
)
GO
CREATE UNIQUE NONCLUSTERED INDEX UQ_IdPeopleDiagnosis ON dbo.t_PeopleDiagnosis(rf_idPeopleENP) WITH IGNORE_DUP_KEY
go
--пересчитывается
if(OBJECT_ID('t_PeoplePCEL',N'U')) is not null
	drop table dbo.t_PeoplePCEL
GO
CREATE TABLE t_PeoplePCEL
(
	rf_idPeopleENP INT NOT NULL,
	DateEnd DATE NOT NULL,
	rf_idCase BIGINT	
)

--пересчитывается
if(OBJECT_ID('t_PeopleONK_USL',N'U')) is not null
	drop table dbo.t_PeopleONK_USL
GO
CREATE TABLE t_PeopleONK_USL
(
	rf_idPeopleENP INT NOT NULL,
	DateEnd DATE NOT NULL,
	USL_TIP TINYINT NOT NULL,
	rf_idCase BIGINT		
)
go
if(OBJECT_ID('t_PeopleSMO',N'U')) is not null
	drop table dbo.t_PeopleSMO
GO
CREATE TABLE t_PeopleSMO
(
	rf_idPeopleENP INT NOT NULL,
	CodeSMO CHAR(5) NOT NULL,
	rf_idCase BIGINT
)
GO
if(OBJECT_ID('t_PeopleNAPR',N'U')) is not null
	drop table dbo.t_PeopleNAPR
GO
CREATE TABLE t_PeopleNAPR
(
	rf_idPeopleENP INT NOT NULL,
	NAPR_DATE DATE,
	rf_idCase BIGINT,
	rf_idV029 tinyint
)
GO


if(OBJECT_ID('t_PeopleSTAD',N'U')) is not null
	drop table dbo.t_PeopleSTAD
GO
CREATE TABLE t_PeopleSTAD
(
	rf_idPeopleENP INT NOT NULL,
	SATD SMALLINT,
	rf_idCase BIGINT
)
GO


-----------------------------------------------------
if(OBJECT_ID('t_PeopleEND',N'U')) is not null
	drop table dbo.t_PeopleEND
GO
CREATE TABLE t_PeopleEND
(
	rf_idPeopleENP INT NOT NULL,
	DateFinde DATETIME NOT NULL DEFAULT(GETDATE()),
	DateEnd DATETIME,
	typeEnd TINYINT --1 -прекращено страхование, 2- смерть пациента
)
GO
---------------------------Tempory tables------------------------------------

if(OBJECT_ID('tmp_PeopleEnp',N'U')) is not null
	drop table dbo.tmp_PeopleEnp
GO
CREATE TABLE tmp_PeopleEnp
(
	ENP VARCHAR(20) NOT NULL,	
	Fam VARCHAR(50) NOT NULL,
	Im VARCHAR(50) NOT NULL,
	Ot VARCHAR(50) ,
	Dr DATE NOT NULL,	
	Sex CHAR(1) NOT NULL,
	TypeSearch TINYINT --1 Диагноз и 2 DS_ONK
	)
GO
--пересчитывается
if(OBJECT_ID('tmp_PeopleDS_ONK',N'U')) is not null
	drop table dbo.tmp_PeopleDS_ONK
GO
CREATE TABLE tmp_PeopleDS_ONK
(
	ENP VARCHAR(20) NOT NULL,	
	DS_ONK TINYINT NOT NULL,
	DateDS_ONK DATE NOT null,
	rf_idCase BIGINT
	
)
GO
--пересчитывается
if(OBJECT_ID('tmp_PeopleBiopsy',N'U')) is not null
	drop table dbo.tmp_PeopleBiopsy
GO
CREATE TABLE tmp_PeopleBiopsy
(
	ENP VARCHAR(20) NOT NULL,	
	DirectionDate DATE NOT null,	
	rf_idCase BIGINT
)
GO
--не пересчитывается
if(OBJECT_ID('tmp_PeopleDiagnosis',N'U')) is not null
	drop table dbo.tmp_PeopleDiagnosis
GO
CREATE TABLE tmp_PeopleDiagnosis
(
	ENP VARCHAR(20) NOT NULL,	
	DiagnosisCode VARCHAR(10) NOT NULL,
	DateSetup DATE NOT NULL,
	rf_idCase BIGINT

)
GO
--пересчитывается
if(OBJECT_ID('tmp_PeoplePCEL',N'U')) is not null
	drop table dbo.tmp_PeoplePCEL
GO
CREATE TABLE tmp_PeoplePCEL
(
	ENP VARCHAR(20) NOT NULL,	
	DateEnd DATE NOT null,
	rf_idCase BIGINT
)
go
--пересчитывается
if(OBJECT_ID('tmp_PeopleONK_USL',N'U')) is not null
	drop table dbo.tmp_PeopleONK_USL
GO
CREATE TABLE tmp_PeopleONK_USL
(
	ENP VARCHAR(20) NOT NULL,	
	DateEnd DATE NOT NULL,
	USL_TIP TINYINT NOT null,
	rf_idCase BIGINT
)
go
--пересчитывается
if(OBJECT_ID('tmp_PeopleSMO',N'U')) is not null
	drop table dbo.tmp_PeopleSMO
GO
CREATE TABLE tmp_PeopleSMO
(
	ENP VARCHAR(20) NOT NULL,	
	CodeSMO CHAR(5) NOT NULL,
	rf_idCase BIGINT
)
go
if(OBJECT_ID('tmp_PeopleNAPR',N'U')) is not null
	drop table dbo.tmp_PeopleNAPR
GO
CREATE TABLE tmp_PeopleNAPR
(
	ENP VARCHAR(20) NOT NULL,
	NAPR_DATE DATE,
	rf_idCase BIGINT,
	rf_idV029 tinyint
)
GO
if(OBJECT_ID('tmp_PeopleSTAD',N'U')) is not null
	drop table dbo.tmp_PeopleSTAD
GO
CREATE TABLE tmp_PeopleSTAD
(
	ENP VARCHAR(20) NOT NULL,
	SATD SMALLINT,
	rf_idCase BIGINT
)
GO
if(OBJECT_ID('tmp_PeopleEND',N'U')) is not null
	drop table dbo.tmp_PeopleEND
GO
CREATE TABLE tmp_PeopleEND
(
	ENP VARCHAR(20) NOT NULL,
	DateEnd DATETIME,
	typeEnd TINYINT --1 -прекращено страхование, 2- смерть пациента
)
GO
---------------------24/09/2019--------------------
if(OBJECT_ID('tmp_PeopleCase',N'U')) is not null
	drop table dbo.tmp_PeopleCase
GO
CREATE TABLE tmp_PeopleCase
(
	ENP VARCHAR(20) NOT NULL,
	rf_idCase BIGINT NOT NULL,	
	Account VARCHAR(15) NOT NULL,
	DateRegistr DATE NOT NULL, 
	CodeM CHAR(6) NOT NULL, 
	NumberCase int, 
	DS1 VARCHAR(10),
	DateBegin DATE,
	DateEnd DATE ,
	DS_ONK TINYINT, 
	USL_OK TINYINT , 
	rf_idv008 smallint,
	rf_idV009 SMALLINT,
	P_CEL varchar(3),
	DN TINYINT
)
GO
if(OBJECT_ID('tmp_PeopleMES',N'U')) is not null
	drop table dbo.tmp_PeopleMES
GO
CREATE TABLE tmp_PeopleMES
(
	Enp VARCHAR(20) NOT NULL,
	rf_idCase BIGINT NOT NULL,
	MES VARCHAR(15) NOT NULL,
	TypeMES TINYINT NOT NULL
)
go
------------------Уборка временных таблиц--------------------
if(OBJECT_ID('tmp_PeopleEnp',N'U')) is not null
	drop table dbo.tmp_PeopleEnp
GO
--пересчитывается
if(OBJECT_ID('tmp_PeopleDS_ONK',N'U')) is not null
	drop table dbo.tmp_PeopleDS_ONK
GO
--пересчитывается
if(OBJECT_ID('tmp_PeopleBiopsy',N'U')) is not null
	drop table dbo.tmp_PeopleBiopsy
GO
--не пересчитывается
if(OBJECT_ID('tmp_PeopleDiagnosis',N'U')) is not null
	drop table dbo.tmp_PeopleDiagnosis
GO
--пересчитывается
if(OBJECT_ID('tmp_PeoplePCEL',N'U')) is not null
	drop table dbo.tmp_PeoplePCEL
GO

if(OBJECT_ID('tmp_PeopleONK_USL',N'U')) is not null
	drop table dbo.tmp_PeopleONK_USL
GO
if(OBJECT_ID('tmp_PeopleSMO',N'U')) is not null
	drop table dbo.tmp_PeopleSMO
GO
if(OBJECT_ID('tmp_PeopleNAPR',N'U')) is not null
	drop table dbo.tmp_PeopleNAPR
GO
if(OBJECT_ID('tm_PeopleSTAD',N'U')) is not null
	drop table dbo.tmp_PeopleSTAD
GO
if(OBJECT_ID('tm_PeopleEND',N'U')) is not null
	drop table dbo.tmp_PeopleEND
GO
----------24.09.2019-----------------
if(OBJECT_ID('tmp_PeopleCase',N'U')) is not null
	drop table dbo.tmp_PeopleCase
GO
if(OBJECT_ID('tmp_PeopleMES',N'U')) is not null
	drop table dbo.tmp_PeopleMES
GO

-----------------------------------------------------


	  */

if(OBJECT_ID('t_PeopleCase',N'U')) is not null
	drop table dbo.t_PeopleCase
GO
CREATE TABLE t_PeopleCase
(
	ENP VARCHAR(20) NOT NULL,
	rf_idCase BIGINT NOT NULL,	
	Account VARCHAR(15) NOT NULL,
	DateRegistr DATE NOT NULL, 
	CodeM CHAR(6) NOT NULL, 
	NumberCase int, 
	DS1 VARCHAR(10),
	DateBegin DATE,
	DateEnd DATE ,
	DS_ONK TINYINT, 
	USL_OK TINYINT , 
	rf_idv008 smallint,
	rf_idV009 SMALLINT,
	P_CEL varchar(3),
	DN TINYINT
)
GO
CREATE UNIQUE NONCLUSTERED INDEX QU_PeopleCase_ID ON dbo.t_PeopleCase(rf_idCase) WITH IGNORE_DUP_KEY
go
if(OBJECT_ID('t_PeopleMES',N'U')) is not null
	drop table dbo.t_PeopleMES
GO
CREATE TABLE t_PeopleMES
(
	Enp VARCHAR(20) NOT NULL,
	rf_idCase BIGINT NOT NULL,
	MES VARCHAR(15) NOT NULL,
	TypeMES TINYINT NOT NULL
)
go
CREATE UNIQUE NONCLUSTERED INDEX QU_PeopleMES_ID ON dbo.t_PeopleMES(rf_idCase) WITH IGNORE_DUP_KEY

