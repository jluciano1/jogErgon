CREATE OR REPLACE VIEW tgrj_rjadm00029_habilitacoes
AS
  SELECT rowidtochar(h.rowid) rowid_reg,
    h.numfunc,
    h.numvinc,
    h.disciplina,
    h.chave,
    d.descricao,
    h.disciplina
    || ' - '
    || d.descricao AS codDescr
  FROM tgrj_habilitacoes h,
    rh_disciplinas d
  WHERE h.disciplina = d.disciplina
  /