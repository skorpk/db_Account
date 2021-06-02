USE ACCOTFOMS2011
GO
CREATE TABLE #tmpEKO(DateEnd date,PID int,ENP varchar(20), ReportYear AS year(dateend))

INSERT #tmpEKO( DateEnd, PID, ENP )
--SELECT DateEnd,0,ENP FROM dbo.tmp_EKO_Victor
SELECT CONVERT(DATE,c.DATE_2,120) AS DateEnd,0,p.ENP
FROM dbo.t_FilesR f INNER JOIN dbo.t_Accounts a ON
			f.id=a.id_FileR
				 INNER JOIN dbo.t_Pacients p ON
			a.id=p.id_Account
				INNER JOIN t_Cases c ON
			p.id=c.id_Pacient              
				 INNER JOIN (VALUES ('40000','2000',27,'780079'), ('40000','1692',8,'780035'),('40000','1753',120,'780486'),('40000','2305',9,'780264'),('45000','431',90,'774781'),
									('45000','431',282,'774795'),('45000','431',1482,'774795'),('45000','592',1023,'774781'),('45000','752',56,'774864'),('45000','752',205,'774781'),
									('45000','752',910,'774781'),('45000','752',2159,'774781'),('45000','752',2162,'774781'),('45000','914',165,'775039'),('45000','914',461,'774781'),
									('45000','914',702,'774781'),('45000','914',916,'774781'),('45000','1076',125,'774781'),('45000','1076',1548,'774781'),('45000','1076',1561,'774781'),
									('45000','1076',1635,'774781'),('45000','1076',1672,'774781'),('45000','1076',1761,'774781'),('45000','1236',123,'774781'),('45000','1236',293,'774781'),
									('45000','1236',551,'775039'),('45000','1236',596,'774781'),('45000','1236',642,'774781'),('45000','1236',697,'774781'),('45000','1236',904,'774781'),
									('45000','1236',1000,'774781'),('45000','1236',1237,'774781'),('45000','1396',29,'774781'),('45000','1396',230,'774781'),('45000','1396',553,'774781'),
									('45000','1396',644,'774781'),('45000','1396',721,'774781'),('45000','1396',729,'774781'),('45000','1396',872,'774781'),('45000','1396',1464,'774781'),
									('45000','1552',239,'774781'),('45000','1715',163,'774781'),('45000','1715',391,'774781'),('45000','1715',430,'774781'),('45000','1715',1534,'774781'),
									('45000','1715',1567,'774781'),('45000','1801',134,'774781'),('45000','1801',837,'774781'),('45000','1801',1177,'774781'),('45000','1801',1279,'774781'),
									('45000','1801',1321,'774781'),('45000','1801',1404,'774781'),('45000','1801',1464,'774781'),('45000','1801',1581,'774781'),('45000','1801',1700,'774781'),
									('45000','1801',1882,'774781'),('60000','6307',466,'610282'),('63000','70134',143,'640971'),('63000','70434',274,'640971'),('63000','71134',393,'640036')
							)v(OKATO,Account,N_ZAP,CodeM) ON
			a.C_OKATO1=v.OKATO
			AND a.NSCHET=v.account
			AND p.N_ZAP=v.n_zap
WHERE a.YEAR=2017
---эти данные получаются после выполнения скриптов на базе счетом ОМС.
INSERT #tmpEKO( DateEnd, PID, ENP )
SELECT DateEnd,pid,enp FROM AccountOMS.dbo.tmpEKO34

SELECT c.id,e.ENP,e.DateEnd,'Иногородние', c.DATE_1, c.DATE_2,c.DS1,mkb.Diagnosis
FROM dbo.t_Pacients q INNER JOIN #tmpEKO e ON
			q.ENP=e.ENP
					 INNER JOIN dbo.t_Cases c ON
			q.ID=c.id_Pacient
					INNER JOIN AccountOMS.dbo.vw_sprMKB10 mkb ON
			c.DS1=mkb.DiagnosisCode     
WHERE PROFIL=136 AND e.DateEnd<=convert(date,c.DATE_1) AND convert(date,c.DATE_1)<'20180101' AND
		 mkb.MainDS IN('O10','O11','O12','O13','O14','O15','O16','O20','O21','O22','O23','O24','O25','O26','O28','O30','O31','O32','O33','O36','O40','O41','O43','O44','O45','O46','O47','O98','O99'
				,'Z33','Z34','Z35','Z36') AND e.ReportYear=2016		
UNION ALL
SELECT DISTINCT c.id,e.ENP,e.DateEnd,'Иногородние', c.DATE_1, c.DATE_2,c.DS1,mkb.Diagnosis
FROM dbo.t_Pacients q INNER JOIN #tmpEKO e ON
			q.ENP=e.ENP
					 INNER JOIN dbo.t_Cases c ON
			q.ID=c.id_Pacient
					INNER JOIN AccountOMS.dbo.vw_sprMKB10 mkb ON
			c.DS1=mkb.DiagnosisCode     
WHERE PROFIL=136 AND e.DateEnd<=convert(date,c.DATE_1) AND convert(date,c.DATE_1)<'20180101' AND
		 mkb.MainDS IN('O10','O11','O12','O13','O14','O15','O16','O20','O21','O22','O23','O24','O25','O26','O28','O30','O31','O32','O33','O36','O40','O41','O43','O44','O45','O46','O47','O98','O99'
				,'Z33','Z34','Z35','Z36') AND e.ReportYear=2017		            		            
		 
go
DROP TABLE #tmpEKO
		 
