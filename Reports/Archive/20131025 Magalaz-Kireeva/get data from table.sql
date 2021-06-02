USE AccountOMS
GO
/*
Данные для выгрузки в Excel с помощью SSIS по СМО
*/
SELECT	Account, CONVERT(varCHAR(10),DateRegister,104) AS DateRegister, idRecordCase, DS1, Diagnosis, CAST(AmountPayment AS MONEY) AS AmountPayment, 
		 V002, CAST(Tariff AS MONEY) AS Tariff,
		 NumberHistoryCase, CONVERT(varCHAR(10),DateBegin,104) DateBegin, CONVERT(varCHAR(10),DateEnd,104) DateEnd, RSLT, ISHOD, PRVS, 
		 Fio, Sex, CONVERT(varCHAR(10),BirthDay,104) AS Dr, Age, 
		 NumberPolis, AttachLPU, MU, MUName, Quantity, CAST(Price AS MONEY) AS Price, 
		 CONVERT(varCHAR(10),DateHelpBegin,104) DateHelpBegin , CONVERT(varCHAR(10),DateHelpEnd,104) DateHelpEnd
FROM  dbo.tmp_MagalazKireeva_34002
UNION ALL
SELECT	Account, CONVERT(varCHAR(10),DateRegister,104) AS DateRegister, idRecordCase, DS1, Diagnosis, CAST(AmountPayment AS MONEY) AS AmountPayment,
		 V002, CAST(Tariff AS MONEY) AS Tariff,
		 NumberHistoryCase, CONVERT(varCHAR(10),DateBegin,104) DateBegin, CONVERT(varCHAR(10),DateEnd,104) DateEnd, RSLT, ISHOD, PRVS, 
		 Fio, Sex, CONVERT(varCHAR(10),BirthDay,104) AS Dr, Age, 
		 NumberPolis, AttachLPU, MU, MUName, Quantity, CAST(Price AS MONEY) AS Price, 
		 CONVERT(varCHAR(10),DateHelpBegin,104) DateHelpBegin , CONVERT(varCHAR(10),DateHelpEnd,104) DateHelpEnd
FROM  dbo.tmp_MagalazKireeva_34001
