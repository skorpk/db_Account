USE CanserRegister
GO
CREATE VIEW vw_sprDN
AS
SELECT id,NameDN
FROM (VALUES(1,'Состоит'),(2,'Взят'),(4,'Снят по причине выздоровления'),(6,'Снят по другим причинам')) AS v(id,NameDN)