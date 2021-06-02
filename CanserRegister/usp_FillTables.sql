USE CanserRegister
GO
alter PROCEDURE usp_FillTables
AS


INSERT dbo.t_PeopleEnp( ENP ,Fam ,Im ,Ot ,Dr ,Sex ,TypeSearch)
SELECT  ENP ,Fam ,Im ,Ot ,Dr ,Sex ,TypeSearch FROM tmp_PeopleENP 
-----------------------------------FillHistory------------------------------
INSERT dbo.t_HistPeopleEnp( rf_idPeopleENP ,Fam ,Im ,Ot ,Dr)
SELECT p.id,p.Fam,p.Im,p.Ot,p.Dr
FROM dbo.t_PeopleEnp p INNER JOIN tmp_PeopleENP tp ON
			p.ENP=tp.ENP
WHERE p.Fam<>tp.Fam OR p.Im<>tp.Im OR p.Ot<>tp.Ot OR p.Dr<>tp.DR
IF @@ROWCOUNT>0
begin
	UPDATE p SET p.Fam=tp.Fam,p.Im=tp.Im,p.Ot=tp.Ot,p.Dr=tp.Dr
	FROM dbo.t_PeopleEnp p INNER JOIN tmp_PeopleENP tp ON
				p.ENP=tp.ENP
	WHERE p.Fam<>tp.Fam OR p.Im<>tp.Im OR p.Ot<>tp.Ot OR p.Dr<>tp.DR
end

---------------------------------------------------------------------

INSERT dbo.t_PeopleDS_ONK( rf_idPeopleENP ,DS_ONK ,DateDS_ONK,rf_idCase)
SELECT d.id,p.DS_ONK,p.DateDS_ONK,p.rf_idCase
FROM t_PeopleEnp d INNER JOIN dbo.tmp_PeopleDS_ONK p ON
			d.ENP = p.ENP

INSERT dbo.t_PeopleBiopsy( rf_idPeopleENP, DirectionDate,rf_idCase )
SELECT d.id,p.DirectionDate,rf_idCase
FROM t_PeopleEnp d INNER JOIN dbo.tmp_PeopleBiopsy p ON
			d.ENP = p.ENP

INSERT dbo.t_PeopleDiagnosis( rf_idPeopleENP,DateSetup,DiagnosisCode,rf_idCase)
SELECT d.id,p.DateSetup,p.DiagnosisCode,rf_idCase
FROM t_PeopleEnp d INNER JOIN dbo.tmp_PeopleDiagnosis p ON
			d.ENP = p.ENP


TRUNCATE TABLE dbo.t_PeoplePCEL
INSERT dbo.t_PeoplePCEL( rf_idPeopleENP, DateEnd,rf_idCase )
 SELECT d.id,p.DateEnd,rf_idCase
 FROM dbo.t_PeopleEnp d INNER JOIN dbo.tmp_PeoplePCEL p ON
			d.ENP = p.ENP

TRUNCATE TABLE dbo.t_PeopleONK_USL 
INSERT dbo.t_PeopleONK_USL( rf_idPeopleENP,DateEnd,USL_TIP,rf_idCase)
 SELECT d.id,p.DateEnd,USL_TIP,rf_idCase
 FROM dbo.t_PeopleEnp d INNER JOIN dbo.tmp_PeopleONK_USL p ON
			d.ENP = p.ENP

TRUNCATE TABLE dbo.t_PeopleSMO
INSERT dbo.t_PeopleSMO( rf_idPeopleENP, CodeSMO,rf_idCase)
 SELECT d.id,p.CodeSMO,rf_idCase
 FROM dbo.t_PeopleEnp d INNER JOIN dbo.tmp_PeopleSMO p ON
			d.ENP = p.ENP


INSERT dbo.t_PeopleSTAD( rf_idPeopleENP, SATD, rf_idCase )
SELECT d.id,p.SATD,p.rf_idCase
FROM dbo.t_PeopleEnp d INNER JOIN dbo.tmp_PeopleSTAD p ON
			d.ENP = p.ENP

TRUNCATE TABLE dbo.t_PeopleNAPR

INSERT dbo.t_PeopleNAPR( rf_idPeopleENP ,NAPR_DATE ,rf_idCase ,rf_idV029)
SELECT d.id,p.NAPR_DATE,p.rf_idCase,p.rf_idV029
FROM dbo.t_PeopleEnp d INNER JOIN dbo.tmp_PeopleNAPR p ON
			d.ENP = p.ENP
						INNER JOIN dbo.t_PeopleDS_ONK dd ON
			d.id=dd.rf_idPeopleENP                      

--TRUNCATE TABLE dbo.t_PeopleEND

INSERT dbo.t_PeopleEND( rf_idPeopleENP ,DateFinde ,DateEnd ,typeEnd)
SELECT d.id,GETDATE(),p.DateEnd,p.typeEnd
FROM dbo.t_PeopleEnp d INNER JOIN dbo.tmp_PeopleEND p ON
			d.ENP = p.ENP
					

INSERT dbo.t_PeopleCase( ENP ,rf_idCase ,Account ,DateRegistr ,CodeM ,NumberCase ,DS1 ,DateBegin ,DateEnd ,DS_ONK ,USL_OK ,rf_idv008 ,rf_idV009 ,P_CEL ,DN)
SELECT ENP ,rf_idCase ,Account ,DateRegistr ,CodeM ,NumberCase ,DS1 ,DateBegin ,DateEnd ,DS_ONK ,USL_OK ,rf_idv008 ,rf_idV009 ,P_CEL ,DN
FROM tmp_PeopleCase

INSERT dbo.t_PeopleMES( Enp, rf_idCase, MES, TypeMES )
SELECT Enp, rf_idCase, MES, TypeMES 
FROM tmp_PeopleMES
go
