USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20200116',
		@reportYear SMALLINT=2019


;with ctePeople
AS(
SELECT distinct rp.Fam+' '+rp.Im+' '+ISNULL(rp.Ot,'') AS Fio,ps.ENP,YEAR(rp.BirthDay) AS BirthYear,d.SNILS,f.CodeM+'- '+l.NAMES AS MO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient				
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase             
					INNER JOIN dbo.t_RegisterPatient rp ON
             r.id=rp.rf_idRecordCase
			AND f.id=rp.rf_idFiles
					INNER JOIN dbo.t_PatientSMO ps ON
             r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.vw_sprT001 l ON
             l.CodeM = f.CodeM
					--left JOIN dbo.vw_PeopleAdressPolicyDB pa ON
     --        ps.ENP=pa.enp
					left JOIN dbo.t_RegisterPatientDocument d ON
			rp.id=d.rf_idRegisterPatient               
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND m.MU IN('2.78.33','2.79.31','2.81.39','2.88.39')
)
SELECT ROW_NUMBER() OVER(ORDER BY FIO) AS idRow, Fio,ENP,BirthYear,SNILS,MO
FROM ctePeople
ORDER BY FIO