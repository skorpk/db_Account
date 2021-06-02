use AccountOMS
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_FileTested',N'U')) is not null
	drop table dbo.t_FileTested
go
create table dbo.t_FileTested
(
	id int identity(1,1) not null PRIMARY KEY,
	DateRegistration datetime not null CONSTRAINT DF_DateRegistrationFileTested DEFAULT (GETDATE()),
	[FileName] varchar(50) not null,
	UserName varchar(30) not null CONSTRAINT DF_UserName default (ORIGINAL_LOGIN())	
) ON [PRIMARY]
go
ALTER TABLE dbo.t_FileTested ADD ErrorDescription VARCHAR(250) null
GO
ALTER TABLE dbo.t_FileTested ALTER COLUMN ErrorDescription NVARCHAR(250) not null
GO
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_File',N'U')) is not null
	drop table dbo.t_File
go
create table dbo.t_File
(
	[GUID] uniqueidentifier ROWGUIDCOL NOT NULL UNIQUE,
	id int identity(1,1) not null PRIMARY KEY,
	DateRegistration datetime not null CONSTRAINT DF_DateRegistration DEFAULT (GETDATE()),
	FileVersion char(5) not null,
	DateCreate date not null,
	[FileNameHR] varchar(26) not null,
	[FileNameLR] varchar(26) not null,	
	FileZIP varbinary(MAX) FILESTREAM
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_File] ADD  CONSTRAINT [DF_GUID_File]  DEFAULT (NEWSEQUENTIALID()) FOR [GUID]
GO
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_RegistersAccounts',N'U')) is not null
	drop table dbo.t_RegistersAccounts
go
create table dbo.t_RegistersAccounts
(
	rf_idFiles int not null CONSTRAINT FK_RegistersAccounts_Files FOREIGN KEY(rf_idFiles) REFERENCES dbo.t_File(id) on delete cascade,
	id int identity(1,1) not null,
	idRecord int not null,
	rf_idMO char(6) not null,
	ReportYear smallint not null CONSTRAINT CheckYear CHECK(ReportYear>YEAR(GETDATE())-1 and ReportYear<=YEAR(GETDATE())),
	ReportMonth tinyint not null CONSTRAINT CheckMonth CHECK(ReportMonth>0 and ReportMonth<13),
	NumberRegister int not null CONSTRAINT CheckNumber CHECK(NumberRegister>0),
	PrefixNumberRegister char(5) not null,
	PropertyNumberRegister tinyint not null,	
	DateRegister date not null CONSTRAINT CheckRegisterDate CHECK(DateRegister<=GETDATE()) ,
	rf_idSMO char(5) null,
	AmountPayment decimal(15,2) not null,
	Comments varchar(250) null,
	AmountPaymentAccept decimal(11,2) null,
	AmountMEK decimal(15,2) null,
	AmountMEE decimal(15,2) null,
	AmountEKMP decimal(15,2) null,
	rf_idRegisterCaseBack int null,--reference to t_RegisterCaseBack
	CONSTRAINT PK_RegistersAccounts_idFiles_idRegisterCases PRIMARY KEY CLUSTERED (id)
) ON [PRIMARY]
go
alter table t_RegistersAccounts alter column rf_idRegisterCaseBack int null
go
/*
связь между t_RecordCasePatient и t_RegistersAccounts осуществляется черз реестр СП и ТК т.к. номер формируется по слудующему правилу

					Номер счета формируется по следующему шаблону:

Pi-N-KJ,

Где 
Pi – реестровый номер страховой компании, в адрес которой направляется счет, или код ТФОМС Волгоградской области (34), если счет направляется за лечение лиц, застрахованных за пределами Волгоградской области.
N-K – номер Реестра СП и ТК, на основании которого формируется счет.
J – параметр, для счетов, сформированных по программе модернизации здравоохранения Волгоградской области, равен М (латинский символ).

Пример. Номер счета в адрес СМО «Капитал», сформированного на основании, Реестра СП и ТК с номером 1001-1, не по программе модернизации, должен быть равен: 34001-1001-1.
Номер счета в адрес СМО «Капитал», сформированного на основании, Реестра СП и ТК с номером 1001-0,  по программе модернизации, должен быть равен: 34001-1001-0М.

*/
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_RecordCasePatient',N'U')) is not null
	drop table dbo.t_RecordCasePatient
