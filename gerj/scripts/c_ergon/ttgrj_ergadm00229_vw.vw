CREATE OR REPLACE FORCE VIEW TTGRJ_ERGADM00229_VW AS
SELECT
    T.AGENCIA,
    T.AGENCIAFGTS,
    T.BANCO,
    T.BANCOFGTS,
    T.CATEGORIA,
    (SELECT max(a.sigla|| ' - '|| a.nome) nome FROM categorias a WHERE a.sigla =  t.categoria) NOME_CATEGORIA,
    T.CLASSIFCONC,
    T.CONTA,
    T.CONTAFGTS,
    NVL(T.CORREIO,'N') CORREIO,
    NVL(T.DESCONTA_IR,'N') DESCONTA_IR,
    T.DTADM_RAIS,
    T.DTAPOSENT,
    T.DTCONC,
    T.DTEXERC,
    T.DTFIMCONTR,
    T.DTFIM_CESSAO,
    T.DTINICONTR,
    T.DTINI_CESSAO,
    T.DTNOM,
    T.DTOPFGTS,
    T.DTPOSSE,
    T.DTPRORROGCONTR,
    T.DTRETRFGTS,
    T.DTVAC,
    T.DT_HOMOLOG,
    T.DT_PGTO_ATE,
    T.DT_SALDO_FGTS,
    T.EMP_CODIGO,
    T.EMP_CODIGO||' - '|| PACK_ERGON.GET_NOME_EMPRESA(T.EMP_CODIGO) EMP_DESCR,
    T.FATOR_PROPORC_APOSENT,
    T.FONE_REQ,
    T.FORMAVAC,
    T.FUNCAO_REQ,
    T.ID_REG,
    T.MATRIC,
    T.MATRICULA,
    T.MATRICULA1,
    T.MOTIVO,
    T.MOTIVOVAC,
    T.NUMERO,
    pack_ergon.get_ident_func(numfunc, numero,1) IDENT_VINC,
    T.NUMERO_PERMUT_1,
    T.NUMERO_PERMUT_2,
    T.NUMFUNC,
    T.NUMFUNC_PERMUT_1,
    T.NUMFUNC_PERMUT_2,
    T.NUMVINCANT,
    T.NUMVINCPOS,
    nvl2(T.NUMVINCANT,(select max(pack_ergon.get_ident_func(numfunc, T.NUMVINCANT,1)|| ' - Exerc�cio: '|| to_char(dtexerc, 'dd/mm/yyyy'))
                       from vinculos w where numfunc=t.numfunc and numero=t.numvincant),null) DESC_VINC_ANT,
    nvl2(T.NUMVINCPOS,(select max(pack_ergon.get_ident_func(numfunc, T.NUMVINCPOS,1)|| ' - Exerc�cio: '|| to_char(dtexerc, 'dd/mm/yyyy'))
                       from vinculos w where numfunc=t.numfunc and numero=t.numvincpos),null) DESC_VINC_POS,
    T.ORGAO_EXT_REQ,
    T.ORGAO_REQ,
    T.PONTLEI,
    T.PONTPUBL,
    T.PROJETO_ATIVIDADE,
    T.REGIMEJUR,
    (SELECT max( a.sigla || ' - ' || a.nome) nome FROM regimes_jur a WHERE a.sigla = t.regimejur)    NOME_REGIMEJUR,
    T.TIPOAPOS,
    T.TIPOORG_REQ,
    T.TIPOPAG,
    (SELECT DESCR FROM ITEMTABELA WHERE TAB    = 'ERG_TIPO_PAG' AND ITEM = T.TIPOPAG) tipopag_descr,
    T.TIPOVINC,
    (SELECT max( a.sigla || ' - ' || a.nome) nome FROM tipo_vinc a WHERE a.sigla = t.tipovinc) NOME_TIPOVINC,
    T.TIPO_ONUS_REQ,
    (SELECT T.TIPO_ONUS_REQ ||' - '|| DESCR FROM ITEMTABELA WHERE TAB = 'ERG_ONUS' AND ITEM = T.TIPO_ONUS_REQ) TIPO_ONUS_REQ_DESCR,
    T.TIPO_REQ,
    T.TIPO_RESSARC_REQ,
    (SELECT T.TIPO_RESSARC_REQ ||' - '||DESCR FROM ITEMTABELA WHERE TAB = 'ERG_RESSARCIMENTO' AND ITEM = T.TIPO_RESSARC_REQ) TIPO_RESSARC_REQ_DESCR,
    T.VALOR_DEP_FGTS,
    nvl2(T.NUMFUNC_PERMUT_1,PACK_ERGON.GET_IDENT_FUNC(T.NUMFUNC_PERMUT_1,T.NUMERO_PERMUT_1,0) ||' - ' ||PACK_ERGON.GET_NOME(T.NUMFUNC_PERMUT_1),null) NOME_PERMUT_1,
    nvl2(T.NUMFUNC_PERMUT_2,PACK_ERGON.GET_IDENT_FUNC(T.NUMFUNC_PERMUT_2,T.NUMERO_PERMUT_2,0) ||' - ' ||PACK_ERGON.GET_NOME(T.NUMFUNC_PERMUT_2),null) NOME_PERMUT_2,
    nvl2(T.BANCO,(SELECT MAX(T.BANCO ||' - '||B1.NOME) FROM BANCOS B1 WHERE B1.BANCO = T.BANCO),null) NOME_BANCO,
    nvl2(T.BANCOFGTS,(SELECT MAX(T.BANCOFGTS ||' - '||B2.NOME) FROM BANCOS B2 WHERE B2.BANCO = T.BANCOFGTS),null) NOME_BANCOFGTS,
    nvl2(T.AGENCIA,(SELECT MAX(T.AGENCIA ||' - '||A1.NOME ) FROM AGENCIAS A1  WHERE A1.BANCO = T.BANCO  AND   A1.AGENCIA = T.AGENCIA),null) NOME_AGENCIA,
    nvl2(T.AGENCIAFGTS,(SELECT MAX(T.AGENCIAFGTS ||' - '||A2.NOME) FROM AGENCIAS A2  WHERE A2.BANCO = t.bancofgts  AND  A2.AGENCIA = t.agenciafgts),null) NOME_AGENCIAFGTS,
    PACK_ERGON.GET_REGIMEPREV_FUNC (T.NUMFUNC, T.NUMERO, T.DTEXERC) REGIMEPREV,
    PACK_ERGON.GET_PLANOPREV_FUNC (T.NUMFUNC, T.NUMERO, T.DTEXERC) PLANOPREV,
    nvl2(T.FORMAVAC,(SELECT MAX(NOME) FROM FORMAS_VAC_ F WHERE SIGLA = T.FORMAVAC),null) DESC_FORMAVAC,
    HAD_FORMATA_PUBLICACOES(T.PONTPUBL) AS TEXTO_PUBL,
    ROWIDTOCHAR(T.ROWID) ROWID_REG,
    (select tipo||' - '||'Proporc.: ('||proporc||') - Calc. IR: ('||pagair||') - '||obs nome from tipo_apos where tipo = t.tipoapos) tipoapos_descr,
    T.FLEX_CAMPO_01,
    T.FLEX_CAMPO_02,
    T.FLEX_CAMPO_03,
    T.FLEX_CAMPO_04,
    T.FLEX_CAMPO_05,
    T.FLEX_CAMPO_06,
    (SELECT item||' - '||descr
      FROM itemtabela
     WHERE tab = 'GRJ_TIPO_ORGAO_EXT'
       AND item1 = 'INTERNO'
       AND upper(t.tipo_req) = 'INTERNA'
       and upper(item) = upper(t.flex_campo_06)
    UNION ALL
    SELECT item||' - '||descr
      FROM itemtabela
     WHERE tab = 'GRJ_TIPO_ORGAO_EXT'
       AND item1 = 'EXTERNO'
       AND upper(t.tipo_req) = 'EXTERNA'
       and upper(item) = upper(t.flex_campo_06)) as flex_06_descr,
    T.FLEX_CAMPO_07,
    T.FLEX_CAMPO_08,
    (select v2.numero||' - '||v2.tipovinc
      from vinculos v2
     where v2.numfunc = t.numfunc
       and v2.numero = t.numero
       and v2.flex_campo_08 = t.flex_campo_08) flex_08_descr,
    T.FLEX_CAMPO_09,
    T.FLEX_CAMPO_10,
    T.FLEX_CAMPO_11,
    T.FLEX_CAMPO_12,
    T.FLEX_CAMPO_13,
    T.FLEX_CAMPO_14,
    T.FLEX_CAMPO_15,
    T.FLEX_CAMPO_16,
    T.FLEX_CAMPO_17,
    T.FLEX_CAMPO_18,
    T.FLEX_CAMPO_19,
    T.FLEX_CAMPO_20,
    T.FLEX_CAMPO_21,
    T.FLEX_CAMPO_22,
    T.FLEX_CAMPO_23,
    T.FLEX_CAMPO_24,
    T.FLEX_CAMPO_25,
    T.FLEX_CAMPO_26,
    T.FLEX_CAMPO_27,
    T.FLEX_CAMPO_28,
    T.FLEX_CAMPO_29,
    T.FLEX_CAMPO_30,
    T.FLEX_CAMPO_31,
    T.FLEX_CAMPO_32,
    T.FLEX_CAMPO_33,
    T.FLEX_CAMPO_34,
    T.FLEX_CAMPO_35,
    T.FLEX_CAMPO_36,
    T.FLEX_CAMPO_37,
    T.FLEX_CAMPO_38,
    T.FLEX_CAMPO_39,
    T.FLEX_CAMPO_40,
    T.FLEX_CAMPO_41,
    T.FLEX_CAMPO_42,
    T.FLEX_CAMPO_43,
    T.FLEX_CAMPO_44,
    T.FLEX_CAMPO_45,
    T.FLEX_CAMPO_46,
    T.FLEX_CAMPO_47,
    T.FLEX_CAMPO_48,
    T.FLEX_CAMPO_49,
    T.FLEX_CAMPO_50,
    (SELECT MAX(O.ORGAO ||' - '||O.DESCR||' - '||O.TIPO_ORGAO ||' - '||o.fone) FROM  ORGAOS_EXTERNOS O WHERE O.ORGAO = t.orgao_ext_req) AS descr_orgao,
    ' ' atos,
    MATRICULA3,
    MATRICULA2,
    ERG_BUSCA_ANOSAPOS (T.NUMFUNC,T.NUMERO,T.DTAPOSENT) ANOSAPOS,
    (select a.agencia||' - '|| a.nome from agencias a where a.banco = 237 and a.agencia = t.flex_campo_19) desc_ag_conta_sal
  FROM
    VINCULOS T
/