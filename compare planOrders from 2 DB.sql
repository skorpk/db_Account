use AccountOMS
go
/*
select * 
from (
select c.GUID_Case,c.DateBegin,c.DateEnd
from RegisterCases.dbo.t_File f inner join RegisterCases.dbo.t_RegistersCase a on
		f.id=a.rf_idFiles
		 	  inner join RegisterCases.dbo.t_RecordCase r on
		a.id=r.rf_idRegistersCase
		 	  inner join RegisterCases.dbo.t_Case c on
		r.id=c.rf_idRecordCase
where f.CodeM='141016' and a.ReportYear=2012
	) t1 inner join (
					select c.GUID_Case,c.DateBegin,c.DateEnd
					from t_File f inner join t_RegistersAccounts a on
							f.id=a.rf_idFiles
		 						  inner join t_RecordCasePatient r on
							a.id=r.rf_idRegistersAccounts
		 						  inner join t_Case c on
							r.id=c.rf_idRecordCasePatient
					where f.CodeM='141016' and a.ReportYear=2012
					) t2 on
	t1.GUID_Case=t2.GUID_Case
	and t1.DateBegin<>t2.DateBegin
	and t1.DateEnd=t2.DateEnd
*/

declare @month tinyint=6,
		@year smallint=2012,
		@codeM char(6)='141016'
		
declare @dateCreate datetime='20120715',
		@monthMin tinyint=1,
		@monthMax tinyint=6,
		@codeLPU char(6)='141016'
		
select *
from (
	select c.rf_idMO
			,r.NumberRegister
			,c.GUID_Case
			,t1.unitCode
			,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
	from t_Case c inner join (
								select rf_idCase,GUID_MU,MUCode,MUGroupCode,MUUnGroupCode,Quantity,IsChildTariff
								from t_Meduslugi
								group by rf_idCase,GUID_MU,MUCode,MUGroupCode,MUUnGroupCode,Quantity,IsChildTariff
							 ) m on
					c.id=m.rf_idCase 
					and c.rf_idMO=@codeM
							inner join dbo.vw_sprMU t1 on
					m.MUGroupCode=t1.MUGroupCode
					and m.MUUnGroupCode=t1.MUUnGroupCode
					and m.MUCode=t1.MUCode
					and t1.unitCode=1
							inner join t_RecordCasePatient rc on
					c.rf_idRecordCasePatient=rc.id
							inner join t_RegistersAccounts r on
					rc.rf_idRegistersAccounts=r.id and
					r.ReportMonth>0 and r.ReportMonth<=@month and
					r.ReportYear=@year		
					and r.NumberRegister=55	
							inner join (select * from vw_sprSMO where smocod<>'34') s on
					r.rf_idSMO=s.smocod				
	group by c.rf_idMO,r.NumberRegister,c.GUID_Case,t1.unitCode	
		) t1 inner join (
						select c.rf_idMO
								,r.NumberRegister
								,c.GUID_Case
								,t1.unitCode
								,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
						from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack r on
										f.id=r.rf_idFilesBack		
										and f.DateCreate<=@dateCreate
												  inner join RegisterCases.dbo.t_RecordCaseBack cb on
										cb.rf_idRegisterCaseBack=r.id and
										r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
										r.ReportYear=@year
										and cb.TypePay=1
										and r.NumberRegister=55
												inner join RegisterCases.dbo.t_Case c on
										c.id=cb.rf_idCase
												inner join RegisterCases.dbo.vw_MeduslugiMes m on
										c.id=m.rf_idCase and c.rf_idMO=@codeLPU
												inner join RegisterCases.dbo.vw_sprMU t1 on
										m.MUCode=t1.MU			
										and t1.unitCode=1
												inner join (
															select rf_idRecordCaseBack,rf_idSMO 
															from RegisterCases.dbo.t_PatientBack
															group by rf_idRecordCaseBack,rf_idSMO 
														   ) p on
										cb.id=p.rf_idRecordCaseBack
												inner join RegisterCases.dbo.vw_sprSMO s on
											p.rf_idSMO=s.smocod						
						group by c.rf_idMO,r.NumberRegister,c.GUID_Case,t1.unitCode
						) t2 on
			t1.NumberRegister=t2.NumberRegister
			and t1.GUID_Case=t2.GUID_Case
			and t1.Quantity<>t2.Quantity