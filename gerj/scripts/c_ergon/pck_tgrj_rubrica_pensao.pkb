prompt ***ATENÇÃO!!!*** Objeto PCK_TGRJ_RUBRICA_PENSAO não possui replace e deve ser mesclado manualmente com a versão existente no banco.
CREATE
PACKAGE BODY C_ERGON.PCK_TGRJ_RUBRICA_PENSAO
IS
  --
  PROCEDURE INSERT_AUX (P_REGISTRO_AUX IN TGRJ_RUBRICA_PENSAO%ROWTYPE) IS
    V_SPID NUMBER;
    L_     NUMBER;
  BEGIN
    V_SPID := HADES_ERRO_PACK.GET_STOREDPROC_ID('C_ERGON','PCK_TGRJ_RUBRICA_PENSAO','INSERT_AUX');
--
L_ := 11;
--
    P_INDICE := P_INDICE + 1;
--
L_ := 15;
--
    P_TGRJ_RUBRICA_PENSAO.EXTEND;
--
L_ := 19;
--
    P_TGRJ_RUBRICA_PENSAO_OLD.EXTEND;
--
L_ := 23;
--
    P_TGRJ_RUBRICA_PENSAO(P_INDICE) := P_REGISTRO_AUX;
  EXCEPTION WHEN OTHERS THEN 
    HADES_ERRO_PACK.TRATA_ERRO('C_Ergon',-1,SQLERRM,V_SPID,L_);
  END;
  --
  PROCEDURE UPDATE_AUX (P_REGISTRO_AUX IN TGRJ_RUBRICA_PENSAO%ROWTYPE,
                        P_REGISTRO_OLD_AUX IN TGRJ_RUBRICA_PENSAO%ROWTYPE) IS
    V_SPID NUMBER;
    L_     NUMBER;
  BEGIN
    V_SPID := HADES_ERRO_PACK.GET_STOREDPROC_ID('C_ERGON','PCK_TGRJ_RUBRICA_PENSAO','UPDATE_AUX');
--
L_ := 37;
--
    P_INDICE := P_INDICE + 1;
--
L_ := 41;
--
    P_TGRJ_RUBRICA_PENSAO.EXTEND;
--
L_ := 45;
--
    P_TGRJ_RUBRICA_PENSAO_OLD.EXTEND;
--
L_ := 49;
--
    P_TGRJ_RUBRICA_PENSAO(P_INDICE) := P_REGISTRO_AUX;
--
L_ := 53;
--
    P_TGRJ_RUBRICA_PENSAO_OLD(P_INDICE) := P_REGISTRO_OLD_AUX;
  EXCEPTION WHEN OTHERS THEN 
    HADES_ERRO_PACK.TRATA_ERRO('C_Ergon',-1,SQLERRM,V_SPID,L_);
  END;
  --
  PROCEDURE DELETE_AUX (P_REGISTRO_AUX IN TGRJ_RUBRICA_PENSAO%ROWTYPE) IS
    V_SPID NUMBER;
    L_     NUMBER;
  BEGIN
    V_SPID := HADES_ERRO_PACK.GET_STOREDPROC_ID('C_ERGON','PCK_TGRJ_RUBRICA_PENSAO','DELETE_AUX');
--
L_ := 66;
--
    P_INDICE := P_INDICE + 1;
--
L_ := 70;
--
    P_TGRJ_RUBRICA_PENSAO.EXTEND;
--
L_ := 74;
--
    P_TGRJ_RUBRICA_PENSAO_OLD.EXTEND;
--
L_ := 78;
--
    P_TGRJ_RUBRICA_PENSAO_OLD(P_INDICE) := P_REGISTRO_AUX;
  EXCEPTION WHEN OTHERS THEN 
    HADES_ERRO_PACK.TRATA_ERRO('C_Ergon',-1,SQLERRM,V_SPID,L_);
  END;
  --
  --!<PCK_TGRJ_RUBRICA_PENSAO:MAIN_PRE>--
  PROCEDURE MAIN_PRE (P_TIPO_DML IN VARCHAR2) IS
    --
    v_ep               BOOLEAN;
    v_mens             VARCHAR2(2000);
    --
    V_SPID NUMBER;
    L_     NUMBER;
  BEGIN
    --
    V_SPID := HADES_ERRO_PACK.GET_STOREDPROC_ID('C_ERGON','PCK_TGRJ_RUBRICA_PENSAO','MAIN_PRE');
    -- Chamada da PCK_BEFORE_CERGON.EPB__TGRJ_RUBRICA_PENSAO
    --
