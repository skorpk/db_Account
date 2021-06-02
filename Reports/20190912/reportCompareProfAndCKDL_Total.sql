USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190501',
		@dateEnd DATETIME='20190907' ,
		@reportMonth TINYINT=8
--услуги при проф мероприятиях и услуги при 125901 и 805965
CREATE TABLE #tMU(MU_Prof VARCHAR(20),TypeGroupProf tinyint, MU_CKDL VARCHAR(20),TypeGroupCKDL tinyint)
INSERT #tMU( MU_Prof,TypeGroupProf, MU_CKDL,TypeGroupCKDL )
VALUES  ('4.8.704',1,'4.8.804',1),('4.11.736',2,'4.11.738',2),('4.11.737',3,'4.11.738',3),('4.12.769',4,'4.12.869',4),
		('4.8.4',1,'4.8.804',1),('4.11.136',2,'4.11.738',2),('4.11.137',3,'4.11.738',3),('4.12.169',4,'4.12.869',4),
		('4.12.774',5,'4.12.886',5),('4.12.774',5,'4.12.887',5),('4.12.774',5,'4.12.888',5),
		('4.14.766',6,'4.15.701',6),('4.14.766',6,'4.15.702',6),
		('4.12.174',5,'4.12.886',5),('4.12.174',5,'4.12.887',5),('4.12.174',5,'4.12.888',5),
		('4.14.66',6,'4.15.701',6),('4.14.66',6,'4.15.702',6)

CREATE TABLE #tLPU(CodeM CHAR(6))
INSERT #tLPU values('114504'),('115506'),('121018'),('124528'),('124530'),('125505'),('131020'),('134505'),('141016'),('141022'),('141023'),('141024'),('145516'),
					('154602'),('154620'),('155601'),('161007'),('161015'),('165531'),('174601'),('175603'),('184512'),('184603'),('185515'),('251001'),('251002'),
					('251003'),('251008'),('254505'),('255627'),('301001'),('311001'),('321001'),('331001'),('341001'),('351001'),('361001'),('371001'),('381001'),
					('391001'),('391002'),('391003'),('401001'),('411001'),('421001'),('431001'),('441001'),('451001'),('451002'),('461001'),('471001'),('481001'),
					('491001'),('501001'),('511001'),('521001'),('531001'),('541001'),('551001'),('561001'),('571001'),('581001'),('591001'),('601001'),('611001'),
					('621001'),('711001')


