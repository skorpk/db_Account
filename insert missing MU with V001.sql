USE AccountOMS
GO
CREATE TABLE #tMUAccount(id BIGINT,GUID_Case UNIQUEIDENTIFIER)

insert #tMUAccount
SELECT c.id,c.GUID_Case
FROM dbo.t_Case c INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase			
				INNER JOIN dbo.vw_sprCSGWithParamAccount csg ON
			m.MES=csg.MU
WHERE c.DateEnd>'20140101'

BEGIN TRANSACTION
insert t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO, rf_idV002,MUSurgery, IsChildTariff, DateHelpBegin, DateHelpEnd, DiagnosisCode, 
					MUGroupCode,MUUnGroupCode,MUCode,
					Quantity, Price, TotalPrice, rf_idV004, Comments,rf_idDepartmentMO)
SELECT a.id,m.id,m.GUID_MU,m.rf_idMO, m.rf_idV002,m.MUSurgery, m.IsChildTariff, m.DateHelpBegin, m.DateHelpEnd, m.DiagnosisCode
		,0,0,0
		, m.Quantity, m.Price, m.TotalPrice, m.rf_idV004, m.Comments,m.rf_idDepartmentMO
FROM RegisterCases.dbo.t_Case c INNER JOIN RegisterCases.dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
								INNER JOIN dbo.vw_V001 v ON
				m.MUCode=v.IDRB
								INNER JOIN #tMUAccount a ON
				c.GUID_Case=a.GUID_Case
								INNER JOIN RegisterCases.dbo.t_RecordCaseBack r on
				c.id=r.rf_idCase
								INNER JOIN RegisterCases.dbo.t_CaseBack c1 ON
			r.id=c1.rf_idRecordCaseBack
WHERE c1.TypePay=1

COMMIT
go
DROP TABLE #tMUAccount								