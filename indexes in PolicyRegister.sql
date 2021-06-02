---------------------------------------------------------1------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'dbo.HISTUDL') AND name = N'IX_HISTUDL_DOCN')
	DROP INDEX IX_HISTUDL_DOCN ON dbo.HISTUDL 

GO

CREATE NONCLUSTERED INDEX IX_HISTUDL_DOCN ON dbo.HISTUDL(PID) 
INCLUDE(DOCN) WITH ( ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO
---------------------------------------------------------2------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'dbo.HISTFDR') AND name = N'IX_HISTFDR_FAM_IM_OT_DR')
DROP INDEX IX_HISTFDR_FAM_IM_OT_DR ON dbo.HISTFDR 

GO
CREATE NONCLUSTERED INDEX IX_HISTFDR_FAM_IM_OT_DR ON dbo.HISTFDR(PID,FAM,IM,OT,DR,w)  
WITH ( ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
GO
----------------------------------------------------------3-----------------------------------------------------
IF  EXISTS (SELECT * FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'dbo.PEOPLE') AND name = N'IX_PEOPLE_DR')
DROP INDEX IX_PEOPLE_DR ON dbo.PEOPLE
 
GO
CREATE NONCLUSTERED INDEX IX_PEOPLE_DR ON dbo.PEOPLE 
(
	DR ASC,
	IM
)INCLUDE(FAM,OT,PID,W) WITH ( ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
GO
-----------------------------------------------------------4----------------------------------------------------
IF  EXISTS (SELECT * FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'dbo.PEOPLE') AND name = N'IX_PEOPLE_FIODR_DOCN_Cases')
DROP INDEX IX_PEOPLE_FIODR_DOCN_Cases ON dbo.PEOPLE
 
GO
CREATE NONCLUSTERED INDEX IX_PEOPLE_FIODR_DOCN_Cases ON dbo.PEOPLE 
(
	FAM ASC,
	IM ASC,
	OT ASC,
	DR ASC
)
INCLUDE ( DOCN,PID,W) WITH ( ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
GO
------------------------------------------------------------5---------------------------------------------------
IF  EXISTS (SELECT * FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'dbo.PEOPLE') AND name = N'IX_PEOPLE_IM_OT_DR_DOCN_Case')
DROP INDEX IX_PEOPLE_IM_OT_DR_DOCN_Case ON dbo.PEOPLE 

GO
CREATE NONCLUSTERED INDEX IX_PEOPLE_IM_OT_DR_DOCN_Case ON dbo.PEOPLE 
(
	DOCN ASC
)
INCLUDE ( IM,
OT,
DR,
FAM,PID,W) WITH ( ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
GO
-------------------------------------------------------------6--------------------------------------------------
IF  EXISTS (SELECT * FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'dbo.PEOPLE') AND name = N'IX_PEOPLE_SS_FAM_OT_IM_Case')
DROP INDEX IX_PEOPLE_SS_FAM_OT_IM_Case ON dbo.PEOPLE 

GO
CREATE NONCLUSTERED INDEX IX_PEOPLE_SS_FAM_OT_IM_Case ON dbo.PEOPLE 
(
	SS ASC,
	FAM ASC,
	IM ASC,
	OT ASC
)
INCLUDE ( DR,PID,W) WITH ( ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
GO
--------------------------------------------------------------7-------------------------------------------------
IF  EXISTS (SELECT * FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'dbo.PEOPLE') AND name = N'IX_PEOPLE_SS_FAM_DOCN_IM_DR_Case')
DROP INDEX IX_PEOPLE_SS_FAM_DOCN_IM_DR_Case ON dbo.PEOPLE
 
GO
CREATE NONCLUSTERED INDEX IX_PEOPLE_SS_FAM_DOCN_IM_DR_Case ON dbo.PEOPLE 
(
	SS ASC,
	FAM ASC,
	IM ASC,
	OT ASC,
	DR ASC,
	DOCN ASC
)
INCLUDE ( PID,W) WITH ( ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
GO
---------------------------------------------------------------8------------------------------------------------
IF  EXISTS (SELECT * FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'dbo.POLIS') AND name = N'IX_POLIS_PID')
DROP INDEX IX_POLIS_PID ON dbo.POLIS 

GO
CREATE NONCLUSTERED INDEX IX_POLIS_PID ON dbo.POLIS 
(
	PID ASC
)
INCLUDE(Q,DBEG,POLTP,SPOL,NPOL,DSTOP,OKATO,DEND) WITH ( ONLINE = ON) 
GO
----------------------------------------------------------------9-----------------------------------------------
IF  EXISTS (SELECT * FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'dbo.HISTFDR') AND name = N'IX_HISTFDR_PID')
DROP INDEX IX_HISTFDR_PID ON dbo.HISTFDR 

GO
CREATE NONCLUSTERED INDEX IX_HISTFDR_PID ON dbo.HISTFDR 
(
	PID ASC
)
INCLUDE(FAM,OT,IM,DR,W) WITH ( ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
GO
-----------------------------------------------------------------10----------------------------------------------
IF  EXISTS (SELECT * FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'dbo.HISTFDR') AND name = N'IX_HISTFDR_FIODR')
DROP INDEX IX_HISTFDR_FIODR ON dbo.HISTFDR
GO
CREATE NONCLUSTERED INDEX IX_HISTFDR_FIODR ON dbo.HISTFDR 
(
	FAM ASC,
	IM ASC,
	OT ASC,
	W ASC,
	DR ASC
)
INCLUDE(PID) WITH ( ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
GO
-------------------------------------------------------------------11--------------------------------------------
IF  EXISTS (SELECT * FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'dbo.HISTLPU') AND name = N'IX_HISTLPU_PID')
DROP INDEX IX_HISTLPU_PID ON dbo.HISTLPU 

GO
CREATE NONCLUSTERED INDEX IX_HISTLPU_PID ON dbo.HISTLPU 
(
	PID ASC
)
INCLUDE(LPUDT,LPU) WITH (STATISTICS_NORECOMPUTE  = ON,  ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 

GO
CREATE NONCLUSTERED INDEX IX_HISTFDR_FIO_Sex_ID
ON [dbo].[HISTFDR] ([FAM],[IM],[DR])
INCLUDE ([ID],[OT],[W]) WITH (DROP_EXISTING=ON,STATISTICS_NORECOMPUTE  = ON,  ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)