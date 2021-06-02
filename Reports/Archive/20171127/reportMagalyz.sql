USE AccountOMS
GO
DECLARE @dtStart DATETIME='20170101',
		@dtEnd DATETIME='20171121 23:59:59',
		@reportYear SMALLINT=2017,
		@reportMonth tinyint=11


SELECT f.Fam,f.Im,CASE WHEN f.OT='' THEN NULL ELSE f.Ot END AS OT , CONVERT(DATE,f.DR,104) AS Dr
into #tmpPeople
FROM ( values('Аверина','Любовь','Викторовна','06.06.1969'),
('Аникиенко','Андрей','Витальевич','05.05.1968'),
('Аношин','Роман','Викторович','12.09.1974'),
('Аристов','Николай','Михайлович','01.10.1959'),
('Бадыкшанов','Рустам','Закизянович','18.10.1936'),
('Баташев','Ханлар','Сейпелиевич','14.02.1960'),
('Богатырев','Николай','Павлович','11.10.1948'),
('Бондаренко','Александр','Николаевич','24.01.1962'),
('Бондаренко','Виктор','Федорович','02.02.1957'),
('Бочковой','Александр','Владимирович','16.01.1954'),
('Бурлакова','Таиса','Ивановна','23.10.1947'),
('Быкадорова','Таисия','Афанасьевна','17.07.1939'),
('Варламов','Виталий','Иванович','08.10.1958'),
('Васильев','Виктор','Николаевич','25.05.1962'),
('Вдовенко','Александр','Михайлович','28.10.1936'),
('Вершинина','Зоя','Николаевна','28.05.1926'),
('Викторов','Владимир','Алексеевич','12.03.1969'),
('Воробьев','Валерий','Николаевич','21.09.1962'),
('Городков','Александр','Петрович','03.04.1957'),
('Грибенников','Александр','Тимофеевич','10.10.1954'),
('Донцов','Лазарь','Тарасович','14.01.1943'),
('Дрябрин','Сергей','Юрьевич','14.09.1969'),
('Емельянов','Николай','Александрович','21.12.1948'),
('Ермилова','Светлана','Николаевна','23.07.1954'),
('Ерофеева','Валентина','Денисовна','08.03.1939'),
('Ефремов','Владимир','Павлович','06.02.1947'),
('Жиряков','Павел','Евгеньевич','10.12.1958'),
('Захаров','Сергей','Викторович','25.02.1967'),
('Зеленов','Сергей','Анатольевич','26.08.1957'),
('Зубков','Вячеслав','Валерьевич','12.06.1981'),
('Зубов','Анатолий','Геннадьевич','04.07.1948'),
('Зуев','Владимир','Васильевич','13.01.1950'),
('Иванов','Виталий','Викторович','05.12.1971'),
('Искалиева','Айман','-','30.01.1945'),
('Кириченко','Борис','Борисович','10.10.1948'),
('Кондрашов','Александр','Анатольевич','02.08.1961'),
('Коненков','Александр','Петрович','22.05.1962'),
('Копцева','Светлана','Константиновна','05.01.1971'),
('Коробкина','Любовь','Сергеевна','04.03.1941'),
('Коротков','Виктор','Павлович','25.06.1953'),
('Коршунова','Галина','Владимировна','29.05.1953'),
('Кочкина','Елена','Михайловна','26.05.1964'),
('Кривцов','Николай','Павлович','28.10.1950'),
('Крынин','Владимир','Петрович','19.10.1948'),
('Куницын','Петр','Васильевич','20.10.1936'),
('Ламзин','Виктор','Степанович','25.08.1940'),
('Лапшова','Рита','Алексеевна','26.03.1963'),
('Лобода','Степан','Владимирович','16.06.1972'),
('Лопатин','Валерий','Викторович','11.03.1958'),
('Лустин','Юрий','Александрович','08.03.1949'),
('Молитвин','Геннадий','Дмитриевич','27.02.1964'),
('Морковкин','Александр','Николаевич','20.09.1956'),
('Никифоров','Василий','Михайлович','26.02.1949'),
('Никулина','Наталия','Васильевна','27.07.1959'),
('Овчинников','Анатолий','Викторович','07.07.1959'),
('Паньков','Дмитрий','Олегович','09.12.1979'),
('Петрова','Татьяна','Алексеевна','27.03.1976'),
('Пименова','Лидия','Петровна','15.02.1940'),
('Полянский','Василий','Михайлович','01.01.1950'),
('Прокудин','Николай','Иванович','01.02.1952'),
('Равчеев','Александр','Николаевич','04.11.1951'),
('Семедянов','Андрей','Вячеславович','09.05.1974'),
('Сиротин','Александр','Николаевич','08.11.1967'),
('Скрыльников','Валентин','Алексеевич','11.02.1945'),
('Стрельцов','Сергей','Викторович','31.01.1963'),
('Трокин','Сергей','Николаевич','10.11.1956'),
('Хаванский','Виктор','Владимирович','08.10.1965'),
('Черницов','Александр','Андреевич','07.11.1949'),
('Шайдуров','Валентин','Михайлович','31.01.1953'),
('Шведова','Людмила','Александровна','20.05.1949'),
('Широков','Виктор','Николаевич','03.07.1950'),
('Шурманова','Белла','Николаевна','04.04.1939'),
('Щегольков','Александр','Алексеевич','14.02.1954'),
('Юшкина','Вера','Михайловна','12.01.1947'),
('Ягубов','Александр','Николаевич','30.05.1939'),
('Якубин','Иван','Иванович','25.12.1936')) f(Fam,Im,Ot,DR)

