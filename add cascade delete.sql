use AccountOMS
go
--добавл€ю каскадное удаление
alter table dbo.t_RegisterPatientDocument  DROP CONSTRAINT FK_RegisterPatientDocument_RegisterPatient 
go
alter table dbo.t_RegisterPatientDocument 
		ADD CONSTRAINT FK_RegisterPatientDocument_RegisterPatient FOREIGN KEY(rf_idRegisterPatient) REFERENCES dbo.t_RegisterPatient(id) ON DELETE CASCADE
go
alter table t_RegistersAccounts drop CONSTRAINT FK_RegistersAccounts_Files
go
alter table t_RegistersAccounts add  CONSTRAINT FK_RegistersAccounts_Files FOREIGN KEY(rf_idFiles) REFERENCES dbo.t_File(id) on delete cascade
go
alter table t_RecordCasePatient drop CONSTRAINT FK_RecordCasePatient_RegistersAccounts
go
alter table t_RecordCasePatient add CONSTRAINT FK_RecordCasePatient_RegistersAccounts FOREIGN KEY(rf_idRegistersAccounts) REFERENCES dbo.t_RegistersAccounts(id) on delete cascade
go
alter table t_PatientSMO drop CONSTRAINT FK_PatientSMO_Patient 
go
alter table t_PatientSMO add CONSTRAINT FK_PatientSMO_Patient FOREIGN KEY(rf_idRecordCasePatient) REFERENCES dbo.t_RecordCasePatient(id) on delete cascade
go
alter table t_Case drop CONSTRAINT FK_Cases_RecordCasePatient 
go
alter table t_Case add CONSTRAINT FK_Cases_RecordCasePatient FOREIGN KEY(rf_idRecordCasePatient) REFERENCES dbo.t_RecordCasePatient(id) on delete cascade
go
alter table t_Diagnosis drop CONSTRAINT FK_Diagnosis_Cases 
go
alter table t_Diagnosis add CONSTRAINT FK_Diagnosis_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id) on delete cascade
go
alter table t_MES drop CONSTRAINT FK_MES_Cases
go
alter table t_MES add CONSTRAINT FK_MES_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id) on delete cascade
go
alter table t_ReasonPaymentCancelled drop CONSTRAINT FK_ReasonPaymentCanseled_Cases 
go
alter table t_ReasonPaymentCancelled add CONSTRAINT FK_ReasonPaymentCanseled_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id) on delete cascade
go
alter table t_FinancialSanctions drop CONSTRAINT FK_FinancialSanctions_Cases
go
alter table t_FinancialSanctions add CONSTRAINT FK_FinancialSanctions_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id) on delete cascade
go
alter table t_Meduslugi drop CONSTRAINT FK_Meduslugi_Cases
go
alter table t_Meduslugi add CONSTRAINT FK_Meduslugi_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id) on delete cascade
go
alter table t_RegisterPatient drop CONSTRAINT FK_RegisterPatient_Files  
go
alter table t_RegisterPatient add CONSTRAINT FK_RegisterPatient_Files FOREIGN KEY(rf_idFiles) REFERENCES dbo.t_File(id) on delete cascade
go
alter table t_RegisterPatientAttendant  drop CONSTRAINT FK_RegisterPatientAttendant_RegisterPatient
go
alter table t_RegisterPatientAttendant add CONSTRAINT FK_RegisterPatientAttendant_RegisterPatient FOREIGN KEY(rf_idRegisterPatient) REFERENCES dbo.t_RegisterPatient(id) on delete cascade
go
