USE AccountOMS
GO
/*
CREATE TABLE #tPeople(rf_idCase BIGINT,
					  DateBegin DATE, 
					  DateEnd DATE,
					  CodeM CHAR(6),
					  Account VARCHAR(15),
					  IdPeople BIGINT,
					  ReportMonth TINYINT,
					  V002 SMALLINT,
					  V009 SMALLINT,
					  DS VARCHAR(10),
					  FIO VARCHAR(120), 
					  DR DATE, 
					  MES VARCHAR(15),
					  AmountPayment DECIMAL(11,2), 
					  AmountRAK DECIMAL(11,2)
					  )

CREATE TABLE #tPeopleA(rf_idCase BIGINT,
						DateBegin DATE, 
						DateEnd DATE,
						CodeM CHAR(6),
						Account VARCHAR(15),
						IdPeople BIGINT,
						ReportMonth tinyint,
						V002 SMALLINT,
						V009 SMALLINT,
						DS VARCHAR(10),
						AmountPayment DECIMAL(11,2),
						AmountRAK DECIMAL(11,2)
						)

INSERT #tPeople( rf_idCase ,DateBegin ,DateEnd ,CodeM ,Account ,IdPeople,V002,V009,ReportMonth,FIO,DR,AmountPayment)
SELECT c.id,c.DateBegin,c.DateEnd,f.CodeM,a.Account,pc.IDPeople,c.rf_idV002,c.rf_idV009,a.ReportMonth
		,p.Fam+' '+p.Im+' '+ISNULL(p.Ot,''),p.BirthDay,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN (VALUES('161007'),('255601'),('175709')) v(CodeM) ON
			f.CodeM=v.CodeM
					INNER JOIN (VALUES('O'),('R'),('F'),('I'),('V'),('U'),('D')) l(Letter) ON
			a.Letter=l.Letter
					INNER JOIN dbo.t_People_Case pc ON
			c.id=pc.rf_idCase	
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20140628' AND a.ReportMonth>0 AND a.ReportMonth<6 AND a.ReportYear=2014
-------------------------------------------update block----------------------------------
UPDATE p SET p.DS=DiagnosisCode
FROM #tPeople p INNER JOIN dbo.t_Diagnosis d ON
		p.rf_idCase=d.rf_idCase
WHERE d.TypeDiagnosis=1

UPDATE p SET p.MES=m.MES
FROM #tPeople p INNER JOIN dbo.t_Mes m ON
		p.rf_idCase=m.rf_idCase

UPDATE p SET p.AmountRAK=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction 
							FROM dbo.t_PaymentAcceptedCase a INNER JOIN (VALUES('O'),('R'),('F'),('I'),('V'),('U'),('D')) l(Letter) ON
														a.Letter=l.Letter 
							WHERE DateRegistration>='20140101' AND DateRegistration<'20140628'
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
					



--------------------
INSERT #tPeopleA( rf_idCase ,DateBegin ,DateEnd ,CodeM ,Account ,IdPeople,V002,V009,ReportMonth,AmountPayment)
SELECT c.id,c.DateBegin,c.DateEnd,f.CodeM,a.Account,pc.IDPeople,c.rf_idV002,c.rf_idV009,a.ReportMonth,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN (VALUES('161007'),('255601'),('175709')) v(CodeM) ON
			f.CodeM=v.CodeM					
					INNER JOIN dbo.t_People_Case pc ON
			c.id=pc.rf_idCase	
					INNER JOIN #tPeople t ON
			pc.IDPeople=t.IdPeople
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20140628' AND a.ReportMonth>0 AND a.ReportMonth<6 AND a.ReportYear=2014 AND a.Letter='A'
-------------------------------------------update block----------------------------------				 
UPDATE p SET p.DS=DiagnosisCode
FROM #tPeopleA p INNER JOIN dbo.t_Diagnosis d ON
		p.rf_idCase=d.rf_idCase
WHERE d.TypeDiagnosis=1

UPDATE p SET p.AmountRAK=p.AmountPayment-r.AmountDeduction
FROM #tPeopleA p INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction 
							 FROM dbo.t_PaymentAcceptedCase 
							 WHERE DateRegistration>='20140101' AND DateRegistration<'20140628' AND Letter='A'
							 GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
			
*/
------------случаи когда амбулаторное лечение начато в период диспансеризации
SELECT DISTINCT t.CodeM
				,l.NAMES
				,p1.FIO
				,p1.DR
				,t.Account 
				--,t.rf_idCase 
				,c1.idRecordCase
				,t.DateBegin 
				,t.DateEnd 				
				,sprV002.name as V002 
				,sprV009_2.name as V009 
				,RTRIM(t.DS)+' - '+mkb10.Diagnosis 
				,RTRIM(p1.MES)+'-'+mu.MUName
				,t.AmountRAK	
				------------------------------------
				--,t.rf_idCase2 
				,t.Acount2 
				,c2.idRecordCase
				,t.DateBegin2 
				,t.DateEnd2
				,sprV002_2.name AS V002_2 
				,sprV009_2.name as V009_2 
				,RTRIM(t.DS2) +' - '+mkb10_2.Diagnosis				
				,t.AmountRAK2
				,t.IdPeople 			
