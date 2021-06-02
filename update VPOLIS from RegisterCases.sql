use RegisterCases
go
declare @t as table(id int, rf_idF008 tinyint)

insert @t
select distinct pa.id,r.rf_idF008
from AccountOMS.dbo.vw_getIdFileNumber va inner join AccountOMS.dbo.t_RegistersAccounts aa on
			va.id=aa.rf_idFiles
			and va.DateRegistration>='20120801'
										inner join AccountOMS.dbo.t_RecordCasePatient pa on
			aa.id=pa.rf_idRegistersAccounts
			and pa.rf_idF008=0
										inner join AccountOMS.dbo.t_Case ca on
			pa.id=ca.rf_idRecordCasePatient
										inner join (
													select c.GUID_Case,r.ID_Patient,pb.rf_idF008
													from t_RecordCase r inner join t_Case c on
																r.id=c.rf_idRecordCase
																		inner join t_RecordCaseBack rb on
																c.id=rb.id
																and rb.TypePay=1
																		inner join t_PatientBack pb on
																rb.id=pb.rf_idRecordCaseBack
																		inner join t_RegisterCaseBack ab on
																rb.rf_idRegisterCaseBack=ab.id
																		inner join t_FileBack fb on
																ab.rf_idFilesBack=fb.id
																and fb.DateCreate>'20120801'																		
																
													) r on 
			pa.ID_Patient=r.ID_Patient
			and ca.GUID_Case=r.GUID_Case
										
			
begin transaction	
update pa set pa.rf_idF008=t.rf_idF008
from AccountOMS.dbo.t_RecordCasePatient pa inner join @t t on
		pa.id=t.id
commit
			