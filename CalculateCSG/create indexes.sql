/*
Missing Index Details from reportCSG.sql - srvsql2-st1.AccountOMS (VTFOMS\SKrainov (82))
The Query Processor estimates that implementing the following index could improve the query cost by 86.5584%.
*/

USE [AccountOMS]
GO
CREATE NONCLUSTERED INDEX IX_CSG_STep
ON [dbo].[tmp_CSG_20141226] ([Step])
INCLUDE ([Код КСГ],[DS1],SUr,Age,Sex,DS2,Los)  WITH drop_existing
GO

CREATE NONCLUSTERED INDEX IX_V006_V010_Age_Must_Delete
ON [dbo].[t_Case] ([rf_idV006],[rf_idV010],[Age])
INCLUDE ([id],[rf_idRecordCasePatient],[DateBegin],[DateEnd],[AmountPayment])
go
-----------drop index
DELETE INDEX IX_V006_V010_Age_Must_Delete ON [dbo].[t_Case]

