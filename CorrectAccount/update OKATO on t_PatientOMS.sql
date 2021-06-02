use RegisterCases
go
begin transaction
update p
set p.OKATO=p1.OKATO
from AccountOMS.dbo.t_PatientSMO p inner join (
												select a.id,c.OKATO
												from (
														select r.id,c.GUID_Case,r.ID_Patient,p.OKATO
														from AccountOMS.dbo.t_Case c inner join AccountOMS.dbo.t_RecordCasePatient r on
																c.rf_idRecordCasePatient=r.id
																					inner join AccountOMS.dbo.t_PatientSMO p on
																r.id=p.rf_idRecordCasePatient
														where rf_idSMO='34'
													 ) a inner join (
																		select c.id,c.GUID_Case,rcb.rf_idRecordCase,r.ID_Patient,p.OKATO
																		from t_Case c inner join t_RecordCaseBack rcb on
																				c.id=rcb.rf_idCase
																						inner join t_PatientBack p on
																				rcb.id=p.rf_idRecordCaseBack
																						inner join t_RecordCase r on
																				c.rf_idRecordCase=r.id
																						inner join t_CaseBack cp on
																				rcb.id=cp.rf_idRecordCaseBack
																				and cp.TypePay=1
																		where rf_idSMO='34'
																	) c on
														a.GUID_Case=c.GUID_Case
														and a.ID_Patient=c.ID_Patient
												where isnull(a.OKATO,'0')<>c.OKATO
												group by a.id,c.OKATO
												) p1 on
											p.rf_idRecordCasePatient=p1.id
commit

go
--use AccountOMS
--go
--if OBJECT_ID('t_RegisterPatientDocumentTemp') is not null
--	drop table t_RegisterPatientDocumentTemp
--go
--CREATE TABLE [dbo].[t_RegisterPatientDocumentTemp](
--	[rf_idRegisterPatient] [int] NULL,
--	[rf_idDocumentType] [char](2) NULL,
--	[SeriaDocument] [varchar](10) NULL,
--	[NumberDocument] [varchar](20) NULL,
--	[SNILS] [char](14) NULL,
--	[OKATO] [char](11) NULL,
--	[OKATO_Place] [char](11) NULL,
--	[Comments] [nvarchar](250) NULL
--) 
--GO
--CREATE UNIQUE INDEX UI_refID ON t_RegisterPatientDocumentTemp(rf_idRegisterPatient)
--    WITH (IGNORE_DUP_KEY = ON);
-- go
-- begin transaction
--	begin try
--insert t_RegisterPatientDocumentTemp select * from dbo.t_RegisterPatientDocumentTemp

--delete from dbo.t_RegisterPatientDocument

--insert dbo.t_RegisterPatientDocument select * from dbo.t_RegisterPatientDocumentTemp

--end try
--begin catch
--if @@TRANCOUNT>0
--	select ERROR_MESSAGE(),ERROR_LINE()
--	rollback transaction
--end catch
--	if @@TRANCOUNT>0
--	commit transaction


