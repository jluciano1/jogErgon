CREATE OR REPLACE VIEW TTGRJ_RJADM00009_VW_RET_AUX ("MES_ANO_FOLHA", "NUM_FOLHA", "LANCAMENTO", "LINHA", "NUMFUNC", "NUMVINC", "NUMPENS", "MES_ANO_DIREITO", "RUBRICA", "NOME_ABREV", "TIPO_RUBRICA", "DESC_VANT", "COMPLEMENTO", "VALOR", "TIPO_FOLHA", "TIPO_CALCULO", "DATA_CONSOL", "EMP_CODIGO", "FLEX_CAMPO_01", "FLEX_CAMPO_02", "FLEX_CAMPO_03", "FLEX_CAMPO_04", "FLEX_CAMPO_05", "FLEX_CAMPO_06", "FLEX_CAMPO_07", "FLEX_CAMPO_08", "FLEX_CAMPO_09", "FLEX_CAMPO_10", "CONSOLIDADA") AS 
  SELECT FV.MES_ANO_FOLHA,
       FV.NUM_FOLHA,
       FV.FICHA LANCAMENTO,
       FR.LINHA,
       FV.NUMFUNC,
       FV.NUMVINC,
       FV.NUMPENS,
       FR.MES_ANO_DIREITO,
       FR.RUBRICA,
       (select nvl(r.rub, r.rubrica) ||' - '|| r.nome_abrev
        from rubricas r
        where r.rubrica = FR.rubrica) nome_abrev, -- Tarefa 61771
       FR.TIPO_RUBRICA,
       FR.DESC_VANT,
       FR.COMPLEMENTO,
       FR.VALOR,
       F.TIPO_FOLHA,
       F.TIPO_CALCULO,
       F.DATA_CONSOL,
       F.EMP_CODIGO,
       NULL FLEX_CAMPO_01,
       NULL FLEX_CAMPO_02,
       NULL FLEX_CAMPO_03,
       NULL FLEX_CAMPO_04,
       NULL FLEX_CAMPO_05,
       NULL FLEX_CAMPO_06,
       NULL FLEX_CAMPO_07,
       NULL FLEX_CAMPO_08,
       NULL FLEX_CAMPO_09,
       NULL FLEX_CAMPO_10,
       CASE
      WHEN PCK_FOLHAS.EH_CONSOLIDADA(FV.MES_ANO_FOLHA,FV.NUM_FOLHA) = 1
      THEN 'S'
      ELSE 'N'
    END
FROM FICHAS_VINCULOS FV,
     FICHAS_RETENCAO FR,
     FOLHAS_EMP F
WHERE F.EMP_CODIGO = FLAG_PACK.GET_EMPRESA
  AND FV.MES_ANO_FOLHA = F.MES_ANO
  AND FV.NUM_FOLHA = F.NUMERO
  AND FV.EMP_CODIGO = F.EMP_CODIGO
  AND FV.FICHA = FR.FICHA
  AND (FR.DESC_VANT = 0)
  AND ( (FR.TIPO_RUBRICA <> 3 AND FR.VALOR <> 0) OR (FR.TIPO_RUBRICA = 3 AND FR.CORRECAO <> 0) )
  --AND (PCK_FOLHAS.EH_CONSOLIDADA (fv.mes_ano_folha, fv.num_folha) = 1)
  AND MOSTRA_FICHA( flag_pack.get_usuario, f.mes_ano, f.numero, F.EMP_CODIGO ) = 1
    UNION ALL
  SELECT FV.MES_ANO_FOLHA,
       FV.NUM_FOLHA,
       FV.FICHA LANCAMENTO,
     FR.LINHA,
       FV.NUMFUNC,
       FV.NUMVINC,
       FV.NUMPENS,
       FR.MES_ANO_DIREITO,
       FR.RUBRICA,
       (select nvl(r.rub, r.rubrica) ||' - '|| r.nome_abrev
        from rubricas r
        where r.rubrica = FR.rubrica) nome_abrev, -- Tarefa 61771
       FR.TIPO_RUBRICA,
       FR.DESC_VANT,
       FR.COMPLEMENTO,
       FR.VALOR,
       F.TIPO_FOLHA,
       F.TIPO_CALCULO,
       F.DATA_CONSOL,
       F.EMP_CODIGO,
       NULL FLEX_CAMPO_01,
       NULL FLEX_CAMPO_02,
       NULL FLEX_CAMPO_03,
       NULL FLEX_CAMPO_04,
       NULL FLEX_CAMPO_05,
       NULL FLEX_CAMPO_06,
       NULL FLEX_CAMPO_07,
       NULL FLEX_CAMPO_08,
       NULL FLEX_CAMPO_09,
       NULL FLEX_CAMPO_10,
       CASE
      WHEN PCK_FOLHAS.EH_CONSOLIDADA(FV.MES_ANO_FOLHA,FV.NUM_FOLHA) = 1
      THEN 'S'
      ELSE 'N'
    END
FROM FICHAS_VINCULOS FV,
     FICHAS_RETENCAO FR,
     FOLHAS_EMP F
WHERE F.EMP_CODIGO = 77
  AND FV.MES_ANO_FOLHA = F.MES_ANO
  AND FV.NUM_FOLHA = F.NUMERO
  AND FV.EMP_CODIGO = F.EMP_CODIGO
  AND FV.FICHA = FR.FICHA
  AND (FR.DESC_VANT = 0)
  AND ( (FR.TIPO_RUBRICA <> 3 AND FR.VALOR <> 0) OR (FR.TIPO_RUBRICA = 3 AND FR.CORRECAO <> 0) )
  --AND (PCK_FOLHAS.EH_CONSOLIDADA (fv.mes_ano_folha, fv.num_folha) = 1)
  AND MOSTRA_FICHA( flag_pack.get_usuario, f.mes_ano, f.numero, F.EMP_CODIGO ) = 1;
/