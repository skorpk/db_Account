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
values(1,'������ � ����� ������'),
	  (2,'������ � ����� �����'),
	  (3,'����� �������� �� zip �����������'),
	  (4,'���� � ����� ������ ��� ������� �����'),
	  (5,'�� ������ ��� ��'),
	  (6,'� ������ ������ ���� 2 �����'),
	  (7,'��� ������ �� �������� ����� GUID'),
	  (8,'������ ��� �������� ������ �� ������������ ����� XSD'),
	  (9,'����� ����� ��� �������� ����� � �������� ���� ��� ����������� ��������������� ����� ������� ��������'),
	  (10,'����� ����� �������� �� ���������� �������'),
	  (11,'������ ��� �������� �������'),
	  (12,'������ ��� �������� ����������� �����'),
	  (13,'�� ���������� ���� �����'),
	  (14,'����� ����� �� ��������� � ������ �������')
GO
use AccountOMS
go
alter table t_Errors add rf_sprErrorAccount tinyint null
GO	  
	  

