USE AccountOMS
go
CREATE PROCEDURE [dbo].[usp_InsertTmpFileSynchFin]
as
TRUNCATE TABLE tmp_FileSynchFin
INSERT tmp_FileSynchFin
SELECT f.id
FROM dbo.t_File	f LEFT JOIN dbo.t_FileSynchFin fs ON
			f.id=fs.rf_idFile
WHERE fs.rf_idFile IS NULL
go

create PROCEDURE [dbo].[usp_InsertFileSynchFin]
as
INSERT dbo.t_FileSynchFin( rf_idFile, DateSynch ) 
SELECT rf_idFile,GETDATE() 
FROM dbo.tmp_FileSynchFin s
WHERE EXISTS(SELECT * FROM [SRVSQL2-ST1].AccountOMS.dbo.t_File WHERE id=s.rf_idFile)

TRUNCATE TABLE tmp_FileSynchFin
GO
-----------------------------------------------t_file---------------------------------
SELECT id,DateRegistration,FileVersion,DateCreate,FileNameHR,FileNameLR,CountSluch
FROM dbo.t_File	f inner JOIN dbo.tmp_FileSynchFin fs ON
			f.id=fs.rf_idFile
-----------------------------------------------t_RegistersAccounts---------------------------------
SELECT a.rf_idFiles,id,idRecord,rf_idMO,ReportYear,ReportMonth,NumberRegister,PrefixNumberRegister,PropertyNumberRegister
      ,DateRegister,rf_idSMO,AmountPayment,AmountPaymentAccept,rf_idRegisterCaseBack,Letter      
FROM dbo.tmp_FileSynchFin f INNER JOIN dbo.t_RegistersAccounts a ON
			f.rf_idFile=a.rf_idFiles
-----------------------------------------------t_RecordCasePatient---------------------------------
SELECT        r.id, r.rf_idRegistersAccounts, r.idRecord, r.IsNew, r.ID_Patient, r.rf_idF008, r.NewBorn, r.AttachLPU, r.SeriaPolis,r.NumberPolis,r.BirthWeight
FROM            tmp_FileSynchFin AS f INNER JOIN
                         t_RegistersAccounts AS a ON f.rf_idFile = a.rf_idFiles INNER JOIN
                         t_RecordCasePatient AS r ON a.id = r.rf_idRegistersAccounts
-----------------------------------------------t_PatientSMO---------------------------------
SELECT p.rf_idRecordCasePatient, p.rf_idSMO, p.OGRN, p.OKATO, p.Name, p.ENP, p.ST_OKATO
FROM tmp_FileSynchFin AS f INNER JOIN t_RegistersAccounts AS a ON 
		f.rf_idFile = a.rf_idFiles 
                  INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient

-----------------------------------------------t_Case---------------------------------
SELECT        c.id, c.rf_idRecordCasePatient, c.idRecordCase, c.GUID_Case, c.rf_idV006, c.rf_idV008, c.rf_idDirectMO, c.HopitalisationType, c.rf_idMO, c.rf_idDepartmentMO, 
                         c.rf_idV002, c.IsChildTariff, c.NumberHistoryCase, c.DateBegin, c.DateEnd, c.rf_idV009, c.rf_idV012, c.rf_idV004, c.IsSpecialCase, c.rf_idV010, c.AmountPayment, 
                         c.TypePay, c.AmountPaymentAccept, c.Comments, c.Age,  c.Emergency, c.rf_idV014, c.rf_idV018, c.rf_idV019, c.rf_idSubMO, c.rf_idDoctor,
c.IsFirstDS, c.IsNeedDisp, c.TypeTranslation, c.IT_SL
FROM            tmp_FileSynchFin AS f INNER JOIN
                         t_RegistersAccounts AS a ON f.rf_idFile = a.rf_idFiles INNER JOIN
                         t_RecordCasePatient AS r ON a.id = r.rf_idRegistersAccounts INNER JOIN
                         t_Case AS c ON r.id = c.rf_idRecordCasePatient
-----------------------------------------------t_Mes---------------------------------
SELECT  m.MES ,m.rf_idCase ,m.TypeMES ,m.Quantity ,m.Tariff
FROM            tmp_FileSynchFin AS f INNER JOIN
                         t_RegistersAccounts AS a ON f.rf_idFile = a.rf_idFiles INNER JOIN
                         t_RecordCasePatient AS r ON a.id = r.rf_idRegistersAccounts INNER JOIN
                         t_Case AS c ON r.id = c.rf_idRecordCasePatient
							INNER JOIN dbo.t_MES m ON
							c.id=m.rf_idCase
-----------------------------------------------t_Meduslugi---------------------------------
SELECT   d.rf_idCase ,
        d.id ,
        d.GUID_MU ,
        d.rf_idMO ,
        d.rf_idSubMO ,
        d.rf_idDepartmentMO ,
        d.rf_idV002 ,
        d.IsChildTariff ,
        d.DateHelpBegin ,
        d.DateHelpEnd ,
        d.DiagnosisCode ,
        d.MUGroupCode ,
        d.MUUnGroupCode ,
        d.MUCode ,
        d.Quantity ,
        d.Price ,
        d.TotalPrice ,
        d.rf_idV004 ,
        d.rf_idDoctor ,
        d.Comments ,
        d.MUSurgery ,
        d.IsNeedUsl
FROM  dbo.tmp_FileSynchFin AS f INNER JOIN t_RegistersAccounts AS a ON 
				f.rf_idFile = a.rf_idFiles 
							INNER JOIN t_RecordCasePatient AS r ON 
				a.id = r.rf_idRegistersAccounts 
							INNER JOIN t_Case AS c ON 
				r.id = c.rf_idRecordCasePatient
							INNER JOIN dbo.t_Meduslugi d ON
							c.id=d.rf_idCase