FROM (
	SELECT t.rf_idCase ,t.DateBegin ,t.DateEnd ,t.CodeM ,t.Account ,t.IdPeople,t.V002,t.V009,t.DS,t.AmountRAK
			,t1.rf_idCase AS rf_idCase2,t1.DateBegin AS DateBegin2 ,t1.DateEnd AS DateEnd2 ,t1.Account AS Acount2,
			t1.V002 AS V002_2,t1.V009 AS V009_2,t1.DS AS DS2, t1.AmountRAK AS AmountRAK2
	FROM #tPeople t INNER JOIN #tPeopleA t1 ON
			t.IdPeople=t1.IdPeople
			AND t.CodeM=t1.CodeM
	WHERE t1.DateBegin>=t.DateBegin AND t1.DateBegin<=t.DateEnd AND ISNULL(t.AmountRAK,'-1')>0 AND ISNULL(t1.AmountRAK,'-1')>0 
	UNION All
	------------случаи когда диспансеризация начато в период амбулаторного лечения
	SELECT  t.rf_idCase ,t.DateBegin ,t.DateEnd ,t.CodeM ,t.Account ,t.IdPeople,t.V002,t.V009,t.DS,t.AmountRAK,
			t1.rf_idCase ,t1.DateBegin ,t1.DateEnd ,t1.Account,t1.V002,t1.V009,t1.DS, t1.AmountRAK  
	FROM #tPeople t INNER JOIN #tPeopleA t1 ON
			t.IdPeople=t1.IdPeople
			AND t.CodeM=t1.CodeM
	WHERE t.DateBegin>=t1.DateBegin AND t.DateBegin<=t1.DateEnd	AND ISNULL(t.AmountRAK,'-1')>0 AND ISNULL(t1.AmountRAK,'-1')>0 
	) t INNER JOIN dbo.vw_sprT001 l ON
			t.CodeM=l.CodeM
		INNER JOIN RegisterCases.dbo.vw_sprV002 sprV002 ON
			t.V002=sprV002.id
		INNER JOIN RegisterCases.dbo.vw_sprV002 sprV002_2 ON
			t.V002_2=sprV002_2.id
			INNER JOIN RegisterCases.dbo.vw_sprV009 sprV009 ON
			t.V009=sprV009.id
		INNER JOIN RegisterCases.dbo.vw_sprV009 sprV009_2 ON
			t.V009_2=sprV009_2.id
		INNER JOIN dbo.vw_sprMKB10 mkb10 ON
			t.DS=mkb10.DiagnosisCode
		INNER JOIN dbo.vw_sprMKB10 mkb10_2 ON
			t.DS2=mkb10_2.DiagnosisCode
		INNER JOIN #tPeople p1 ON
			t.rf_idCase=p1.rf_idCase
		INNER JOIN dbo.t_Case c1 ON
			t.rf_idCase=c1.id
		INNER JOIN dbo.t_Case c2 ON
			t.rf_idCase2=c2.id
		left JOIN  dbo.vw_sprMU mu ON
			p1.MES=MU.MU
go
DROP TABLE #tPeople
DROP TABLE #tPeopleA
