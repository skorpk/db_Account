use AccountOMS
go
if OBJECT_ID('usp_InsertCompletedCaseIntoMeduslugi',N'P') is not null
drop proc usp_InsertCompletedCaseIntoMeduslugi
go
create procedure usp_InsertCompletedCaseIntoMeduslugi
					@idFile INT
AS
DECLARE @fileName VARCHAR(25),
		@outRowMES INT
		
SELECT @fileName=FileNameHR FROM dbo.t_File WHERE id=@idFile

declare @inserted as table(GUID_Case UNIQUEIDENTIFIER,rf_idCase bigint,MES varchar(20))
insert @inserted
select distinct c.GUID_Case,c.id,mes
from t_RegistersAccounts a inner join t_RecordCasePatient r on
		a.id=r.rf_idRegistersAccounts
		AND a.rf_idFiles=@idFile
				inner join t_Case c on
		r.id=c.rf_idRecordCasePatient
				inner join t_MES mes on
		c.id=mes.rf_idCase
				INNER JOIN (
								SELECT DISTINCT MU
								FROM vw_sprMUCompletedCase m LEFT JOIN (SELECT MU AS MUCode FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
																		UNION ALL
																		SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
																		UNION ALL
																		SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72
																		) m1 ON
											m.MU=m1.MUCode
								WHERE m1.MUCode IS NULL
							  ) vw_c ON
			mes.MES=vw_c.MU
WHERE c.DateEnd<'20130401'	
UNION ALL
select distinct c.GUID_Case,c.id,mes
from t_RegistersAccounts a inner join t_RecordCasePatient r on
		a.id=r.rf_idRegistersAccounts
		AND a.rf_idFiles=@idFile
				inner join t_Case c on
		r.id=c.rf_idRecordCasePatient
				inner join t_MES mes on
		c.id=mes.rf_idCase
				INNER JOIN (
								SELECT DISTINCT MU
								FROM vw_sprMUCompletedCase m LEFT JOIN (SELECT MU AS MUCode FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
																		UNION ALL
																		SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
																		UNION ALL
																		SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72
																		) m1 ON
											m.MU=m1.MUCode
								WHERE m1.MUCode IS NULL
							  ) vw_c ON
			mes.MES=vw_c.MU
WHERE c.DateEnd>='20130401'  AND c.rf_idV006<>2 
		
SELECT @outRowMES=@@ROWCOUNT		

INSERT t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO,rf_idSubMO,rf_idDepartmentMO,rf_idV002,IsChildTariff,DateHelpBegin,DateHelpEnd,DiagnosisCode,
						MUGroupCode,MUUnGroupCode,MUCode,Quantity,Price,TotalPrice,rf_idV004,rf_idDoctor)
SELECT DISTINCT  c.id,CAST(c.idRecordCase AS varchar(36)),NEWID(),c.rf_idMO,c.rf_idSubMO,c.rf_idDepartmentMO,c.rf_idV002,c.IsChildTariff,c.DateBegin,c.DateEnd,d.DiagnosisCode,
		   vw_c.MUGroupCodeP,vw_c.MUUnGroupCodeP,vw_c.MUCodeP		   
		   , case when c.rf_idV006=2 then CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2))+1 
			else (case when(CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2)))=0 then 1 else CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2))end) end
		   ,0.00,0.00,c.rf_idV004,c.rf_idDoctor
FROM t_Case c INNER JOIN (SELECT DISTINCT * FROM @inserted) i ON
			c.id=i.rf_idCase
				  INNER JOIN (SELECT rf_idCase,DiagnosisCode FROM t_Diagnosis WHERE TypeDiagnosis=1 GROUP BY rf_idCase,DiagnosisCode) d ON
			c.id=d.rf_idCase
				  INNER JOIN (
								SELECT MU,MUGroupCodeP,MUUnGroupCodeP,MUCodeP,AgeGroupShortName 
								FROM vw_sprMUCompletedCase m 
								GROUP BY MU,MUGroupCodeP,MUUnGroupCodeP,MUCodeP,AgeGroupShortName
							  ) vw_c ON
			i.MES=vw_c.MU	
WHERE c.DateEnd<'20130401' AND vw_c.AgeGroupShortName=(CASE WHEN c.Age>17 THEN 'в' ELSE 'д' END)
----- Новый порядок учета Дневного стационара в качестве ЗС. Количество услуг не считается с 01.04.2013
UNION ALL 
SELECT DISTINCT  c.id,CAST(c.idRecordCase AS varchar(36)),NEWID(),c.rf_idMO,c.rf_idSubMO,c.rf_idDepartmentMO,c.rf_idV002,c.IsChildTariff,c.DateBegin,c.DateEnd,d.DiagnosisCode,
		   vw_c.MUGroupCodeP,vw_c.MUUnGroupCodeP,vw_c.MUCodeP		   
		   , case when(CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(9,2)))=0 then 1 else CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(9,2))end
		   ,0.00,0.00,c.rf_idV004,c.rf_idDoctor
FROM t_Case c INNER JOIN (SELECT DISTINCT * FROM @inserted ) i ON
			c.id=i.rf_idCase
				  INNER JOIN (SELECT rf_idCase,DiagnosisCode FROM t_Diagnosis WHERE TypeDiagnosis=1 GROUP BY rf_idCase,DiagnosisCode) d ON
			c.id=d.rf_idCase
				  INNER JOIN (
								SELECT MU,MUGroupCodeP,MUUnGroupCodeP,MUCodeP,AgeGroupShortName 
								FROM vw_sprMUCompletedCase m 
								GROUP BY MU,MUGroupCodeP,MUUnGroupCodeP,MUCodeP,AgeGroupShortName
							  ) vw_c ON
			i.MES=vw_c.MU	
WHERE c.DateEnd>='20130401'  AND c.rf_idV006<>2 AND vw_c.AgeGroupShortName=(CASE WHEN c.Age>17 THEN 'в' ELSE 'д' END)
	
IF(@outRowMES<>@@ROWCOUNT) INSERT t_SystemError(FileName,DateOperation,Error) VALUES(@fileName,GETDATE(),'Произведено соответствие не по всем ЗС.')
	
GO
