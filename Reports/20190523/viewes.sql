USE AccountOMS
GO

CREATE VIEW vw_sprV012
AS 
SELECT id,name,DL_USLOV as USL_OK FROM oms_NSI.dbo.sprV012

GO

go
CREATE VIEW [dbo].[vw_sprV009]
AS 
SELECT id,name,DL_USLOV as USL_OK,DateBeg,DateEnd FROM oms_NSI.dbo.sprV009

GO
CREATE VIEW vw_sprV002
AS 
SELECT id,name FROM oms_NSI.dbo.sprV002

GO
CREATE VIEW [dbo].[vw_sprV004]
AS 
SELECT id,name,CAST('20110101' AS DATE) AS DateBeg, CAST('20160101' AS DATE) AS DateEnd FROM oms_NSI.dbo.sprMedicalSpeciality WHERE Name IS NOT null
UNION ALL
SELECT Code,NAME, CAST('20160101' AS DATE),CAST('20190101' AS DATE)  FROM oms_nsi.dbo.sprV015
UNION ALL
SELECT IDSPEC,SPECNAME, CAST('20190101' AS DATE),DATEEND  FROM oms_nsi.dbo.sprV021

GO
CREATE VIEW dbo.vw_sprV006
AS
select id, name,DateBeg,isnull(DateEnd,'22220101') as DateEnd from oms_NSI.dbo.sprV006
GO

GRANT SELECT ON vw_sprV012 TO db_AccountOMS 
GRANT SELECT ON vw_sprV009 TO db_AccountOMS 
GRANT SELECT ON vw_sprV002 TO db_AccountOMS 
GRANT SELECT ON vw_sprV004 TO db_AccountOMS 
GRANT SELECT ON vw_sprV006 TO db_AccountOMS 