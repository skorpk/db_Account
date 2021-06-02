--DROP TABLE tmp_Raschet_9_mes_clear
--DROP TABLE tmp_Raschet_9_mu_clear
--SELECT * INTO tmp_Raschet_9_mes_clear FROM dbo.tmp_Raschet_9_mes
--SELECT * INTO tmp_Raschet_9_mu_clear FROM dbo.tmp_Raschet_9_mu


delete from tmp_Raschet_9_mes_clear where MES like '70.3.%'
delete from tmp_Raschet_9_mes_clear where MES like '70.5.%'
delete from tmp_Raschet_9_mes_clear where MES like '70.6.%'
delete from tmp_Raschet_9_mes_clear where MES like '72.%'

delete from tmp_Raschet_9_mu_clear where MUGroupCode=2 and MUUnGroupCode in (83,84,85,86,87)
delete from tmp_Raschet_9_mu_clear where MUGroupCode=57
delete from tmp_Raschet_9_mu_clear where MUGroupCode=60 and MUUnGroupCode =2 and MUCode=5

delete from tmp_Raschet_9_mes_clear where MES='2.78.5'
delete from tmp_Raschet_9_mu_clear where MUGroupCode=2 and MUUnGroupCode =79 and MUCode=6
delete from tmp_Raschet_9_mu_clear where MUGroupCode=2 and MUUnGroupCode =81 and MUCode=5
