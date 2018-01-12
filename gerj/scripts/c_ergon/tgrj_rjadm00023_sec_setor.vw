CREATE OR REPLACE VIEW tgrj_rjadm00023_sec_setor
AS
  SELECT rowidtochar(su.rowid) rowid_reg,
    su.processo,
    su.processo || ' - ' || p.descricao descricao,
    su.subemp_codigo,
    su.data_avaliacao,
    su.emp_codigo,
    su.pontuacao,
    s.codigo || ' - ' || s.fantasia subempresa
  FROM pgov_pontuacao_subempresa su,
    prom_processo p,
    subempresas s
  WHERE su.processo    = p.processo
  AND su.emp_codigo    = p.emp_codigo
  AND su.subemp_codigo = s.codigo
  AND p.emp_codigo     = s.emp_codigo
  /