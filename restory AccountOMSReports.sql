RESTORE DATABASE [AccountOMSReports] FROM  DISK = N'K:\AccountOMSReports_22_1_2014.bak' WITH  FILE = 1, 
MOVE N'AccountOMSReports' TO N'E:\AccountOMSReports\AccountOMSReports.mdf',  
MOVE N'AccountOMSReports_log' TO N'E:\AccountOMSReports\AccountOMSReports_1.ldf',  NOUNLOAD,  STATS = 5
GO
