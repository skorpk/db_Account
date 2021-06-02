USE CanserRegister
GO
CREATE TABLE #tId(rf_idPeopleENP INT, ENP VARCHAR(20))

BEGIN TRANSACTION

INSERT dbo.t_PeopleEnp( ENP ,Fam ,Im ,Ot ,Dr ,Sex ,TypeSearch)
OUTPUT INSERTED.id, INSERTED.ENP INTO #tId
SELECT  ENP ,Fam ,Im ,Ot ,Dr ,Sex ,TypeSearch FROM tmp_PeopleENP 

INSERT dbo.t_PeopleDS_ONK( rf_idPeopleENP ,DS_ONK ,DateDS_ONK)
SELECT d.rf_idPeopleENP,p.DS_ONK,p.DateDS_ONK
FROM #tId d INNER JOIN dbo.tmp_PeopleDS_ONK p ON
			d.ENP = p.ENP

INSERT dbo.t_PeopleBiopsy( rf_idPeopleENP, DirectionDate )
SELECT d.rf_idPeopleENP,p.DirectionDate
FROM #tId d INNER JOIN dbo.tmp_PeopleBiopsy p ON
			d.ENP = p.ENP

INSERT dbo.t_PeopleDiagnosis( rf_idPeopleENP,DateSetup,DiagnosisCode)
SELECT d.rf_idPeopleENP,p.DateSetup,p.DiagnosisCode
FROM #tId d INNER JOIN dbo.tmp_PeopleDiagnosis p ON
			d.ENP = p.ENP


TRUNCATE TABLE dbo.t_PeoplePCEL
INSERT dbo.t_PeoplePCEL( rf_idPeopleENP, DateEnd )
 SELECT d.id,p.DateEnd
 FROM dbo.t_PeopleEnp d INNER JOIN dbo.tmp_PeoplePCEL p ON
			d.ENP = p.ENP

TRUNCATE TABLE dbo.t_PeopleONK_USL 
INSERT dbo.t_PeopleONK_USL( rf_idPeopleENP,DateEnd,USL_TIP)
 SELECT d.id,p.DateEnd,USL_TIP
 FROM dbo.t_PeopleEnp d INNER JOIN dbo.tmp_PeopleONK_USL p ON
			d.ENP = p.ENP

TRUNCATE TABLE dbo.t_PeopleSMO
INSERT dbo.t_PeopleSMO( rf_idPeopleENP, CodeSMO)
 SELECT d.id,p.CodeSMO
 FROM dbo.t_PeopleEnp d INNER JOIN dbo.tmp_PeopleSMO p ON
			d.ENP = p.ENP

ROLLBACK
GO
DROP TABLE #tId