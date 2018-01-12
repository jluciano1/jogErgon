CREATE OR REPLACE FORCE 
VIEW TTGRJ_ERGADM00009_TIPOAPOS
AS 
  SELECT DISTINCT -2 VALOR ,
    0 EMPCOD ,
    NULL EMPNOME ,
    t.tipo ,
    t.proporc ,
    t.pagair ,
    t.obs ,
    t.formavac ,
    (fc.sigla || ' - ' || fc.nome) as formavac_descr,
    t.fundamento ,
    it.item || ' - ' || it.descr as nome_fundamento,
    t.tipoprop ,
    t.fracao1tabger ,
    (select tab||' - '||descr descr 
       from tabela
      where tab = t.fracao1tabger
        and t.proporc = 'S' 
        and t.tipoprop = 'F') fracao1tabger_desc,
    t.fracao2 ,
    t.pontlei ,
    'TIPO_APOS_' TABELA ,
    rowidtochar(t.ROWID) ROWID_REG ,
    t.flex_campo_01 ,
    PACK_UTIL_CERG.GET_DESCR_ITEM('GRJ_GRUPO_APOSENT', t.flex_campo_01) as flex01desc,
    t.flex_campo_02 ,
    t.flex_campo_03 ,
    DECODE (t.flex_campo_03 ,'P', 'Proporcional', 
                             'I', 'Integral', 
                             'R', 'Redutor') flex03desc,
    t.flex_campo_04 ,
    T.FLEX_CAMPO_05 ,
    T.FLEX_CAMPO_06   ,
    T.FLEX_CAMPO_07   ,
    T.FLEX_CAMPO_08   ,
    T.FLEX_CAMPO_09   ,
    T.FLEX_CAMPO_10   ,
    T.FLEX_CAMPO_11   ,
    T.FLEX_CAMPO_12   ,
    T.FLEX_CAMPO_13   ,
    T.FLEX_CAMPO_14   ,
    T.FLEX_CAMPO_15   ,
    PACK_UTIL_CERG.GET_DESCR_ITEM('PGOV_TIPO_BENEFICIO', t.flex_campo_15) as flex15desc,
    T.FLEX_CAMPO_16   ,
    T.FLEX_CAMPO_17   ,
    T.FLEX_CAMPO_18   ,
    T.FLEX_CAMPO_19   ,
    T.FLEX_CAMPO_20   ,
    (case when T.TIPOPROP = 'A' then 'ANO'
         when T.TIPOPROP = 'F' then 'FRAÇÃO'
         end) as DESCRTIPOPROP,
    'Empresa' link_emp,
    'N' associado
  FROM tipo_apos_ t ,
    tipo_apos_empresa d,
    itemtabela it,
    formas_vac fc
  WHERE t.tipo = d.tipo(+)
  AND d.tipo  IS NULL
  AND it.tab = 'ERG_FUNDTOS_LEGAIS'
  AND t.fundamento = it.item
  AND t.formavac = fc.sigla(+)
  UNION ALL
  SELECT DISTINCT -1 VALOR ,
    0 EMPCOD ,
    NULL EMPNOME ,
    t.tipo ,
    t.proporc ,
    t.pagair ,
    t.obs ,
    t.formavac ,
    (fc.sigla || ' - ' || fc.nome) as formavac_descr,
    t.fundamento ,
    it.item||' - '||it.descr as nome_fundamento,
    t.tipoprop ,
    t.fracao1tabger ,
    (select tab||' - '||descr descr 
       from tabela
      where tab = t.fracao1tabger
        and t.proporc = 'S' 
        and t.tipoprop = 'F') fracao1tabger_desc,
    t.fracao2 ,
    t.pontlei ,
    'TIPO_APOS_' TABELA ,
    rowidtochar(t.ROWID) ROWID_REG ,
    t.flex_campo_01 ,
    PACK_UTIL_CERG.GET_DESCR_ITEM('GRJ_GRUPO_APOSENT', t.flex_campo_01) as flex01desc,
    t.flex_campo_02 ,
    t.flex_campo_03 ,
    DECODE (t.flex_campo_03 ,'P', 'Proporcional', 
                             'I', 'Integral', 
                             'R', 'Redutor') flex03desc,
    T.FLEX_CAMPO_04 ,
    t.flex_campo_05,
    T.FLEX_CAMPO_06   ,
    T.FLEX_CAMPO_07   ,
    T.FLEX_CAMPO_08   ,
    T.FLEX_CAMPO_09   ,
    T.FLEX_CAMPO_10   ,
    T.FLEX_CAMPO_11   ,
    T.FLEX_CAMPO_12   ,
    T.FLEX_CAMPO_13   ,
    T.FLEX_CAMPO_14   ,
    T.FLEX_CAMPO_15   ,
    PACK_UTIL_CERG.GET_DESCR_ITEM('PGOV_TIPO_BENEFICIO', t.flex_campo_15) as flex15desc,
    T.FLEX_CAMPO_16   ,
    T.FLEX_CAMPO_17   ,
    T.FLEX_CAMPO_18   ,
    T.FLEX_CAMPO_19   ,
    T.FLEX_CAMPO_20   ,
    (case when T.TIPOPROP = 'A' then 'ANO'
         when T.TIPOPROP = 'F' then 'FRAÇÃO'
         end) as DESCRTIPOPROP,
    'Empresa' link_emp,
    nvl((select 'S' 
       from tipo_apos_empresa ce 
    where t.tipo = ce.tipo
    and ce.empresa = flag_pack.get_empresa),'N') associado
  FROM tipo_apos_ t ,
    itemtabela it,
    formas_vac fc
  WHERE t.fundamento = it.item
    AND it.tab = 'ERG_FUNDTOS_LEGAIS'
    AND t.formavac = fc.sigla(+)
  UNION ALL
  SELECT DISTINCT b.empresa VALOR ,
    d.empresa EMPCOD ,
    d.nome EMPNOME ,
    t.tipo ,
    t.proporc ,
    t.pagair ,
    t.obs ,
    t.formavac ,
    (fc.sigla || ' - ' || fc.nome) as formavac_descr,
    t.fundamento ,
    it.item||' - '||it.descr as nome_fundamento,
    t.tipoprop ,
    t.fracao1tabger ,
    (select tab||' - '||descr descr 
       from tabela
      where tab = t.fracao1tabger
        and t.proporc = 'S' 
        and t.tipoprop = 'F') fracao1tabger_desc,
    t.fracao2 ,
    t.pontlei ,
    'TIPO_APOS_' TABELA ,
    rowidtochar(t.ROWID) ROWID_REG ,
    t.flex_campo_01 ,
    PACK_UTIL_CERG.GET_DESCR_ITEM('GRJ_GRUPO_APOSENT', t.flex_campo_01) as flex01desc,
    t.flex_campo_02 ,
    t.flex_campo_03 ,
    DECODE (t.flex_campo_03 ,'P', 'Proporcional', 
                         'I', 'Integral', 
                         'R', 'Redutor') flex03desc,
    t.flex_campo_04 ,
    t.flex_campo_05,
    T.FLEX_CAMPO_06   ,
    T.FLEX_CAMPO_07   ,
    T.FLEX_CAMPO_08   ,
    T.FLEX_CAMPO_09   ,
    T.FLEX_CAMPO_10   ,
    T.FLEX_CAMPO_11   ,
    T.FLEX_CAMPO_12   ,
    T.FLEX_CAMPO_13   ,
    T.FLEX_CAMPO_14   ,
    T.FLEX_CAMPO_15   ,
    PACK_UTIL_CERG.GET_DESCR_ITEM('PGOV_TIPO_BENEFICIO', t.flex_campo_15) as flex15desc,
    T.FLEX_CAMPO_16   ,
    T.FLEX_CAMPO_17   ,
    T.FLEX_CAMPO_18   ,
    T.FLEX_CAMPO_19   ,
    T.FLEX_CAMPO_20   ,
    (case when T.TIPOPROP = 'A' then 'ANO'
         when T.TIPOPROP = 'F' then 'FRAÇÃO'
         end) as DESCRTIPOPROP,
    'Empresa' link_emp,
    'S' associado
  FROM tipo_apos_ t ,
    tipo_apos_empresa b ,
    itemtabela it,
    empresas d,
    formas_vac fc
  WHERE t.tipo = b.tipo
    AND b.empresa = d.empresa
    AND t.fundamento = it.item
    AND it.tab = 'ERG_FUNDTOS_LEGAIS'
    AND t.formavac = fc.sigla(+)
    AND acesso_usuario_empresa(flag_pack.get_usuario(), d.empresa) = 1
/