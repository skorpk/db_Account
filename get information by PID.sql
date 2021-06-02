USE AccountOMS
GO
SELECT c.DateBegin,c.DateEnd,d.DS1,mkb.Diagnosis
FROM dbo.t_Case_PID_ENP ce INNER JOIN dbo.t_Case c ON
			ce.rf_idCase=c.id
							INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
							INNER JOIN dbo.vw_sprMKB10 mkb ON
			d.DS1=mkb.DiagnosisCode                          
WHERE ce.PID=1750162 AND ce.ReportYear>2015