use AccountOMS
go
declare @account varchar(15)='34001-408-1',
		@rf_idF003 char(6)='161015',
		@month tinyint=6,
		@year smallint=2012

--разбираем номер счета на код СМО, и номер реестра СП и ТК
declare @number int,
		@property tinyint,
		@smo char(5)
		
select @number=dbo.fn_NumberRegister(@account),@smo=dbo.fn_PrefixNumberRegister(@account),@property=dbo.fn_PropertyNumberRegister(@account)

declare @idFile int
select top 1 @idFile=f.rf_idFiles
from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack a on 
			f.id=a.rf_idFilesBack
			and f.CodeM=@rf_idF003
			and a.NumberRegister=@number
			and a.PropertyNumberRegister=@property

select r1.ID_Patient,rp.Fam,rp.Im,rp.Ot,rp.rf_idV005 as W,rp.BirthDay,ra.Fam as Fam_P, ra.Im as IM_P, ra.Ot as Ot_P,ra.rf_idV005 as W_P,
		ra.BirthDay as DR_P, rp.BirthPlace, doc.rf_idDocumentType, doc.SeriaDocument, doc.NumberDocument, doc.SNILS, doc.OKATO, doc.OKATO_Place
from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack a on 
			f.id=a.rf_idFilesBack
			and f.CodeM=@rf_idF003
			and a.NumberRegister=@number
			and a.PropertyNumberRegister=@property
								inner join RegisterCases.dbo.t_RecordCaseBack r on
			a.id=r.rf_idRegisterCaseBack
								inner join RegisterCases.dbo.t_RecordCase r1 on
			r.rf_idRecordCase=r1.id
								inner join RegisterCases.dbo.t_PatientBack p on
			r.id=p.rf_idRecordCaseBack
			and p.rf_idSMO=@smo
								inner join RegisterCases.dbo.t_RegisterPatient rp on
			r1.id=rp.rf_idRecordCase
			and rp.rf_idFiles=@idFile
								left join RegisterCases.dbo.t_RegisterPatientAttendant ra on
			rp.id=ra.rf_idRegisterPatient
								left join RegisterCases.dbo.t_RegisterPatientDocument doc on
			rp.id=doc.rf_idRegisterPatient