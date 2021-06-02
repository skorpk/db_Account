USE [master]
GO

/****** Object:  Database [oms_acount_temp]    Script Date: 09/09/2011 15:14:00 ******/
IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'AccountOMS')
begin
	ALTER DATABASE AccountOMS set single_user with rollback immediate
	DROP DATABASE [AccountOMS]
end
GO
USE [master]
GO
CREATE DATABASE AccountOMS 
---------для таблиц содержащие данные из реестров счетов(файлы входящие, заголовок счета)
ON  PRIMARY 
( 
	NAME = N'account_primary', 
	FILENAME = N'G:\DataBase\AccountOMS\AccountsOMS_data.mdf' , 
	SIZE = 4072KB , MAXSIZE = UNLIMITED, 
	FILEGROWTH = 1024KB 
),
--сведения о случаях
FILEGROUP AccountOMSCase
( 
	NAME = N'AccountOMS_Case', 
	FILENAME = N'G:\DataBase\AccountOMS\AccountOMSCases_data.ndf' , 
	SIZE = 3072KB , MAXSIZE = UNLIMITED, 
	FILEGROWTH = 1024KB 
),
--сведения о пациенте
FILEGROUP AccountOMSInsurer
( 
	NAME = N'accountOMS_Insurer', 
	FILENAME = N'G:\DataBase\AccountOMS\AccountOMSInsurer_data.ndf' , 
	SIZE = 3072KB , MAXSIZE = UNLIMITED, 
	FILEGROWTH = 1024KB 
),
---сведения о медуслугах
FILEGROUP AccountOMSMeduslugi
( 
	NAME = N'AccountOMS_Meduslugi', 
	FILENAME = N'G:\DataBase\AccountOMS\AccountOMSMeduslugi_data.ndf' , 
	SIZE = 3072KB , MAXSIZE = UNLIMITED, 
	FILEGROWTH = 1024KB 
),
--хранит файлы реестров счетов
 FILEGROUP FileStreamGroup CONTAINS FILESTREAM( NAME = Files,FILENAME = 'G:\DataBase\AccountOMS\FileStream')
 LOG ON 
( 
	NAME = N'account_log', 
	FILENAME = N'G:\DataBase\AccountOMS\AccountsOMS_log.ldf' , 
	SIZE = 1024KB , MAXSIZE = 2048GB , 
	FILEGROWTH = 10%
)
GO
ALTER DATABASE AccountOMS SET COMPATIBILITY_LEVEL = 100
GO