--отбираем людей по профмероприятию
SELECT p.ENP,c.DateBegin,c.DateEnd,c.id,SUM(m.Quantity) AS Quntity,mm.TypeGroupProf/*,mm.MU_Prof,mm.MU_CKDL*/,f.CodeM
INTO #tProf
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
				  INNER JOIN #tLPU ll ON
			f.CodeM=ll.CodeM                
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient											                 													
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
					INNER JOIN (SELECT DISTINCT TypeGroupProf,MU_Prof FROM #tMU) mm on
			m.MU=mm.MU_Prof
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=2019 AND Letter IN('O','D','R','F','U') AND a.ReportMonth IN(5,6,7,8)--=@reportMonth
		AND m.IsNeedUsl NOT IN(1,2) -- AND f.CodeM='125505'
GROUP BY p.ENP,c.DateBegin,c.DateEnd,c.id,mm.TypeGroupProf/*,mm.MU_Prof,mm.MU_CKDL*/,f.CodeM

--отбираем людей по ЦКДЛ
SELECT p.ENP,m.DateHelpBegin AS DateBegin,m.DateHelpEnd AS DateEnd,c.id,SUM(m.Quantity) AS Quntity,mm.TypeGroupCKDL/*,mm.MU_Prof,mm.MU_CKDL*/,f.CodeM
INTO #tCKDL
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient											                 													
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
					INNER JOIN (SELECT DISTINCT TypeGroupCKDL,MU_CKDL FROM #tMU) mm on
			m.MU=mm.MU_CKDL
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=2019 AND Letter='K' AND a.ReportMonth IN(5,6,7,8)/*=@reportMonth*/ AND f.CodeM IN('125901','805965')
GROUP BY p.ENP,m.DateHelpBegin,m.DateHelpEnd,c.id,mm.TypeGroupCKDL/*,mm.MU_Prof,mm.MU_CKDL*/,f.CodeM

;WITH cteProf
as
(
SELECT p.CodeM,p.TypeGroupProf,p.ENP,SUM(Quntity) AS Quntity
FROM #tProf p 
GROUP BY p.CodeM,p.TypeGroupProf,ENP
),
cteCKDL
AS
(
	SELECT CodeM, t.TypeGroupProf,t.ENP,SUM(Quntity) AS Quntity
	from (
			 SELECT DISTINCT c.CodeM, p.TypeGroupProf,c.ENP,c.Quntity,c.id
			 FROM #tProf p INNER JOIN #tCKDL c ON
					p.ENP =c.ENP			   
					AND p.TypeGroupProf=c.TypeGroupCKDL
					AND c.DateBegin>=p.DateBegin AND c.DateEnd<=p.DateEnd
			) t
	GROUP BY CodeM,TypeGroupProf,ENP
)
SELECT l.CodeM,l.NAMES AS LPU
	,cast(SUM(CASE WHEN p.TypeGroupProf=1 THEN p.Quntity ELSE 0 END ) as int) AS Col3
	,cast(SUM(CASE WHEN p.TypeGroupProf=2 THEN p.Quntity ELSE 0 END ) as int) AS Col4
	,cast(SUM(CASE WHEN p.TypeGroupProf=3 THEN p.Quntity ELSE 0 END ) as int) AS Col5
	,cast(SUM(CASE WHEN p.TypeGroupProf=4 THEN p.Quntity ELSE 0 END ) as int) AS Col6
	,cast(SUM(CASE WHEN p.TypeGroupProf=5 THEN p.Quntity ELSE 0 END ) as int) AS Col7
	,cast(SUM(CASE WHEN p.TypeGroupProf=6 THEN p.Quntity ELSE 0 END ) as int) AS Col8
	-----------------КДП2------------
	,cast(SUM(CASE WHEN c.TypeGroupProf=1 and c.Codem='125901' THEN c.Quntity ELSE 0 END ) as int) AS Col3
	,cast(SUM(CASE WHEN c.TypeGroupProf=2 and c.Codem='125901' THEN c.Quntity ELSE 0 END ) as int) AS Col4
	,cast(SUM(CASE WHEN c.TypeGroupProf=3 and c.Codem='125901' THEN c.Quntity ELSE 0 END ) as int) AS Col5
	,cast(SUM(CASE WHEN c.TypeGroupProf=4 and c.Codem='125901' THEN c.Quntity ELSE 0 END ) as int) AS Col6
	,cast(SUM(CASE WHEN c.TypeGroupProf=5 and c.Codem='125901' THEN c.Quntity ELSE 0 END ) as int) AS Col7
	,cast(SUM(CASE WHEN c.TypeGroupProf=6 and c.Codem='125901' THEN c.Quntity ELSE 0 END ) as int) AS Col8
	-----------------РДЛ------------												   
	,cast(SUM(CASE WHEN c.TypeGroupProf=1 and c.Codem='805965' THEN c.Quntity ELSE 0 END ) as int) AS Col3
	,cast(SUM(CASE WHEN c.TypeGroupProf=2 and c.Codem='805965' THEN c.Quntity ELSE 0 END ) as int) AS Col4
	,cast(SUM(CASE WHEN c.TypeGroupProf=3 and c.Codem='805965' THEN c.Quntity ELSE 0 END ) as int) AS Col5
	,cast(SUM(CASE WHEN c.TypeGroupProf=4 and c.Codem='805965' THEN c.Quntity ELSE 0 END ) as int) AS Col6
	,cast(SUM(CASE WHEN c.TypeGroupProf=5 and c.Codem='805965' THEN c.Quntity ELSE 0 END ) as int) AS Col7
	,cast(SUM(CASE WHEN c.TypeGroupProf=6 and c.Codem='805965' THEN c.Quntity ELSE 0 END ) as int) AS Col8
FROM cteProf p INNER JOIN dbo.vw_sprT001 l ON
		p.CodeM=l.CodeM
				left JOIN cteCKDL c ON
		p.enp=c.enp
		AND p.TypeGroupProf=c.TypeGroupProf
					
GROUP BY l.CodeM,l.NAMES
ORDER BY l.CodeM


go
DROP TABLE #tMU
DROP TABLE #tCKDL
DROP TABLE #tProf
DROP TABLE #tLPU
