CREATE OR REPLACE FUNCTION ttgrj_epb__regras_pensao_02(
    p_row_new   IN OUT REGRAS_PENSAO%rowtype,
    p_row_old   IN REGRAS_PENSAO%rowtype,
    p_inserting IN BOOLEAN,
    p_updating  IN BOOLEAN,
    p_deleting  IN BOOLEAN,
    p_mens OUT VARCHAR2 )
  RETURN BOOLEAN
IS
  --
  FUNCTION verifica_dtfim(
      p_row_new IN OUT REGRAS_PENSAO%rowtype,
      p_row_old IN REGRAS_PENSAO%rowtype)
    RETURN BOOLEAN
  IS
    V_IDADE_MIN         NUMBER := 0;
    V_IDADE_MAX         NUMBER := 0;
    V_IDADE             NUMBER := 0;
    V_ANIVERSARIOLIMITE DATE;
    V_ANIVERSARIO       DATE;
  BEGIN
    IF P_ROW_NEW.DTFIM IS NULL THEN
      --
      BEGIN
        SELECT NVL(HTB.IDADE, 0),
          NVL(HTB.IDADE_EXT, 0)
        INTO V_IDADE_MIN,
          V_IDADE_MAX
        FROM TGRJ_HIST_TIPO_BENEF HTB
        WHERE HTB.TIPO                                                                                                                           = P_ROW_NEW.FLEX_CAMPO_09
        AND PACK_HADES.EH_CONCOMITANTE(DTINI, NVL(DTFIM, PACK_ERGON.DATA_MAXIMA), P_ROW_NEW.DTINI, NVL(P_ROW_NEW.DTFIM, PACK_ERGON.DATA_MAXIMA)) = 1;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_IDADE_MIN := 0;
        V_IDADE_MAX := 0;
        V_IDADE     := 0;
      END;
      --
      BEGIN
        SELECT RP.DTNASC
        INTO V_ANIVERSARIO
        FROM PENSIONISTAS RP
        WHERE RP.NUMFUNC = P_ROW_NEW.NUMFUNC
        AND RP.NUMVINC   = P_ROW_NEW.NUMVINC
        AND RP.NUMERO    = P_ROW_NEW.NUMPENS;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_ANIVERSARIOLIMITE := NULL;
        V_ANIVERSARIO       := NULL;
      END;
      --
      IF V_ANIVERSARIO        IS NOT NULL THEN
        IF V_IDADE_MAX         > 0 THEN
          V_ANIVERSARIOLIMITE := ADD_MONTHS(V_ANIVERSARIO,V_IDADE_MAX * 12 ) - 1;
        ELSIF V_IDADE_MIN      > 0 THEN
          V_ANIVERSARIOLIMITE := ADD_MONTHS(V_ANIVERSARIO,V_IDADE_MIN * 12 ) - 1;
        END IF;
      END IF;
      --
      IF P_ROW_NEW.FLEX_CAMPO_09 IN ('FILHO (A) MENOR', 'FILHO (A) MENOR UNIVERSITÁRIO', 'FILHO (A) MAIOR UNIVERSITÁRIO', 'MENOR SOB GUARDA', 'MENOR TUTELADO', 'ENTEADO') AND V_ANIVERSARIOLIMITE IS NOT NULL THEN
        --
        IF V_ANIVERSARIOLIMITE >= P_ROW_NEW.DTINI THEN
          P_ROW_NEW.DTFIM      := TO_CHAR(V_ANIVERSARIOLIMITE, 'dd/mm/yyyy');
        END IF;
        --
      END IF;
    END IF;
    RETURN (true);
  END verifica_dtfim;
--
BEGIN
  IF p_inserting THEN
    RETURN verifica_dtfim(p_row_new,p_row_old);
  END IF;
IF p_updating THEN
  IF (P_ROW_OLD.DTFIM IS NOT NULL AND P_ROW_NEW.DTFIM IS NULL) THEN
    RETURN verifica_dtfim(p_row_new,p_row_old);
  END IF;
END IF;
--
RETURN (true);
END ttgrj_epb__regras_pensao_02;
/