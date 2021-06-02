/*
Missing Index Details from SQLQuery34.sql - srvportal.CanserRegister (VTFOMS\skrainov (63))
The Query Processor estimates that implementing the following index could improve the query cost by 93.1173%.
*/


USE [CanserRegister]
GO
CREATE NONCLUSTERED INDEX IX_PeopleCase_ENP
ON [dbo].[t_PeopleCase] ([ENP])
INCLUDE(rf_idCase, Account, DateRegistr, CodeM, NumberCase, DS1, DateBegin, DateEnd, DS_ONK, USL_OK, rf_idv008, rf_idV009, P_CEL, DN) with DROP_EXISTING

GO

