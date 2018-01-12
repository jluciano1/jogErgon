CREATE OR REPLACE VIEW rjadm00085_subespecialidades
AS
  SELECT a.disciplina ,
    a.atividade,
    a.tipo_area,
    a.descricao DESC_ATIV,
    rowidtochar(a.rowid) rowid_reg,
    d.descricao DESC_DISC ,
    d.flex_campo_01 ,
    d.flex_campo_02 ,
    d.flex_campo_03 ,
    d.flex_campo_04 ,
    d.flex_campo_05 ,
    d.pontlei
  FROM RH_DISCIPLINAS d,
    RH_ATIV_DISCIPLINA a
  WHERE a.disciplina = d.disciplina
  /