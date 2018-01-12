prompt ***ATEN��O!!!*** Objeto TGRJ_GEE n�o possui replace e deve ser mesclado manualmente com a vers�o existente no banco.
  CREATE FORCE VIEW "C_ERGON"."TGRJ_GEE" ("ROWID_REG", "NOME", "DT_CRIACAO", "GEE") AS
  select
         rowidtochar(t.rowid) as rowid_reg,
         t.nome,
         t.dt_criacao,
         t.gee
    from tgrj_gee_ t, tgrj_gee_empresa te
   where te.empresa = flag_pack.get_empresa
     and t.gee = te.gee
/



