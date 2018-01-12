CREATE OR REPLACE FORCE VIEW pgov_rjadm00069_conc_ben_ms605
AS 
  SELECT numfunc, numvinc, tipo, dt_ini, dt_fim, perc, valor, dtini_atraso, dtfim_atraso, mesano_pag, vl_atraso, flag_desligamento, rowidtochar(rowid) rowid_reg
	FROM pgov_conc_benef_ms605
/