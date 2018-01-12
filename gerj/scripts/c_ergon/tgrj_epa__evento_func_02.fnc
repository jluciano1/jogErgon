CREATE OR REPLACE FUNCTION tgrj_epa__evento_func_02(
    p_row_new   IN OUT EVENTO_FUNC%rowtype,
    p_row_old   IN EVENTO_FUNC%rowtype,
    p_inserting IN BOOLEAN,
    p_updating  IN BOOLEAN,
    p_deleting  IN BOOLEAN,
    p_mens OUT VARCHAR2 )
  RETURN BOOLEAN
IS
  V_COUNT NUMBER := 0;
BEGIN
  IF p_inserting THEN
    BEGIN
      SELECT COUNT(1)
      INTO V_COUNT
      FROM VINCULOS VI
      WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
      AND NUMERO    = P_ROW_NEW.NUMVINC
      AND EXISTS
        (SELECT 1
        FROM ERG_FORMAPROV_VALID_EMPRESA FV
        WHERE FV.FORMAPROV  = 'RESP EXPEDIENTE'
        AND FV.CATEGORIA    = VI.CATEGORIA
        AND FV.REGIMEJUR    = VI.REGIMEJUR
        AND FV.TIPOVINC     = VI.TIPOVINC
        AND FV.SUBCATEGORIA = PACK_ERGON.GET_SUBCATEGORIA_FUNC(VI.NUMFUNC, VI.NUMERO, SYSDATE)
        );
      IF V_COUNT = 0 THEN
        P_MENS  := 'Servidor sem permissão para Evento de Respondendo pelo Expediente.';
        RETURN(true);
      END IF;
    END;
  END IF;
RETURN (true);
END TGRJ_EPA__EVENTO_FUNC_02;
/