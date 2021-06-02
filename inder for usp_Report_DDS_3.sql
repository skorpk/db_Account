/*
Missing Index Details from SQLQuery3.sql - tserver.AccountOMS (VTFOMS\SKrainov (66))
The Query Processor estimates that implementing the following index could improve the query cost by 34.6375%.
*/

USE [AccountOMS]
GO
CREATE NONCLUSTERED INDEX IX_MUCode_Case
ON [dbo].[t_Meduslugi] ([MUGroupCode],[MUUnGroupCode])
INCLUDE ([rf_idCase]) WITH (ONLINE=ON, DROP_EXISTING=ON)
GO
CREATE NONCLUSTERED INDEX [IX_DateEnd_ID_idRecordCasePatient] ON [dbo].[t_Case] 
(
	[DateEnd] ASC
)
INCLUDE ( [id],
[rf_idRecordCasePatient],[rf_idV009],[AmountPayment]) WITH (DROP_EXISTING=ON, ONLINE=ON)  ON [AccountOMSCase]
GO
-----------------------------------------------------------------------------------------------
USE [ExchangeFinancing]
GO
CREATE NONCLUSTERED INDEX [IX_IdSettledAccount] ON [dbo].[t_SettledCase] 
(
	[rf_idSettledAccount] ASC
)
INCLUDE ( [idRecord],
[AmountPayment], rf_idCase) WITH (DROP_EXISTING=ON, ONLINE=ON) ON [PRIMARY]
GO

