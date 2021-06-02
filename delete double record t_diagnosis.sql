USE AccountOMSReports
GO
BEGIN TRANSACTION
;WITH double_r 
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY rf_idCase,TypeDiagnosis,DiagnosisCode ORDER BY rf_idCase,DiagnosisCode ) AS id, rf_idCase ,TypeDiagnosis,DiagnosisCode
FROM dbo.t_Diagnosis
WHERE TypeDiagnosis=2 
)
delete FROM double_r WHERE id>1

IF EXISTS(SELECT  rf_idCase ,TypeDiagnosis,DiagnosisCode,COUNT(*) AS ROW_COUNT
			FROM dbo.t_Diagnosis
			WHERE TypeDiagnosis=1 
			GROUP BY rf_idCase ,TypeDiagnosis,DiagnosisCode
			HAVING COUNT(*)>1  )
BEGIN
	ROLLBACK
  PRINT 'rollback'  
END
ELSE
BEGIN
	COMMIT
	PRINT 'commit'    
END