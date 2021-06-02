USE AccountOMS
GO
CREATE TABLE tmp_NMIC 
(
id INT IDENTITY(1,1) NOT NULL,
NumberQuestion nvarchar(255),
[Адрес ТКП] nvarchar(255),
OID nvarchar(255),
FullNameMO nvarchar(255),
ShortNameMO nvarchar(255),
ShortNameNMIC nvarchar(255),
IdPacient nvarchar(255),
SNILS nvarchar(20),
ENP NVARCHAR(23),
DateConclusion datetime,
Profil nvarchar(255),
[Приоритет] nvarchar(255),
CodeM CHAR(6)
)
