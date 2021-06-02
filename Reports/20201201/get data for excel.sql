USE AccountOMS
GO
SELECT LPU,Account, DateAccount, idRecordCase, DateBegin,  DateEnd,  AmountPayment,  V006,  FIO,  BirthDay
	,  Sex,  SNILS, ENP,  TypePolis,  NumberPolis,  DS1,  DS2,  RSLT,  ISHOD 
FROM dbo.tmpCovidCases_20201130
ORDER BY lpu