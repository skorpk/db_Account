USE RegisterCases
GO
DECLARE @idFile INT
SELECT @idFile=id FROM dbo.vw_getIdFileNumber WHERE ReportYear=2014 AND NumberRegister=4 AND CodeM='491001'

---------------------Test 1---------------------
SELECT COUNT(rf_idCase),ErrorNumber FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber

select mes.rf_idCase,566
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
					inner join t_MES mes on
			c.id=mes.rf_idCase
where mes.Tariff<>c.AmountPayment

select c.id,566
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.IsCompletedCase=0
						left join dbo.t_Meduslugi m on
			c.id=m.rf_idCase
where a.rf_idFiles=@idFile
group by c.id,c.AmountPayment
having c.AmountPayment<>ISNULL(cast(SUM(m.Quantity*m.Price) as decimal(15,2)),0) 

select c.id,566,c.AmountPayment,c.rf_idV006
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
where a.rf_idFiles=@idFile AND c.AmountPayment<=0 AND c.rf_idV006<>4