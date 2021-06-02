USE PeopleAttach
GO
DROP TABLE [dbo].[t_CovidRegister20201026]
go
CREATE TABLE t_CovidRegister20201026
(
[Id_Source] int,
[DateCreateRecord_Source] NVARCHAR(20),
[SNILS_Source] VARCHAR(20),
[FIO_Source] nvarchar(100),
[Sex_Source] nvarchar(20),
[DR_Source] NVARCHAR(20),
[DS1_Source] varchar(15),
[DateSetupDS1_Source] NVARCHAR(20),
[DS2_Source] varchar(15),
[MO_Source] nvarchar(255),
[CodeM_Source] varchar(6),
[DateEnd_Source] NVARCHAR(20),
[ISHOD_Source] nvarchar(50),
[SeverityDisease_Source] nvarchar(50),
[DSDeath_Source] varchar(15),
[Amobulance_Source] NVARCHAR(15),
[AttachLPU_Source] nvarchar(255),
[IsMedical_Source] nvarchar(15),
[Fam] nvarchar(40),
[Im] nvarchar(40),
[Ot] nvarchar(40),
[Sex] nvarchar(15),
[DR] datetime,
[SNILS] nvarchar(20),
[ENP] nvarchar(20),
[TyPolicy] int,
[SMO] nvarchar(555),
[погашен] datetime,
DateDeath datetime,
[SeriaDoc] nvarchar(255),
[NumDoc] nvarchar(255),
[DateDoc] datetime
)