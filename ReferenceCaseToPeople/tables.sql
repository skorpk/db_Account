USE AccountOMS
GO
ALTER DATABASE [AccountOMS] ADD FILEGROUP [personalData]
GO
ALTER DATABASE [AccountOMS] ADD FILE ( NAME = N'People', FILENAME = N'h:\AccountOMS\People.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB ) TO FILEGROUP [personalData]
GO
if(OBJECT_ID('t_PeopleInAccount',N'U')) is not null
	drop table dbo.t_PeopleInAccount
GO
CREATE TABLE t_PeopleInAccount
(
	id INT IDENTITY(1,1) NOT NULL,
	PID INT NULL,
	ENP VARCHAR(20) NULL,
	Fam VARCHAR(40) NOT NULL,
	IM VARCHAR(40) NOT NULL,
	OT VARCHAR(40) NULL,
	BirthDay DATE NOT NULL--,
	--SNILS VARCHAR(11)
)
GO
if(OBJECT_ID('t_PeopleInAccountCase',N'U')) is not null
	drop table dbo.t_PeopleInAccountCase
GO
CREATE TABLE t_PeopleInAccountCase
(
	rf_idPeopleInAccount INT NOT null,
	rf_idCase BIGINT NOT null
)