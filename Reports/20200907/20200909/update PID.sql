USE AccountOMS
GO
--ALTER TABLE tmpDSB2020 ADD pid int

UPDATE e SET PID=p.Id
FROM tmpDSB2020 e INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		e.enp=p.ENP
UPDATE e SET PID=p.PID
FROM tmpDSB2020 e INNER JOIN PolicyRegister.dbo.HISTENP p ON
		e.enp=p.ENP
WHERE e.pid IS null