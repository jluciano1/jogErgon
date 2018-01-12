CREATE OR REPLACE VIEW tgrj_rjadm00058_vw_usuarios
AS
  SELECT rowidtochar(t.rowid) rowid_reg,
    u.nomeusuario nome,
    t.id_agencia,
    t.fl_supervisor,
    t.dtini,
    t.dtfim,
    t.usuario
  FROM usuario u,
    tgrj_age_rioprev_usuario t
  WHERE t.usuario = u.usuario
  /