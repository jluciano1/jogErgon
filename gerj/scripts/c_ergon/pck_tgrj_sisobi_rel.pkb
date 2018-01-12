CREATE OR REPLACE
PACKAGE BODY C_ERGON.PCK_TGRJ_SISOBI_REL
IS
  --
  PROCEDURE INSERT_AUX (P_REGISTRO_AUX IN TGRJ_SISOBI_REL%ROWTYPE) IS
    V_SPID NUMBER;
    L_     NUMBER;
  BEGIN
    V_SPID := HADES_ERRO_PACK.GET_STOREDPROC_ID('C_ERGON','PCK_TGRJ_SISOBI_REL','INSERT_AUX');
--
L_ := 10;
--
    P_INDICE := P_INDICE + 1;
--
L_ := 20;
--
    P_TGRJ_SISOBI_REL.EXTEND;
--
L_ := 30;
--
    P_TGRJ_SISOBI_REL_OLD.EXTEND;
--
L_ := 40;
--
    P_TGRJ_SISOBI_REL(P_INDICE) := P_REGISTRO_AUX;
  EXCEPTION WHEN OTHERS THEN 
    HADES_ERRO_PACK.TRATA_ERRO('C_Ergon',-1,SQLERRM,V_SPID,L_);
  END;
  --
  PROCEDURE UPDATE_AUX (P_REGISTRO_AUX IN TGRJ_SISOBI_REL%ROWTYPE,
                        P_REGISTRO_OLD_AUX IN TGRJ_SISOBI_REL%ROWTYPE) IS
    V_SPID NUMBER;
    L_     NUMBER;
  BEGIN
    V_SPID := HADES_ERRO_PACK.GET_STOREDPROC_ID('C_ERGON','PCK_TGRJ_SISOBI_REL','UPDATE_AUX');
--
L_ := 50;
--
    P_INDICE := P_INDICE + 1;
--
L_ := 60;
--
    P_TGRJ_SISOBI_REL.EXTEND;
--
L_ := 70;
--
    P_TGRJ_SISOBI_REL_OLD.EXTEND;
--
L_ := 80;
--
    P_TGRJ_SISOBI_REL(P_INDICE) := P_REGISTRO_AUX;
--
L_ := 90;
--
    P_TGRJ_SISOBI_REL_OLD(P_INDICE) := P_REGISTRO_OLD_AUX;
  EXCEPTION WHEN OTHERS THEN 
    HADES_ERRO_PACK.TRATA_ERRO('C_Ergon',-1,SQLERRM,V_SPID,L_);
  END;
  --
  PROCEDURE DELETE_AUX (P_REGISTRO_AUX IN TGRJ_SISOBI_REL%ROWTYPE) IS
    V_SPID NUMBER;
    L_     NUMBER;
  BEGIN
    V_SPID := HADES_ERRO_PACK.GET_STOREDPROC_ID('C_ERGON','PCK_TGRJ_SISOBI_REL','DELETE_AUX');
--
L_ := 100;
--
    P_INDICE := P_INDICE + 1;
--
L_ := 110;
--
    P_TGRJ_SISOBI_REL.EXTEND;
--
L_ := 120;
--
    P_TGRJ_SISOBI_REL_OLD.EXTEND;
--
L_ := 130;
--
    P_TGRJ_SISOBI_REL_OLD(P_INDICE) := P_REGISTRO_AUX;
  EXCEPTION WHEN OTHERS THEN 
    HADES_ERRO_PACK.TRATA_ERRO('C_Ergon',-1,SQLERRM,V_SPID,L_);
  END;
  --
  --!<PCK_TGRJ_SISOBI_REL:MAIN_PRE>--
  PROCEDURE MAIN_PRE (P_TIPO_DML IN VARCHAR2) IS
    --
    v_ep               BOOLEAN;
    v_mens             VARCHAR2(2000);
    --
    V_SPID NUMBER;
    L_     NUMBER;
  BEGIN
    --
    V_SPID := HADES_ERRO_PACK.GET_STOREDPROC_ID('C_ERGON','PCK_TGRJ_SISOBI_REL','MAIN_PRE');
    -- Chamada da PCK_BEFORE_CERGON.EPB__TGRJ_SISOBI_REL
    --
