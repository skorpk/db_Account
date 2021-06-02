USE PlanDD
GO
IF OBJECT_ID('t_Case_173N_Profil') IS NOT NULL
DROP TABLE t_Case_173N_Profil
go
CREATE TABLE t_Case_173N_Profil
(
	CodeM CHAR(6) NOT null, 
	ENP VARCHAR(20) NOT null,
	DateRegistration DATETIME NOT null,
	ReportYear SMALLINT NOT null,
	ReportMonth TINYINT NOT null
)
go