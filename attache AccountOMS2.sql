--CREATE DATABASE [AccountOMS] ON 
--( FILENAME = N'L:\AccountOMS\AccountsOMS_data.mdf' ),
--( FILENAME = N'P:\AccountOMS\AccountsOMS_log.ldf' ),
--( FILENAME = N'Q:\AccountOMS\AccountOMSCases_data.ndf' ),
--( FILENAME = N'L:\AccountOMS\AccountOMSInsurer_data.ndf' ),
--( FILENAME = N'R:\AccountOMS\AccountMU.ndf' )
-- FOR ATTACH
--GO

CREATE DATABASE [AccountOMS] ON 
( FILENAME = N'G:\AccountOMS\AccountsOMS_data.mdf' ),
( FILENAME = N'P:\AccountOMS\AccountsOMS_log.ldf' ),
( FILENAME = N'Q:\AccountOMS\AccountOMSCases_data.ndf' ),
( FILENAME = N'D:\AccountOMS\AccountOMSInsurer_data.ndf' ),
( FILENAME = N'R:\AccountOMS\AccountMU.ndf' )
 FOR ATTACH