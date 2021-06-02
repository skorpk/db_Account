USE Accounts
GO
SELECT SUM(RowID) AS 'Количество случаев',YearReg,'Стационар' AS Name
FROM (
		SELECT 1 AS RowID,YEAR(DateOfRegistrationOfFile) AS YearReg
		FROM t_Cases  
		WHERE Conditions=1 AND DateOfRegistrationOfFile>'20050101' AND DateOfRegistrationOfFile<'20080101'
	) t
GROUP BY YearReg
UNION ALL
SELECT SUM(RowID),YearReg,'Дневной стационар' 
FROM (
		SELECT 1 AS RowID,YEAR(DateOfRegistrationOfFile) AS YearReg
		FROM t_Cases  
		WHERE Conditions IN(2,3,4) AND DateOfRegistrationOfFile>'20050101' AND DateOfRegistrationOfFile<'20080101'
	) t
GROUP BY YearReg
ORDER BY YearReg,Name


				