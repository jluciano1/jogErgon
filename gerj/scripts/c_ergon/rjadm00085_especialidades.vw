CREATE OR REPLACE 
VIEW rjadm00085_especialidades
AS
  SELECT pontlei,
    flex_campo_05,
    flex_campo_04,
    flex_campo_03,
    flex_campo_02,
    flex_campo_01,
    grupo_medicina,
    grupo_segur,
    grau_risco,
    qual_equip,
    descricao,
    equip_segur,
    nome,
    codigo,
    flex_campo_15,
    flex_campo_14,
    flex_campo_13,
    flex_campo_12,
    flex_campo_11,
    flex_campo_10,
    flex_campo_09,
    flex_campo_07,
    flex_campo_06,
    rowidtochar(rowid) rowid_reg
  FROM RH_ATIVIDADE_

/