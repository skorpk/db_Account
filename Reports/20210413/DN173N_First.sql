USE PlanDD
GO
CREATE TABLE dbo.DN173N_First
(
ENP varchar (16) COLLATE Cyrillic_General_CI_AS NULL,
DATE_F date NULL,
rf_D02Person int NOT NULL,
DS char (6) COLLATE Cyrillic_General_CI_AS NOT NULL,
CODEM varchar (6) COLLATE Cyrillic_General_CI_AS NULL,
Age int NULL,
sex_ENP int NULL,
Sex AS (case when sex_ENP=(1) then 'Ì' else 'Æ' end),
flag tinyint NULL,
ReportYear smallint NOT NULL ,
DateRegistration datetime NULL
) 
GO
CREATE NONCLUSTERED INDEX IX_ENP ON dbo.DN173N_First (ENP) INCLUDE (Age, sex_ENP) 
GO
