USE AccountOMS
GO
--ALTER TABLE dbo.t_Report1FFOMS alter column N_ZAP2 INT
;WITH cte
AS(
SELECT DENSE_RANK() OVER( ORDER BY AttachLPU,SNILS_Doc) AS ID,
		 AttachLPU,rf_idCase
FROM dbo.t_Report1FFOMS 
)
UPDATE r SET r.N_Zap2=c.ID
--select c.ID,r.AttachLPU,r.rf_idCase,snils_doc ,r.ReportMonth
from dbo.t_Report1FFOMS r INNER JOIN cte c ON
			r.rf_idCase=c.rf_idCase
--WHERE ReportMonth=2 and reportYear=2017 
--order by r.AttachLPU,r.snils_doc,r.ReportMonth

--SELECT MAX(N_ZAP2) FROM dbo.t_Report1FFOMS

SELECT r.N_ZAP2,r.ReportMonth 
FROM dbo.t_Report1FFOMS r INNER JOIN dbo.t_Report1FFOMS r1 ON
				r.N_ZAP2=r1.N_ZAP2
				AND r.ReportMonth=r1.ReportMonth
WHERE r.SNILS_Doc<>r.SNILS_Doc 
ORDER BY ReportMonth
