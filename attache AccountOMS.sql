USE [master]
GO
CREATE DATABASE [AccountOMS] ON 
( FILENAME = N'L:\AccountOMS\AccountsOMS_data.mdf' ),
( FILENAME = N'P:\AccountOMS\AccountsOMS_log.ldf' ),
( FILENAME = N'Q:\AccountOMS\AccountOMSCases_data.ndf' ),
( FILENAME = N'L:\AccountOMS\AccountOMSInsurer_data.ndf' ),
( FILENAME = N'R:\AccountOMS\AccountMU.ndf' ),
FILEGROUP [FileStreamGroup] CONTAINS FILESTREAM DEFAULT 
( NAME = N'Files', FILENAME = N'K:\FileStream\AccountOMS')
FOR ATTACH
GO

--USE [master]
--GO
--CREATE DATABASE [FileStreamDB] ON 
--( FILENAME = N'C:\FileStreamDB\FileStreamDB.mdf' ),
--( FILENAME = N'C:\FileStreamDB\FileStreamDB_log.ldf' ),
--FILEGROUP [FileStreamGroup] CONTAINS FILESTREAM DEFAULT 
--( NAME = N'FileStreamDB_FSData', FILENAME = N'C:\FileStreamDB\FileStreamData' )