CREATE OR REPLACE FORCE 
VIEW TTGRJ_ERGADM00010_FORMASVAC 
AS
  SELECT DISTINCT
    -2    VALOR ,
    0     EMPCOD  ,
    NULL  EMPNOME ,
    a.sigla         , 
    a.nome          , 
    a.flex_campo_01 ,
    PACK_UTIL_CERG.GET_DESCR_ITEM('CERG_GFIP_CDAFAST', a.flex_campo_01) as flex01desc, 
    a.flex_campo_02 ,
    a.flex_campo_03 , 
    a.flex_campo_04 , 
    a.flex_campo_05 , 
    a.pontlei       ,   
    a.flex_campo_06 , 
    a.flex_campo_07 , 
    a.flex_campo_08 , 
    a.flex_campo_09 , 
    a.flex_campo_10 , 
    a.flex_campo_11 , 
    a.flex_campo_12 , 
    a.flex_campo_13 , 
    a.flex_campo_14 , 
    a.flex_campo_15 , 
    a.flex_campo_16 , 
    a.flex_campo_17 , 
    a.flex_campo_18 , 
    a.flex_campo_19 , 
    a.flex_campo_20 ,
    a.codigo_caged  , 
    decode(a.codigo_caged, null, null, (a.codigo_caged || ' - ' || ( SELECT itb.descr FROM itemtabela itb
       WHERE itb.tab   = 'ERG_TIPO_MOV_CAGED' AND 
             itb.item1 = 'DEMISSAO' AND 
             itb.item  = a.codigo_caged
    ))) DESCR_COD_CAGED ,
    rowidtochar(a.ROWID) ROWID_REG
  , 'Empresa' link_emp
  FROM
    formas_vac_        a,
    formas_vac_empresa b
  WHERE
    a.sigla    = b.sigla(+)
  AND b.sigla IS NULL
  --
  UNION ALL
  --
  SELECT DISTINCT
    -1    VALOR ,
    0     EMPCOD  ,
    NULL  EMPNOME ,
    a.sigla     ,
    a.nome      ,
    a.flex_campo_01 ,
    PACK_UTIL_CERG.GET_DESCR_ITEM('CERG_GFIP_CDAFAST', a.flex_campo_01) as flex01desc,  
    a.flex_campo_02 ,
    a.flex_campo_03 , 
    a.flex_campo_04 , 
    a.flex_campo_05 , 
    a.pontlei   , 
    a.flex_campo_06 , 
    a.flex_campo_07 , 
    a.flex_campo_08 , 
    a.flex_campo_09 , 
    a.flex_campo_10 , 
    a.flex_campo_11 , 
    a.flex_campo_12 , 
    a.flex_campo_13 , 
    a.flex_campo_14 , 
    a.flex_campo_15 , 
    a.flex_campo_16 , 
    a.flex_campo_17 , 
    a.flex_campo_18 , 
    a.flex_campo_19 , 
    a.flex_campo_20 ,
    a.codigo_caged  ,
    decode(a.codigo_caged, null, null, (a.codigo_caged 
  || 
  ' - ' 
  ||
  ( SELECT itb.descr FROM itemtabela itb
       WHERE itb.tab   = 'ERG_TIPO_MOV_CAGED' AND 
             itb.item1 = 'DEMISSAO' AND 
             itb.item  = a.codigo_caged
    ))) DESCR_COD_CAGED ,
    rowidtochar(a.ROWID)       ROWID_REG
  , 'Empresa' link_emp
  FROM
    formas_vac_        a 
  --
  UNION ALL
  --
  SELECT DISTINCT
    b.empresa   VALOR   ,
    em.empresa  EMPCOD  ,
    em.nome     EMPNOME ,
    a.sigla             ,
    a.nome              ,
    a.flex_campo_01     ,
    PACK_UTIL_CERG.GET_DESCR_ITEM('CERG_GFIP_CDAFAST', a.flex_campo_01) as flex01desc,   
    a.flex_campo_02     ,
    a.flex_campo_03     , 
    a.flex_campo_04     , 
    a.flex_campo_05     , 
    a.pontlei           , 
    a.flex_campo_06     , 
    a.flex_campo_07     , 
    a.flex_campo_08     , 
    a.flex_campo_09     , 
    a.flex_campo_10     ,  
    a.flex_campo_11     , 
    a.flex_campo_12     , 
    a.flex_campo_13     , 
    a.flex_campo_14     , 
    a.flex_campo_15     , 
    a.flex_campo_16     , 
    a.flex_campo_17     , 
    a.flex_campo_18     , 
    a.flex_campo_19     , 
    a.flex_campo_20     ,      
    a.codigo_caged      ,
    decode(a.codigo_caged, null, null, (a.codigo_caged
    || ' - '
    ||( SELECT itb.descr FROM itemtabela itb
       WHERE itb.tab   = 'ERG_TIPO_MOV_CAGED' AND 
             itb.item1 = 'DEMISSAO' AND 
             itb.item  = a.codigo_caged
    ))) DESCR_COD_CAGED ,
    rowidtochar(a.ROWID) ROWID_REG
  , 'Empresa' link_emp
  FROM
    formas_vac_        a,
    formas_vac_empresa b,
    empresas           em
  WHERE
    a.sigla     = b.sigla
  AND b.empresa = em.empresa
  AND ACESSO_USUARIO_EMPRESA(FLAG_PACK.GET_USUARIO(), b.empresa) = 1
/