--
L_ := 99;
--
      v_ep := PCK_EXEC_EP_CERG.EXEC_EP_PCK_BEFORE (
                'EPB__TGRJ_RUBRICA_PENSAO', 
                (P_TIPO_DML = 'I'),
                (P_TIPO_DML = 'U'),
                (P_TIPO_DML = 'D'),
                 v_mens);
    --
--
L_ := 109;
--
    IF v_mens IS NOT NULL THEN
      --
      HADES_ERRO_PACK.TRATA_ERRO_EP ('C_Ergon', 10000, V_MENS);
      --
    END IF;
    --
--
      IF (P_TIPO_DML IN ('I') AND V_ROW_NEW.ID IS NULL) THEN
        SELECT TGRJ_RUBRICA_PENSAO_SEQ.NEXTVAL
          INTO V_ROW_NEW.ID    ---
          FROM DUAL;
      END IF;
--      
--
L_ := 125;
--
    IF v_ep THEN
      --
      -- O EP retornou valor VERDADEIRO, ou seja, as VALIDAÇÕEES do PRODUTO devem ser executadas
      --
--
L_ := 132;
--
      NULL;
      --
    END IF;
    --
  EXCEPTION WHEN OTHERS THEN 
  HADES_ERRO_PACK.TRATA_ERRO('C_Ergon',-1,SQLERRM,V_SPID,L_);
  END MAIN_PRE;
  --!/<PCK_TGRJ_RUBRICA_PENSAO:MAIN_PRE>--
  --
  --!<PCK_TGRJ_RUBRICA_PENSAO:MAIN_POS>--
  PROCEDURE MAIN_POS (P_TIPO_DML IN VARCHAR2) IS
    --
    v_ep                   BOOLEAN;
    v_mens                 VARCHAR2(2000);
    --
    V_SPID NUMBER;
    L_     NUMBER;
    v_cont NUMBER := 0;    
  BEGIN
    --
    V_SPID := HADES_ERRO_PACK.GET_STOREDPROC_ID('C_ERGON','PCK_TGRJ_RUBRICA_PENSAO','MAIN_POS');
    -- varre a tabela auxiliar de TGRJ_RUBRICA_PENSAO
    --
--
L_ := 158;
--
    FOR i IN 1..P_INDICE LOOP
      --
      -- Chamada da PCK_AFTER_CERGON.EPA__TGRJ_RUBRICA_PENSAO
      --
--
L_ := 165;
--
      v_ep := PCK_EXEC_EP_CERG.EXEC_EP_PCK_AFTER (
                'EPA__TGRJ_RUBRICA_PENSAO',
                (P_TIPO_DML = 'I'),
                (P_TIPO_DML = 'U'),
                (P_TIPO_DML = 'D'),
                i,
                v_mens);
      --
--
L_ := 176;
--
      IF v_mens IS NOT NULL THEN
        --
        HADES_ERRO_PACK.TRATA_ERRO_EP ('C_Ergon', 10000, V_MENS);
        --
      END IF;
      --
--
L_ := 185;
--
      IF v_ep THEN
        NULL;
      END IF;
      --
      --
    END LOOP;
  EXCEPTION WHEN OTHERS THEN 
    HADES_ERRO_PACK.TRATA_ERRO('C_Ergon',-1,SQLERRM,V_SPID,L_);
  END MAIN_POS;
  --
  --!/<PCK_TGRJ_RUBRICA_PENSAO:MAIN_POS>--
BEGIN
  P_INDICE               := 0;
  P_TGRJ_RUBRICA_PENSAO      := TGRJ_RUBRICA_PENSAO_REC();
  P_TGRJ_RUBRICA_PENSAO_OLD  := TGRJ_RUBRICA_PENSAO_REC();
END PCK_TGRJ_RUBRICA_PENSAO;
/