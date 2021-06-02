USE AccountOMS
GO
DECLARE @dateStart DATETIME,
		@dateEnd DATETIME=GETDATE(),
		@reportYear SMALLINT=2017,
		@startMM TINYINT,
		@endMM TINYINT ,
		@quater TINYINT=4

DECLARE @dtCaseBeg DATE,
		@dtCaseEnd date

DECLARE @t AS TABLE(quater TINYINT,startMonth TINYINT, endMonth TINYINT)
INSERT @t( quater, startMonth, endMonth ) VALUES  (1,1,3),(2,4,6),(3,7,9),(4,10,12)

SELECT @startMM=startMonth, @endMM=endMonth from @t WHERE quater=@quater

set @dtCaseBeg=CAST(@reportYear AS CHAR(4))+RIGHT('0'+CAST(@startMM AS VARCHAR(2) ),2 )+'01'
SET @dateStart=@dtCaseBeg
SET @dtCaseEnd=dateadd(day,-1, dateadd(month,3*datepart(quarter,@dtCaseBeg), datename(year,@dtCaseBeg)))
SELECT @dateStart,@dateEnd, @dtCaseBeg, @dtCaseEnd, @startMM,@endMM

DROP TABLE MedicalCare

SELECT c.id, a.rf_idMO AS CODE_MO,a.Account AS NSCHET,a.DateRegister, c.idRecordCase AS IDCASE, a.rf_idSMO AS PLAT, r.IsNew AS PR_NOV,
		r.NewBorn AS NOVOR, p.Fam,p.IM,p.Ot,p.BirthDay AS DR, p.rf_idV005 AS W, p.BirthPlace AS MR,s.ENP,c.rf_idV006 AS USL_OK, c.rf_idV008 AS VIDPOM,
		c.rf_idV014 AS FOR_POM, c.rf_idV012 AS ISHOD,c.rf_idV009 AS RSLT, c.AmountPayment AS SUMV, c.GUID_Case AS SL_ID, c.rf_idV002 AS PROFIL,
		c.NumberHistoryCase AS NHISTORY, c.TypeTranslation AS P_PER, c.DateBegin AS DATE_1, c.DateEnd AS DATE_2, dd.DS1, c.rf_idV004 AS PRVS,
		c.rf_idDoctor AS IDDOKT
INTO MedicalCare
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_PatientSMO s ON
			r.id=s.rf_idRecordCasePatient                  
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase							
					INNER JOIN dbo.t_RegisterPatient p ON
			f.id=p.rf_idFiles
			AND r.id=p.rf_idRecordCase                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>@startMM AND a.ReportMonth<=@endMM AND a.ReportYear=@reportYear 
		AND c.DateEnd>=@dtCaseBeg AND c.DateEnd<=@dtCaseEnd
GO
--DROP TABLE #t		