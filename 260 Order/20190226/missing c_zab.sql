USE AccountOMS
GO
SELECT *
FROM dbo.t_260order_ONK WHERE GUID_Case='F2AA6774-6FF2-4F4F-65E7-4DA188B93227'
go
USE RegisterCases
GO
SELECT SL_ID INTO #t
FROM (VALUES ('F2AA6774-6FF2-4F4F-65E7-4DA188B93227'),
('242C44D4-978C-370B-98B8-CAA18A33B0B2'),
('5B80A7B8-B754-1E7F-5A8D-D6718A3472A2'),
('A7D08D7D-2F1D-22C4-045E-43418A354D75'),
('3DCCDBAD-F58E-64F0-93FC-53F18B2BF608'),
('488E224F-5670-4653-E6EC-99918B2C9E9C'),
('CA3CA947-8DAF-901F-4A3A-F431891AC485'),
('8F9CAF1D-913E-F068-DCA0-BE4188B962D5'),
('060C4E3D-1A1B-7027-6382-14A1891DCA40'),
('D25CF10F-1511-E712-900B-E26188B7ECBB'),
('08D5622D-3DD9-F297-8686-A50188B894E1'),
('7ED495A9-BE0B-4048-7A2D-1BE1891E8093'),
('E12E7F75-B63F-4630-321C-B491891A3321'),
('27A500A3-E4F3-79E9-7D60-4B7188B6AE74'),
('6CF39F7C-914A-9F7A-4AD6-05618920B692'),
('E61D7BFB-8DFA-6587-73D7-61E188B88749'),
('CD770B34-E6D1-6F0C-569A-57D188B90061'),
('6D814098-2E6E-1B6E-04B9-6AD188B8FB12'),
('CDC23B9A-FC07-9C29-0AA6-A64188B7963D'),
('A03B52E2-3167-85CB-0449-AFC188B73CDD'),
('445AAD39-E6C0-5BFB-E978-8EC188B8E2B2'),
('AB455C6E-55A8-4C9D-AB25-747188B91603'),
('D8C5ECDE-DBB0-24D7-D575-9201891EED21'),
('CBC3EB4F-8A57-2305-29DD-116188B71DFB'),
('D5D80F17-D42E-8E3B-868A-E1E188B94E51'),
('0F813F31-7A30-D486-1F85-C04188AC6199'),
('D5682608-7155-9C73-F44D-F74188B58B08'),
('381DAE0C-943F-A58A-346E-180188B87604'),
('9ECFFCDF-0242-79D0-BDEC-59D188B85DD7'),
('7AD64E5B-24CB-71FA-4423-4ED188B75B3A'),
('C025912D-4973-6342-B4F3-A76188B7AF14'),
('84841EA2-8DB1-FA78-C584-379188B74836'),
('29181A63-2792-A2F9-9F04-818188B8CF0F'),
('FC20F302-1307-8793-BA10-051188B77D44'),
('F656EDFA-8D68-DC27-02F1-23E188B824FA'),
('9A8102FD-312F-453B-9AFD-5CB18920411A') ) v(SL_ID)

SELECT f.FileNameHR,f.id ,a.NumberRegister,COUNT(c.id)
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase	
					INNER JOIN #t t ON
			c.GUID_Case=t.sl_id                  
WHERE  f.DateRegistration>'20190120'
GROUP BY f.FileNameHR,f.id ,a.NumberRegister