use oms_NSI
go
if OBJECT_ID('sprErrorForAccount',N'U') is not null
drop table sprErrorForAccount
go
create table sprErrorForAccount
(
	id tinyint,
	DescriptionError varchar(250)
)
go
insert sprErrorForAccount(id,DescriptionError)
values(1,'Ошибка в имени пакета'),
	  (2,'Ошибка в имени файла'),
	  (3,'Пакет упакован не zip архиватором'),
	  (4,'Файл с таким именем был прнесен ранее'),
	  (5,'Не верный код МО'),
	  (6,'В пакете должно быть 2 файла'),
	  (7,'Тип данных не является типом GUID'),
	  (8,'Ошибка при проверке файлов на соответствие схемы XSD'),
	  (9,'Номер счета был принесен ранее в отчетном году или отсутствует соответствующий номер реестра сведений'),
	  (10,'Номер счета содержит не допустимые символы'),
	  (11,'Ошибка при проверке случаев'),
	  (12,'Ошибка при проверке медицинских услуг'),
	  (13,'Не корректная дата счета'),
	  (14,'Сумма счета не совпадает с суммой случаев')
GO
use AccountOMS
go
alter table t_Errors add rf_sprErrorAccount tinyint null
GO	  
	  

