USE AccountOMS
GO

/*
alter TABLE tmpPeopleDN_2018  ADD id int not null IDENTITY(1,1)
ALTER TABLE tmpPeopleDN_2018 ADD MainDS VARCHAR(4)
ALTER TABLE tmpPeopleDN_2018 ADD idRow int
ALTER TABLE tmpPeopleDN_2018 ADD IsDNType tinyint not null default (1)

ALTER TABLE tmpPeopleDN_2018 ADD LPU CHAR(6)
ALTER TABLE tmpPeopleDN_2018 ADD Q CHAR(5)
ALTER TABLE tmpPeopleDN_2018 ADD PID INT
ALTER TABLE tmpPeopleDN_2018 ADD [sid] INT
ALTER TABLE tmpPeopleDN_2018 ADD [lid] INT

ALTER TABLE tmpPeopleDN_2018 ADD dd date not null default('20190101')

ALTER TABLE tmpPeopleDN_2018 ADD Col8 tinyint
ALTER TABLE tmpPeopleDN_2018 ADD Col9 date
*/
-----------------обновляем рубрику
/*
UPDATE p SET p.MainDS=m.MainDS
FROM dbo.tmpPeopleDN_2018 p INNER JOIN dbo.vw_sprMKB10 m ON
			p.DS1=m.DiagnosisCode
*/
-----------------помечаем первый поставленный диагноз
/*
;WITH cte
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY enp,MainDS ORDER BY DateEnd) AS idrow,p.id
FROM dbo.tmpPeopleDN_2018 p
)
UPDATE p SET p.idRow=c.idrow
FROM cte c INNER JOIN dbo.tmpPeopleDN_2018 p ON
		p.id = c.id


UPDATE p SET p.w=r.Sex
FROM dbo.tmpPeopleDN_2018 p INNER JOIN dbo.t_Case c ON
			p.rf_idCase=c.id
					INNER JOIN dbo.t_RegisterPatient r ON
            c.rf_idRecordCasePatient=r.rf_idRecordCase
		

DECLARE @dateStartReg DATETIME='20170101',
		@dateEndReg DATETIME=GETDATE(),
		@dateStartRegRAK DATETIME='20170101',
		@dateEndRegRAK DATETIME=GETDATE(),
		@year INT=2017

UPDATE pp SET pp.IsDNType=2
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient							
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase				
					INNER JOIN dbo.tmpPeopleDN_2018 pp ON
			p.enp=pp.ENP		
			AND dd.DiagnosisCode=pp.DS1												
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear>=@year AND f.TypeFile='F'
	 AND c.rf_idV006 =3 AND c.IsNeedDisp =2 AND a.rf_idSMO<>'34' AND pp.idRow=1 AND c.DateEnd<pp.DateEnd

UPDATE pp SET pp.IsDNType=2
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient						
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_DS2_Info dd ON
			c.id=dd.rf_idCase				
					INNER JOIN dbo.tmpPeopleDN_2018 pp ON
			p.enp=pp.ENP				
			AND pp.DS1=dd.DiagnosisCode								
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear>=@year AND f.TypeFile='F'
	 AND c.rf_idV006 =3 AND dd.IsNeedDisp=2 AND a.rf_idSMO<>'34' AND c.DateEnd<pp.DateEnd AND pp.idRow=1

update tmpPeopleDN_2018 set IsDNType=1 where IsDNType is null
*/
UPDATE t SET t.PID=p.PID
FROM dbo.tmpPeopleDN_2018 t INNER JOIN dbo.t_Case_PID_ENP p ON
			t.rf_idCase=p.rf_idCase
WHERE p.PID IS NOT NULL

UPDATE p SET p.PID=pp.id
FROM dbo.tmpPeopleDN_2018 p INNER JOIN PolicyRegister.dbo.PEOPLE pp ON
			p.ENP=pp.ENP
WHERE p.idRow=1 AND p.PID IS NULL

UPDATE p SET p.PID=pp.PID
FROM dbo.tmpPeopleDN_2018 p INNER JOIN PolicyRegister.dbo.HISTENP pp ON
			p.ENP=pp.ENP
WHERE p.idRow=1


----------------------------------------------------------------------------------------------------
if Object_ID(N'tempdb..#t_giplpu_1', N'U') is not null drop table [#t_giplpu_1];
	if Object_ID(N'tempdb..#t_giplpu_2', N'U') is not null drop table [#t_giplpu_2];

	select p.id pid, t.dd dd, s.id [sid], s.q
		into #t_giplpu_1 
		from PolicyRegister.dbo.polis s join PolicyRegister.dbo.people p ON s.pid=p.id inner join tmpPeopleDN_2018 t ON s.pid=t.pid                                                                  
		where isnull(s.st, 0) <> 2 
			and isnull(s.dstop, t.dd) >= t.dd 
			and isnull(p.ds, t.dd) >= t.dd
			--and cast(isnull(s.dstop, t.dd) as date) >= t.dd 
			--and cast(isnull(p.ds, t.dd) as date) >= t.dd
			and (left(s.okato,2)='18')
			and (s.poltp in (1,2) or isnull(s.dend,'21000101')>=t.dd) 
			and (s.poltp in(2,3,4,5 ) or (s.poltp=1 and (isnull(s.dend,'21000101')>'20101231')))  
			and s.dbeg <= t.dd 
		order by cast(s.dbeg as date) desc, s.poltp desc, s.id desc;

	with t(n) as (select row_number()over(partition by pid order by [sid] desc) from #t_giplpu_1)
	delete t where n>1;

	select h.pid,h.id lid,h.lpu 
		into #t_giplpu_2
		from PolicyRegister.dbo.Histlpu h join #t_giplpu_1 t on(h.pid=t.pid) 
		where cast(h.lpudt as date) <= t.dd
			and cast(isnull(h.lpudx,t.dd) as date) >= t.dd
		order by cast(h.lpudt as date) desc, h.id desc;

	with t(n) as (select row_number()over(partition by pid order by [lid] desc) from #t_giplpu_2)
	delete t where n>1;

	update tmpPeopleDN_2018 set [sid]=#t_giplpu_1.[sid], q=#t_giplpu_1.q  from tmpPeopleDN_2018 join #t_giplpu_1 on(tmpPeopleDN_2018.pid=#t_giplpu_1.pid);
	update tmpPeopleDN_2018 set lid=#t_giplpu_2.lid, lpu=#t_giplpu_2.lpu  from tmpPeopleDN_2018 join #t_giplpu_2 on(tmpPeopleDN_2018.pid=#t_giplpu_2.pid);

	drop table [#t_giplpu_1];
	drop table [#t_giplpu_2];

UPDATE t SET t.Col8=3
FROM tmpPeopleDN_2018 t INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		t.pid=p.id
WHERE p.DS IS NOT NULL AND p.ds>='20180101' AND p.DS<'20190101' 

BEGIN TRANSACTION
UPDATE t SET Col8=2,col9=p.DSTOP
FROM tmpPeopleDN_2018 t INNER JOIN (SELECT PID, MAX(DSTop) DSTop FROM PolicyRegister.dbo.POLIS GROUP BY PID) p ON
		t.pid=p.pid
WHERE SID IS NULL AND Col8 =2 AND idRow=1
--ROLLBACK
COMMIT

update tmpPeopleDN_2018 SET idRow=null WHERE Col9<'20180101' 
go