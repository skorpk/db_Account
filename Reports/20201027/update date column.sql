USE PeopleAttach
GO
update dbo.t_CovidRegister20201026 SET 
			DateCreateRecord_Source2= convert(DATE,DateCreateRecord_Source,104) 
			,DateSetupDS1_Source2= convert(DATE,DateSetupDS1_Source,104) 
			,DR_Source2=convert(DATE,DR_Source,104) 
			,DateEnd_Source2=convert(DATE,DateEnd_Source,104) 
/*
ALTER TABLE dbo.t_CovidRegister20201026 ADD DateSetupDS1_Source2 DATE
go
ALTER TABLE dbo.t_CovidRegister20201026 ADD DateCreateRecord_Source2 DATE
GO
ALTER TABLE dbo.t_CovidRegister20201026 ADD DR_Source2 DATE
GO
ALTER TABLE dbo.t_CovidRegister20201026 ADD DateEnd_Source2 DATE
GO
ALTER TABLE dbo.t_CovidRegister20201026 ALTER COLUMN Amobulance_Source BIT
*/