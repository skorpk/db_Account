USE CanserRegister
GO
CREATE VIEW vw_sprDN
AS
SELECT id,NameDN
FROM (VALUES(1,'�������'),(2,'����'),(4,'���� �� ������� �������������'),(6,'���� �� ������ ��������')) AS v(id,NameDN)