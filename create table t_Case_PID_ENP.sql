use AccountOMS
go
if(OBJECT_ID('t_Case_PID_ENP',N'U')) is not null
	drop table dbo.t_Case_PID_ENP
go
create table dbo.t_Case_PID_ENP
(
	rf_idCase bigint not null,
	PID int null,
	ENP varchar(20) null,
	IsLocal tinyint not null
)
go
create nonclustered index IX_RefCase on dbo.t_Case_PID_ENP(rf_idCase)
go
use RegisterCases
go
alter table dbo.t_CaseDefine add  UNumberPolicy as (case when rf_idF008=1 then COALESCE(UniqueNumberPolicy,COALESCE(rtrim(SPolicy),'')+NPolcy) else null end)
go
CREATE NONCLUSTERED INDEX IX_UNumberPolicy_Ref_PID
ON [dbo].[t_CaseDefine] ([UNumberPolicy])
INCLUDE ([rf_idRefCaseIteration],[PID])
GO
CREATE NONCLUSTERED INDEX IX_UNumberPolicy_Ref
ON [dbo].t_CaseDefineZP1Found (UniqueNumberPolicy)
INCLUDE (rf_idRefCaseIteration)
go