USE RegisterCases
GO
SELECT distinct r.id,v.*,a.NumberRegister, ps.rf_idSMO
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
				INNER JOIN dbo.t_RefRegisterPatientRecordCase rp ON
		r.id=rp.rf_idRecordCase
				INNER JOIN dbo.t_PatientSMO ps ON
		r.id=ps.ref_idRecordCase              
				INNER JOIN dbo.t_RegisterPatient p ON
		rp.rf_idRegisterPatient=p.id
		AND p.rf_idFiles=f.id
				INNER JOIN (VALUES ('Авдеева','Елена','Юрьевна'),('Безверхова','Анастасия','Павловна'),('Божкова','Валентина','Анатольевна'),
							('Кайрлебер','Алёна','Родионовна'),('Капинос','Наталья','Николаевна'),('Каратаева','Ирина','Владимировна'),
							('Кригер','Лариса','Сергеевна'),('Куделка','Юлия','Николаевна'),('Кудимова','Наталья','Алексеевна'),
							('Куликова','Марина','Владимировна'),('Лобарь','Ирина','Сергеевна'),('Нижегородова','Татьяна','Владимировна'),
							('Разумовская','Елена','Сергеевна'),('Резвова','Татьяна','Николаевна'),('Рогозина','Надежда','Валериевна'),
							('Сачкова','Наталия','Николаевна'),('Сигаева','Юлия','Валентиновна'),('Тишкова','Светлана','Ивановна'),
							('Уткина','Надежда','Александровна'),('Шахова','Людмила','Вячеславовна')) v(FAM,IM,OT) ON
		p.Fam=v.Fam
		AND p.Im=v.IM
		AND p.Ot=v.Ot
WHERE a.ReportYear=2015 AND a.ReportMonth=12 AND f.DateRegistration>'20151201'	AND f.CodeM='801934' AND a.NumberRegister=22	                            
ORDER BY v.Fam