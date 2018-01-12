CREATE OR REPLACE FUNCTION ttgrj_epa__regras_pensao_02(
    p_row_new   IN OUT REGRAS_PENSAO%rowtype,
    p_row_old   IN REGRAS_PENSAO%rowtype,
    p_inserting IN BOOLEAN,
    p_updating  IN BOOLEAN,
    p_deleting  IN BOOLEAN,
    p_mens OUT VARCHAR2 )
  RETURN BOOLEAN
IS
  V_COUNT NUMBER := 0;
BEGIN
  --
  IF p_deleting THEN
    SELECT COUNT(1)
    INTO v_count
    FROM REGRAS_PENSAO
    WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
    AND NUMVINC   = P_ROW_NEW.NUMVINC
    AND NUMPENS   = P_ROW_NEW.NUMPENS;
    IF v_count   <= 1 THEN
      DELETE
      FROM ERGON.TGRJ_DOC_PENSIONISTA
      WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
      AND NUMVINC   = P_ROW_NEW.NUMVINC
      AND NUMPENS   = P_ROW_NEW.NUMPENS;
    END IF;
  END IF;
--
RETURN (true);
--
END TTGRJ_EPA__REGRAS_PENSAO_02;
/