/*
Missing Index Details from get report.sql - srvsql1-st2.AccountOMSReports (VTFOMS\SKrainov (227))
The Query Processor estimates that implementing the following index could improve the query cost by 11.0675%.
*/

USE [AccountOMSReports]
GO
CREATE NONCLUSTERED INDEX IX_DateReg_ReportPeriod
ON [dbo].[t_ReportAnalyzeDeath] ([DateRegistration],[ReportYearMonth])
INCLUDE ([rf_idV009],[rf_idCase],[DS1],[AmountPayment],[CodeM],[CodeSMO],[Account],[DateAccount],[rf_idV006],[rf_idV002],[SNILS],[Child],[NumberCase],[Sex],[Policy])
GO
CREATE NONCLUSTERED INDEX IX_PaymentCase
ON [dbo].[t_PaymentAcceptedCaseType] ([rf_idCase],DateRegistration)
INCLUDE(DocumentNumber,DocumentDate,TypeCheckup)
GO
