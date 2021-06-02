USE AccountOMSReports
GO
SELECT ReportMonth,
CASE WHEN ReportMonth=1 THEN '������' WHEN ReportMonth=2 THEN '�������' WHEN ReportMonth=3 THEN '����' WHEN ReportMonth=4 THEN '������' ELSE '���' end
,MES,COUNT(DISTINCT rf_idCase)
FROM dbo.t_SendingDataIntoFFOMS
WHERE Mes IS NOT NULL AND IsFullDoubleDate=0
GROUP BY ReportMonth,CASE WHEN ReportMonth=1 THEN '������' WHEN ReportMonth=2 THEN '�������' WHEN ReportMonth=3 THEN '����' WHEN ReportMonth=4 THEN '������' ELSE '���' end,MES
ORDER BY ReportMonth,MES

