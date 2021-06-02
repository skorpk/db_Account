USE AccountOMS
GO
---Таблица t_PaidCase и другие таблицы должны присутствовать на сервере
CREATE PROCEDURE usp_SendingDataToFFOMS
		@reportYear SMALLINT,
		@dateStart DATETIME,--всегда с начало года берутся случаи
		@dateEnd DATE,		
		@dateStartPay DATETIME,--всегда с 10 числа отчетного месяца. В сентябре 2017 конечная дата изменилась, теперь нужно брать с 6 числа и по 10 число следующего месяца
		@dateEndPay DATETIME
as
--случаи с данными КСГ не должны попасть в выборку
DECLARE @tCSGDisable AS TABLE(CSG VARCHAR(19), rf_idV006 TINYINT)
INSERT @tCSGDisable
        ( CSG, rf_idV006 )
VALUES  ('1000901',1),('1000902',1),('1000903',1),('1000905',1),('1000906',1),('1000907',1),('1000913',1),('2000912',2),('2000916',2),('2000917',2),('2000918',2),('2000919',2),
('10000901',1),('10000902',1),('10000903',1), ('10000905',1),('10000906',1),('10000907',1),('10000913',1), ('2000920',2),('20000912',2),('20000916',2),('20000917',2),('20000918',2),
('20000919',2),('20000920',2)

CREATE TABLE #tPeople(
					  rf_idCase BIGINT,					 
					  AmountPayment DECIMAL(11,2) NOT NULL DEFAULT(0), 
					  CodeM CHAR(6),
					  rf_idV006 TINYINT,
					  rf_idV002 SMALLINT,
					  DateBegin DATE,
					  DateEnd DATE,
					  AmountPaymentAccepted decimal(11,2),
					  rf_idDepartmentMO VARCHAR(6) ,					  
					  TypeCases TINYINT
					  )
--23.08.2017 добавленно поле rf_idDepartmentMO, которое участвует в формировании Кода отделений.Это связанно с появлением подразделений у некоторых МО.
INSERT #tPeople( rf_idCase ,CodeM ,rf_idV006 ,rf_idV002,DateBegin,DateEnd, AmountPaymentAccepted,rf_idDepartmentMO,TypeCases)
SELECT c.id,c.rf_idMO ,c.rf_idV006 ,c.rf_idV002, c.DateBegin,c.DateEnd,c.AmountPayment, CAST(c.rf_idDepartmentMO AS VARCHAR(6)), 9
FROM dbo.t_Case c INNER JOIN (VALUES(1,33,32),(2,43,null)) v(v006,v010,V008) ON
			c.rf_idv006=v.v006
			AND c.rf_idv010=v.v010  				 
			AND c.rf_idV008<>ISNULL(v.v008,0)
WHERE c.DateEnd>@dateStart AND c.DateEnd<@dateEnd

IF @reportYear>2017
BEGIN 
	INSERT #tPeople( rf_idCase ,CodeM ,rf_idV006 ,rf_idV002,DateBegin,DateEnd, AmountPaymentAccepted,rf_idDepartmentMO,TypeCases)
	SELECT distinct c.id,c.rf_idMO ,c.rf_idV006 ,c.rf_idV002, c.DateBegin,c.DateEnd,c.AmountPayment, CAST(c.rf_idDepartmentMO AS VARCHAR(6)), 10
	FROM dbo.t_Case c INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
	WHERE c.rf_idV010=4 AND c.rf_idV006<4 AND c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd  AND m.MUGroupCode=60 AND m.MUUnGroupCode=3
END 
--------------------------------------Update information about RPD---------------------------
UPDATE p SET p.AmountPayment=r.AmountPayment
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountPaymentAccept) AS AmountPayment
							FROM dbo.t_PaidCase p INNER  JOIN #tPeople t ON			
												p.rf_idCase=t.rf_idCase
							WHERE p.DateRegistration>=@dateStartPay AND p.DateRegistration<@dateEndPay	 
							GROUP BY t.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

UPDATE p SET p.AmountPaymentAccepted=p.AmountPaymentAccepted-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCase2 p INNER  JOIN #tPeople t ON			
												p.rf_idCase=t.rf_idCase
							WHERE p.DateRegistration>=@dateStart AND p.DateRegistration<@dateEndPay	 
							GROUP BY t.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


