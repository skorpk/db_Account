USE AccountOMS
go
DECLARE @codeM CHAR(6)='471001'
DECLARE @tsnils AS TABLE(snils varchar(16))
INSERT @tsnils( snils )
--VALUES ('017-656-412-57'),('008-770-332-49'),('018-074-135-28'),('008-770-350-51'),('013-142-481-92'),('013-142-501-79'),('008-273-664-48'),('018-074-053-27'),('010-526-597-11')
VALUES ('004-091-988 27'),('004-779-628 70'),('067-984-890 47'),('004-779-643 69'),('104-490-936 44'),('009-372-685 65'),('006-259-090 32'),
		('006-259-082 32'),('050-934-981 68'),('006-259-080 30'),('009-372-763 61'),('009-372-696 65'),('050-934-978-73'),('009-330-203 04'),('006-259-097 39')



SELECT DISTINCT s.snils,p.Fam+' '+p.Im+' '+ISNULL(p.Ot,'') AS FIO,m.DateHelpBegin, m.DateHelpEnd
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
WHERE f.DateRegistration>'20150101' AND f.DateRegistration<'20151001' /*AND f.CodeM=@codeM*/ AND a.ReportYear=2015

