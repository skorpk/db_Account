USE PeopleAttach
GO
--ALTER TABLE dbo.t_CovidRegister20201026 ADD ENP_My VARCHAR(16)
create table #t
(
	nrec bigint not null,		
	pid int null,			
	penp varchar(16) null,
	enp varchar(16) null,	
	sKey varchar(3) null,	
	sid	int null,			
	q varchar(5) null,		
	lid int null,			
	lpu varchar(6) null,	
	spol varchar(20) null,
	npol varchar(20) null,
	fam varchar(40) null,
	im varchar(40) null,
	ot varchar(40) null,
	dr datetime null,
	mr varchar(100) null,
	docn varchar(20) null,
	ss varchar(14) NULL
	)
INSERT #t( nrec ,fam ,im ,ot ,dr ,ss)
SELECT distinct c.Id_Source,c.Fam_My,c.im_my,c.ot_my, c.DR_My,LEFT(c.SNILS_Source,14)
FROM dbo.t_CovidRegister20201026 c

exec Utility.dbo.sp_GetPid 

--UPDATE  c SET c.enp=t.penp
--FROM #t t INNER JOIN #tCases c ON
--		t.nrec=c.rf_idRecordCasePatient
--WHERE t.enp<>t.penp
UPDATE r SET r.ENP_My=t.penp
FROM #t t INNER JOIN t_CovidRegister20201026 r ON
		t.nrec=r.Id_Source
WHERE penp IS NOT NULL
 GO
 DROP TABLE #t