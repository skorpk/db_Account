USE CanserRegister
GO
ALTER TABLE dbo.t_PeopleCase ADD rf_idPeopleENP INT
GO
DROP INDEX [IX_PeopleCase_ENP] ON [dbo].[t_PeopleCase]
go
ALTER TABLE dbo.t_PeopleCase DROP COLUMN ENP
GO
CREATE NONCLUSTERED INDEX [IX_PeopleCase_ENP] ON [dbo].[t_PeopleCase]
(
	[ENP] ASC
)
INCLUDE ( 	[rf_idCase],
	[Account],
	[DateRegistr],
	[CodeM],
	[NumberCase],
	[DS1],
	[DateBegin],
	[DateEnd],
	[DS_ONK],
	[USL_OK],
	[rf_idv008],
	[rf_idV009],
	[P_CEL],
	[DN]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


