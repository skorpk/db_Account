USE AccountOMSReports
GO
DECLARE @reportYear SMALLINT=2019,
		@dateStart DATETIME='20190101',--всегда с начало года берутся случаи
		@dateEnd DATE='20190601',		
		@dateStartPay DATETIME='20190610',--всегда с 10 числа отчетного месяца. В сентябре 2017 конечная дата изменилась, теперь нужно брать с 6 числа и по 10 число следующего месяца
		@dateEndPay DATETIME='20190710'

SELECT c.id
INTO #t1
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
			c.id=p.rf_idCase                  
WHERE f.DateRegistration>'20190101' AND f.DateRegistration<'20190615' AND a.ReportYear=2019 AND c.rf_idV006=1
		AND d.TypeDiagnosis=1 AND d.DiagnosisCode LIKE 'J4[0-2]%' 
          

CREATE TABLE #tPeople(
					  rf_idCase BIGINT,					 
					  AmountPayment DECIMAL(11,2) NOT NULL DEFAULT(0), 
					  CodeM CHAR(6),
					  rf_idV006 TINYINT,
					  rf_idV002 SMALLINT,
					  DateBegin DATE,
					  DateEnd DATE,
					  AmountPaymentAccepted decimal(11,2),
					   AmountPaymentAcceptedZSL decimal(11,2),
					  rf_idDepartmentMO VARCHAR(6) ,					  
					  TypeCases TINYINT,
					  IDSP TINYINT
					  )
--зачищаю сведения
--TRUNCATE TABLE dbo.t_SendingDataIntoFFOMS
/*
09.02.2019
случаи оказания медицинской помощи в дневном стационаре, в которых применяется способ оплаты 43 или 33, за исключением случаев, в которых применяются следующие коды КСГ
*/
INSERT #tPeople( rf_idCase ,CodeM ,rf_idV006 ,rf_idV002,DateBegin,DateEnd, AmountPaymentAccepted,rf_idDepartmentMO,TypeCases,IDSP,AmountPaymentAcceptedZSL)
SELECT c.id,c.rf_idMO ,c.rf_idV006 ,c.rf_idV002, c.DateBegin,c.DateEnd,c.AmountPayment, CAST(c.rf_idDepartmentMO AS VARCHAR(6)), 9,c.rf_idV010,cc.AmountPayment
FROM dbo.t_Case c INNER JOIN (VALUES(1,33,32),(2,43,null),(2,33,null)) v(v006,v010,V008) ON
			c.rf_idv006=v.v006
			AND c.rf_idv010=v.v010  				 
			AND c.rf_idV008<>ISNULL(v.v008,0)
					INNER JOIN dbo.t_CompletedCase cc ON
			c.rf_idRecordCasePatient=cc.rf_idRecordCasePatient 
					INNER JOIN #t1 t ON
			c.id=t.id
WHERE c.DateEnd>@dateStart AND c.DateEnd<@dateEnd AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.MUGroupCode=60 AND m.MUUnGroupCode=3 AND m.rf_idCase=c.id)

/*
09.02.2019
- начиная с отчетного периода 2018 год случаи проведения заместительной почечной терапии в условиях стационара (USL_OK=1), 
дневного стационара (USL_OK=2) и амбулаторно (USL_OK=3): случаи, содержащие на уровне услуг хотя бы одну услугу с кодом группы 60.3.*, 
способ оплаты по данным случаям – 4 лечебно-диагностическая процедура или 33, или 28.
*/
	INSERT #tPeople( rf_idCase ,CodeM ,rf_idV006 ,rf_idV002,DateBegin,DateEnd, AmountPaymentAccepted,rf_idDepartmentMO,TypeCases,IDSP,AmountPaymentAcceptedZSL)
	SELECT distinct c.id,c.rf_idMO ,c.rf_idV006 ,c.rf_idV002, c.DateBegin,c.DateEnd,c.AmountPayment, CAST(c.rf_idDepartmentMO AS VARCHAR(6)), 10,CASE WHEN c.rf_idV010=43 THEN 33 ELSE c.rf_idV010 END, cc.AmountPayment
	FROM dbo.t_Case c INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.t_CompletedCase cc ON
			c.rf_idRecordCasePatient=cc.rf_idRecordCasePatient
						INNER JOIN #t1 t ON
			c.id=t.id
	WHERE c.rf_idV010 IN(4,33,28,43) AND c.rf_idV006<4 AND c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd AND m.MUGroupCode=60 AND m.MUUnGroupCode=3--указан 43 способ оплаты т.к ДС оплачивается в основном по нем если есть КСГ
