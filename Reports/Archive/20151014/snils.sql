USE AccountOMS
go
DECLARE @codeM CHAR(6)='561001'
DECLARE @tsnils AS TABLE(snils varchar(16),CodeM CHAR(6),FAP VARCHAR(50))
INSERT @tsnils( CodeM,FAP,snils )
VALUES ('351001','Морецкая УБ','167-701-983-97'),
('351001','Терсиновский ФАП','020-095-660-10'),
('351001','Терновский ФАП','007-953-940-74'),
('351001','Ивановский ФАП','007-953-911-69'),
('351001','Водопьяновский ФАП','007-954-049-60'),
('351001','Набатский ФАП','110-929-323-32'),
('351001','Березовский ФАП','007-956-193-75'),
('351001','Хвощинский ФАП','007-203-087-96'),
('351001','Новодобринский ФАП','007-203-088-97'),
('351001','Щелоковский ФАП','007-203-084-93'),	
('331001','Бобровский ФАП','133-631-235-25'),
('331001','Плотниковский ФАП','019-591-286-77'),
('561001','Трясиновский ФАП','053-958-884-16'),
('561001','Подольховский ФАП','148-542-531-76'),
('561001','Новоалександровский ФАП','015-630-082-11')






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

