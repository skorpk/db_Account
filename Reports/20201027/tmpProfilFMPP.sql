/*
DROP table tmpProfilFMPP
drop table tmpProfilFMPP2
*/
SELECT * 
FROM tmpProfilFMPP p 
WHERE NOT EXISTS(SELECT * FROM tmpProfilFMPP2 pp WHERE p.id=pp.id AND p.q=pp.q)

SELECT * FROM dbo.tmpProfilFMPP WHERE id=15805349

SELECT * FROM dbo.tmpProfilFMPP2 WHERE id=15805349

-- SELECT * FROM [AccountOMSReports].[dbo].[vw_UnitCode_MES] WHERE MU='2.78.17'