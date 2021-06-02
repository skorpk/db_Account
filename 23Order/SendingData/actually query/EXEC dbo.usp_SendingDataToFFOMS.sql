USE AccountOMS
GO
EXEC dbo.usp_SendingDataToFFOMS @reportYear = 2018, 
    @dateStart = '20180101', --с начало года берем
    @dateEnd = '20180227', -- на сегодняшний день случаи
    @dateStartPay = '20180212', -- дата последнего платежа
    @dateEndPay = '20180227' -- на сегодняшний день
