CREATE OR REPLACE FUNCTION ttgrj_epb__regras_pensao_04(
    p_row_new   IN OUT REGRAS_PENSAO%rowtype,
    p_row_old   IN REGRAS_PENSAO%rowtype,
    p_inserting IN BOOLEAN,
    p_updating  IN BOOLEAN,
    p_deleting  IN BOOLEAN,
    p_mens OUT VARCHAR2 )
  RETURN BOOLEAN
IS
  V_NUMDEP     NUMBER;
  V_VALOR_FIXO VARCHAR2(2000);
  V_CONT       NUMBER DEFAULT 0;
BEGIN
  IF p_inserting THEN
    IF P_ROW_NEW.FLEX_CAMPO_09 = 'COTISTA' THEN
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
        SELECT DECODE(BP.E_VALOR_FIXO,'S',NVL(PA.PERCENTUAL,0))
        INTO V_VALOR_FIXO
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
        V_VALOR_FIXO := '0';
      END;
      --
      IF P_ROW_NEW.FLEX_CAMPO_02   IS NOT NULL THEN
        IF P_ROW_NEW.FLEX_CAMPO_02 <> V_VALOR_FIXO THEN
          p_mens                   := 'O valor fixo da pensão informado (' || P_ROW_NEW.FLEX_CAMPO_02 || ') está diferente do valor fixo aplicado na regra de pensão alimentícia (' || V_VALOR_FIXO || ').';
          RETURN(true);
        ELSE
          IF TO_NUMBER(V_VALOR_FIXO) > 0 THEN
            P_ROW_NEW.FLEX_CAMPO_02 := V_VALOR_FIXO;
          END IF;
        END IF;
      END IF;
      --
    END IF;
  END IF;
RETURN (true);
END TTGRJ_EPB__REGRAS_PENSAO_04;
/