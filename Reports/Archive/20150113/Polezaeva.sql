USE AccountOMS
GO
CREATE TABLE #searchPeople(PID INT,Fam VARCHAR(30),Im VARCHAR(30),OT VARCHAR(30),DR DATE)

INSERT #searchPeople( PID, Fam, Im, OT, DR )
SELECT v.PID,v.Fam,v.IM,v.Ot,CAST(DATEADD(DAY,-2,cast(v.DR AS datetime)) AS DATE)
FROM (VALUES  (36919,'����������','�������','��������',5125),
(48867,'�������','�������','���������',5060),
(52501,'��������','���������','��������',5455),
(98592,'��������','�������','����������',4660),
(125582,'���������','������','������������',5451),
(147520,'����������','���������','�����������',4285),
(157102,'������������','���������','��������',5431),
(139614,'���������','�������','�����������',4200),
(119391,'���������','���������','��������',5296),
(198672,'����������','�����','��������',3835),
(118788,'�����','������','��������',5059),
(89383,'���������','�������','����������',5420),
(88112,'��������','�����','����������',5173),
(228704,'������','����','����������',4959),
(229837,'��������','�������','��������',4931),
(232660,'���','�������','�������������',4495),
(137255,'���������','�������','��������',5181),
(253656,'����������','����','���������',5462),
(205149,'��������','����','��������������',4019),
(74026,'�������','�������','��������',4763),
(302026,'�������','�����','��������',5479),
(302243,'��������','��������','����������',5312),
(285357,'��������','������','���������',5270),
(167128,'���������','����������','��������',5443),
(286317,'����������','��������','��������',4822),
(191776,'����������','�������','������������',5298),
(291640,'����������','������','����������',4793),
(211994,'����������','����','����������',4189),
(68268,'����������','�����','���������',5296),
(294133,'��������','����������','�������������',4461),
(293258,'�����������','����','���������',5199),
(125116,'��������','�����','����������',5361),
(267662,'���������','��������','����������',4200),
(113825,'�������','����������','��������',4496),
(248643,'���������','���������','����������',5442),
(100386,'���������','����������','���������',5228),
(282175,'�����','�����','�����������',5382),
(318398,'��������','�����','���������',4880),
(318413,'��������','������','����������',5061),
(340867,'��������','�����','����������',4879),
(341510,'���������','������','���������',4805),
(345854,'����','����','���������',5285),
(360119,'�������','�������','�����������',3758),
(357822,'�������','����','���������',5293),
(356877,'������','�������','���������',5284),
(313987,'�������','�����','��������',4719),
(339345,'��������','���������','���������',4668),
(378710,'��������','����','����������',4577),
(386205,'��������','�������','��������',4019),
(386843,'��������','������','����������',5009),
(433855,'�����������','�����','���������',5121),
(495330,'����������','�����','���������',5161),
(431569,'������','�������','�������',3729),
(504213,'�������','���������','������������',5048),
(477000,'������','����','����������',5475),
(488661,'���������','������','�����������',5400),
(497762,'�������','�������','��������',4754),
(468975,'�������','�������','���������',4555),
(468901,'���������','�������','��������',4389),
(496501,'�������','����������','���������',5225),
(421890,'�����������','�������','���������',5334),
(415141,'�������','����','��������',5396),
(411785,'������','�����','���������',4575),
(505965,'��������','���������','��������',4670),
(590960,'�������','�����','�����������',4499),
(536273,'���','�������','',3654),
(542935,'�����','�������','����������',5207),
(601166,'����������','�������','�����������',4590),
(613219,'����������','���������','���������',5403),
(456712,'����������','����','�����������',5208),
(544538,'������','�������','������������',4494),
(555400,'����������','�������','���������',4642),
(543798,'���������','�����','���������',4886),
(581728,'��������������','����','�����������',4981),
(651719,'�����','������','���������',4931),
(669128,'����������','������','�����������',4726),
(642868,'�������','���������','����������',4681),
(672419,'���������','������','����������',5395),
(686660,'����������','���������','�����������',4162),
(691171,'������','��������','��������',4628),
(709409,'������','������','����������',5230),
(717713,'������','�����','����������',5153),
(721463,'�������','���������','��������',4750),
(724919,'��������','������','�����������',5163),
(725003,'�����','���������','�����������',5154),
(734947,'���������','�������','��������',5069),
(734976,'��������','�����','����������',5131),
(740483,'�������','����������','��������',3767),
(761232,'���������','�������','��������',4541),
(823097,'����������','���������','����������',4693),
(822774,'�������','������','����������',5296),
(822517,'������','�����','���������',5242),
(818445,'��������','���������','���������',4285),
(803447,'������','�����','���������',4750),
(796907,'�������','�������','��������',5329),
(790623,'�������','�����','��������',4943),
(786184,'��������','�����','���������',3783),
(775611,'�����','��������','�����������',5037),
(775005,'��������','�����','���������',5220),
(772351,'�������','�������','���������',4884),
(765931,'����������','�������','���������',4795),
(765344,'����������','������','�������������',5395),
(841507,'��������','�������','����������',4931),
(855056,'�������','�������','����������',4566),
(865065,'���������','����������','��������',4632),
(968533,'�������','�������','���������',4983),
(880262,'�������','�����','���������',4942),
(970810,'���������','�������','���������',5397),
(887047,'������','���������','��������',5290),
(889144,'���������','�����','��������',4025),
(988036,'�������','�������','����������',5060),
(895401,'���������','�����','',5296),
(989568,'��������','����','��������',5178),
(991803,'������','�����','����������',5296),
(899246,'����������','���������','��������',4931),
(907943,'������','������','��������',5019),
(911779,'���������','�������','��������',5469),
(913149,'������','�������','��������',5218),
(1016387,'����������','����','���������',4815),
(914153,'���������','�����','���������',4785),
(947928,'���������','����','��������',4566),
(1003000,'�������','�������','����������',5296),
(1062409,'�����','�������','�����������',5399),
(1079558,'������','���������','���������',4424),
(1031695,'��������','��������','�����������',3886),
(1042503,'��������','���������','�����������',5354),
(1043924,'���������','����','����������',4920),
(976313,'�����','���������','���������',5331),
(987682,'�������','������','��������',5004),
(988858,'��������','���������','����������',5380),
(1061765,'�������','�������','��������',5425),
(1068552,'������','����','��������',4641),
(1069040,'�������','�����','����������',5244),
(1052964,'���������','�������','��������',5339),
(945723,'��������','�����','�������������',4230),
(960970,'��������','���������','����������',5245),
(1082021,'���������','�������','���������',5122),
(1095547,'���������','���������','�����������',5442),
(1112654,'�����','�����','���������',5351),
(1112974,'����������','�����','����������',5207),
(1119067,'������','���������','����������',5097),
(1126721,'���������','��������','�����������',5319),
(1114420,'������','�������','���������',4822),
(1145891,'��������','����������','��������',4853),
(1163517,'������','���������','����������',5054),
(1172918,'��������','�������','����������',5346),
(1181164,'�������','�������','����������',5219),
(1185202,'�������','�������','���������',5296),
(1190912,'�������','���������','����������',5445),
(1192114,'���������','����������','��������',5433),
(1193316,'������','����','����������',5237),
(1198363,'���������','������','��������',5369),
(1198496,'������','������','���������',4245),
(1200726,'���������','������','��������',5296),
(1201498,'�������','���������','��������',5407),
(1205085,'�������','�����','�����������',4509),
(1206791,'��������','�������','���������',4200),
(1209279,'��������','����','���������',5019),
(1210038,'��������','����','����������',5193),
(1213436,'����������','�������','��������',4489),
(2945503,'���������','�������','���������',3613),
(2993199,'��������','����������','���������',3364),
(2993449,'��������','�������','���������',3359),
(2962218,'�����������','�����','����������',2676)) v(PID,Fam,IM,Ot,DR)


