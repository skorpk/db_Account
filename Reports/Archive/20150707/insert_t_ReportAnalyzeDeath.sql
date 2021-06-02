USE AccountOMS
GO
DECLARE @startPeriod INT=201301,
		@endPeriod INT,
		@startDateReg DATETIME='20130101',
		@endDateReg DATETIME=GETDATE()	

SET @endPeriod=CAST(LEFT( CONVERT(VARCHAR(8),GETDATE(),112),6) AS INT)

DECLARE @startDateEnd DATE=CAST(@startPeriod AS CHAR(6))+'01',
        @endDateEnd DATE=dateadd(day,-1, convert(char(6), dateadd(month,1,CAST(@endPeriod AS CHAR(6))+'01' ),112)+'01');

SELECT DISTINCT f.DateRegistration,a.ReportYearMonth,c.rf_idV009,c.id,cast(RTRIM(d.DiagnosisCode) AS VARCHAR(6)) AS DS1,c.AmountPayment,f.CodeM,a.rf_idSMO,a.Account,a.DateRegister,c.rf_idV006
				,c.rf_idV002,CAST(c.rf_idDoctor AS VARCHAR(15)) AS SNILS,c.IsChildTariff,c.idRecordCase,rp.Sex,ISNULL(r.SeriaPolis,'')+r.NumberPolis  AS Policy
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles																
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts			           
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
			AND c.DateEnd>=@startDateEnd AND c.DateEnd<=@endDateEnd																									
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1
					INNER JOIN (VALUES(105),(106),(205),(206),(313),(405),(406),(411) )	v(idV009) ON
			c.rf_idV009=v.idV009 
					INNER JOIN dbo.t_RegisterPatient rp ON
			r.id=rp.rf_idRecordCase                 
WHERE f.DateRegistration>@startDateReg AND f.DateRegistration<@endDateReg AND a.ReportYearMonth>=@startPeriod AND a.ReportYearMonth<=@endPeriod 
		AND a.rf_idSMO<>'34'
GO