--END 
--------------------------------------Update information about RPD---------------------------

--За январь нету оплаты
UPDATE p SET p.AmountPayment=r.AmountPayment
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountPaymentAccept) AS AmountPayment
							FROM dbo.t_PaidCase p INNER  JOIN #tPeople t ON			
												p.rf_idCase=t.rf_idCase
							WHERE p.DateRegistration>=@dateStartPay AND p.DateRegistration<@dateEndPay	 
							GROUP BY t.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
 
-----снятия смотрим по законченному случаю
UPDATE p SET p.AmountPaymentAcceptedZSL=p.AmountPaymentAcceptedZSL-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCase2 p INNER  JOIN #tPeople t ON			
												p.rf_idCase=t.rf_idCase
							WHERE p.DateRegistration>=@dateStart AND p.DateRegistration<@dateEndPay	 
							GROUP BY t.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
/*отбираем номенклатуру для диализа*/
SELECT DISTINCT MUSurgery
INTO #t
FROM (VALUES ('60.3.2','A18.05.002.002'),('60.3.3','A18.05.002.001'),('60.3.4','A18.05.011'),('60.3.5','A18.05.002.003'),('60.3.6','A18.05.003'),
										('60.3.7','A18.05.003.001'),('60.3.8','A18.30.001.001'),('60.3.9','A18.05.002.002'),('60.3.10','A18.05.002.001'),('60.3.1','A18.30.001')
										,('60.3.11','A18.05.011'),('60.3.12','A18.30.001.002')) v(MU,MuSurgery)
