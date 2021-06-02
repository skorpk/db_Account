USE oms_accounts
GO

SELECT SUM(RowID) AS 'Количество пациентов',YearReg,'Стационар' AS Name
FROM (
		SELECT 1 AS RowID,Fam,IM,Ot,Dr,YEAR(DateOfRegistrationOfAccount) AS YearReg				
		FROM dbo.t_Accounts a INNER JOIN dbo.t_Cases c ON
				a.id=c.rf_idAccounts
		WHERE DateOfRegistrationOfAccount>'20080101' AND DateOfRegistrationOfAccount<'20111201' AND rf_conditions=1
		GROUP BY Fam,IM,Ot,Dr,YEAR(DateOfRegistrationOfAccount)
	) t
GROUP BY YearReg
UNION ALL
SELECT SUM(RowID),YearReg,'Дневной стационар'
FROM (
		SELECT 1 AS RowID,Fam,IM,Ot,Dr,YEAR(DateOfRegistrationOfAccount) AS YearReg				
		FROM dbo.t_Accounts a INNER JOIN dbo.t_Cases c ON
				a.id=c.rf_idAccounts
		WHERE DateOfRegistrationOfAccount>'20080101' AND DateOfRegistrationOfAccount<'20111201' AND rf_conditions IN (2,3,4)
		GROUP BY Fam,IM,Ot,Dr,YEAR(DateOfRegistrationOfAccount)
	) t
GROUP BY YearReg
UNION ALL
SELECT SUM(RowID),ReportYear,'Стационар' AS NAME
FROM(
		SELECT 1 AS RowId,rp.Fam,rp.Im,rp.Ot,rp.BirthDay,a.ReportYear
		FROM AccountOMS.dbo.t_File f INNER JOIN AccountOMS.dbo.t_RegistersAccounts a ON
						f.id=a.rf_idFiles
									INNER JOIN AccountOMS.dbo.t_RecordCasePatient r ON
						a.id=r.rf_idRegistersAccounts
									INNER JOIN AccountOMS.dbo.t_Case c ON
						r.id=c.rf_idRecordCasePatient
									INNER JOIN AccountOMS.dbo.t_RegisterPatient rp on
						f.id=rp.rf_idFiles
						AND rp.rf_idRecordCase=r.id
		WHERE f.DateRegistration>'20111201' AND f.DateRegistration<'20130301' AND a.ReportYear IN (2011,2012) AND c.DateEnd<'20130101' AND c.rf_idV006=1
		GROUP BY rp.Fam,rp.Im,rp.Ot,rp.BirthDay,a.ReportYear
	) t
GROUP BY t.ReportYear
union ALL 
SELECT SUM(RowID),ReportYear,'Дневной стационар' AS NAME
FROM(
		SELECT 1 AS RowId,rp.Fam,rp.Im,rp.Ot,rp.BirthDay,a.ReportYear
		FROM AccountOMS.dbo.t_File f INNER JOIN AccountOMS.dbo.t_RegistersAccounts a ON
						f.id=a.rf_idFiles
									INNER JOIN AccountOMS.dbo.t_RecordCasePatient r ON
						a.id=r.rf_idRegistersAccounts
									INNER JOIN AccountOMS.dbo.t_Case c ON
						r.id=c.rf_idRecordCasePatient
									INNER JOIN AccountOMS.dbo.t_RegisterPatient rp on
						f.id=rp.rf_idFiles
						AND rp.rf_idRecordCase=r.id
		WHERE f.DateRegistration>'20111201' AND f.DateRegistration<'20130301' AND a.ReportYear IN (2011,2012) AND c.DateEnd<'20130101' AND c.rf_idV006=2
		GROUP BY rp.Fam,rp.Im,rp.Ot,rp.BirthDay,a.ReportYear
	) t
GROUP BY t.ReportYear
ORDER BY YearReg,Name