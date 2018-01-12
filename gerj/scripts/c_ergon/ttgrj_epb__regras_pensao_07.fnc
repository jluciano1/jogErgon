CREATE OR REPLACE FUNCTION ttgrj_epb__regras_pensao_07(
    p_row_new   IN OUT REGRAS_PENSAO%rowtype,
    p_row_old   IN REGRAS_PENSAO%rowtype,
    p_inserting IN BOOLEAN,
    p_updating  IN BOOLEAN,
    p_deleting  IN BOOLEAN,
    p_mens OUT VARCHAR2 )
  RETURN BOOLEAN
IS
  V_VALOR_FIXO_COTISTA NUMBER DEFAULT 0;
  V_PERC_COTISTA       NUMBER DEFAULT 0;
  V_SAL_MIN            NUMBER DEFAULT 0;
  V_NUMDEP             NUMBER;
  V_PERCENTUAL         NUMBER;
  V_VALOR_FIXO         NUMBER;
  V_SALMINIMO          NUMBER;
  V_CONT               NUMBER DEFAULT 0;
  --
BEGIN
  IF p_inserting THEN
    IF P_ROW_NEW.FLEX_CAMPO_09 = 'COTISTA' THEN
      --
      V_VALOR_FIXO_COTISTA := TO_NUMBER(REPLACE(TRANSLATE(NVL(P_ROW_NEW.FLEX_CAMPO_02,0),'.',' '), ' ',''));
      V_PERC_COTISTA       := NVL( P_ROW_NEW.PERCENTUAL, 0);
      V_SAL_MIN            := NVL(TO_NUMBER(P_ROW_NEW.FLEX_CAMPO_05), 0);
      --
      BEGIN
        SELECT NUMDEP
        INTO V_NUMDEP
        FROM PENSIONISTAS
        WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
        AND NUMVINC   = P_ROW_NEW.NUMVINC
        AND NUMERO    = P_ROW_NEW.NUMPENS;
      EXCEPTION
      WHEN OTHERS THEN
        V_NUMDEP := NULL;
      END;
      BEGIN
        SELECT DECODE(BP.E_VALOR_FIXO,'N',NVL(PA.PERCENTUAL,0)),
          DECODE(BP.E_VALOR_FIXO,'S',NVL(PA.PERCENTUAL,0))
        INTO V_PERCENTUAL,
          V_VALOR_FIXO
        FROM REGRAS_PENSAO_AL PA,
          BASE_PENSAO BP
        WHERE PA.NUMFUNC = P_ROW_NEW.NUMFUNC
        AND PA.NUMVINC   = P_ROW_NEW.NUMVINC
        AND PA.NUMDEP    = V_NUMDEP
        AND PA.DTINI    <= SYSDATE
        AND (PA.DTFIM   IS NULL
        OR PA.DTFIM     >= SYSDATE)
        AND BP.BASE      = PA.BASE;
      EXCEPTION
      WHEN OTHERS THEN
        V_PERCENTUAL := 0;
        V_VALOR_FIXO := 0;
      END;
      --
      IF V_PERC_COTISTA > 100 THEN
        p_mens         :='Atenção! Percentual informado, não pode ser superior a 100%';
      END IF;
      --
      IF (V_VALOR_FIXO_COTISTA = 0) AND (V_PERC_COTISTA = 0) AND (V_SAL_MIN = 0) THEN
        p_mens                :='Atenção! Favor informar valor, percentual, ou quantidade de salários mínimos para a regra de pensão.';
      END IF;
      --
      IF ((V_VALOR_FIXO_COTISTA > 0) AND (V_PERC_COTISTA > 0 OR V_SAL_MIN > 0)) OR ((V_PERC_COTISTA > 0) AND (V_VALOR_FIXO_COTISTA > 0 OR V_SAL_MIN > 0)) OR ((V_SAL_MIN > 0) AND (V_PERC_COTISTA > 0 OR V_VALOR_FIXO_COTISTA > 0)) THEN
        p_mens                 :='Atenção! Favor informar valor, ou percentual, ou valor de salário mínimo para a regra de pensão.';
      END IF;
      IF V_VALOR_FIXO     > 0 THEN
        IF V_PERC_COTISTA > 0 THEN
          p_mens         := 'Atenção! Favor informar o valor fixo ou a quantidade de salários mínimos. Não é permitido informar o percentual para esta regra de pensão.';
        END IF;
      END IF;
      --
      IF V_PERCENTUAL           > 0 THEN
        IF V_VALOR_FIXO_COTISTA > 0 OR V_SAL_MIN > 0 THEN
          p_mens               :='Atenção! Favor informar o percentual. Não é permitido informar o valor fixo ou a quantidade de salários mínimos para esta regra de pensão.';
        END IF;
      END IF;
    END IF;
  END IF;
RETURN (true);
END TTGRJ_EPB__REGRAS_PENSAO_07;
/