SELECT l.filialName AS [������],f.CodeM AS [��� ��],l.Namef AS [������������ ��],p.Fam +' '+ p.Im+' '+ p.OT AS [���]
		, p.DR AS [���� ��������],c.DateBegin AS [���� ������],c.DateEnd AS [���� ���������],v006.name AS [������� ��������]
		,a.Account AS [� �����],a.DateRegister AS [���� �����],c.idRecordCase AS [� ������]
		,a.ReportMonth AS [�������� �����],CAST(c.AmountPayment AS MONEY)  AS [��������� ������]
FROM dbo.t_Case_PID_ENP ce INNER JOIN #searchPeople p ON
			ce.PID=p.PID
						INNER JOIN t_Case c ON
			ce.rf_idCase=c.id
						INNER JOIN dbo.t_RecordCasePatient rp ON
			c.rf_idRecordCasePatient=rp.id
						INNER JOIN dbo.t_RegistersAccounts a ON
			rp.rf_idRegistersAccounts=a.id
						INNER JOIN dbo.t_File f ON
			a.rf_idFiles=f.id
						INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM
						INNER JOIN RegisterCases.dbo.vw_sprV006 v006 ON
			c.rf_idV006=v006.id						
WHERE ce.ReportYear=2014 AND f.DateRegistration>'20140101' AND f.DateRegistration<'20150114'
UNION 
SELECT l.filialName AS [������],f.CodeM AS [��� ��],l.Namef AS [������������ ��],p.Fam +' '+ p.Im+' '+ p.OT AS [���]
		, p.DR AS [���� ��������],c.DateBegin AS [���� ������],c.DateEnd AS [���� ���������],v006.name AS [������� ��������]
		,a.Account AS [� �����],a.DateRegister AS [���� �����],c.idRecordCase AS [� ������]
		,a.ReportMonth AS [�������� �����],CAST(c.AmountPayment AS MONEY)  AS [��������� ������]
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
				  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
				  INNER JOIN dbo.t_RegisterPatient p1 ON
					r.id=p1.rf_idRecordCase
					AND p1.rf_idFiles=f.id
				  INNER JOIN #searchPeople p ON
					p1.Fam=p.Fam
					AND p1.Im=p.Im
					AND ISNULL(p1.Ot,'')=ISNULL(p.Ot,'')
				  INNER JOIN t_Case c ON
					r.id=c.rf_idRecordCasePatient						
						INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM
						INNER JOIN RegisterCases.dbo.vw_sprV006 v006 ON
			c.rf_idV006=v006.id						
WHERE a.ReportYear=2014 AND f.DateRegistration>'20140101' AND f.DateRegistration<'20150114'
ORDER BY filialName

go

DROP TABLE #searchPeople			
