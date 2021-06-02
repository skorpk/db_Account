use AccountOMS
go
if OBJECT_ID('usp_GetFiles',N'P') is not null
drop proc usp_GetFiles
go
--данные для формы отображающей файлы входящие
create proc usp_GetFiles
			@year smallint
as

declare @startDate datetime=cast(@year as char(4))+'0101',
		@yearPrev smallint=@year-1
		
declare @startPrevDate datetime=cast(@yearPrev as char(4))+'0101',
		@dateRegEnd datetime=cast(@year as char(4))+'1231 23:59:59'
IF @year=YEAR(GETDATE())
BEGIN
	select a.id,a.FileNameHR,a.Account,a.DateAccount,a.Summa
				,s.sNameS as SMO,
				l.NameS as LPU,a.IsUnLoadToSMO,
				s.smocod
				,l.FilialId as CodeFilial
				,l.filialName
				,DateReg
				,ReportMonth
				,ReportYear
	from(
			select f.id,rtrim(f.FileNameHR) as FileNameHR,a.Account
				,a.DateRegister as DateAccount,
				a.AmountPayment as Summa
				,a.PrefixNumberRegister
				,f.CodeM
						,case when fe.rf_idFile is null then 'Нет' else 'Да' end as IsUnLoadToSMO
						,f.DateRegistration as DateReg
						,a.ReportMonth
						,a.ReportYear					
			from t_File f inner join t_RegistersAccounts a on
						f.id=a.rf_idFiles
						and f.DateRegistration>=@startDate and f.DateRegistration<=@dateRegEnd
						and a.ReportYear>=@yearPrev and a.ReportYear<=@year
						and a.ReportMonth>0 and a.ReportMonth<13
							left join t_FileExit fe on
						f.id=fe.rf_idFile	
					
				) a	inner join vw_sprSMO s on
						a.PrefixNumberRegister=s.smocod
					inner join vw_sprT001 l on
						a.CodeM=l.CodeM
	order by a.id
END
ELSE
BEGIN 
	select a.id,a.FileNameHR,a.Account,a.DateAccount,a.Summa
				,s.sNameS as SMO,
				l.NameS as LPU,a.IsUnLoadToSMO,
				s.smocod
				,l.FilialId as CodeFilial
				,l.filialName
				,DateReg
				,ReportMonth
				,ReportYear
	from(
			select f.id,rtrim(f.FileNameHR) as FileNameHR,a.Account
				,a.DateRegister as DateAccount,
				a.AmountPayment as Summa
				,a.PrefixNumberRegister
				,f.CodeM
						,case when fe.rf_idFile is null then 'Нет' else 'Да' end as IsUnLoadToSMO
						,f.DateRegistration as DateReg
						,a.ReportMonth
						,a.ReportYear					
			from t_File f inner join t_RegistersAccounts a on
						f.id=a.rf_idFiles
						and f.DateRegistration>=@startPrevDate and f.DateRegistration<=@dateRegEnd
						and a.ReportYear>=@yearPrev and a.ReportYear<=@year
						and a.ReportMonth>0 and a.ReportMonth<13
							left join t_FileExit fe on
						f.id=fe.rf_idFile	
					
				) a	inner join vw_sprSMO s on
						a.PrefixNumberRegister=s.smocod
					inner join vw_sprT001 l on
						a.CodeM=l.CodeM
	order by a.id
END
go
			
