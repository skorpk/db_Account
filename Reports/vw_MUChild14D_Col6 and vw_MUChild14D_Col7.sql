create view vw_MUChild14D_Col6
as
select m1.rf_idCase,(m1.Quantity1+m2.Quantity2) as Quantity
from(
	 select m.rf_idCase,sum(m.Quantity) as Quantity1
	 from t_Meduslugi m where m.MUInt=7001003 group by m.rf_idCase
	 ) m1 inner join(select m.rf_idCase,sum(m.Quantity) as Quantity2 from t_Meduslugi m where m.MUInt=7001001 group by m.rf_idCase) m2 on
		m1.rf_idCase=m2.rf_idCase
go
create view vw_MUChild14D_Col7
as
select m1.rf_idCase,(m1.Quantity1+m2.Quantity2) as Quantity
from(
	 select m.rf_idCase,sum(m.Quantity) as Quantity1
	 from t_Meduslugi m where m.MUInt=7001002 group by m.rf_idCase
	 ) m1 inner join(select m.rf_idCase,sum(m.Quantity) as Quantity2 from t_Meduslugi m where m.MUInt=7001003 group by m.rf_idCase) m2 on
		m1.rf_idCase=m2.rf_idCase
go