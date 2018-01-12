CREATE OR REPLACE VIEW tgrj_rjadm00058_vw_agencias
AS
  SELECT rowidtochar(rowid) rowid_reg,
    id_agencia,
    ds_agencia
  FROM tgrj_agencias_rioprev
  /