CREATE UNIQUE NONCLUSTERED INDEX IX_P ON #tmpPeople(Fam,IM,OT,DR)


SELECT distinct c.id, c.GUID_Case,a.rf_idSMO, l.NAMES,a.Account,a.DateRegister,f.DateRegistration
		,c.idRecordCase,d.DS1,mkb10.Diagnosis,CAST(c.AmountPayment AS MONEY) AS AmountPayment,v2.name AS PROFIL
		,0 AS Tariff,c.NumberHistoryCase,c.DateBegin,c.DateEnd,v9.name AS RSLT,v12.name AS ISHOD,v4.name AS PRVS
		,p.Fam+' '+p.Im+' '+p.Ot AS Fio,p.Sex,p.BirthDay,c.Age,r.NumberPolis,v6.name AS USL_OK,
		c.AmountPayment AS AmountDeduction, r.AttachLPU
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_RegisterPatient p ON
		r.id=p.rf_idRecordCase
		AND f.id=p.rf_idFiles				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN dbo.vw_sprMKB10 mkb10 ON
		d.DS1=mkb10.DiagnosisCode			
				INNER JOIN RegisterCases.dbo.vw_sprV009 v9 ON
		c.rf_idV009=v9.id
				INNER JOIN RegisterCases.dbo.vw_sprV012 v12 ON
		c.rf_idV012=v12.id		
				INNER JOIN RegisterCases.dbo.vw_sprV004 v4 ON
		c.rf_idV004=v4.id	
		AND c.DateEnd>=v4.DateBeg
		AND c.DateEnd<=v4.DateEnd	
				INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
		c.rf_idV002=v2.id
				INNER JOIN dbo.vw_sprT001 l ON
		f.CodeM=l.CodeM		
				INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
		c.rf_idV006=v6.id
				INNER JOIN #tmpPeople tp ON		
		p.Fam=tp.Fam
		AND p.Im=tp.Im
		AND p.Ot=tp.Ot
		AND p.BirthDay=tp.Dr	
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.reportYear=@reportYear AND a.ReportMonth>0 AND a.ReportMonth<@reportMonth AND a.rf_idSMO<>'34'
ORDER BY FIO,DateRegister

UPDATE p SET p.AmountDeduction=Deduction
FROM #tmpCases p INNER JOIN (SELECT f.rf_idCase,SUM(f.AmountDeduction) AS Deduction
								FROM dbo.t_PaymentAcceptedCase2 f																					
								WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<=@dtEnd AND f.TypeCheckup=1
								GROUP BY f.rf_idCase
							) r ON
			p.id=r.rf_idCase
/*
SELECT s.smocod,s.sNameS,c.Names,DateRegistration,Account,DateRegister,idRecordCase,DS1,Diagnosis,AmountPayment,USL_OK,PROFIL, NumberHistoryCase, 
		c.DateBegin,c.DateEnd,PRVS,Fio,BirthDay,Age,NumberPolis, l.NAMES AS LPUAttach, AmountDeduction 
FROM #tmpCases c INNER JOIN dbo.vw_sprSMO s ON
			c.rf_idSMO=s.smocod
				left JOIN dbo.vw_sprT001 l ON
			c.AttachLPU=l.CodeM              
ORDER BY s.smocod
*/
SELECT s.smocod,s.sNameS,c.Names,CAST(DateRegistration AS DATE) AS DateReg,Account,DateRegister,idRecordCase,DS1,Diagnosis,AmountPayment,PROFIL,USL_OK, NumberHistoryCase, 
		c.DateBegin,c.DateEnd,c.RSLT,c.ISHOD,PRVS,Fio,Sex,BirthDay,Age,NumberPolis, l.NAMES AS LPUAttach 
FROM #tmpCases c INNER JOIN dbo.vw_sprSMO s ON
			c.rf_idSMO=s.smocod
				left JOIN dbo.vw_sprT001 l ON
			c.AttachLPU=l.CodeM              
WHERE AmountPayment>0 AND AmountDeduction>0
UNION ALL
SELECT s.smocod,s.sNameS,c.Names,CAST(DateRegistration AS DATE),Account,DateRegister,idRecordCase,DS1,Diagnosis,AmountPayment,PROFIL,USL_OK, NumberHistoryCase, 
		c.DateBegin,c.DateEnd,c.RSLT,c.ISHOD,PRVS,Fio,Sex,BirthDay,Age,NumberPolis, l.NAMES AS LPUAttach 
FROM #tmpCases c INNER JOIN dbo.vw_sprSMO s ON
			c.rf_idSMO=s.smocod
				left JOIN dbo.vw_sprT001 l ON
			c.AttachLPU=l.CodeM              
WHERE AmountPayment=0 AND AmountDeduction=0
ORDER BY s.smocod
go
DROP TABLE #tmpCases
DROP TABLE #tmpPeople