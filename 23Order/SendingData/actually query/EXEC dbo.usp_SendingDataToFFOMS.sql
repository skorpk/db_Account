USE AccountOMS
GO
EXEC dbo.usp_SendingDataToFFOMS @reportYear = 2018, 
    @dateStart = '20180101', --� ������ ���� �����
    @dateEnd = '20180227', -- �� ����������� ���� ������
    @dateStartPay = '20180212', -- ���� ���������� �������
    @dateEndPay = '20180227' -- �� ����������� ����
