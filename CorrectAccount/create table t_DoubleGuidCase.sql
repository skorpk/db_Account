use AccountOMS
go
--0. В ХП usp_InsertAccountDataLPU убрать все проверки
if OBJECT_ID('t_DoubleGuidCase') is not null
drop table t_DoubleGuidCase
go
--1.Формируется таблица в которой хранится информация о старых файлах
select a.rf_idFiles,f.FileNameHR,f.DateRegistration--,c.GUID_Case
into t_DoubleGuidCase
from t_Case c inner join t_RecordCasePatient r on
		c.rf_idRecordCasePatient=r.id
				inner join t_RegistersAccounts a on
		r.rf_idRegistersAccounts=a.id
				inner join (
								select GUID_Case from t_Case group by GUID_Case	having COUNT(*)>1
							) td on
		c.GUID_Case=td.GUID_Case
				inner join t_File f on
		a.rf_idFiles=f.id
group by a.rf_idFiles,f.FileNameHR,f.DateRegistration--,c.GUID_Case
go
--2.Создать хранимую процедуру usp_GetFileUnLoadGUID

--3.Удаляем данные перед загрузко, но прежде все необходимо СДЕЛАТЬ РЕЗЕРВНУЮ КОПИЮ и ВЫГРУЗИТЬ УДАЛЯЕМЫЕ файлы!!!!
delete from t_File where id in (select rf_idFiles from t_DoubleGuidCase)
go
--4. Проверяем какие файлы не были загружены
select /*id,f.FileNameHR,f.DateRegistration,*/'"'+rtrim(d.FileNameHR)+'.zip",',d.DateRegistration
from t_File f right join t_DoubleGuidCase d on
		rtrim(f.FileNameHR)=rtrim(d.FileNameHR)
where f.id is null
group by d.FileNameHR,d.DateRegistration


select id,f.FileNameHR,f.DateRegistration
from t_File f
where DateRegistration>'20120119 12:00:00'