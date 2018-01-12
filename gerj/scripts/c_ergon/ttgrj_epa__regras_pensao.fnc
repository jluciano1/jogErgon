create or replace FUNCTION TTGRJ_EPA__REGRAS_PENSAO (P_ROW_NEW    IN OUT REGRAS_PENSAO%ROWTYPE,
                                  P_ROW_OLD    IN     REGRAS_PENSAO%ROWTYPE,
                                  P_INSERTING  IN     BOOLEAN,
                                  P_UPDATING   IN     BOOLEAN,
                                  P_DELETING   IN     BOOLEAN,
                                  P_MENS       OUT    VARCHAR2) RETURN BOOLEAN IS
  V_COUNT NUMBER;
BEGIN

  IF P_DELETING THEN
  --  
	  select count(1) into v_count 
    from REGRAS_PENSAO 
    WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
      AND NUMVINC = P_ROW_NEW.NUMVINC
      AND NUMPENS = P_ROW_NEW.NUMPENS;
  
    if v_count <= 1 then
      delete FROM TGRJ_DOC_PENSIONISTA
      WHERE NUMFUNC = P_ROW_NEW.NUMFUNC
        AND NUMVINC = P_ROW_NEW.NUMVINC
        AND NUMPENS = P_ROW_NEW.NUMPENS;
    end if;
  
  END IF;
  --
  RETURN (TRUE);
  --

END TTGRJ_EPA__REGRAS_PENSAO;
/
