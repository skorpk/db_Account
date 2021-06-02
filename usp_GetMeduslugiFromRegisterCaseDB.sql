use AccountOMS
go
if OBJECT_ID('usp_GetMeduslugiFromRegisterCaseDB',N'P') is not null
drop proc usp_GetMeduslugiFromRegisterCaseDB
go
create procedure usp_GetMeduslugiFromRegisterCaseDB
		@account varchar(15)
		--,@rf_idF003 char(6)
		--,@month tinyint
		--,@year smallint
AS
		declare /*@number int,
				@property tinyint,
				@smo char(5),*/
				@letter CHAR(1)
				
		select --@number=dbo.fn_NumberRegister(@account),@smo=dbo.fn_PrefixNumberRegister(@account),@property=dbo.fn_PropertyNumberRegister(@account),
				@letter=dbo.fn_LetterNumberRegister(@account)	
				
		CREATE TABLE #case1(id BIGINT, GUID_Case UNIQUEIDENTIFIER,IsCompletedCase TINYINT,DateEnd date,rf_idV006 tinyint)
		INSERT #case1( id, GUID_Case, IsCompletedCase,DateEnd,rf_idV006 )
		SELECT c.id,c.GUID_Case,c.IsCompletedCase,c.DateEnd,c.rf_idV006
		from #Case c0 inner join RegisterCases.dbo.t_Case c on
						c0.id=c.id										
		------------------------------------------------------------------------------------------------------------
		insert #meduslugi
		select c.GUID_Case,m.id,m.GUID_MU,m.rf_idMO,m.rf_idV002,m.MUSurgery,m.IsChildTariff,m.DateHelpBegin,m.DateHelpEnd,m.DiagnosisCode,
		m.MUCode,m.Quantity,m.Price,m.TotalPrice,m.rf_idV004,m.Comments
		from #case1 c inner join RegisterCases.dbo.t_Meduslugi m on
				c.id=m.rf_idCase				
				--AND c.IsCompletedCase=0
						INNER JOIN vw_sprMuWithParamAccount mu ON
				m.MUCode=mu.MU
		WHERE ISNULL(mu.AccountParam,@letter)=@letter
		------------------------------------------------------------------------------------------------------------
		--добавил медуслуги в связи с тем что ввели хирургический койко-день
		insert #meduslugi
		select c.GUID_Case,m.id,m.GUID_MU,m.rf_idMO,m.rf_idV002,m.MUSurgery,m.IsChildTariff,m.DateHelpBegin,m.DateHelpEnd,m.DiagnosisCode,
		m.MUCode,m.Quantity,m.Price,m.TotalPrice,m.rf_idV004,m.Comments
		from #case1 c inner join RegisterCases.dbo.t_Meduslugi m on
						c.id=m.rf_idCase
						--			inner join RegisterCases.dbo.t_Mes mes on
						--c.id=mes.rf_idCase
									inner join oms_NSI.dbo.V001 v on
						m.MUCode=v.IDRB
		------------------------------------------------------------------------------------------------------------				
		insert #meduslugi ----добавление врачебных приемов
		select c.GUID_Case,m.id,m.GUID_MU,m.rf_idMO,m.rf_idV002,m.MUSurgery,m.IsChildTariff,m.DateHelpBegin,m.DateHelpEnd,m.DiagnosisCode,
				m.MUCode,m.Quantity,m.Price,m.TotalPrice,m.rf_idV004,m.Comments
		from #case1 c inner join RegisterCases.dbo.t_Meduslugi m on
								c.id=m.rf_idCase					
											inner join RegisterCases.dbo.vw_mes_2_78 mes on
								c.id=mes.rf_idCase
		------------------------------------------------------------------------------------------------------------								
		insert #meduslugi ----добавление случаев по диспансеризации
		select c.GUID_Case,m.id,m.GUID_MU,m.rf_idMO,m.rf_idV002,m.MUSurgery,m.IsChildTariff,m.DateHelpBegin,m.DateHelpEnd,m.DiagnosisCode,
				m.MUCode,m.Quantity,m.Price,m.TotalPrice,m.rf_idV004,m.Comments
		from #case1 c inner join RegisterCases.dbo.t_Meduslugi m on
								c.id=m.rf_idCase					
											inner join RegisterCases.dbo.vw_ClinicalExamination mes ON
								c.id=mes.rf_idCase
		------------------------------------------------------------------------------------------------------------						
		insert #meduslugi ----добавление случаев по дневному стационару, с 01.04.2013 дневной стационар идет как ЗС
		select c.GUID_Case,m.id,m.GUID_MU,m.rf_idMO,m.rf_idV002,m.MUSurgery,m.IsChildTariff,m.DateHelpBegin,m.DateHelpEnd,m.DiagnosisCode,
				m.MUCode,m.Quantity,m.Price,m.TotalPrice,m.rf_idV004,m.Comments
		from #case1 c inner join RegisterCases.dbo.t_Meduslugi m on
								c.id=m.rf_idCase					
											inner join RegisterCases.dbo.t_Mes mes on
								c.id=mes.rf_idCase																			
		WHERE c.DateEnd>='20130401' and c.rf_idV006=2
		
DROP TABLE #case1
GO