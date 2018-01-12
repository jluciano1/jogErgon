CREATE OR REPLACE VIEW ttgrj_rjadm00046_secr_cat_subc
AS
  SELECT DISTINCT rowidtochar(pss.rowid) rowid_reg,
    pss.chave,
    pss.subempresa cod,
    pss.subempresa,
    pack_cergon.pgov__get_subempresa_nome(pss.subempresa,flag_pack.get_empresa,'N') secretaria,
    pss.subempresa || ' - ' || pack_cergon.pgov__get_subempresa_nome(pss.subempresa,flag_pack.get_empresa,'N') secretaria_desc,
    pss.categoria,
    pss.categoria || ' - ' || c.nome categoria_desc,
    pss.subcategoria,
    pss.subcategoria || ' - ' || s.sigla subcategoria_desc
  FROM pgov_subemp_subcat pss,
    categorias c,
    subcategorias s
  WHERE pss.categoria  = c.sigla
  AND pss.categoria    = s.categoria
  AND pss.categoria    = c.sigla
  AND pss.subcategoria = s.sigla
  ORDER BY cod,
    secretaria,
    categoria,
    subcategoria
/