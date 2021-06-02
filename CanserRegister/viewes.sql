USE CanserRegister
go
CREATE VIEW vw_PeopleONK_USL
as
SELECT u.rf_idPeopleENP, u.USL_TIP,n13.TLech_NAME,u.DateEnd
FROM t_PeopleONK_USL u INNER JOIN oms_nsi.dbo.sprN013 n13 ON
			u.USL_TIP=n13.sprN013Id

GO
CREATE VIEW vw_PeopleSMO
AS
SELECT s.rf_idPeopleENP,s.CodeSMO,ss.sNameS
FROM dbo.t_PeopleSMO s INNER JOIN oms_nsi.dbo.tSMO ss ON
		s.CodeSMO=ss.smocod
GO
CREATE VIEW vw_PeopleNAPR
AS
SELECT s.rf_idPeopleENP,s.NAPR_DATE,s.rf_idV029,v29.N_MET
FROM dbo.t_PeopleNAPR s INNER JOIN oms_nsi.dbo.sprV029 v29 ON
		s.rf_idV029=v29.IDMET
GO
alter VIEW vw_PeopleDiagnosis
AS
SELECT s.rf_idPeopleENP,s.DateSetup,RTRIM(s.DiagnosisCode)+' - '+mkb.Diagnosis AS Diagnosis
FROM dbo.t_PeopleDiagnosis s INNER JOIN dbo.vw_sprMKB10 mkb ON
		s.DiagnosisCode=mkb.DiagnosisCode
GO
create VIEW vw_PeopleSTAD
AS
SELECT  s.rf_idPeopleENP ,
        s.SATD ,
        s.rf_idCase,n2.KOD_St
FROM t_PeopleSTAD s INNER JOIN oms_nsi.dbo.sprN002 n2 ON
			s.SATD=n2.ID_St
GO