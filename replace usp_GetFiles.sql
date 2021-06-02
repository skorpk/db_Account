USE AccountOMS
GO
DECLARE @year SMALLINT=2016

declare @startDate datetime=cast(@year as char(4))+'0101',
		@yearPrev smallint=@year-1
		

DROP TABLE dbo.t_FileAccounts

CREATE NONCLUSTERED INDEX IX_ReportYear ON dbo.t_FileAccounts(ReportYear) 
INCLUDE(id ,FileNameHR ,Account ,DateAccount ,Summa ,SMO ,LPU ,IsUnLoadToSMO ,smocod ,CodeFilial ,filialName ,DateReg ,ReportMonth)

select a.id,a.FileNameHR,a.Account,a.DateAccount,a.Summa
			,s.sNameS as SMO,
			l.NameS as LPU,a.IsUnLoadToSMO,
			s.smocod
			,l.FilialId as CodeFilial
			,l.filialName
			,DateReg
			,ReportMonth
			,ReportYear
INTO t_FileAccounts
from(
	------------------------------------------------------------
	select f.id,rtrim(f.FileNameHR) as FileNameHR,a.Account,a.DateRegister as DateAccount,a.AmountPayment as Summa
			,a.PrefixNumberRegister,f.CodeM,'Да' as IsUnLoadToSMO,f.DateRegistration as DateReg,a.ReportMonth,a.ReportYear					
		from t_File f inner join t_RegistersAccounts a on
					f.id=a.rf_idFiles
					and f.DateRegistration>=@startDate and f.DateRegistration<=GETDATE()
					and a.ReportYear>=@year
					--and a.ReportMonth>0 and a.ReportMonth<13
						inner join t_FileExit fe on
					f.id=fe.rf_idFile
		UNION ALL
		select f.id,rtrim(f.FileNameHR) as FileNameHR,a.Account,a.DateRegister as DateAccount,a.AmountPayment as Summa
			,a.PrefixNumberRegister,f.CodeM,'Нет' as IsUnLoadToSMO,f.DateRegistration as DateReg,a.ReportMonth,a.ReportYear					
		from t_File f inner join t_RegistersAccounts a on
					f.id=a.rf_idFiles
					and f.DateRegistration>=@startDate and f.DateRegistration<=GETDATE()
					and a.ReportYear>=@year
					--and a.ReportMonth>0 and a.ReportMonth<13
		WHERE NOT EXISTS(SELECT 1 FROM dbo.t_FileExit WHERE rf_idFile=f.id)
	) a	inner join vw_sprSMO s on
					a.PrefixNumberRegister=s.smocod
				inner join vw_sprT001 l on
					a.CodeM=l.CodeM
order by a.id