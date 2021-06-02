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
	DS2 VARCHAR(10),
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