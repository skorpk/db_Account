USE AccountOMSReports
GO
DROP TABLE dbo.t_SendingDataIntoFFOMS
GO
CREATE TABLE dbo.t_SendingDataIntoFFOMS(
	id bigint NULL,
	rf_idCase bigint NOT NULL,
	CodeM char(6) NOT NULL,
	rf_idMO char(6) NOT NULL,
	ReportMonth tinyint NOT NULL,
	ReportYear smallint NOT NULL,
	rf_idF008 tinyint NOT NULL,
	rf_idV006 tinyint NOT NULL,
	SeriaPolis varchar(10) NULL,
	NumberPolis varchar(20) NOT NULL,
	BirthDay date NOT NULL,
	rf_idV005 tinyint NOT NULL,
	idRecordCase bigint NOT NULL,
	rf_idV014 tinyint NULL,
	UnitOfHospital varchar(20) NULL,
	DateBegin date NOT NULL,
	DateEnd date NOT NULL,
	DS1 char(10) NULL,
	DS2 char(10) NULL,
	DS3 char(10) NULL,
	rf_idV009 smallint NOT NULL,
	MES varchar(20) NULL,
	AmountPayment decimal(15, 2) NOT NULL,
	AmountPaymentZSL decimal(15, 2) NOT NULL,
	idMU varchar(36) NULL,
	MUSurgery varchar(20) NULL,
	Age smallint NULL,
	VZST int NOT NULL,
	K_KSG varchar(20) NULL,
	KSG_PG int NOT NULL,
	PVT int NOT NULL,
	IsDisableCheck int NOT NULL,
	IsFullDoubleDate bit NOT NULL,
	IsUnload bit NOT NULL,
	IT_SL decimal(3, 2) NULL,
	SL_K  AS (case when IT_SL IS NOT NULL then (1) else (0) end),
	ENP varchar(16) NULL,
	TypeCases tinyint NOT NULL,
	Quantity int NULL,
	TotalPriceMU decimal(15, 2) NULL,
	UR_K tinyint NULL,
	IDSP TINYINT	
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE dbo.t_SendingDataIntoFFOMS ADD  DEFAULT ((0)) FOR IsFullDoubleDate
GO

ALTER TABLE dbo.t_SendingDataIntoFFOMS ADD  DEFAULT ((0)) FOR IsUnload
GO

ALTER TABLE dbo.t_SendingDataIntoFFOMS ADD  DEFAULT ((9)) FOR TypeCases
GO

/****** Object:  Index IX_DisableCheck_FullDate    Script Date: 09.02.2019 11:57:51 ******/
CREATE NONCLUSTERED INDEX IX_DisableCheck_FullDate ON dbo.t_SendingDataIntoFFOMS
(
	IsDisableCheck ASC,
	IsFullDoubleDate ASC,
	IsUnload ASC
)
INCLUDE ( 	rf_idCase,
	rf_idV006) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
GO

/****** Object:  Index IX_IDCAse_MU    Script Date: 09.02.2019 11:57:51 ******/
CREATE NONCLUSTERED INDEX IX_IDCAse_MU ON dbo.t_SendingDataIntoFFOMS
(
	rf_idCase ASC,
	idMU ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
GO

SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO

/****** Object:  Index IX_ReportMonthFullDoubleDate2018    Script Date: 09.02.2019 11:57:51 ******/
CREATE NONCLUSTERED INDEX IX_ReportMonthFullDoubleDate2018 ON dbo.t_SendingDataIntoFFOMS
(
	ReportMonth ASC,
	ReportYear ASC,
	IsFullDoubleDate ASC,
	IsUnload ASC
)
INCLUDE ( 	id,
	rf_idCase,
	rf_idMO,
	rf_idF008,
	SeriaPolis,
	NumberPolis,
	BirthDay,
	rf_idV005,
	rf_idV014,
	UnitOfHospital,
	DateBegin,
	DateEnd,
	DS1,
	DS2,
	DS3,
	rf_idV009,
	AmountPayment,
	idMU,
	MUSurgery,
	VZST,
	K_KSG,
	KSG_PG,
	PVT,
	IT_SL,
	SL_K) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
GO

/****** Object:  Index IX_ReportYear_DisableCheck_Full    Script Date: 09.02.2019 11:57:52 ******/
CREATE NONCLUSTERED INDEX IX_ReportYear_DisableCheck_Full ON dbo.t_SendingDataIntoFFOMS
(
	ReportYear ASC,
	IsDisableCheck ASC,
	IsFullDoubleDate ASC
)
INCLUDE ( 	rf_idV006,
	DateBegin,
	DateEnd,
	DS1,
	ENP) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index IX_ReportYear_MES_IdCase    Script Date: 09.02.2019 11:57:52 ******/
CREATE NONCLUSTERED INDEX IX_ReportYear_MES_IdCase ON dbo.t_SendingDataIntoFFOMS
(
	IsUnload ASC,
	ReportYear ASC
)
INCLUDE ( 	rf_idCase,
	MES,
	rf_idV006,
	DateBegin,
	DateEnd,
	IsFullDoubleDate,
	ENP,
	DS1,
	PVT) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
GO

/****** Object:  Index IX_SendIsUnloadReportYearDs2    Script Date: 09.02.2019 11:57:52 ******/
CREATE NONCLUSTERED INDEX IX_SendIsUnloadReportYearDs2 ON dbo.t_SendingDataIntoFFOMS
(
	IsUnload ASC,
	ReportYear ASC
)
INCLUDE ( 	DS1,
	DS2,
	DS3,
	rf_idV006,
	DateBegin,
	DateEnd,
	IsFullDoubleDate,
	ENP) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
GO

/****** Object:  Index IX_V006_Year_DS1_ENP    Script Date: 09.02.2019 11:57:52 ******/
CREATE NONCLUSTERED INDEX IX_V006_Year_DS1_ENP ON dbo.t_SendingDataIntoFFOMS
(
	ReportYear ASC,
	rf_idV006 ASC,
	DS1 ASC,
	IsFullDoubleDate ASC,
	ENP ASC
)
INCLUDE ( 	rf_idCase,
	DateBegin,
	DateEnd,
	IsDisableCheck) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
GO

/****** Object:  Index IX_V009_Unload    Script Date: 09.02.2019 11:57:52 ******/
CREATE NONCLUSTERED INDEX IX_V009_Unload ON dbo.t_SendingDataIntoFFOMS
(
	rf_idV009 ASC,
	IsUnload ASC
)
INCLUDE ( 	DateBegin,
	DateEnd,
	IsDisableCheck) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
GO

/****** Object:  Index IX_Year_FullDouble    Script Date: 09.02.2019 11:57:52 ******/
CREATE NONCLUSTERED INDEX IX_Year_FullDouble ON dbo.t_SendingDataIntoFFOMS
(
	ReportYear ASC,
	IsFullDoubleDate ASC
)
INCLUDE ( 	rf_idCase,
	rf_idV006,
	DateBegin,
	DateEnd,
	DS1,
	ENP) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index IX_YearPVTDisable_Double    Script Date: 09.02.2019 11:57:52 ******/
CREATE NONCLUSTERED INDEX IX_YearPVTDisable_Double ON dbo.t_SendingDataIntoFFOMS
(
	ReportYear ASC,
	PVT ASC,
	IsDisableCheck ASC,
	IsFullDoubleDate ASC
)
INCLUDE ( 	rf_idCase,
	rf_idV006,
	DS1,
	ENP) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
GO




