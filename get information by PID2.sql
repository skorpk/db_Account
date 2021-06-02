USE AccountOMS
GO
/*
SELECT a.Account,c.rf_idMO,l.NAMES, c.DateEnd,mk.Diagnosis, ds1, c.AmountPayment, c.rf_idV002
FROM dbo.t_Case_PID_ENP ce INNER JOIN t_Case c ON
			ce.rf_idCase=c.id
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN dbo.vw_sprMKB10 mk ON
			d.DS1=mk.DiagnosisCode                  
					INNER JOIN dbo.t_RecordCasePatient rp ON
			c.rf_idRecordCasePatient=rp.id
					INNER JOIN dbo.t_RegistersAccounts a on
			rp.rf_idRegistersAccounts=a.id
					INNER JOIN dbo.vw_sprT001 l ON
			c.rf_idMO=l.CodeM                  
WHERE ce.pid=2020785 AND ce.ReportYear=2020 
ORDER BY c.DateEnd
*/
SELECT a.Account,c.rf_idMO,l.NAMES, c.DateEnd,mk.Diagnosis, ds1, c.AmountPayment, c.rf_idV002
FROM t_Case c INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN dbo.vw_sprMKB10 mk ON
			d.DS1=mk.DiagnosisCode                  
					INNER JOIN dbo.t_RecordCasePatient rp ON
			c.rf_idRecordCasePatient=rp.id
					INNER JOIN dbo.t_PatientSMO ps ON
              rp.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegistersAccounts a on
			rp.rf_idRegistersAccounts=a.id
					INNER JOIN dbo.vw_sprT001 l ON
			c.rf_idMO=l.CodeM                  
WHERE ps.ENP='3494099796000072' AND a.ReportYear=2020 
ORDER BY c.DateEnd


--SELECT id,* FROM PolicyRegister.dbo.PEOPLE WHERE FAM='Тарасенко' AND Im='Юлия' AND Dr>'20080101' AND Dr<'20081001'
--SELECT id,* FROM PolicyRegister.dbo.PEOPLE WHERE FAM='Крайнова'  AND Dr='20090503' --Дарья
--SELECT id,* FROM PolicyRegister.dbo.PEOPLE WHERE FAM='Крайнова' AND Dr='20180602' --Санька

--SELECT id,enp,* FROM PolicyRegister.dbo.PEOPLE WHERE FAM='Михайлов' AND IM='Валерий' AND id=751292

SELECT id,enp FROM PolicyRegister.dbo.PEOPLE WHERE id=2020785
SELECT id,ENP FROM PolicyRegister.dbo.PEOPLE WHERE FAM='Крайнова' AND Dr='20180602' --Санька