;WITH UnitOfHosp
AS
(
SELECT rf_idCase,p.DateBegin,p.DateEnd
	,CASE WHEN p.rf_idDepartmentMO IS NULL THEN p.CodeM+'.'+CAST(p.rf_idV006 AS varchar(3))+'.'+CAST(p.rf_idV002 AS varchar(5))
			ELSE p.CodeM+'.'+p.rf_idDepartmentMO+'.'+CAST(p.rf_idV006 AS varchar(3)) END AS UnitOfHospital
	,TypeCases
FROM #tPeople p 
WHERE AmountPayment=AmountPaymentAccepted AND AmountPaymentAccepted>0--полная оплата
),
data_Send AS (
SELECT DISTINCT c.id AS rf_idCase,c.rf_idMO AS CodeM,a.rf_idMO,a.ReportMonth,a.ReportYear,r.rf_idF008,c.rf_idV006,r.SeriaPolis,r.NumberPolis,p.BirthDay,p.rf_idV005
		,c.idRecordCase,c.rf_idV014,u.UnitOfHospital,c.DateBegin,c.DateEnd,
		d.DS1, d.DS2, d.DS3,c.rf_idV009
		,m.MES,case when SUBSTRING(m.MES,3,1)='2' THEN 1 ELSE 0 END IsDelete--не учитываются случаи реабилитации
		,c.AmountPayment,mu.id AS idMU, mu.MUSurgery
		,c.Age,CASE WHEN c.Age>0 AND c.Age<18 THEN 4
					WHEN c.age>17 AND c.Age<75 THEN 5
					WHEN c.Age>74 THEN 6
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>28 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<91 THEN 2
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<29 THEN 1
				ELSE 3 END AS VZST
		,CASE WHEN csg.codePGR IS NOT null THEN csg.codePGR ELSE csg.codeMinZdrav END AS K_KSG
		,CASE WHEN csg.codePGR IS NOT null THEN 1 ELSE 0 END AS KSG_PG
		,c.IT_SL,ps.ENP,TypeCases
FROM UnitOfHosp u INNER JOIN dbo.t_Case c ON
		u.rf_idCase=c.id
					INNER JOIN dbo.t_RecordCasePatient r ON
		r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegistersAccounts a ON
		a.id=r.rf_idRegistersAccounts					                  
					INNER JOIN dbo.vw_RegisterPatient p ON
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
WHERE TypeCases=9 AND NOT EXISTS(SELECT * FROM @tCSGDisable t WHERE t.CSG=m.MES AND t.rf_idV006=c.rf_idV006)
UNION ALL
SELECT DISTINCT c.id AS rf_idCase,c.rf_idMO AS CodeM,a.rf_idMO,a.ReportMonth,a.ReportYear,r.rf_idF008,c.rf_idV006,r.SeriaPolis,r.NumberPolis,p.BirthDay,p.rf_idV005
		,c.idRecordCase,c.rf_idV014,u.UnitOfHospital,c.DateBegin,c.DateEnd,
		d.DS1, d.DS2, d.DS3,c.rf_idV009
		,NULL AS MES,0 IsDelete--не учитываются случаи реабилитации
		,c.AmountPayment,m.id AS idMU, v.MUSurgery
		,c.Age,CASE WHEN c.Age>0 AND c.Age<18 THEN 4
					WHEN c.age>17 AND c.Age<75 THEN 5
					WHEN c.Age>74 THEN 6
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)>28 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<91 THEN 2
					WHEN c.Age=0 AND DATEDIFF(DAY,p.BirthDay,c.DateBegin)<29 THEN 1
				ELSE 3 END AS VZST
		,'DIAL' AS K_KSG
		,0 AS KSG_PG
		,c.IT_SL,ps.ENP,TypeCases
FROM UnitOfHosp u INNER JOIN dbo.t_Case c ON
		u.rf_idCase=c.id
					INNER JOIN dbo.t_RecordCasePatient r ON
		r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegistersAccounts a ON
		a.id=r.rf_idRegistersAccounts					                  
					INNER JOIN dbo.vw_RegisterPatient p ON
		r.id=p.rf_idRecordCase                 
					INNER JOIN dbo.vw_Diagnosis d ON 
		c.id=d.rf_idCase										
					INNER JOIN dbo.t_PatientSMO ps ON
		r.id=ps.rf_idRecordCasePatient                  
					INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase     
					INNER JOIN (VALUES ('60.3.2','A18.05.002.002'),('60.3.3','A18.05.002.001'),('60.3.4','A18.05.011'),('60.3.5','A18.05.002.003'),('60.3.6','A18.05.003'),
										('60.3.7','A18.05.003.001'),('60.3.8','A18.30.001.001'),('60.3.9','A18.05.002.002'),('60.3.10','A18.05.002.001'),('60.3.1','A18.30.001')) v(MU,MuSurgery) ON
		m.MU=v.MU                                      
