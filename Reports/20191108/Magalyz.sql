USE AccountOMS
GO
USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME=GETDATE(),
		@reportYear SMALLINT=2019
	


SELECT DISTINCT c.id AS rf_idCase, a.Account, a.DateRegister, c.idRecordCase,d.DS1,cc.DateBegin,cc.DateEnd,c.rf_idV008 AS Vid,c.rf_idV002 ,
		f.CodeM,cc.AmountPayment ,c.NumberHistoryCase,c.rf_idV009 AS RSLT	,c.rf_idV010 AS IDSP,c.rf_idV012 AS ISHOD ,c.Age ,ps.ENP,f.DateRegistration,r.AttachLPU,a.rf_idSMO
		,CASE WHEN p.TypeCheckup=1 THEN 1 ELSE 0 end AS MEK,CASE WHEN p.TypeCheckup=2 THEN 1 ELSE 0 end AS MEE,CASE WHEN p.TypeCheckup=3 THEN 1 ELSE 0 end AS EKMP
		,c.rf_idDirectMO,n.id,pp.FAM+' '+pp.IM+' '+pp.OT AS FIO, CASE WHEN pp.W=1 THEN'Ì' ELSE 'Æ' END AS Sex,pp.DR,m.Tariff
INTO #tmpPeople 
FROM AccountOMS.dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts                  
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
		r.id = c.rf_idRecordCasePatient 	
					INNER JOIN dbo.t_CompletedCase cc ON
		r.id = cc.rf_idRecordCasePatient 						  
					INNER JOIN dbo.tmp_NMIC	n ON
        ps.ENP=n.ENP	
		AND n.CodeM=f.CodeM	
					INNER JOIN dbo.vw_Diagnosis d ON
          c.id=d.rf_idCase					
					INNER JOIN PolicyRegister.dbo.PEOPLE pp ON
           ps.ENP=pp.ENP
					INNER JOIN dbo.t_MES m ON
                c.id=m.rf_idCase
					left JOIN dbo.t_PaymentAcceptedCase2 p ON
			c.id=p.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportMonth>=1 AND a.ReportMonth<=9 AND a.ReportYear=@reportYear
	AND n.DateConclusion >=cc.DateBegin AND n.DateConclusion<=cc.DateEnd AND c.rf_idV006<3

SELECT 
	p.Account,
       p.DateRegister,
	   CAST(n.DateConclusion AS DATE) AS DateConclusion,
	   p.idRecordCase,
	   n.NumberQuestion,      
	   v2.name AS Profil,
	   p.DS1,
	   mkb.Diagnosis,
	   p.DateBegin,
       p.DateEnd,
	   p.CodeM+' - '+l.NAMES AS LPU,
	   v6.name AS Vid,
	   mm.mNameS AS NPR_MO,
	   cast(p.AmountPayment AS MONEY) AS AmountPayment,
	   cast(p.Tariff AS MONEY) AS Tariff,
	   p.NumberHistoryCase,
        v9.name AS RSLT,
       v10.name AS IDSP,
       v12.name AS ISHOD,
	   p.FIO ,p.Sex,CAST(p.DR AS DATE) AS dr,
	   p.Age,
	   n.ENP,
       CAST(p.DateRegistration AS DATE) AS DateRegistration,
       --p.AttachLPU,
	   lll.NAMES,
       SUM(p.MEK) AS MEK,
	   SUM(p.MEE) AS MEE,
	   SUM(p.EKMP) AS EKMP,     
       s.sNameS      
FROM dbo.tmp_NMIC n inner JOIN  #tmpPeople p on
		n.id=p.id
			inner JOIN dbo.vw_sprMKB10 mkb ON
        p.DS1=mkb.DiagnosisCode
			inner JOIN dbo.vw_sprT001 l ON
        p.CodeM=l.CodeM
			inner JOIN RegisterCases.dbo.vw_sprV08 v6 ON
         p.Vid=v6.id
				inner JOIN RegisterCases.dbo.vw_sprV010 v10 ON
         p.IDSP	=v10.id
				inner JOIN RegisterCases.dbo.vw_sprV009 v9 ON
         p.RSLT	=v9.id
				inner JOIN RegisterCases.dbo.vw_sprV002 v2 ON
         p.rf_idV002=v2.id
				inner JOIN RegisterCases.dbo.vw_sprV012 v12 ON
         p.ISHOD=v12.id
				--INNER JOIN dbo.vw_sprT001 ll ON
    --    p.rf_idDirectMO=l.mcod
				inner JOIN dbo.vw_sprSMO s	ON
        p.rf_idSMO=s.smocod	   
				INNER JOIN oms_nsi.dbo.tMO mm ON
		p.rf_idDirectMO=mm.mcod                
				LEFT JOIN 	dbo.vw_sprT001 lll ON
        p.AttachLPU=lll.CodeM
GROUP BY p.Account,
       p.DateRegister,
	   CAST(n.DateConclusion AS DATE) ,
	   p.idRecordCase,
	   n.NumberQuestion,      
	   v2.name ,
	   p.DS1,
	   mkb.Diagnosis,
	   p.DateBegin,
       p.DateEnd,
	   p.CodeM+' - '+l.NAMES ,
	   v6.name ,
	   mm.mNameS ,
	   cast(p.AmountPayment AS MONEY) ,
	   cast(p.Tariff AS MONEY) ,
	   p.NumberHistoryCase,
        v9.name ,
       v10.name ,
       v12.name ,
	   p.FIO ,p.Sex,CAST(p.DR AS DATE) ,
	   p.Age,
	   n.ENP,
       CAST(p.DateRegistration AS DATE) ,
	   lll.NAMES,       
       s.sNameS      
GO
		
DROP TABLE #tmpPeople