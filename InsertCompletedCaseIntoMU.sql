USE AccountOMS
GO
IF OBJECT_ID('InsertCompletedCaseIntoMU',N'TR') IS NOT NULL
DROP TRIGGER InsertCompletedCaseIntoMU
GO
CREATE TRIGGER InsertCompletedCaseIntoMU
ON dbo.t_MES
FOR INSERT
AS
--добавл€ем данные в t_Meduslugi по законченным случа€м дл€ стационара и стациоанарозамещающей помощи.
--расчет кол-ва услуг дл€ стационара ведетс€ как [дата окончани€ слуа€]-[дата начала случа€]
--расчет кол-ва услуг дл€ стационарозамещающей ведетс€ как [дата окончани€ слуа€]-[дата начала случа€]+1


	INSERT t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO,rf_idSubMO,rf_idDepartmentMO,rf_idV002,IsChildTariff,DateHelpBegin,DateHelpEnd,DiagnosisCode,
						MUGroupCode,MUUnGroupCode,MUCode,Quantity,Price,TotalPrice,rf_idV004,rf_idDoctor)
	SELECT DISTINCT  c.id,c.idRecordCase,NEWID(),c.rf_idMO,c.rf_idSubMO,c.rf_idDepartmentMO,c.rf_idV002,c.IsChildTariff,c.DateBegin,c.DateEnd,d.DiagnosisCode,
		   vw_c.MUGroupCodeP,vw_c.MUUnGroupCodeP,vw_c.MUCodeP		   
		   , case when c.rf_idV006=2 then CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2))+1 
			else (case when(CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2)))=0 then 1 else CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2))end) end
		   ,0.00,0.00,c.rf_idV004,c.rf_idDoctor
	FROM t_Case c INNER JOIN (SELECT DISTINCT * FROM inserted) i ON
			c.id=i.rf_idCase
				  INNER JOIN (SELECT rf_idCase,DiagnosisCode FROM t_Diagnosis WHERE TypeDiagnosis=1 GROUP BY rf_idCase,DiagnosisCode) d ON
			c.id=d.rf_idCase
				  INNER JOIN (
								SELECT MU,MUGroupCodeP,MUUnGroupCodeP,MUCodeP,AgeGroupShortName 
								FROM vw_sprMUCompletedCase m LEFT JOIN (SELECT MU AS MUCode FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
																		UNION ALL
																		SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
																		UNION ALL
																		SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72
																		) m1 ON
											m.MU=m1.MUCode
								WHERE m1.MUCode IS NULL
								GROUP BY MU,MUGroupCodeP,MUUnGroupCodeP,MUCodeP,AgeGroupShortName
							  ) vw_c ON
			i.MES=vw_c.MU	
	WHERE c.DateEnd<'20130401' AND vw_c.AgeGroupShortName=(CASE WHEN c.Age>17 THEN 'в' ELSE 'д' END)
	UNION ALL ----- Ќовый пор€док учета ƒневного стационара в качестве «—.  оличество услуг не считаетс€ с 01.04.2013
	SELECT DISTINCT  c.id,c.idRecordCase,NEWID(),c.rf_idMO,c.rf_idSubMO,c.rf_idDepartmentMO,c.rf_idV002,c.IsChildTariff,c.DateBegin,c.DateEnd,d.DiagnosisCode,
		   vw_c.MUGroupCodeP,vw_c.MUUnGroupCodeP,vw_c.MUCodeP		   
		   , case when(CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(9,2)))=0 then 1 else CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(9,2))end
		   ,0.00,0.00,c.rf_idV004,c.rf_idDoctor
	FROM t_Case c INNER JOIN (SELECT DISTINCT * FROM inserted) i ON
			c.id=i.rf_idCase
				  INNER JOIN (SELECT rf_idCase,DiagnosisCode FROM t_Diagnosis WHERE TypeDiagnosis=1 GROUP BY rf_idCase,DiagnosisCode) d ON
			c.id=d.rf_idCase
				  INNER JOIN (
								SELECT MU,MUGroupCodeP,MUUnGroupCodeP,MUCodeP,AgeGroupShortName 
								FROM vw_sprMUCompletedCase m LEFT JOIN (SELECT MU AS MUCode FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
																		UNION ALL
																		SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
																		UNION ALL
																		SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72																													) m1 ON
											m.MU=m1.MUCode
								WHERE m1.MUCode IS NULL
								GROUP BY MU,MUGroupCodeP,MUUnGroupCodeP,MUCodeP,AgeGroupShortName
							  ) vw_c ON
			i.MES=vw_c.MU	
	WHERE c.DateEnd>='20130401'  AND c.rf_idV006<>2 AND vw_c.AgeGroupShortName=(CASE WHEN c.Age>17 THEN 'в' ELSE 'д' END)
GO
ENABLE TRIGGER InsertCompletedCaseIntoMU ON dbo.t_MES
GO