USE CanserRegister
GO

ALTER TABLE dbo.t_PeopleEnp ADD BirthYear AS YEAR(Dr) 
go
CREATE NONCLUSTERED INDEX IX_BirthDay ON dbo.t_PeopleEnp(BirthYear)
GO
CREATE NONCLUSTERED INDEX IX_Sex ON dbo.t_PeopleEnp(Sex)
GO
CREATE NONCLUSTERED INDEX IX_Diagnosis ON dbo.t_PeopleDiagnosis(DiagnosisCode)