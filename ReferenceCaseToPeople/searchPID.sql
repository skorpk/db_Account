USE AccountOMS
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.tmpPeopleCase') AND type in (N'U'))
DROP TABLE dbo.tmpPeopleCase
go
CREATE TABLE  tmpPeopleCase
(
	id bigint NULL,
	ENP varchar(20) NULL,
	FAM varchar(40) NULL,
	IM varchar(40) NULL,
	OT varchar(40) NULL,
	DR datetime NULL,
	MR varchar(100) NULL,
	SS varchar(16) NULL,
	DOCS varchar(20) NULL,
	DOCN varchar(20) NULL,
	OKATO varchar(11) NULL,
	DateEnd date NULL,
	TypeFound TINYINT
)

--заполняем таблицу данными из счетов по нашим застрахованным
insert tmpPeopleCase
select c.id,case when r.rf_idF008=3 then r.NumberPolis else null end,p.Fam,p.Im,p.Ot,p.BirthDay,p.BirthPlace,pd.SNILS,null,pd.NumberDocument,null,
		c.DateEnd,NULL
from dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles
					LEFT JOIN dbo.t_RegisterPatientDocument pd ON
			p.id=pd.rf_idRegisterPatient 
WHERE f.DateRegistration>'20160101' AND f.DateRegistration<GETDATE()  AND a.rf_idSMO<>'34' AND c.DateEnd>'20150101' AND c.DateEnd<'20161107'
go
----------------сопостовляем случаем уже найденные PID
------------------------------------------------------------------------------
ALTER TABLE dbo.tmpPeopleCase ADD PIDOld INT NULL
ALTER TABLE dbo.tmpPeopleCase ADD PIDNew INT null
DROP INDEX CL_FIO_DR ON dbo.tmpPeopleCase
CREATE NONCLUSTERED INDEX IX_FIO_DR ON dbo.tmpPeopleCase(FAM,IM,DR) INCLUDE(Ot,DOCN,SS,DOCS,id)	WITH drop_existing
go
UPDATE p SET PIDOld=pe.PID
from tmpPeopleCase p INNER JOIN dbo.t_Case_PID_ENP pe ON
			p.id=pe.rf_idCase

------------------------------------------------------------------------------
--create table #tPeople
--(
--	rf_idRefCaseIteration bigint,
--	PID int,
--    DateEnd DATE,
--    IsDelete TINYINT,
--    DateBegin DATE,
--	Sex TINYINT,
--	DR date
--)
create table #tFound (id int, PID INT,sex INT,DR DATE,TFound TINYINT)

CREATE UNIQUE NONCLUSTERED INDEX IX_tFound_id on #tFound(id) WITH IGNORE_DUP_KEY
DECLARE @i TINYINT=1
    --H01
     insert #tFound
     select t.id,p.ID,p.W,p.DR,@i
     from PolicyRegister.dbo.People p inner join tmpPeopleCase t on 
		p.FAM=t.FAM and p.IM=t.IM and isnull(p.OT,'')=isnull(t.OT,'') and p.DR=t.DR 
	
SET @i=@i+1	
	--H02
	 insert #tFound
     select t.id,p.ID,p.W,p.DR,@i
     from PolicyRegister.dbo.People p inner join tmpPeopleCase t on
		p.FAM=t.FAM and p.IM=t.IM 
		and isnull(p.OT,'')=isnull(t.OT,'') 
		and p.SS=t.SS				
SET @i=@i+1	
   --H03
     insert #tFound
     select t.id,p.ID,p.W,p.DR, @i
     from PolicyRegister.dbo.People p inner join tmpPeopleCase t on 
		p.FAM=t.FAM 
		and p.IM=t.IM 
		and isnull(p.OT,'')=isnull(t.OT,'') 
		and p.DOCN=t.DOCN    
SET @i=@i+1	    
    --H04
     insert #tFound
     select t.id,p.ID,p.W,p.DR, @i
     from PolicyRegister.dbo.People p inner join tmpPeopleCase t on 
		p.FAM=t.FAM 
		and p.IM=t.IM 
		and p.DR=t.DR 
		and p.SS=t.SS     
SET @i=@i+1	 	
	--H05
	 insert #tFound
     select t.id,p.ID,p.W,p.DR, @i
     from PolicyRegister.dbo.People p inner join tmpPeopleCase t on 
		p.FAM=t.FAM and p.IM=t.IM and p.DR=t.DR and p.DOCN=t.DOCN
SET @i=@i+1	 	
	--H06    
	 insert #tFound
     select t.id,p.ID,p.W,p.DR, @i
     from PolicyRegister.dbo.People p inner join tmpPeopleCase t on 
		p.FAM=t.FAM 
		and p.IM=t.IM 
		and p.DR=t.DR 
		and p.DOCN=t.DOCN 
		and p.SS=t.SS
SET @i=@i+1	
	--H07
     insert #tFound
     select t.id,p.ID,p.W,p.DR, @i
     from PolicyRegister.dbo.People p inner join tmpPeopleCase t on 
		p.FAM=t.FAM 
		and p.DR=t.DR 
		and isnull(p.OT,'')=isnull(t.OT,'')
		and p.SS=t.SS