--------------------------------------------------------------------------------------------------------------------------
;WITH UnitOfHosp
AS
(
SELECT rf_idCase,p.DateBegin,p.DateEnd
	,CASE WHEN p.rf_idDepartmentMO IS NULL THEN p.CodeM+'.'+CAST(p.rf_idV006 AS varchar(3))+'.'+CAST(p.rf_idV002 AS varchar(5))
			ELSE p.CodeM+'.'+p.rf_idDepartmentMO+'.'+CAST(p.rf_idV006 AS varchar(3)) END AS UnitOfHospital
	,TypeCases,IDSP, AmountPaymentAcceptedZSL
FROM #tPeople p 
WHERE /*AmountPayment=AmountPaymentAccepted AND*/ AmountPaymentAcceptedZSL>0--полная оплата. не считаем оплату т.к. ее еще нету
),
data_Send AS (
SELECT DISTINCT c.id AS rf_idCase,c.rf_idMO AS CodeM,a.rf_idMO,a.ReportMonth,a.ReportYear,r.rf_idF008,c.rf_idV006,r.SeriaPolis,r.NumberPolis,p.BirthDay,p.rf_idV005
		,c.idRecordCase,c.rf_idV014,u.UnitOfHospital,c.DateBegin,c.DateEnd,
		d.DS1, d.DS2, d.DS3,c.rf_idV009
		,m.MES,case when SUBSTRING(m.MES,3,1)='2' THEN 1 ELSE 0 END IsDelete--не учитываются случаи реабилитации
		,c.AmountPayment,mu.id AS idMU, mu.MUSurgery
		,c.Age,CASE WHEN c.Age>0 AND c.Age<4 THEN 4
					WHEN c.age>3 AND c.Age<18 THEN 5
					WHEN c.Age>17 AND c.Age<60 THEN 6
					WHEN c.Age>59 AND c.Age<75 THEN 7
					WHEN c.Age>74 THEN 8
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>28 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<91 THEN 2
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>90 THEN 3
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<29 THEN 1
				/*ELSE 3*/ END AS VZST
		,CASE WHEN csg.codePGR IS NOT null THEN csg.codePGR ELSE csg.codeMinZdrav END AS K_KSG
		,CASE WHEN csg.codePGR IS NOT null THEN 1 ELSE 0 END AS KSG_PG
		,c.IT_SL,ps.ENP,TypeCases, NULL AS Quantity, NULL AS TotalPriceMU, csg.NoLevelCoefficient AS UR_K
		,cc.AmountPayment AS AmountPaymentZSL,u.IDSP
FROM UnitOfHosp u INNER JOIN dbo.t_Case c ON
		u.rf_idCase=c.id
					INNER JOIN dbo.t_RecordCasePatient r ON
		r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegistersAccounts a ON
		a.id=r.rf_idRegistersAccounts					                  
					INNER JOIN dbo.t_RegisterPatient p ON --vw_RegisterPatient
		r.id=p.rf_idRecordCase                 
					INNER JOIN dbo.vw_Diagnosis d ON 
		c.id=d.rf_idCase
					INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase
					INNER JOIN dbo.vw_sprCSG csg ON
		m.MES=csg.code		
					INNER JOIN dbo.t_PatientSMO ps ON
		r.id=ps.rf_idRecordCasePatient                  
					LEFT JOIN (SELECT rf_idCase,MUSurgery,id FROM dbo.t_Meduslugi WHERE MUSurgery IS NOT NULL ) mu ON
		c.id=mu.rf_idCase     
WHERE TypeCases=9 
UNION ALL
SELECT DISTINCT c.id AS rf_idCase,c.rf_idMO AS CodeM,a.rf_idMO,a.ReportMonth,a.ReportYear,r.rf_idF008,c.rf_idV006,r.SeriaPolis,r.NumberPolis,p.BirthDay,p.rf_idV005
		,c.idRecordCase,c.rf_idV014,u.UnitOfHospital,c.DateBegin,c.DateEnd,
		d.DS1, d.DS2, d.DS3,c.rf_idV009
		,mes.MES AS MES,0 IsDelete--не учитываются случаи реабилитации
		,c.AmountPayment,m.id AS idMU, v.MUSurgery
		,c.Age,CASE WHEN c.Age>0 AND c.Age<4 THEN 4
					WHEN c.age>3 AND c.Age<18 THEN 5
					WHEN c.Age>17 AND c.Age<60 THEN 6
					WHEN c.Age>59 AND c.Age<75 THEN 7
					WHEN c.Age>74 THEN 8
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>28 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<91 THEN 2
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>90 THEN 3
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<29 THEN 1
				/*ELSE 3*/ END AS VZST
		,CASE WHEN IDSP IN(4,28) THEN 'DIAL' ELSE NULL END AS K_KSG
		,0 AS KSG_PG
		,c.IT_SL,ps.ENP,TypeCases,CAST(m.Quantity AS INT) AS Quantity, m.TotalPrice,ISNULL(NULL,0) AS NoLevelCoefficient
		,cc.AmountPayment AS AmountPaymentZSL,u.IDSP
FROM UnitOfHosp u INNER JOIN dbo.t_Case c ON
		u.rf_idCase=c.id
					INNER JOIN dbo.t_RecordCasePatient r ON
		r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegistersAccounts a ON
		a.id=r.rf_idRegistersAccounts					                  
					INNER JOIN dbo.t_RegisterPatient p ON --vw_RegisterPatient
		r.id=p.rf_idRecordCase                 					
					INNER JOIN dbo.vw_Diagnosis d ON 
		c.id=d.rf_idCase										
					INNER JOIN dbo.t_PatientSMO ps ON
		r.id=ps.rf_idRecordCasePatient                  
					INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase     
					INNER JOIN (VALUES ('60.3.2','A18.05.002.002'),('60.3.3','A18.05.002.001'),('60.3.4','A18.05.011'),('60.3.5','A18.05.002.003'),('60.3.6','A18.05.003'),
										('60.3.7','A18.05.003.001'),('60.3.8','A18.30.001.001'),('60.3.9','A18.05.002.002'),('60.3.10','A18.05.002.001'),('60.3.1','A18.30.001')
										,('60.3.11','A18.05.011'),('60.3.12','A18.30.001.002')) v(MU,MuSurgery) ON
		m.MU=v.MU                              
					left JOIN t_Mes mes ON
		c.id=mes.rf_idCase
		AND mes.TypeMES=2        
WHERE TypeCases=10 AND IDSP IN(4,28)	
UNION ALL
SELECT DISTINCT c.id AS rf_idCase,c.rf_idMO AS CodeM,a.rf_idMO,a.ReportMonth,a.ReportYear,r.rf_idF008,c.rf_idV006,r.SeriaPolis,r.NumberPolis,p.BirthDay,p.rf_idV005
		,c.idRecordCase,c.rf_idV014,u.UnitOfHospital,c.DateBegin,c.DateEnd,
		d.DS1, d.DS2, d.DS3,c.rf_idV009
		,mes.MES AS MES,0 IsDelete--не учитываются случаи реабилитации
		,c.AmountPayment,m.id AS idMU, v.MUSurgery
		,c.Age,CASE WHEN c.Age>0 AND c.Age<4 THEN 4
					WHEN c.age>3 AND c.Age<18 THEN 5
					WHEN c.Age>17 AND c.Age<60 THEN 6
					WHEN c.Age>59 AND c.Age<75 THEN 7
					WHEN c.Age>74 THEN 8
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>28 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<91 THEN 2
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>90 THEN 3
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<29 THEN 1
				/*ELSE 3*/ END AS VZST		
		,CASE WHEN csg.codePGR IS NOT null THEN csg.codePGR ELSE csg.codeMinZdrav END AS K_KSG
		,CASE WHEN csg.codePGR IS NOT null THEN 1 ELSE 0 END AS KSG_PG
		,c.IT_SL,ps.ENP,TypeCases,CAST(m.Quantity AS INT) AS Quantity, m.TotalPrice,ISNULL(NULL,0) AS NoLevelCoefficient
		,cc.AmountPayment AS AmountPaymentZSL,u.IDSP
FROM UnitOfHosp u INNER JOIN dbo.t_Case c ON
		u.rf_idCase=c.id
					INNER JOIN dbo.t_RecordCasePatient r ON
		r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegistersAccounts a ON
		a.id=r.rf_idRegistersAccounts					                  
					INNER JOIN dbo.t_RegisterPatient p ON --vw_RegisterPatient
		r.id=p.rf_idRecordCase                 					
					INNER JOIN dbo.vw_Diagnosis d ON 
		c.id=d.rf_idCase										
					INNER JOIN dbo.t_PatientSMO ps ON
		r.id=ps.rf_idRecordCasePatient                  
					INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase     
					INNER JOIN (VALUES ('60.3.2','A18.05.002.002'),('60.3.3','A18.05.002.001'),('60.3.4','A18.05.011'),('60.3.5','A18.05.002.003'),('60.3.6','A18.05.003'),
										('60.3.7','A18.05.003.001'),('60.3.8','A18.30.001.001'),('60.3.9','A18.05.002.002'),('60.3.10','A18.05.002.001'),('60.3.1','A18.30.001')
										,('60.3.11','A18.05.011'),('60.3.12','A18.30.001.002')) v(MU,MuSurgery) ON
		m.MU=v.MU                              
					INNER JOIN t_Mes mes ON
		c.id=mes.rf_idCase
		AND mes.TypeMES=2 
					INNER JOIN dbo.vw_sprCSG csg ON
		mes.MES=csg.code						   
WHERE TypeCases=10 AND IDSP=33		            
---------------------------Берем услуги у которыг VID_VME есть для диализа, но которые не диализ---------------------------------------
UNION ALL
SELECT DISTINCT c.id AS rf_idCase,c.rf_idMO AS CodeM,a.rf_idMO,a.ReportMonth,a.ReportYear,r.rf_idF008,c.rf_idV006,r.SeriaPolis,r.NumberPolis,p.BirthDay,p.rf_idV005
		,c.idRecordCase,c.rf_idV014,u.UnitOfHospital,c.DateBegin,c.DateEnd,
		d.DS1, d.DS2, d.DS3,c.rf_idV009
		,mes.MES AS MES,0 IsDelete--не учитываются случаи реабилитации
		,c.AmountPayment,mu1.id AS idMU, mu1.MUSurgery
		,c.Age,CASE WHEN c.Age>0 AND c.Age<4 THEN 4
					WHEN c.age>3 AND c.Age<18 THEN 5
					WHEN c.Age>17 AND c.Age<60 THEN 6
					WHEN c.Age>59 AND c.Age<75 THEN 7
					WHEN c.Age>74 THEN 8
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>28 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<91 THEN 2
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>90 THEN 3
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<29 THEN 1
				/*ELSE 3*/ END AS VZST		
		,CASE WHEN csg.codePGR IS NOT null THEN csg.codePGR ELSE csg.codeMinZdrav END AS K_KSG
		,CASE WHEN csg.codePGR IS NOT null THEN 1 ELSE 0 END AS KSG_PG
		,c.IT_SL,ps.ENP,TypeCases,null AS Quantity, NULL,ISNULL(NULL,0) AS NoLevelCoefficient
		,cc.AmountPayment AS AmountPaymentZSL,u.IDSP
FROM UnitOfHosp u INNER JOIN dbo.t_Case c ON
		u.rf_idCase=c.id
					INNER JOIN dbo.t_RecordCasePatient r ON
		r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegistersAccounts a ON
		a.id=r.rf_idRegistersAccounts					                  
					INNER JOIN dbo.t_RegisterPatient p ON --vw_RegisterPatient
		r.id=p.rf_idRecordCase                 					
					INNER JOIN dbo.vw_Diagnosis d ON 
		c.id=d.rf_idCase										
					INNER JOIN dbo.t_PatientSMO ps ON
		r.id=ps.rf_idRecordCasePatient                  
					INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase    
		AND m.MUGroupCode=60 AND m.MUUnGroupCode=3 					                      
					INNER JOIN t_Mes mes ON
		c.id=mes.rf_idCase
		AND mes.TypeMES=2 
					INNER JOIN dbo.vw_sprCSG csg ON
		mes.MES=csg.code	
					INNER JOIN dbo.t_Meduslugi mu1 ON
		c.id=mu1.rf_idCase       
		AND mu1.MUSurgery IS NOT NULL		
WHERE TypeCases=10 AND IDSP=33	AND NOT EXISTS(SELECT 1 FROM #t WHERE mu1.MUSurgery=MUSurgery)	
)
SELECT  DENSE_RANK() OVER(ORDER BY rf_idCase ,ReportYear,ReportMonth) AS id, rf_idCase ,CodeM ,rf_idMO ,CAST(MONTH(@dateStartPay) AS TINYINT) AS ReportMonth 
		,CAST(YEAR(@dateStartPay) AS SMALLINT) AS ReportYear,
        rf_idF008 ,rf_idV006 ,SeriaPolis ,NumberPolis ,BirthDay ,rf_idV005 ,idRecordCase ,rf_idV014 ,UnitOfHospital ,
        DateBegin ,DateEnd ,DS1 ,DS2 ,DS3 ,rf_idV009 ,MES ,AmountPayment ,idMU ,MUSurgery ,Age ,VZST ,K_KSG ,KSG_PG,0 PVT,0 AS IsDisableCheck,IT_SL,ENP,TypeCases,Quantity
		,TotalPriceMU, UR_K,IDSP,AmountPaymentZSL
FROM data_Send 
WHERE NOT EXISTS(SELECT * FROM dbo.t_SendingDataIntoFFOMS WHERE rf_idCase=data_Send.rf_idCase)--включение случая происходит только один раз
GO
DROP TABLE #t
go
DROP TABLE #t1
GO
DROP TABLE #tPeople