go
create table dbo.t_RecordCasePatient
(
	id int identity(1,1) not null,
	rf_idRegistersAccounts int not null CONSTRAINT FK_RecordCasePatient_RegistersAccounts FOREIGN KEY(rf_idRegistersAccounts) REFERENCES dbo.t_RegistersAccounts(id) on delete cascade,
	idRecord smallint not null,	
	IsNew bit,
	ID_Patient varchar(36) not null,
	rf_idF008 tinyint not null,
	SeriaPolis varchar(10) null,
	NumberPolis varchar(20) not null,
	NewBorn  varchar(9) not null,
	CONSTRAINT PK_RecordCasePatient_idFiles_idRecordCase PRIMARY KEY CLUSTERED (id) 
) ON [AccountOMSInsurer]
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_PatientSMO',N'U')) is not null
	drop table dbo.t_PatientSMO
go
create table dbo.t_PatientSMO
(
	rf_idRecordCasePatient int not null,
	rf_idSMO char(5) null,
	OGRN char(15) null,
	OKATO char(5) null,
	Name nvarchar(100) null,
	CONSTRAINT FK_PatientSMO_Patient FOREIGN KEY(rf_idRecordCasePatient) REFERENCES dbo.t_RecordCasePatient(id) on delete cascade
) ON [AccountOMSInsurer]
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_Case',N'U')) is not null
	drop table dbo.t_Case
go
create table dbo.t_Case
(
	id bigint identity(1,1) not null PRIMARY KEY,
	rf_idRecordCasePatient int not null,
	idRecordCase int not null,
	GUID_Case uniqueidentifier not null ,
	rf_idV006 tinyint not null,
	rf_idV008 smallint not null,
	rf_idDirectMO char(6) null,
	HopitalisationType tinyint null,
	rf_idMO char(6) not null,
	rf_idSubMO char(6) null,
	rf_idDepartmentMO int null,
	rf_idV002 smallint not null,
	IsChildTariff bit not null,
	NumberHistoryCase nvarchar(50) not null,
	DateBegin date not null,
	DateEnd date not null,
	rf_idV009 smallint not null,
	rf_idV012 smallint not null,
	rf_idV004 int not null,
	rf_idDoctor char(16) null,
	IsSpecialCase tinyint null,
	rf_idV010 tinyint not null,
	AmountPayment decimal(15,2) not null CONSTRAINT CH_More_Equal_Zero CHECK(AmountPayment>=0),
	TypePay tinyint null,
	AmountPaymentAccept decimal(15,2) null,
	Comments nvarchar(250) null,
	CONSTRAINT FK_Cases_RecordCasePatient FOREIGN KEY(rf_idRecordCasePatient) REFERENCES dbo.t_RecordCasePatient(id) on delete cascade
) ON [AccountOMSCase]
go
alter table t_Case add Age tinyint null
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_Diagnosis',N'U')) is not null
	drop table dbo.t_Diagnosis
go
create table dbo.t_Diagnosis
(
	DiagnosisCode char(10),
	rf_idCase bigint not null,
	TypeDiagnosis tinyint not null,--- 1-Primary 2-Secondary 3-Accompanied
	CONSTRAINT FK_Diagnosis_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id) on delete cascade
) ON [PRIMARY]
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_MES',N'U')) is not null
	drop table dbo.t_MES
go
create table t_MES
(
	MES char(16),
	rf_idCase bigint not null,
	TypeMES tinyint not null ,--- 1-Primary 2-Secondary 
	Quantity decimal(5,2) null,
	Tariff decimal(15,2) null,
	CONSTRAINT FK_MES_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id) on delete cascade
) ON [AccountOMSCase]
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_ReasonPaymentCancelled',N'U')) is not null
	drop table dbo.t_ReasonPaymentCancelled
