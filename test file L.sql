use AccountOMS
go
--подготовка 
declare @patient xml,
		@ipatient int
		
declare @account varchar(15)='34001-27-1',
		@codeMO char(6)='255416',
		@month tinyint=6,
		@year smallint=2012


SELECT	@patient=LRM.PERS_LIST				
FROM	OPENROWSET(BULK 'c:\Test\20120203\LM255416S34001_120610.xml',SINGLE_BLOB) LRM (PERS_LIST)

create table #t8
(
	ID_PAC nvarchar(36),
	FAM nvarchar(40),
	IM nvarchar(40),
	OT nvarchar(40),
	W tinyint,
	DR date,
	FAM_P nvarchar(40),
	IM_P nvarchar(40),
	OT_P nvarchar(40),
	W_P tinyint,
	DR_P date,
	MR nvarchar(100),
	DOCTYPE nchar(2),
	DOCSER nchar(10),
	DOCNUM nchar(20),
	SNILS nchar(14),
	OKATOG nchar(11),
	OKATOP nchar(11),
	COMENTP nvarchar(250)
)

-----------обоработка xml файла с людьми
EXEC sp_xml_preparedocument @ipatient OUTPUT, @patient
	
insert #t8
SELECT ID_PAC,FAM,IM,OT,W,replace(DR,'-',''),FAM_P,IM_P,OT_P,W_P,replace(DR_P,'-',''),MR,DOCTYPE,DOCSER,DOCNUM,SNILS,OKATOG,OKATOP,COMENTP
FROM OPENXML (@ipatient, 'PERS_LIST/PERS',2)
	WITH(
			ID_PAC NVARCHAR(36),
			FAM NVARCHAR(40),
			IM NVARCHAR(40),
			OT NVARCHAR(40),
			W TINYINT,
			DR NCHAR(10),
			FAM_P NVARCHAR(40),
			IM_P NVARCHAR(40),
			OT_P NVARCHAR(40),
			W_P TINYINT,
			DR_P NCHAR(10),
			MR NVARCHAR(100),
			DOCTYPE NCHAR(2),
			DOCSER NCHAR(10),
			DOCNUM NCHAR(20),
			SNILS NCHAR(14),
			OKATOG NCHAR(11),
			OKATOP NCHAR(11),
			COMENTP NVARCHAR(250)
		)		
EXEC sp_xml_removedocument @ipatient

---сам тест
declare @number int,
		@property tinyint,
		@smo char(5)
		
select @number=dbo.fn_NumberRegister(@account),@smo=dbo.fn_PrefixNumberRegister(@account),@property=dbo.fn_PropertyNumberRegister(@account)

declare @idf int
		
select top 1 @idf=f.rf_idFiles
from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack a on 
			f.id=a.rf_idFilesBack
			and f.CodeM=@codeMO
			and a.NumberRegister=@number
			and a.PropertyNumberRegister=@property

select COUNT(*) 
from(
		select distinct r1.ID_Patient,rp.Fam,rp.Im,rp.Ot,rp.rf_idV005 as W,rp.BirthDay as DR,ra.Fam as Fam_P, ra.Im as IM_P, ra.Ot as Ot_P,ra.rf_idV005 as W_P,
		      ra.BirthDay as DR_P, rp.BirthPlace as MR, doc.rf_idDocumentType as DOCTYPE, doc.SeriaDocument as DOCSER, doc.NumberDocument as DOCNUM, 
		      doc.SNILS, doc.OKATO as OKATOG, doc.OKATO_Place as OKATOP
		from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack a on 
			f.id=a.rf_idFilesBack
			and f.rf_idFiles=@idF			
								inner join RegisterCases.dbo.t_RecordCaseBack r on
			a.id=r.rf_idRegisterCaseBack
			and r.TypePay=1
								inner join RegisterCases.dbo.t_RecordCase r1 on
			r.rf_idRecordCase=r1.id
								inner join RegisterCases.dbo.t_PatientBack p on
			r.id=p.rf_idRecordCaseBack
			and p.rf_idSMO=@smo
								inner join RegisterCases.dbo.t_RefRegisterPatientRecordCase rf on				
			r1.id=rf.rf_idRecordCase
								inner join RegisterCases.dbo.t_RegisterPatient rp on
			rf.rf_idRegisterPatient=rp.id
			and rp.rf_idFiles=@idF
								left join RegisterCases.dbo.t_RegisterPatientAttendant ra on
			rp.id=ra.rf_idRegisterPatient
								left join RegisterCases.dbo.t_RegisterPatientDocument doc on
			rp.id=doc.rf_idRegisterPatient
	) t inner join #t8 t1 on
		t.ID_Patient=t1.ID_PAC
		and t.FAM =t1.FAM 
		and t.IM =t1.IM 
		and t.OT=t1.OT 
		and t.W =t1.W 
		and t.DR =t1.DR 
		and isnull(t.FAM_P,'')=isnull(t1.FAM_P,'')
		and isnull(t.FAM_P,'')=isnull(t1.FAM_P,'')
		and isnull(t.OT_P,'') =isnull(t1.OT_P,'') 
		and isnull(t.W_P,'') =isnull(t1.W_P,'') 
		and isnull(t.DR_P,'') =isnull(t1.DR_P,'') 
		and isnull(t.MR,'') =isnull(t1.MR,'') 
		and isnull(t.DOCTYPE,'')=isnull(t1.DOCTYPE,'')
		and isnull(t.DOCSER,'') =isnull(t1.DOCSER,'') 
		and isnull(t.DOCNUM,'') =isnull(t1.DOCNUM,'') 
		and isnull(t.SNILS,'') =isnull(t1.SNILS,'') 
		and isnull(t.OKATOG,'') =isnull(t1.OKATOG,'') 
		and isnull(t.OKATOP,'') =isnull(t1.OKATOP,'') 

select COUNT(*) from #t8
go
drop table #t8