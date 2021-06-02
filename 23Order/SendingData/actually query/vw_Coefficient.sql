USE AccountOMS
go
alter VIEW vw_Coefficient
as
SELECT A.SLPCoefficientId as IDSL,
       B.code as codeTFOMS,
       A.coefficient as KOEF,
	   c.id,
	   cc.Coefficient
FROM oms_nsi.dbo.tSLPCoefficient A inner join oms_nsi.dbo.tSLP B on 
				A.rf_SLPId = B.SLPId
								INNER JOIN dbo.t_Coefficient cc ON
				b.code=cc.Code_SL
								INNER JOIN dbo.t_Case c ON
				cc.rf_idCase=c.id
WHERE c.DateEnd>=a.dateBeg AND c.DateEnd<=a.dateEnd AND c.id=80576220				                              
go				                              