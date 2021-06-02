USE AccountOMS
go
DECLARE @codeM CHAR(6)='611001'
DECLARE @tsnils AS TABLE(snils varchar(16),CodeM CHAR(6),FAP VARCHAR(50))
INSERT @tsnils( CodeM,FAP,snils )
VALUES ('451001','Сенновский','149-475-547-11'),
		('451001','Сенновский','155-477-429-95'),
		('451001','Ильменский - 2','015-362-103-04'),
		('451001','Глушицинский','132-098-610-43'),
		('451001','Етеревский','015-362-097-23'),
		('451001','Етеревский','015-362-098-24'),
		('611001','Дудаченский','014-533-439-19'),
		('611001','Кирпичный','015-394-457-50'),
		('611001','Малодельский','008-781-011-44')





SELECT DISTINCT s.FAP,s.snils,p.Fam+' '+p.Im+' '+ISNULL(p.Ot,'') AS FIO,m.DateHelpBegin, m.DateHelpEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM	 			                  
				  INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
				 INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles
				INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
				INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
				INNER JOIN @tsnils s ON
			RTRIM(m.rf_idDoctor)=REPLACE(replace(s.snils,'-',''),' ','')
			AND f.CodeM=s.CodeM
WHERE f.DateRegistration>'20150101' AND f.DateRegistration<'20151001' AND f.CodeM=@codeM AND a.ReportYear=2015