SET @i=@i+1		
	--H08
     insert #tFound
     select t.id,p.ID,p.W,p.DR, @i
     from PolicyRegister.dbo.People p inner join tmpPeopleCase t on 
		p.FAM=t.FAM and p.DR=t.DR and isnull(p.OT,'')=isnull(t.OT,'') and p.DOCN=t.DOCN
SET @i=@i+1	    
    --H09
     insert #tFound
     select t.id,p.ID,p.W,p.DR, @i
     from PolicyRegister.dbo.People p inner join tmpPeopleCase t on 
		p.FAM=t.FAM 
		and isnull(p.OT,'')=isnull(t.OT,'') 
		and p.DOCN=t.DOCN 
		and p.SS=t.SS
SET @i=@i+1		
 --H10   
     insert #tFound
     select t.id,p.ID,p.W,p.DR, @i
     from PolicyRegister.dbo.People p inner join tmpPeopleCase t on 
		p.FAM=t.FAM 
		and p.DR=t.DR 
		and p.DOCN=t.DOCN 
		and p.SS=t.SS
SET @i=@i+1			 
    --H11
    insert #tFound
     select t.id,p.ID,p.W,p.DR, @i
     from PolicyRegister.dbo.People p inner join tmpPeopleCase t on 
		p.IM=t.IM 
		and isnull(p.OT,'')=isnull(t.OT,'') 
		and p.DR=t.DR 
		and p.SS=t.SS
SET @i=@i+1	

    --H12
    insert #tFound
     select t.id,p.ID,p.W,p.DR, @i
     from PolicyRegister.dbo.People p inner join tmpPeopleCase t on 
		p.IM=t.IM 
		and isnull(p.OT,'')=isnull(t.OT,'') 
		and p.DR=t.DR 
		and p.DOCN=t.DOCN
SET @i=@i+1	
	 --H13
    insert #tFound
     select t.id,p.ID,p.W,p.DR, @i
     from PolicyRegister.dbo.People p inner join tmpPeopleCase t on 
		p.IM=t.IM 
		and isnull(p.OT,'')=isnull(t.OT,'') 
		and p.SS=t.SS 
		and p.DOCN=t.DOCN
SET @i=@i+1	
   
    --H14
    insert #tFound
     select t.id,p.ID,p.W,p.DR, @i
     from PolicyRegister.dbo.People p inner join tmpPeopleCase t on 
		p.IM=t.IM 
		and  p.DR=t.DR 
		and p.DOCN=t.DOCN 
		and p.SS=t.SS
SET @i=@i+1	
    --H15
    insert #tFound
     select t.id,p.ID,p.W,p.DR, @i
     from PolicyRegister.dbo.People p inner join tmpPeopleCase t on 
		isnull(p.OT,'')=isnull(t.OT,'') 
		and p.DR=t.DR 
		and p.DOCN=t.DOCN 
		and p.SS=t.SS
SET @i=@i+1	
	--2
	insert #tFound
     select t.id,p.PID,p.W,p.DR, @i
     from PolicyRegister.dbo.HISTFDR p inner join tmpPeopleCase t on 
		p.FAM=t.FAM and p.IM=t.IM and isnull(p.OT,'')=isnull(t.OT,'') and p.DR=t.DR 
SET @i=@i+1	
	--3
	 insert #tFound
     select t.id,p.ID,p.Sex,p.DR,@i 
     from RegisterCases.dbo.vw_HISTPEOPLE p inner join tmpPeopleCase t on 
		p.FAM=t.FAM 
		and p.IM=t.IM 
		and isnull(p.OT,'')=isnull(t.OT,'') 
		and p.DOCN=t.DOCN  	
SET @i=@i+1	
	--4
	 insert #tFound
     select t.id,p.ID,p.Sex,p.DR,@i 
     from RegisterCases.dbo.vw_HISTPEOPLE p inner join tmpPeopleCase t on 
		p.FAM=t.FAM and p.IM=t.IM and p.DR=t.DR and p.DOCN=t.DOCN
SET @i=@i+1	
	--5
	 insert #tFound
     select t.id,p.ID,p.Sex,p.DR,@i
     from RegisterCases.dbo.vw_HISTPEOPLE p inner join tmpPeopleCase t on 
		p.FAM=t.FAM and isnull(p.OT,'')=isnull(t.Ot,'') and p.DR=t.DR and p.DOCN=t.DOCN	
SET @i=@i+1		
	 --6
	 insert #tFound
     select t.id,p.ID,p.Sex,p.DR,@i 
     from RegisterCases.dbo.vw_HISTPEOPLE p inner join tmpPeopleCase t on 
		p.IM=t.IM 
		and isnull(p.OT,'')=isnull(t.OT,'') 
		and p.DR=t.DR 
		and p.DOCN=t.DOCN	
		
--------------------------------------------------------------------		
	
	UPDATE t1 SET PIDNew=t.PID,TypeFound=t.TFound
	from #tFound t inner join tmpPeopleCase t1 on
			t.id=t1.id					
	--WHERE t.PID<>t1.PIDOld
	
go
--DROP TABLE #tPeople
DROP TABLE #tFound


