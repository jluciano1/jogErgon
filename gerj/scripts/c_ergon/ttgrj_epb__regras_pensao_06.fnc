CREATE OR REPLACE FUNCTION ttgrj_epb__regras_pensao_06(
    p_row_new   IN OUT REGRAS_PENSAO%rowtype,
    p_row_old   IN REGRAS_PENSAO%rowtype,
    p_inserting IN BOOLEAN,
    p_updating  IN BOOLEAN,
    p_deleting  IN BOOLEAN,
    p_mens OUT VARCHAR2 )
  RETURN BOOLEAN
IS
  V_NUMDEP     NUMBER;
  V_VALOR_FIXO NUMBER;
  V_SALMINIMO  NUMBER;
BEGIN
  IF p_inserting OR p_updating THEN
    IF P_ROW_NEW.DTFIM IS NULL THEN
      P_ROW_NEW.DTFIM  := P_ROW_NEW.FLEX_CAMPO_08;
    END IF;
  END IF;
RETURN (true);
END TTGRJ_EPB__REGRAS_PENSAO_06;
/