CREATE OR REPLACE FORCE VIEW pgov_rjadm00069_benefici_ms605 
AS 
  SELECT numfunc, numvinc, dt_ini, dt_fim, vl_perc_reajuste, vl_mont, vl_mont_pg_sape, dt_ini_ref, dt_fim_ref, vl_ufir, st_beneficio, total_pago, rowidtochar(rowid) rowid_reg,
  case st_beneficio when 'S' then 'S - Sem Processo' when 'A' then 'A - Ativo' when 'C' then 'C - Concluído' when 'X' then 'Sim' end as st_ben_desc
   FROM pgov_beneficios_ms605
/