USE Accounts
GO
SELECT SUM(RowID) AS '���������� �������',YearReg,'���������' AS Name
FROM (
		SELECT 1 AS RowID,YEAR(DateOfRegistrationOfFile) AS YearReg
		FROM t_Cases  
		WHERE Conditions=1 AND DateOfRegistrationOfFile>'20050101' AND DateOfRegistrationOfFile<'20080101'
	) t
GROUP BY YearReg
UNION ALL
SELECT SUM(RowID),YearReg,'������� ���������' 
FROM (
		SELECT 1 AS RowID,YEAR(DateOfRegistrationOfFile) AS YearReg
		FROM t_Cases  
		WHERE Conditions IN(2,3,4) AND DateOfRegistrationOfFile>'20050101' AND DateOfRegistrationOfFile<'20080101'
	) t
GROUP BY YearReg
ORDER BY YearReg,Name


				