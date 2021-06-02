USE AccountOMSReports
GO
DROP INDEX [IX_ClusteredIdex] ON [dbo].[t_Meduslugi] WITH ( ONLINE = OFF )
GO
DROP INDEX [IDX_mu_mugrcode] ON [dbo].[t_Meduslugi]
GO
DROP INDEX [IDX_MU_rfidcase] ON [dbo].[t_Meduslugi]
GO
DROP INDEX [IDX_MU_fullMU] ON [dbo].[t_Meduslugi]
GO
DROP INDEX [IDX_MU_GC] ON [dbo].[t_Meduslugi]
GO
----------------------------------------------------------------------
ALTER TABLE dbo.t_Meduslugi ALTER COLUMN rf_idCase INT NOT NULL
GO
----------------------------------------------------------------------
CREATE CLUSTERED INDEX [IX_ClusteredIdex] ON [dbo].[t_Meduslugi]
(
	[id] ASC,
	[rf_idCase] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Meduslugi]
GO
CREATE NONCLUSTERED INDEX [IDX_mu_mugrcode] ON [dbo].[t_Meduslugi]
(
	[MUGroupCode] ASC,
	[MUUnGroupCode] ASC
)
INCLUDE ( 	[rf_idCase]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_MU_rfidcase] ON [dbo].[t_Meduslugi]
(
	[rf_idCase] ASC
)
INCLUDE ( 	[Quantity],
	[Price],
	[MUGroupCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_MU_GC] ON [dbo].[t_Meduslugi]
(
	[MUGroupCode] ASC
)
INCLUDE ( 	[rf_idCase],
	[Quantity],
	[Price],
	[MU]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IDX_MU_fullMU]    Script Date: 27.11.2015 9:17:21 ******/
CREATE NONCLUSTERED INDEX [IDX_MU_fullMU] ON [dbo].[t_Meduslugi]
(
	[MUGroupCode] ASC,
	[MUUnGroupCode] ASC,
	[MUCode] ASC
)
INCLUDE ( 	[rf_idCase],
	[Quantity]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Meduslugi]
GO




