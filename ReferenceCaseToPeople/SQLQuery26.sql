USE AccountOMS
GO
SELECT distinct  p.FAM ,p.IM ,p.OT ,CAST(p.DR AS DATE) AS DR ,/*p.DOCN,p.DOCS,p.SS,*/p.DateEnd ,
        p.PIDNew,p.PIDOld,TypeFound,p1.DSTOP,p2.DSTOP
FROM dbo.tmpPeopleCase p INNER JOIN PolicyRegister.dbo.PEOPLE p1 ON
				p.PIDNew=p1.ID					                     
						INNER JOIN PolicyRegister.dbo.POLIS ps ON
		p1.ID=ps.PID	
						INNER JOIN PolicyRegister.dbo.PEOPLE p2 ON
				p.PIDOld=p2.ID						
WHERE p.PIDNew<>p.PIDOld AND p.FAM=p1.FAM AND p.IM=p1.IM AND p.DR=p1.DR AND p1.Fam=p2.Fam AND p.DateEnd<=ps.DSTOP AND ps.St<>2 --AND p.TypeFound=1