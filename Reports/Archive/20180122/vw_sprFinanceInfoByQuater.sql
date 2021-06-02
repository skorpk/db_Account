USE oms_nsi
GO
create VIEW vw_sprFinanceInfoByQuater
as
SELECT u.UnitCode, p.[year] AS PlanYear, p.rf_QuarterId AS Quater,p.rf_MOId,left(mo.tfomsCode,6) AS CodeM,p.unit_sum+ISNULL(c.correction_sum,0.0) AS SumPlan		
FROM oms_nsi.dbo.vw_sprFinSecurityUnit u INNER JOIN oms_nsi.dbo.tFinSecurityPlan p ON
			u.FinSecurityUnitId=p.rf_FinSecurityUnitId
										inner join oms_NSI.dbo.tMO mo on
			p.rf_MOId=mo.MOId 
									left JOIN oms_nsi.dbo.tFinSecurityCorrection c ON
			p.FinSecurityPlanId=c.rf_FinSecurityPlanId
				