WHERE TypeCases=10 		            
)
INSERT dbo.t_SendingDataIntoFFOMS( id ,rf_idCase ,CodeM ,rf_idMO ,ReportMonth ,ReportYear ,rf_idF008 ,rf_idV006 ,SeriaPolis ,NumberPolis ,BirthDay ,
          rf_idV005 ,idRecordCase ,rf_idV014 ,UnitOfHospital ,DateBegin ,DateEnd ,DS1 ,DS2 ,DS3 ,rf_idV009 ,MES ,AmountPayment ,idMU ,MUSurgery ,
          Age ,VZST ,K_KSG ,KSG_PG ,PVT ,IsDisableCheck,IT_SL, ENP, TypeCases) 
SELECT ROW_NUMBER() OVER(ORDER BY ReportYear,ReportMonth) AS id, rf_idCase ,CodeM ,rf_idMO ,MONTH(@dateStartPay) ,YEAR(@dateStartPay),
        rf_idF008 ,rf_idV006 ,SeriaPolis ,NumberPolis ,BirthDay ,rf_idV005 ,idRecordCase ,rf_idV014 ,UnitOfHospital ,
        DateBegin ,DateEnd ,DS1 ,DS2 ,DS3 ,rf_idV009 ,MES ,AmountPayment ,idMU ,MUSurgery ,Age ,VZST ,K_KSG ,KSG_PG,0 PVT,0 AS IsDisableCheck,IT_SL,ENP,TypeCases
FROM data_Send 
WHERE IsDelete=0 AND NOT EXISTS(SELECT * FROM dbo.t_SendingDataIntoFFOMS WHERE rf_idCase=data_Send.rf_idCase)--включение случая происходит только один раз



--------------------------------------------------------------------------------------------------------------------------
--произвести расчет PVT
----перекодировка символов DS2 и DS3
UPDATE f SET f.DS2=v.DS_T
FROM dbo.t_SendingDataIntoFFOMS f INNER JOIN dbo.t_DS_Recode v ON
					ISNULL(f.DS2,'bla-bla')=v.DS_w
WHERE ReportYear>=2018 AND IsUnload=0
UPDATE f SET f.DS3=v.DS_T
FROM dbo.t_SendingDataIntoFFOMS f INNER JOIN dbo.t_DS_Recode v ON
					ISNULL(f.DS3,'bla-bla')=v.DS_w
WHERE ReportYear>=2018 AND IsUnload=0
UPDATE f SET f.DS1=v.DS_T
FROM dbo.t_SendingDataIntoFFOMS f INNER JOIN dbo.t_DS_Recode v ON
					f.DS1=v.DS_w
WHERE reportYear>=2018 AND IsUnload=0

UPDATE dbo.t_SendingDataIntoFFOMS SET DS1='M45' WHERE DS1='M45.8' AND ReportYear>=2018
UPDATE dbo.t_SendingDataIntoFFOMS SET DS1='J47' WHERE DS1='J47.0' AND ReportYear>=2018


UPDATE dbo.t_SendingDataIntoFFOMS SET MUSurgery=NULL, idMU=NULL
WHERE MUSurgery IN ('B03.001.002','B03.001.003','B03.003.005','A16.04.064') AND ReportYear>2017


UPDATE s SET s.MUSurgery=v.MU
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN (VALUES ('B01.001.006.001','B01.001.006'),('B01.001.009.001','B01.001.009 '),('A11.20.025','A11.20.027')) v(MU_E, MU) ON
			s.MUSurgery=v.MU_E
--WHERE IsUnload=0
UPDATE s SET s.MUSurgery=null, s.idMU=NULL
FROM dbo.t_SendingDataIntoFFOMS s
WHERE IsUnload=0 AND s.MUSurgery IS NOT null AND s.ReportYear>=2018 AND NOT EXISTS(SELECT * FROM dbo.t_MUSurgery_23 WHERE MUSurgery=s.MUSurgery)

DROP TABLE #tPeople
GO