--
L_ := 140;
--
      v_ep := PCK_EXEC_EP_CERG.EXEC_EP_PCK_BEFORE (
                'EPB__TGRJ_SISOBI_REL', 
                (P_TIPO_DML = 'I'),
                (P_TIPO_DML = 'U'),
                (P_TIPO_DML = 'D'),
                 v_mens);
    --
--
L_ := 150;
--
    IF v_mens IS NOT NULL THEN
      --
      HADES_ERRO_PACK.TRATA_ERRO_EP ('C_Ergon', 10000, V_MENS);
      --
    END IF;
    --
--
L_ := 160;

    IF P_TIPO_DML = 'I' AND V_ROW_NEW.CHAVE is null THEN
     SELECT tgrj_sisobi_rel_seq.nextval into V_ROW_NEW.CHAVE from dual;
   END IF;
--
    IF v_ep THEN
      --
      -- O EP retornou valor VERDADEIRO, ou seja, as VALIDAÇÕES do PRODUTO devem ser executadas
      --
--
L_ := 170;
--
      NULL;
      --
    END IF;
    --
  EXCEPTION WHEN OTHERS THEN 
  HADES_ERRO_PACK.TRATA_ERRO('C_Ergon',-1,SQLERRM,V_SPID,L_);
  END MAIN_PRE;
  --!/<PCK_TGRJ_SISOBI_REL:MAIN_PRE>--
  --
  --!<PCK_TGRJ_SISOBI_REL:MAIN_POS>--
  PROCEDURE MAIN_POS (P_TIPO_DML IN VARCHAR2) IS
    --
    v_ep                   BOOLEAN;
    v_mens                 VARCHAR2(2000);
    --
    V_SPID NUMBER;
    L_     NUMBER;
  BEGIN
    --
    V_SPID := HADES_ERRO_PACK.GET_STOREDPROC_ID('C_ERGON','PCK_TGRJ_SISOBI_REL','MAIN_POS');
    -- varre a tabela auxiliar de TGRJ_SISOBI_REL
    --
--
L_ := 180;
--
    FOR i IN 1..P_INDICE LOOP
      --
      -- Chamada da PCK_AFTER_CERGON.EPA__TGRJ_SISOBI_REL
      --
--
L_ := 190;
--
      v_ep := PCK_EXEC_EP_CERG.EXEC_EP_PCK_AFTER (
                'EPA__TGRJ_SISOBI_REL',
                (P_TIPO_DML = 'I'),
                (P_TIPO_DML = 'U'),
                (P_TIPO_DML = 'D'),
                i,
                v_mens);
      --
--
L_ := 200;
--
      IF v_mens IS NOT NULL THEN
        --
        HADES_ERRO_PACK.TRATA_ERRO_EP ('C_Ergon', 10000, V_MENS);
        --
      END IF;
      --
--
L_ := 210;
--
      IF v_ep THEN
        --
        -- O EP retornou valor VERDADEIRO, ou seja,
        -- as VALIDAÇÕES do PRODUTO devem ser executadas
        --
--
L_ := 220;
--
        --IF (P_TIPO_DML IN ('I', 'U')) THEN
--
L_ := 230;
--
        NULL;
        --
        -- usar P_TGRJ_SISOBI_REL(i).campos
        --
        --END IF;-- P_TIPO_DML IN (I,U)
        --
      END IF;
      --
      --
    END LOOP;
  EXCEPTION WHEN OTHERS THEN 
    HADES_ERRO_PACK.TRATA_ERRO('C_Ergon',-1,SQLERRM,V_SPID,L_);
  END MAIN_POS;
  --
  --!/<PCK_TGRJ_SISOBI_REL:MAIN_POS>--
BEGIN
  P_INDICE               := 0;
  P_TGRJ_SISOBI_REL      := TGRJ_SISOBI_REL_REC();
  P_TGRJ_SISOBI_REL_OLD  := TGRJ_SISOBI_REL_REC();
END PCK_TGRJ_SISOBI_REL;
/