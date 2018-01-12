CREATE OR REPLACE VIEW tgrj_rjadm00023_aval_setor
AS
  SELECT DISTINCT rowidtochar(p.rowid) rowid_reg,
    p.setor setor,
    p.setor || ' - ' || h.nomesetor setordesc,
    p.pontuacao,
    p.emp_codigo,
    p.subemp_codigo,
    p.processo,
    p.data_avaliacao,
    s.codigo subempresa,
    s.codigo || ' - ' || s.fantasia subempresadesc
  FROM pgov_pontuacao_setor p,
    hsetor h,
    subempresas s
  WHERE p.setor       = h.setor
  AND p.subemp_codigo = s.codigo
  /