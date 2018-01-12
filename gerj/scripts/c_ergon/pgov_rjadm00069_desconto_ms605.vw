CREATE OR REPLACE FORCE VIEW pgov_rjadm00069_desconto_ms605 
AS 
  SELECT numfunc, numvinc, dt_ini_benef, dt_fim_credito, dt_desc, vl_desc, vl_pago, matricula, dt_migracao, st_pago, obs, rowidtochar(rowid) rowid_reg
    FROM pgov_descontos_ms605
/