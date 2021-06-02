USE AccountOMS
GO
SELECT --zp.PID,
		f.CodeM,l.Names,a.Account,c.idRecordCase,po.FAM,po.IM,po.OT,CAST(po.DR AS DATE) AS DR
		,V012.name AS ISHOD,
		V009.name AS RSLT,v006.name AS USL_OK,c.DateBegin,c.DateEnd,CAST(zp.DS AS DATE) AS Ds
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
				INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
				INNER JOIN dbo.t_Case_PID_ENP cp ON
			c.id=cp.rf_idCase	
			AND cp.ReportYear=2014
				INNER JOIN PolicyRegister.dbo.REPZP4 zp ON
			cp.PID=zp.PID	
				INNER JOIN PolicyRegister.dbo.PEOPLE po ON
			zp.PID=po.ID 	
				INNER JOIN RegisterCases.dbo.vw_sprV009 V009 ON
			c.rf_idV009=V009.id	
				INNER JOIN RegisterCases.dbo.vw_sprV012 v012 ON
			c.rf_idV012=v012.id		
				INNER JOIN RegisterCases.dbo.vw_sprV006 v006 ON
			c.rf_idV006=v006.id	
				INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM	
			--------------------------------
			--	INNER JOIN dbo.t_RegisterPatient rp ON
			--r.id=rp.rf_idRecordCase
			--AND f.id=rp.rf_idFiles			
WHERE f.DateRegistration>'20140101' AND a.ReportYear=2014 AND c.DateEnd>=zp.DS   AND zp.dt>'20140629'
ORDER BY f.CodeM, a.Account