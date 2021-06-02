USE AccountOMSReports
GO
SELECT ReportMonth,
CASE WHEN ReportMonth=1 THEN 'Январь' WHEN ReportMonth=2 THEN 'Февраль' WHEN ReportMonth=3 THEN 'Март' WHEN ReportMonth=4 THEN 'Апрель' ELSE 'Май' end
,MES,COUNT(DISTINCT rf_idCase)
FROM dbo.t_SendingDataIntoFFOMS
WHERE Mes IS NOT NULL AND IsFullDoubleDate=0
GROUP BY ReportMonth,CASE WHEN ReportMonth=1 THEN 'Январь' WHEN ReportMonth=2 THEN 'Февраль' WHEN ReportMonth=3 THEN 'Март' WHEN ReportMonth=4 THEN 'Апрель' ELSE 'Май' end,MES
ORDER BY ReportMonth,MES

