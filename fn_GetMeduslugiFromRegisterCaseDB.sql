use AccountOMS
go		
IF OBJECT_ID (N'dbo.fn_GetMeduslugiFromRegisterCaseDB', N'TF') IS NOT NULL
    DROP FUNCTION dbo.fn_GetMeduslugiFromRegisterCaseDB
go
CREATE FUNCTION dbo.fn_GetMeduslugiFromRegisterCaseDB(@account varchar(15),@rf_idF003 char(6),@month tinyint,@year smallint)
RETURNS @meduslugi TABLE(
							GUID_Case uniqueidentifier NOT NULL,
							id int NOT NULL,
							GUID_MU uniqueidentifier NOT NULL,
							rf_idMO char(6) NOT NULL,
							rf_idV002 smallint NOT NULL,
							IsChildTariff bit NOT NULL,
							DateHelpBegin date NOT NULL,
							DateHelpEnd date NOT NULL,
							DiagnosisCode char(10) NOT NULL,
							MUCode varchar(16) NOT NULL,
							Quantity decimal(6, 2) NOT NULL,
							Price decimal(15, 2) NOT NULL,
							TotalPrice decimal(15, 2) NOT NULL,
							rf_idV004 int NOT NULL
						)
as
begin
		declare @number int,
				@property tinyint,
				@smo char(5)
				
		select @number=dbo.fn_NumberRegister(@account),@smo=dbo.fn_PrefixNumberRegister(@account),@property=dbo.fn_PropertyNumberRegister(@account)
		
		insert @meduslugi
		select c.GUID_Case,m.id,m.GUID_MU,m.rf_idMO,m.rf_idV002,m.IsChildTariff,m.DateHelpBegin,m.DateHelpEnd,m.DiagnosisCode,
		m.MUCode,m.Quantity,m.Price,m.TotalPrice,m.rf_idV004
		from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack reg on
						f.id=reg.rf_idFilesBack
						and f.CodeM=@rf_idF003 
											inner join RegisterCases.dbo.t_RecordCaseBack rec on
						reg.id=rec.rf_idRegisterCaseBack and
						--reg.ref_idF003=@rf_idF003 and
						reg.ReportMonth=@month and
						reg.ReportYear=@year and
						reg.NumberRegister=@number and
						reg.PropertyNumberRegister=@property
									inner join RegisterCases.dbo.t_PatientBack p on
						rec.id=p.rf_idRecordCaseBack 
						and	p.rf_idSMO=@smo
									inner join RegisterCases.dbo.t_CaseBack cb on
						rec.id=cb.rf_idRecordCaseBack and
						cb.TypePay=1
									inner join RegisterCases.dbo.t_Case c on
						rec.rf_idCase=c.id
									inner join RegisterCases.dbo.t_Meduslugi m on
						c.id=m.rf_idCase				
									left join RegisterCases.dbo.t_Mes mes on
						c.id=mes.rf_idCase
		where mes.rf_idCase is null
		--добавил медуслуги в связи с тем что ввели хирургический койко-день
		insert @meduslugi
		select c.GUID_Case,m.id,m.GUID_MU,m.rf_idMO,m.rf_idV002,m.IsChildTariff,m.DateHelpBegin,m.DateHelpEnd,m.DiagnosisCode,
		m.MUCode,m.Quantity,m.Price,m.TotalPrice,m.rf_idV004
		from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack reg on
						f.id=reg.rf_idFilesBack
						and f.CodeM=@rf_idF003 
											inner join RegisterCases.dbo.t_RecordCaseBack rec on
						reg.id=rec.rf_idRegisterCaseBack and
						reg.ReportMonth=@month and
						reg.ReportYear=@year and
						reg.NumberRegister=@number and
						reg.PropertyNumberRegister=@property
									inner join RegisterCases.dbo.t_PatientBack p on
						rec.id=p.rf_idRecordCaseBack 
						and	p.rf_idSMO=@smo
									inner join RegisterCases.dbo.t_CaseBack cb on
						rec.id=cb.rf_idRecordCaseBack and
						cb.TypePay=1
									inner join RegisterCases.dbo.t_Case c on
						rec.rf_idCase=c.id
									inner join RegisterCases.dbo.t_Meduslugi m on
						c.id=m.rf_idCase
									inner join RegisterCases.dbo.t_Mes mes on
						c.id=mes.rf_idCase
									inner join oms_NSI.dbo.V001 v on
						m.MUCode=v.IDRB
		insert @meduslugi ----добавление врачебных приемов
		select c.GUID_Case,m.id,m.GUID_MU,m.rf_idMO,m.rf_idV002,m.IsChildTariff,m.DateHelpBegin,m.DateHelpEnd,m.DiagnosisCode,
				m.MUCode,m.Quantity,m.Price,m.TotalPrice,m.rf_idV004
				from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack reg on
								f.id=reg.rf_idFilesBack
								and f.CodeM=@rf_idF003 
													inner join RegisterCases.dbo.t_RecordCaseBack rec on
								reg.id=rec.rf_idRegisterCaseBack and
								--reg.ref_idF003=@rf_idF003 and
								reg.ReportMonth=@month and
								reg.ReportYear=@year and
								reg.NumberRegister=@number and
								reg.PropertyNumberRegister=@property
											inner join RegisterCases.dbo.t_PatientBack p on
								rec.id=p.rf_idRecordCaseBack 
								and	p.rf_idSMO=@smo
											inner join RegisterCases.dbo.t_CaseBack cb on
								rec.id=cb.rf_idRecordCaseBack and
								cb.TypePay=1
											inner join RegisterCases.dbo.t_Case c on
								rec.rf_idCase=c.id
											inner join RegisterCases.dbo.t_Meduslugi m on
								c.id=m.rf_idCase					
											inner join RegisterCases.dbo.t_Mes mes on
								c.id=mes.rf_idCase
											inner join vw_sprMU mu on
								mes.MES=mu.MU							
		where mu.MUGroupCode=2 and mu.MUUnGroupCode=78
						
RETURN
end;
GO