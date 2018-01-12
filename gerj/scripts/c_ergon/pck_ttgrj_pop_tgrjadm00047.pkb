create or replace PACKAGE BODY "PCK_TTGRJ_POP_TGRJADM00047" IS
  --
  FUNCTION TTGRJ_POP_TGRJADM00047 (P_NUMFUNC      IN NUMBER,
                                   P_NUMVINC      in number,
                                   P_NUMPENS      IN NUMBER,
                                   P_DTFIM_PENS   IN DATE)  RETURN TTGRJ_TYP_TGRJADM00047_TAB PIPELINED IS
    --
    -- CURSOR PARA TRAZER OS TIPOS DE BENEFIIARIOS
    --
    CURSOR ARQ_PENS IS SELECT TBE.TIPO,
                              TBE.DESCRICAO,
                              FUN.SEXO     FUN_SEXO,
                              PEN.SEXO     PEN_SEXO,
                              HTB.CONDICAO CON_SEXO,
                              nvl(HTB.IDADE, 0)    CON_IDADE,
                              PEN.DTNASC,
                           --   FLOOR(CAST((CAST((SYSDATE - PEN.DTNASC) AS NUMBER)/365.25) AS NUMBER)
                              FLOOR(CAST((CAST(((NVL(P_DTFIM_PENS,SYSDATE) - PEN.DTNASC )) AS number)/365.25) AS number)) PEN_IDADE,
                              TRUNC((months_between(TRUNC(ADD_MONTHS(NVL(P_DTFIM_PENS,SYSDATE),PACK_HADES.GET_OPCAO('C_Ergon','PENS_PREV','FILHO_MAIOR_BENEFICIARIO'))),PEN.DTNASC))/12) AS FILHO_MAIOR_BENEFICIARIO
                       FROM TGRJ_TIPO_BENEF            TBE,
                            TGRJ_HIST_TIPO_BENEF       HTB,
                            TGRJ_TIPO_BENEF_PARENTESCO TBP,
                            PENSIONISTAS               PEN,
                            FUNCIONARIOS               FUN
                       WHERE TBE.TIPO        = HTB.TIPO
                       AND   TBE.TIPO        = TBP.TIPO
                       AND   TBP.PARENTESCO  = PEN.PARENTESCO
                       AND   PEN.NUMFUNC     = P_NUMFUNC
                       AND   PEN.NUMVINC     = P_NUMVINC
                       AND   PEN.NUMERO      = P_NUMPENS
                       AND   TRUNC(NVL(P_DTFIM_PENS,SYSDATE))  BETWEEN HTB.DTINI
                       AND   NVL(HTB.DTFIM, PACK_ERGON.DATA_MAXIMA)
                       AND ((HTB.CONDICAO   <> 'A' AND HTB.CONDICAO = PEN.SEXO) OR (HTB.CONDICAO = 'A'))
                       AND   FUN.NUMERO      = PEN.NUMFUNC
                       AND   NVL(TBE.FLEX_CAMPO_01, 'NAO') = 'NAO'
                       AND   TBE.TIPO NOT IN ('BENEFICIARIO AUXILIO RECLUSAO')
                       UNION
                       SELECT TBE.TIPO,
                              TBE.DESCRICAO,
                              NULL FUN_SEXO,
                              NULL PEN_SEXO,
                              NULL CON_SEXO,
                              nvl(NULL, 0) CON_IDADE,
                              NULL DTNASC,
                              nvl(NULL, 0) PEN_IDADE,
                              NULL AS FILHO_MAIOR_BENEFICIARIO
                       FROM TGRJ_TIPO_BENEF TBE,
                            TGRJ_HIST_TIPO_BENEF HTB,
                            TGRJ_TIPO_BENEF_PARENTESCO TBP
                       WHERE TBE.TIPO       = HTB.TIPO
                       AND   TBE.TIPO       = TBP.TIPO
                       AND   TBP.PARENTESCO = 'COTISTA'
                       AND   TRUNC(NVL(P_DTFIM_PENS,SYSDATE)) BETWEEN HTB.DTINI
                       AND   NVL(HTB.DTFIM, PACK_ERGON.DATA_MAXIMA)
                       AND   NOT EXISTS (SELECT NULL
                                         FROM PENSIONISTAS PEN
                                         WHERE PEN.NUMFUNC = P_NUMFUNC
                       AND   PEN.NUMERO     = P_NUMPENS)
                       AND   NVL(TBE.FLEX_CAMPO_01, 'NAO') = 'NAO'
                       UNION
                       SELECT TBE.TIPO,
                              TBE.DESCRICAO,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL AS FILHO_MAIOR_BENEFICIARIO
                         FROM TGRJ_TIPO_BENEF TBE
                        WHERE TBE.TIPO = 'BENEFICIARIO AUXILIO RECLUSAO'
                          AND EXISTS (SELECT 1
                                        FROM VINCULOS
                                       WHERE NUMFUNC = P_NUMFUNC
                                         AND NUMERO = P_NUMVINC
                                         AND CATEGORIA = 'AUX RECLUSAO');
    --
    REG_TGRJADM00047_TAB ARQ_PENS%ROWTYPE;
    --
    VPENS                   TTGRJ_TYP_TGRJADM00047;
    --
  BEGIN
    --
    VPENS := TTGRJ_TYP_TGRJADM00047 (NULL, NULL);

    --
    FOR REG_TGRJADM00047_TAB IN ARQ_PENS LOOP
      --
      VPENS.TIPO          := REG_TGRJADM00047_TAB.TIPO;
      VPENS.DESCRICAO     := REG_TGRJADM00047_TAB.DESCRICAO;
      --
      IF (REG_TGRJADM00047_TAB.FUN_SEXO    = REG_TGRJADM00047_TAB.PEN_SEXO   AND
          REG_TGRJADM00047_TAB.TIPO     LIKE '%HOMO%')                       OR
         (REG_TGRJADM00047_TAB.TIPO NOT LIKE '%FILH%'                        AND
          REG_TGRJADM00047_TAB.TIPO NOT LIKE '%COMP%'                        AND
          REG_TGRJADM00047_TAB.TIPO NOT LIKE '%ENTEADO%')                    THEN
         PIPE ROW(VPENS);
      END IF;
      --
      IF REG_TGRJADM00047_TAB.TIPO      LIKE '%COMP%'  AND
         REG_TGRJADM00047_TAB.TIPO   NOT LIKE '%HOMO%'  AND
         REG_TGRJADM00047_TAB.FUN_SEXO     <> REG_TGRJADM00047_TAB.CON_SEXO THEN
         PIPE ROW(VPENS);

      END IF;
      --
      IF REG_TGRJADM00047_TAB.TIPO      LIKE '%MAIOR%' AND
         REG_TGRJADM00047_TAB.CON_SEXO     = 'A'       AND
         REG_TGRJADM00047_TAB.PEN_IDADE   >= REG_TGRJADM00047_TAB.CON_IDADE THEN
         PIPE ROW(VPENS);
      ELSIF
         REG_TGRJADM00047_TAB.TIPO      LIKE '%MAIOR%UNIVERSITÁRIO' AND
         REG_TGRJADM00047_TAB.CON_SEXO     = 'A'       AND
         REG_TGRJADM00047_TAB.FILHO_MAIOR_BENEFICIARIO >= REG_TGRJADM00047_TAB.CON_IDADE THEN
         PIPE ROW(VPENS);
      END IF;
      --
      IF REG_TGRJADM00047_TAB.TIPO      LIKE '%MENOR%' AND
         REG_TGRJADM00047_TAB.CON_SEXO     = 'A'       AND
         REG_TGRJADM00047_TAB.PEN_IDADE    < REG_TGRJADM00047_TAB.CON_IDADE THEN
         PIPE ROW(VPENS);
      END IF;
      --
      IF REG_TGRJADM00047_TAB.TIPO         IN ('FILHA MAIOR', 'FILHA MAIOR L285') AND
         REG_TGRJADM00047_TAB.CON_SEXO     = REG_TGRJADM00047_TAB.PEN_SEXO        AND
         REG_TGRJADM00047_TAB.PEN_IDADE   >= REG_TGRJADM00047_TAB.CON_IDADE THEN
         PIPE ROW(VPENS);
      END IF;
      --
      IF REG_TGRJADM00047_TAB.TIPO       IN ('FILHO (A) INTERDITADO','FILHO (A) INVÁLIDO (A)') THEN
         PIPE ROW(VPENS);
      END IF;
      --
      IF REG_TGRJADM00047_TAB.TIPO      LIKE '%ENTEADO%' AND
         REG_TGRJADM00047_TAB.CON_SEXO     = 'A'       AND
         REG_TGRJADM00047_TAB.PEN_IDADE    < REG_TGRJADM00047_TAB.CON_IDADE THEN
         PIPE ROW(VPENS);
      END IF;
      --
      IF REG_TGRJADM00047_TAB.TIPO      IN ('IRMÃ','IRMÃO') AND
         REG_TGRJADM00047_TAB.CON_SEXO     = REG_TGRJADM00047_TAB.PEN_SEXO  AND
         REG_TGRJADM00047_TAB.PEN_IDADE    < REG_TGRJADM00047_TAB.CON_IDADE THEN
         PIPE ROW(VPENS);
      END IF;
      --
    END LOOP;
  END TTGRJ_POP_TGRJADM00047;
  --
BEGIN
  NULL;
end PCK_TTGRJ_POP_TGRJADM00047;
/