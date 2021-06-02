USE AccountOMS
GO

SELECT  t.ReportMonth ,z.Name, SUM(t.CountCases) AS Cases
FROM (
SELECT s.ReportMonth,s.C_POKL,COUNT(rf_idCase) AS CountCases
FROM dbo.t_SNILSAmbulanceFFOMS s
GROUP BY s.ReportMonth,s.C_POKL
UNION ALL
SELECT s.ReportMonth,s.C_POKL,COUNT(rf_idCase)
FROM dbo.t_Report1FFOMS s 
GROUP BY s.ReportMonth,s.C_POKL
) t	INNER JOIN (VALUES (2,'���������� ������� ������ ����������� ������'),
(4,'���������� ����������� ������� ������� ����� ��������������� ������������ ����� ��������� ���������.'),
(5,'���������� ����������� ������� ���������������� �������� ��������� ���������.'),
(6,'���������� ���������, ������������������� �� ������ ��������, ����������������� ���������� �������� ��������� (���� �� ���-10: I10 � I15.9).'),
(7,'���������� ���������, ������������������� �� ������ ����������������� �������������, �������������� �������������, ������ ���������������� �������������� �������������, �������� �����, ���������, �� ���������� ��� ������������� ��� ������� (���� �� ���-10: I60.0 � I64.9).'),
(8,'���������� ���������, ������������������� �� ������ ������������ ����������� (��� �� ���-10: I20.0).'),
(9,'���������� ���������, ������������������� �� ������ ������� �������� �������� (���� �� ���-10: I21.0 � I21.9).'),
(10,'���������� ���������, ������������������� �� ������ ���������� �������� �������� (��� �� ���-10: I22.0 � I22.9).')) z(C_POKL,Name) ON
		t.C_POKL=z.C_POKL		
GROUP BY t.ReportMonth ,z.Name
ORDER BY t.ReportMonth