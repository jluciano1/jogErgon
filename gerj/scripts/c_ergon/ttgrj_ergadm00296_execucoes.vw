  CREATE OR REPLACE VIEW ttgrj_ergadm00296_execucoes AS
  SELECT rowidtochar(f.rowid) rowid_reg,
    f.mes_ano,
    f.numero,
    f.data_consol,
    t.tipo AS tipo_folha,
    t.nome,
    t.finalidade_calculo,
    t.calculavel,
    fe.emp_codigo
  FROM tipo_folha t,
    folhas f,
    folhas_emp fe
  WHERE t.tipo  = f.tipo_folha
  AND f.mes_ano = fe.mes_ano
  AND f.numero  = fe.numero
  /