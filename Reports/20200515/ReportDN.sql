USE PlanDD
GO
SELECT d.ENP
INTO #t
FROM dbo.DNPersons2020 d INNER JOIN dbo.tmp_ENP_AttachLPU e ON
			d.ENP=e.enp
INSERT #t
SELECT d.ENP
FROM dbo.tmp_DN_I d INNER JOIN dbo.tmp_ENP_AttachLPU e ON
			d.ENP=e.enp
WHERE d.ReportMonth<4

;WITH cteENP
AS(
SELECT l.CodeM,l.NAMES,null AS AllENP,d.ENP AS ENP_April
FROM dbo.tmp_DN_I d INNER JOIN dbo.tmp_ENP_AttachLPU e ON
			d.ENP=e.enp
				INNER JOIN Consultation_NMRC.dbo.vw_sprT001 l ON
             e.AttachLPU=l.CodeM
WHERE  d.ReportMonth=4 AND NOT EXISTS(SELECT 1 FROM #t i WHERE i.ENP=d.ENP)
UNION ALL 
SELECT l.CodeM,l.NAMES,d.ENP,null
FROM dbo.tmp_DN_I d INNER JOIN dbo.tmp_ENP_AttachLPU e ON
			d.ENP=e.enp
				INNER JOIN Consultation_NMRC.dbo.vw_sprT001 l ON
             e.AttachLPU=l.CodeM
UNION ALL 
SELECT l.CodeM,l.NAMES,d.ENP,null
FROM dbo.DNPersons2020 d INNER JOIN dbo.tmp_ENP_AttachLPU e ON
			d.ENP=e.enp
				INNER JOIN Consultation_NMRC.dbo.vw_sprT001 l ON
             e.AttachLPU=l.CodeM
)
SELECT c.CodeM,c.NAMES, COUNT( DISTINCT c.AllENP),count(DISTINCT c.ENP_April)
FROM cteENP c GROUP BY c.CodeM,c.NAMES ORDER BY c.CodeM

SELECT COUNT(DISTINCT d.ENP) AS ENP_April
FROM dbo.tmp_DN_I d INNER JOIN dbo.tmp_ENP_AttachLPU e ON
			d.ENP=e.enp				
WHERE  d.ReportMonth=4 AND NOT EXISTS(SELECT 1 FROM #t i WHERE i.ENP=d.ENP)
--количество людей с признаком DN=2 всех
SELECT COUNT(DISTINCT d.ENP) AS ENP_April
FROM dbo.tmp_DN_I d INNER JOIN dbo.tmp_ENP_AttachLPU e ON
			d.ENP=e.enp
				INNER JOIN Consultation_NMRC.dbo.vw_sprT001 l ON
             e.AttachLPU=l.CodeM
WHERE  d.ReportMonth=4  AND dn=2
--количество людей с признаком DN=2 но которые уже обращались
SELECT COUNT(DISTINCT d.ENP) AS ENP_April
FROM dbo.tmp_DN_I d INNER JOIN dbo.tmp_ENP_AttachLPU e ON
			d.ENP=e.enp
				INNER JOIN Consultation_NMRC.dbo.vw_sprT001 l ON
             e.AttachLPU=l.CodeM
WHERE  d.ReportMonth=4  AND dn=2 AND EXISTS(SELECT 1 FROM #t i WHERE i.ENP=d.ENP)


GO
DROP TABLE #t