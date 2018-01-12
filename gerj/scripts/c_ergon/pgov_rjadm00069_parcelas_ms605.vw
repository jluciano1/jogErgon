CREATE OR REPLACE FORCE VIEW pgov_rjadm00069_parcelas_ms605 
AS 
  SELECT p.numfunc, p.numvinc, p.dt_ini, p.dt_fim, p.vl_perc_parcela, p.vl_parcela, s.nome_beneficio, s.data, s.vl_saldo, s.dtfim, s.dtini, rowidtochar(p.rowid) rowid_reg
     FROM pgov_parcelas_ms605 p
LEFT JOIN pgov_saldos_ms605 s ON s.numfunc = p.numfunc
                             AND s.numvinc = p.numvinc
/