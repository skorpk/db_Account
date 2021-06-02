USE AccountOMS
GO
DECLARE @reportYear SMALLINT=2017,
		@dateStart DATETIME,
		@dateEnd DATETIME='20170710 23:59:59',
		@mmBegin TINYINT=1,
		@mmEnd TINYINT=6,
		@dateEndPay DATETIME=GETDATE()

SET @dateStart=CAST(@reportYear AS VARCHAR(4))+'0101' 
CREATE TABLE #tPeople(
					  CodeM VARCHAR(6),
					  rf_idCase BIGINT,					  					  
					  AmountDeduction DECIMAL(11,2), 
					  rf_idSMO CHAR(5),	
					  ENP VARCHAR(20),
					  DateBegin DATE,
					  DateEnd DATE,
					  rf_idV006 TINYINT,
					  DS1 VARCHAR(9),
					  Policy VARCHAR(20),
					  AmountPayment DECIMAL(11,2),
					  Account VARCHAR(15),
					  DateAccount DATE,
					  NumberCase INT,
					  ------------
					  CodeM_D VARCHAR(6),
					  rf_idCase_D BIGINT,					  					  
					  AmountDeduction_D DECIMAL(11,2), 
					  rf_idSMO_D CHAR(5),	
					  ENP_D VARCHAR(20),
					  DateBegin_D DATE,
					  DateEnd_D DATE,
					  rf_idV006_D TINYINT,
					  DS1_D VARCHAR(9),
					  Policy_D VARCHAR(20),
					  AmountPayment_D DECIMAL(11,2),
					  Account_D VARCHAR(15),
					  DateAccount_D DATE,
					  NumberCase_D INT, 
					 )

;WITH cte
AS
(
SELECT DISTINCT f.CodeM ,c.id ,c.AmountPayment ,a.rf_idSMO ,ps.ENP ,c.DateBegin ,c.DateEnd ,c.rf_idV006,d.DS1,r.NumberPolis, c.AmountPayment AS AmountDeduction,a.Account,a.DateRegister,c.idRecordCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles			
			AND a.rf_idSMO<>'34'				
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase								                 
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>=@mmBegin AND a.ReportMonth<=@mmEnd AND a.ReportYear=@reportYear AND c.rf_idV006<3 
)
INSERT #tPeople( CodeM ,rf_idCase ,AmountDeduction ,rf_idSMO ,ENP ,DateBegin ,DateEnd ,rf_idV006 ,DS1 ,Policy ,AmountPayment ,Account ,DateAccount ,NumberCase
				,CodeM_D ,rf_idCase_D ,AmountDeduction_D ,rf_idSMO_D ,ENP_D ,DateBegin_D ,DateEnd_D ,rf_idV006_D ,DS1_D ,Policy_D ,AmountPayment_D ,Account_D ,DateAccount_D ,NumberCase_D)
SELECT  c1.CodeM ,c1.id ,c1.AmountDeduction ,c1.rf_idSMO ,c1.ENP ,c1.DateBegin ,c1.DateEnd ,c1.rf_idV006 ,c1.DS1 ,c1.NumberPolis ,c1.AmountPayment ,c1.Account ,c1.DateRegister ,c1.idRecordCase, 
	    c2.CodeM ,c2.id ,c2.AmountDeduction ,c2.rf_idSMO ,c2.ENP ,c2.DateBegin ,c2.DateEnd ,c2.rf_idV006 ,c2.DS1 ,c2.NumberPolis ,c2.AmountPayment ,c2.Account ,c2.DateRegister ,c2.idRecordCase
FROM cte c1 INNER JOIN cte c2 ON
		c1.ENP=c2.ENP
		AND c1.CodeM=c2.CodeM
		AND c1.rf_idV006=c2.rf_idV006
		AND c1.DateBegin=c2.DateBegin
		AND c1.DateEnd=c2.DateEnd
		AND c1.DS1=c2.DS1
		AND c1.id<>c2.id

UPDATE p SET AmountDeduction=AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT rf_idCase, SUM(AmountMEK+AmountMEE+AmountEKMP) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCaseVZ
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay	
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

UPDATE p SET AmountDeduction_D=AmountPayment_D-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT rf_idCase, SUM(AmountMEK+AmountMEE+AmountEKMP) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCaseVZ
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay	
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase_D=r.rf_idCase

SELECT  p1.CodeM ,l.NAMES,rf_idSMO ,Account ,DateAccount ,NumberCase ,DateBegin ,p1.DateEnd ,rf_idV006 ,DS1 ,Policy ,AmountDeduction, 
		----------------------
		p1.CodeM_D ,l_D.NAMES,rf_idSMO_D ,Account_D ,DateAccount_D ,NumberCase_D ,DateBegin_D ,p1.DateEnd_D ,rf_idV006_D ,DS1_D ,Policy_D ,AmountDeduction_D 
FROM #tPeople p1 INNER JOIN dbo.vw_sprT001 l ON
		p1.CodeM=l.CodeM
				INNER JOIN dbo.vw_sprT001 l_D ON
		p1.CodeM_D=l_D.CodeM

go

DROP TABLE #tPeople