go
create table dbo.t_ReasonPaymentCancelled
(
	rf_idCase bigint not null,
	rf_idPaymentAccountCanseled tinyint not null,
	CONSTRAINT FK_ReasonPaymentCanseled_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id) on delete cascade
) ON [AccountOMSCase]
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_FinancialSanctions',N'U')) is not null
	drop table dbo.t_FinancialSanctions
go
create table dbo.t_FinancialSanctions
(
	rf_idCase bigint not null,
	Amount decimal(15,2) not null,
	TypeSanction tinyint not null,--1-MEK 2-MEE 3-EKMP
	CONSTRAINT FK_FinancialSanctions_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id) on delete cascade
) ON [AccountOMSCase]
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_Meduslugi',N'U')) is not null
	drop table dbo.t_Meduslugi
go
create table dbo.t_Meduslugi
(
	rf_idCase bigint not null,
	id int not null,
	GUID_MU uniqueidentifier not null,
	rf_idMO char(6) not null,
	rf_idSubMO char(6) null,
	rf_idDepartmentMO int null,
	rf_idV002 smallint not null,
	IsChildTariff bit not null,
	DateHelpBegin date not null,
	DateHelpEnd date not null,
	DiagnosisCode char(10) not null,
	MUGroupCode tinyint not null,
	MUUnGroupCode tinyint not null,
	MUCode smallint not null,
	Quantity decimal(6,2) not null,
	Price decimal(15,2) not null,
	TotalPrice decimal(15,2) not null,
	rf_idV004 int not null,
	rf_idDoctor char(16) null,
	Comments nvarchar(250) null,
	CONSTRAINT FK_Meduslugi_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id) on delete cascade
) ON [AccountOMSMeduslugi]
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_RegisterPatient',N'U')) is not null
	drop table dbo.t_RegisterPatient
go
create table t_RegisterPatient
(
	id int identity(1,1) not null PRIMARY KEY,
	rf_idFiles int not null CONSTRAINT FK_RegisterPatient_Files FOREIGN KEY(rf_idFiles) REFERENCES dbo.t_File(id) on delete cascade,
	ID_Patient varchar(36) not null,
	Fam nvarchar(40) not null,
	Im nvarchar(40) not null,
	Ot nvarchar(40) null,
	rf_idV005 tinyint not null,
	BirthDay date not null,
	BirthPlace nvarchar(100) null	
) ON [AccountOMSInsurer]
go
alter table dbo.t_RegisterPatient add rf_idRecordCase int
--alter table dbo.t_RegisterPatient alter column Ot nvarchar(40) null
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_RegisterPatientAttendant',N'U')) is not null
	drop table dbo.t_RegisterPatientAttendant
go
create table t_RegisterPatientAttendant
(
	rf_idRegisterPatient int,
	Fam nvarchar(40) not null,
	Im nvarchar(40) not null,
	Ot nvarchar(40) null,
	rf_idV005 tinyint not null,
	BirthDay date not null,
	CONSTRAINT FK_RegisterPatientAttendant_RegisterPatient FOREIGN KEY(rf_idRegisterPatient) REFERENCES dbo.t_RegisterPatient(id) on delete cascade
) ON [AccountOMSInsurer]
go

----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_RegisterPatientDocument',N'U')) is not null
	drop table dbo.t_RegisterPatientDocument
go
create table t_RegisterPatientDocument
(
	rf_idRegisterPatient int,
	rf_idDocumentType char(2) null,
	SeriaDocument varchar(10) null,
	NumberDocument varchar(20) null,
	SNILS char(14) null,
	OKATO char(11) null,
	OKATO_Place char(11) null,
	Comments nvarchar(250) null,
	CONSTRAINT FK_RegisterPatientDocument_RegisterPatient FOREIGN KEY(rf_idRegisterPatient) REFERENCES dbo.t_RegisterPatient(id) on delete cascade
) ON [AccountOMSInsurer]
go
